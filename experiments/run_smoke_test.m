function run_smoke_test()
%RUN_SMOKE_TEST Fast diagnostic before any repeated experiment.
%   One small instance, one seed, 20 individuals, and 3 generations.

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataPath = fullfile(fileparts(root),'T2FJSP','Type2FJSP_20_6.txt');
    cfg = DefaultExperimentConfig();
    cfg.populationSize = 20;
    cfg.maxGenerations = 3;
    cfg.plotProgress = false;
    fprintf('Starting smoke test: T2J20M6, population=%d, generations=%d.\n', ...
        cfg.populationSize,cfg.maxGenerations);
    r = RunConfigurableINSGAIII(dataPath,cfg,1);
    fprintf('Smoke test completed. HV=%.8f, runtime=%.2f seconds, nondominated=%d.\n', ...
        r.HV,r.runtimeSeconds,size(r.paretoCosts,1));
    rootResults = fullfile(root,'results');
    if ~isfolder(rootResults), mkdir(rootResults); end
    save(fullfile(rootResults,'smoke_test.mat'),'r','cfg');
end
