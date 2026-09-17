function run_mutation_sensitivity_parallel(workerCount)
%RUN_MUTATION_SENSITIVITY_PARALLEL Parallel 600-run Reviewer-1 experiment.
%   workerCount is optional. Use 4 workers by default after confirming that
%   Parallel Computing Toolbox is licensed.

    if nargin < 1, workerCount = 4; end
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_10.txt',...
                 'Type2FJSP_50_10.txt','Type2FJSP_100_10.txt'};
    pmLevels = [0.10 0.30 0.50 0.70 0.80];
    seeds = 1:30;
    cfg0 = DefaultExperimentConfig();
    totalRuns = numel(instances)*numel(pmLevels)*numel(seeds);
    runPlan = zeros(totalRuns,3); % instance index, Pm index, seed
    k = 1;
    for i = 1:numel(instances)
        for p = 1:numel(pmLevels)
            for seed = seeds
                runPlan(k,:) = [i,p,seed];
                k = k + 1;
            end
        end
    end
    pool = gcp('nocreate');
    if isempty(pool)
        pool = parpool('local',workerCount);
    end
    fprintf('Starting %d runs on %d workers.\n',totalRuns,pool.NumWorkers);
    fronts = cell(totalRuns,1);
    rows = zeros(totalRuns,6);
    parfor k = 1:totalRuns
        i = runPlan(k,1); p = runPlan(k,2); seed = runPlan(k,3);
        cfg = cfg0;
        cfg.mutationProbability = pmLevels(p);
        r = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg,seed);
        fronts{k} = r.paretoCosts;
        rows(k,:) = [i,pmLevels(p),seed,NaN,r.runtimeSeconds,size(r.paretoCosts,1)];
    end
    [hv,referencePoint] = ComputeBatchHV(fronts);
    rows(:,4) = hv;
    results = array2table(rows,'VariableNames',{'InstanceId','Pm','Seed','HV','RuntimeSeconds','NondominatedCount'});
    writetable(results,fullfile(root,'results','mutation_sensitivity.csv'));
    save(fullfile(root,'results','mutation_sensitivity.mat'),'results','fronts','referencePoint',...
        'cfg0','instances','pmLevels','seeds','runPlan');
    fprintf('Mutation sensitivity experiment completed. Results saved in results/.\n');
end
