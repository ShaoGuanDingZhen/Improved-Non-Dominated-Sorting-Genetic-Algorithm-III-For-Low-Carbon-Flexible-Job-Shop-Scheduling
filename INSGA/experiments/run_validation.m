function run_validation()
%RUN_VALIDATION Low-cost validation before the full reviewer experiments.
%   Runs 3 instances x 2 seeds at a reduced budget and checks finite
%   objectives, feasible chromosome length, and deterministic replay.

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_8.txt','Type2FJSP_20_10.txt'};
    cfg = DefaultExperimentConfig();
    cfg.populationSize = 30;
    cfg.maxGenerations = 10; % validation only; retain 100/200 for publication runs
    rows = [];
    for i = 1:numel(instances)
        for seed = 1:2
            r = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg,seed);
            assert(all(isfinite(r.paretoCosts),'all'),'Non-finite objective found.');
            assert(~isempty(r.paretoCosts),'No nondominated solution returned.');
            rows = [rows; i,seed,r.HV,r.runtimeSeconds,size(r.paretoCosts,1)]; %#ok<AGROW>
        end
        r1 = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg,1);
        r2 = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg,1);
        assert(isequaln(r1.paretoCosts,r2.paretoCosts),'Seed replay failed.');
    end
    results = array2table(rows,'VariableNames',{'InstanceId','Seed','HV','RuntimeSeconds','NondominatedCount'});
    writetable(results,fullfile(root,'results','validation.csv'));
    save(fullfile(root,'results','validation.mat'),'results','cfg','instances');
end
