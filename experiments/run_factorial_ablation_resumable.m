function run_factorial_ablation_resumable(workerCount)
%RUN_FACTORIAL_ABLATION_RESUMABLE Checkpointed 2^3 ablation experiment.
%   Six instances x eight configurations x thirty common random seeds = 1440
%   runs. Each finished run is immediately written to a separate MAT file.
%   Rerunning after interruption computes only missing runs.
%   Factors: five-strategy initialization, hybrid crossover, dynamic elitism.

    if nargin < 1, workerCount = 4; end
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    resultsRoot = fullfile(root,'results');
    runRoot = fullfile(resultsRoot,'factorial_ablation_runs');
    if ~isfolder(resultsRoot), mkdir(resultsRoot); end
    if ~isfolder(runRoot), mkdir(runRoot); end

    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_10.txt','Type2FJSP_50_10.txt',...
                 'Type2FJSP_80_10.txt','Type2FJSP_100_7.txt','Type2FJSP_100_10.txt'};
    variants = dec2bin(0:7)-'0'; % initialization, crossover, elite
    seeds = 1:30;
    cfg0 = DefaultExperimentConfig();
    runPlan = buildRunPlan(numel(instances),size(variants,1),seeds);
    totalRuns = size(runPlan,1);

    completed = false(totalRuns,1);
    for k = 1:totalRuns
        completed(k) = isValidRunFile(fullfile(runRoot,sprintf('run_%04d.mat',k)));
    end
    pending = find(~completed);
    fprintf('Checkpoint status: %d/%d completed; %d remaining.\n', ...
        sum(completed),totalRuns,numel(pending));
    if ~isempty(pending)
        pool = gcp('nocreate');
        if isempty(pool), pool = parpool('local',workerCount); end
        fprintf('Running remaining ablation tasks on %d workers.\n',pool.NumWorkers);
        parfor q = 1:numel(pending)
            runOneCheckpoint(pending(q),runPlan,cfg0,variants,instances,...
                dataRoot,runRoot,totalRuns);
        end
    end

    completed = false(totalRuns,1);
    for k = 1:totalRuns
        completed(k) = isValidRunFile(fullfile(runRoot,sprintf('run_%04d.mat',k)));
    end
    if ~all(completed)
        fprintf('Checkpoint saved. %d/%d runs complete; rerun this function to continue.\n', ...
            sum(completed),totalRuns);
        return;
    end

    rows = zeros(totalRuns,9);
    fronts = cell(totalRuns,1);
    for k = 1:totalRuns
        data = load(fullfile(runRoot,sprintf('run_%04d.mat',k)),'row','front');
        rows(k,:) = data.row;
        fronts{k} = data.front;
    end
    [hv,referencePoint] = ComputeBatchHV(fronts);
    rows(:,7) = hv;
    results = array2table(rows,'VariableNames', ...
        {'InstanceId','VariantId','Seed','UseFiveStrategyInitialization',...
         'UseHybridCrossover','UseDynamicElitism','HV','RuntimeSeconds',...
         'NondominatedCount'});
    writetable(results,fullfile(resultsRoot,'factorial_ablation.csv'));
    save(fullfile(resultsRoot,'factorial_ablation.mat'), ...
        'results','fronts','referencePoint','cfg0','instances','variants','seeds','runPlan','-v7');
    fprintf('Factorial ablation completed: %d runs saved and summarized.\n',totalRuns);
end

function runPlan = buildRunPlan(nInstances,nVariants,seeds)
    runPlan = zeros(nInstances*nVariants*numel(seeds),3);
    k = 0;
    for instanceId = 1:nInstances
        for variantId = 1:nVariants
            for seed = seeds
                k = k + 1;
                runPlan(k,:) = [instanceId,variantId,seed];
            end
        end
    end
end

function runOneCheckpoint(k,runPlan,cfg0,variants,instances,dataRoot,runRoot,totalRuns)
    instanceId = runPlan(k,1); variantId = runPlan(k,2); seed = runPlan(k,3);
    cfg = cfg0;
    cfg.useFiveStrategyInitialization = logical(variants(variantId,1));
    cfg.useHybridCrossover = logical(variants(variantId,2));
    cfg.useDynamicElitism = logical(variants(variantId,3));
    output = RunConfigurableINSGAIII( ...
        fullfile(dataRoot,instances{instanceId}),cfg,seed);
    row = [instanceId,variantId,seed,double(cfg.useFiveStrategyInitialization),...
        double(cfg.useHybridCrossover),double(cfg.useDynamicElitism),NaN,...
        output.runtimeSeconds,size(output.paretoCosts,1)];
    front = output.paretoCosts;
    runMeta = struct('runIndex',k,'instanceId',instanceId,'variantId',variantId,...
        'seed',seed,'configuration',cfg,'savedAt',datetime('now'));
    save(fullfile(runRoot,sprintf('run_%04d.mat',k)), ...
        'row','front','runMeta','-v7');
    fprintf('Saved ablation run %d/%d.\n',k,totalRuns);
end

function ok = isValidRunFile(filePath)
    ok = false;
    if ~isfile(filePath), return; end
    try
        data = load(filePath,'row','front');
        ok = isfield(data,'row') && isfield(data,'front') && ...
            isequal(size(data.row),[1,9]) && ~isempty(data.front) && ...
            all(isfinite(data.front),'all');
    catch
        ok = false;
    end
end
