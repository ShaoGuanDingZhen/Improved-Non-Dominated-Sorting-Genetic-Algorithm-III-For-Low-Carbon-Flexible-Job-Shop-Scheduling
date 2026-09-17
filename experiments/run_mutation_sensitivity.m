function run_mutation_sensitivity()
%RUN_MUTATION_SENSITIVITY Reviewer-1 parameter robustness experiment.
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_10.txt',...
                 'Type2FJSP_50_10.txt','Type2FJSP_100_10.txt'};
    pmLevels = [0.10 0.30 0.50 0.70 0.80];
    seeds = 1:30;
    cfg = DefaultExperimentConfig();
    rows = [];
    fronts = cell(numel(instances)*numel(pmLevels)*numel(seeds),1);
    rowIndex = 1;
    for i = 1:numel(instances)
        for p = 1:numel(pmLevels)
            for seed = seeds
                cfg.mutationProbability = pmLevels(p);
                r = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg,seed);
                fronts{rowIndex} = r.paretoCosts;
                rows = [rows; i,pmLevels(p),seed,NaN,r.runtimeSeconds,size(r.paretoCosts,1)]; %#ok<AGROW>
                rowIndex = rowIndex + 1;
            end
        end
    end
    [hv,referencePoint] = ComputeBatchHV(fronts);
    rows(:,4) = hv;
    results = array2table(rows,'VariableNames',{'InstanceId','Pm','Seed','HV','RuntimeSeconds','NondominatedCount'});
    out = fullfile(root,'results','mutation_sensitivity.csv');
    writetable(results,out);
    save(fullfile(root,'results','mutation_sensitivity.mat'),'results','fronts','referencePoint','cfg','instances','pmLevels','seeds');
end
