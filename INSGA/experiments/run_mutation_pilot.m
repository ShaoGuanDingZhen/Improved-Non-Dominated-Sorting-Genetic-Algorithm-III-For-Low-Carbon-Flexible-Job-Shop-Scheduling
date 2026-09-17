function run_mutation_pilot()
%RUN_MUTATION_PILOT Estimate formal-experiment duration on all four scales.

    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_10.txt',...
                 'Type2FJSP_50_10.txt','Type2FJSP_100_10.txt'};
    cfg = DefaultExperimentConfig();
    cfg.mutationProbability = 0.80;
    rows = zeros(numel(instances),3);
    for i = 1:numel(instances)
        fprintf('Pilot %d/%d: %s\n',i,numel(instances),instances{i});
        r = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg,1);
        rows(i,:) = [i,r.runtimeSeconds,size(r.paretoCosts,1)];
        fprintf('  completed in %.2f s; nondominated=%d.\n', ...
            r.runtimeSeconds,size(r.paretoCosts,1));
    end
    results = array2table(rows,'VariableNames',{'InstanceId','RuntimeSeconds','NondominatedCount'});
    writetable(results,fullfile(root,'results','mutation_pilot.csv'));
    fprintf('Pilot completed. Estimated sequential time for 600 runs: %.2f hours.\n', ...
        150*sum(results.RuntimeSeconds)/3600);
end
