function cfg = DefaultExperimentConfig()
%DEFAULTEXPERIMENTCONFIG Reproducible settings for revised experiments.

    cfg.populationSize = 100;
    cfg.maxGenerations = 200;
    cfg.crossoverProbability = 0.80;
    cfg.mutationProbability = 0.80; % offspring-level composite mutation
    cfg.referenceDivisions = 100;
    cfg.baseEliteProportion = 0.06;
    cfg.eliteScaleFactor = 0.02;
    cfg.minEliteProportion = 0.02;
    cfg.maxEliteProportion = 0.12;
    cfg.useFiveStrategyInitialization = true;
    cfg.useHybridCrossover = true;
    % Final INSGA-III (configuration 110): the factorial ablation retained
    % five-strategy initialization and hybrid crossover, but not the
    % dynamic-elitism candidate.
    cfg.useDynamicElitism = false;
    cfg.plotProgress = false;
    cfg.saveParetoFront = true;
end
