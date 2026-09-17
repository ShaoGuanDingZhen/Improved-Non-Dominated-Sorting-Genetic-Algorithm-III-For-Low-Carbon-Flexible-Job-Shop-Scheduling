function run_factorial_ablation()
%RUN_FACTORIAL_ABLATION Three-factor 2^3 ablation required by Reviewer 1.
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    dataRoot = fullfile(fileparts(root),'T2FJSP');
    instances = {'Type2FJSP_20_6.txt','Type2FJSP_20_10.txt','Type2FJSP_50_10.txt',...
                 'Type2FJSP_80_10.txt','Type2FJSP_100_7.txt','Type2FJSP_100_10.txt'};
    variants = dec2bin(0:7)-'0'; % columns: initialization, crossover, elite
    seeds = 1:30;
    cfg0 = DefaultExperimentConfig();
    rows = [];
    fronts = cell(numel(instances)*size(variants,1)*numel(seeds),1);
    rowIndex = 1;
    for i = 1:numel(instances)
        for v = 1:size(variants,1)
            for seed = seeds
                cfg = cfg0;
                cfg.useFiveStrategyInitialization = logical(variants(v,1));
                cfg.useHybridCrossover = logical(variants(v,2));
                cfg.useDynamicElitism = logical(variants(v,3));
                r = RunConfigurableINSGAIII(fullfile(dataRoot,instances{i}),cfg,seed);
                fronts{rowIndex} = r.paretoCosts;
                rows = [rows; i,v,seed,NaN,r.runtimeSeconds,size(r.paretoCosts,1)]; %#ok<AGROW>
                rowIndex = rowIndex + 1;
            end
        end
    end
    [hv,referencePoint] = ComputeBatchHV(fronts);
    rows(:,4) = hv;
    results = array2table(rows,'VariableNames',{'InstanceId','VariantId','Seed','HV','RuntimeSeconds','NondominatedCount'});
    writetable(results,fullfile(root,'results','factorial_ablation.csv'));
    save(fullfile(root,'results','factorial_ablation.mat'),'results','fronts','referencePoint','cfg0','instances','variants','seeds');
end
