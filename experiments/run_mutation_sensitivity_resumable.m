function run_mutation_sensitivity_resumable(workerCount)
%RUN_MUTATION_SENSITIVITY_RESUMABLE Checkpointed 600-run sensitivity study.
%   Every completed run is saved immediately as a separate MAT file. If the
%   function is interrupted, call it again with the same worker count and it
%   will run only the missing configurations, then create the final CSV/MAT.

    if nargin < 1, workerCount = 4; end
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    resultsRoot = fullfile(root,'results');
    runRoot = fullfile(resultsRoot,'mutation_sensitivity_runs');
    if ~isfolder(resultsRoot), mkdir(resultsRoot); end
    if ~isfolder(runRoot), mkdir(runRoot); end

    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_10.txt',...
                 'Type2FJSP_50_10.txt','Type2FJSP_100_10.txt'};
    pmLevels = [0.10 0.30 0.50 0.70 0.80];
    seeds = 1:30;
    cfg0 = DefaultExperimentConfig();
    runPlan = buildRunPlan(instances,pmLevels,seeds);
    totalRuns = size(runPlan,1);

    completed = false(totalRuns,1);
    for k = 1:totalRuns
        completed(k) = isValidRunFile(fullfile(runRoot,sprintf('run_%03d.mat',k)));
    end
    pending = find(~completed);
    fprintf('Checkpoint status: %d/%d completed; %d remaining.\n', ...
        sum(completed),totalRuns,numel(pending));
    if ~isempty(pending)
        pool = gcp('nocreate');
        if isempty(pool), pool = parpool('local',workerCount); end
        fprintf('Running remaining tasks on %d workers.\n',pool.NumWorkers);
        % Keep the PARFOR body to a single function call. This avoids the
        % transparency restriction that R2024b applies to SAVE in a PARFOR body.
        parfor q = 1:numel(pending)
            runOneCheckpoint(pending(q),runPlan,cfg0,pmLevels,instances,...
                dataRoot,runRoot,totalRuns);
        end
    end

    completed = false(totalRuns,1);
    for k = 1:totalRuns
        completed(k) = isValidRunFile(fullfile(runRoot,sprintf('run_%03d.mat',k)));
    end
    if ~all(completed)
        fprintf('Checkpoint saved. %d/%d runs complete; rerun this function to continue.\n', ...
            sum(completed),totalRuns);
        return;
    end

    rows = zeros(totalRuns,6);
    fronts = cell(totalRuns,1);
    for k = 1:totalRuns
        data = load(fullfile(runRoot,sprintf('run_%03d.mat',k)),'row','front');
        rows(k,:) = data.row;
        fronts{k} = data.front;
    end
    [hv,referencePoint] = ComputeBatchHV(fronts);
    rows(:,4) = hv;
    results = array2table(rows,'VariableNames', ...
        {'InstanceId','Pm','Seed','HV','RuntimeSeconds','NondominatedCount'});
    writetable(results,fullfile(resultsRoot,'mutation_sensitivity.csv'));
    save(fullfile(resultsRoot,'mutation_sensitivity.mat'), ...
        'results','fronts','referencePoint','cfg0','instances','pmLevels','seeds','runPlan','-v7');
    fprintf('Mutation sensitivity experiment completed: %d runs saved and summarized.\n',totalRuns);
end

function runPlan = buildRunPlan(instances,pmLevels,seeds)
    runPlan = zeros(numel(instances)*numel(pmLevels)*numel(seeds),3);
    k = 1;
    for i = 1:numel(instances)
        for p = 1:numel(pmLevels)
            for seed = seeds
                runPlan(k,:) = [i,p,seed];
                k = k + 1;
            end
        end
    end
end

function ok = isValidRunFile(filePath)
    ok = false;
    if ~isfile(filePath), return; end
    try
        data = load(filePath,'row','front');
        ok = isfield(data,'row') && isfield(data,'front') && ...
             isequal(size(data.row),[1,6]) && ~isempty(data.front) && ...
             all(isfinite(data.front),'all');
    catch
        ok = false;
    end
end

function runOneCheckpoint(k,runPlan,cfg0,pmLevels,instances,dataRoot,runRoot,totalRuns)
%RUNONECHECKPOINT Execute and persist one independent experimental run.
%   This local function is deliberately called from PARFOR rather than placing
%   SAVE directly in the loop body, which is required for R2024b transparency.
    instanceId = runPlan(k,1);
    pmIndex = runPlan(k,2);
    seed = runPlan(k,3);
    cfg = cfg0;
    cfg.mutationProbability = pmLevels(pmIndex);
    output = RunConfigurableINSGAIII( ...
        fullfile(dataRoot,instances{instanceId}),cfg,seed);
    row = [instanceId,pmLevels(pmIndex),seed,NaN,...
        output.runtimeSeconds,size(output.paretoCosts,1)];
    front = output.paretoCosts;
    runMeta = struct('runIndex',k,'instanceId',instanceId,...
        'pm',pmLevels(pmIndex),'seed',seed,'savedAt',datetime('now'));
    checkpointFile = fullfile(runRoot,sprintf('run_%03d.mat',k));
    save(checkpointFile,'row','front','runMeta','-v7');
    fprintf('Saved run %d/%d.\n',k,totalRuns);
end
