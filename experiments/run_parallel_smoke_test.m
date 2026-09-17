function run_parallel_smoke_test()
%RUN_PARALLEL_SMOKE_TEST Confirm four MATLAB workers can run the algorithm.

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_8.txt',...
                 'Type2FJSP_20_9.txt','Type2FJSP_20_10.txt'};
    cfg0 = DefaultExperimentConfig();
    cfg0.populationSize = 20;
    cfg0.maxGenerations = 3;
    pool = gcp('nocreate');
    if isempty(pool), pool = parpool('local',4); end
    fprintf('Parallel smoke test: %d workers, %d short runs.\n', ...
        pool.NumWorkers,numel(instances));
    runtime = zeros(numel(instances),1);
    nFront = zeros(numel(instances),1);
    parfor i = 1:numel(instances)
        r = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg0,i);
        runtime(i) = r.runtimeSeconds;
        nFront(i) = size(r.paretoCosts,1);
    end
    assert(all(runtime > 0),'At least one parallel run did not complete.');
    assert(all(nFront > 0),'At least one parallel run returned no Pareto solution.');
    results = table((1:numel(instances))',runtime,nFront, ...
        'VariableNames',{'InstanceId','RuntimeSeconds','NondominatedCount'});
    writetable(results,fullfile(root,'results','parallel_smoke_test.csv'));
    disp(results);
    fprintf('Parallel smoke test passed.\n');
end
