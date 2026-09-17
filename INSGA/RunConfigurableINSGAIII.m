function result = RunConfigurableINSGAIII(instancePath,cfg,seed)
%RUNCONFIGURABLEINSGAIII Reproducible implementation with ablation switches.

    if nargin < 3, seed = 1; end
    rng(seed,'twister');
    global N H SH NM M TM time ps
    [N,TM,H,NM,M,SH,time] = DataRead(instancePath);
    ps = cfg.populationSize;
    nObj = 2;
    params.nPop = cfg.populationSize;
    params.Zr = GenerateReferencePoints(nObj,cfg.referenceDivisions);
    params.nZr = size(params.Zr,2);
    params.zmin = []; params.zmax = []; params.smin = [];
    empty = EmptyIndividual();

    if cfg.useFiveStrategyInitialization
        [pc,mc] = initialmix5();
        pc = pc(1:cfg.populationSize,:); mc = mc(1:cfg.populationSize,:);
    else
        [pc,mc] = InitializeRandomFeasible(cfg.populationSize);
    end
    pop = repmat(empty,cfg.populationSize,1);
    for p = 1:cfg.populationSize
        pop(p).Position = [pc(p,:),mc(p,:)];
        pop(p).Cost = finalvalue1(pop(p).Position);
    end
    [pop,~,params] = SortAndSelectPopulation(pop,params);
    archive = pop([]);
    generationHV = nan(cfg.maxGenerations,1);
    tic;
    for generation = 1:cfg.maxGenerations
        offspring = CreateOffspring(pop,empty,cfg);
        merged = [pop;offspring;archive]; %#ok<AGROW>
        if cfg.useDynamicElitism
            [eliteCount,~] = CalculateDynamicEliteCount(merged,cfg);
            archive = SelectEliteArchive(merged,eliteCount);
        else
            archive = pop([]);
        end
        [pop,fronts,params] = SortAndSelectPopulation(merged,params);
        if ~isempty(fronts) && ~isempty(fronts{1})
            frontCosts = vertcat(pop(fronts{1}).Cost);
            generationHV(generation) = ComputeHV(frontCosts);
        end
        if cfg.plotProgress
            PlotCosts(pop(fronts{1})); drawnow;
        end
    end
    runtime = toc;
    [pop,fronts] = NonDominatedSorting(pop);
    pareto = pop(fronts{1});
    costs = vertcat(pareto.Cost);
    result = struct('seed',seed,'paretoCosts',costs,'paretoPopulation',pareto,...
                    'HV',ComputeHV(costs),'runtimeSeconds',runtime,...
                    'generationHV',generationHV,'config',cfg);
end

function empty = EmptyIndividual()
    empty = struct('Position',[],'Cost',[],'Rank',[],'DominationSet',[],...
        'DominatedCount',[],'NormalizedCost',[],'AssociatedRef',[],...
        'DistanceToAssociatedRef',[]);
end

function offspring = CreateOffspring(pop,empty,cfg)
    n = numel(pop);
    nCross = 2*floor(cfg.crossoverProbability*cfg.populationSize/2);
    nMut = round(cfg.mutationProbability*cfg.populationSize);
    offspring = repmat(empty,nCross+nMut,1);
    index = 1;
    for k = 1:2:nCross
        parent1 = pop(randi(n)); parent2 = pop(randi(n));
        if cfg.useHybridCrossover
            [x1,x2] = Crossover(parent1.Position,parent2.Position);
        else
            [x1,x2] = CrossoverBaseline(parent1.Position,parent2.Position);
        end
        offspring(index).Position = x1; offspring(index).Cost = finalvalue1(x1);
        offspring(index+1).Position = x2; offspring(index+1).Cost = finalvalue1(x2);
        index = index + 2;
    end
    for k = 1:nMut
        x = Mutate(pop(randi(n)).Position);
        offspring(index).Position = x; offspring(index).Cost = finalvalue1(x);
        index = index + 1;
    end
end

function score = ComputeHV(costs)
    if isempty(costs), score = 0; return; end
    fmin = min(costs,[],1);
    fmax = max(costs,[],1);
    reference = fmax + 0.1*(fmax-fmin+eps);
    normalized = (costs-fmin)./(reference-fmin);
    normalized = normalized(all(isfinite(normalized),2),:);
    score = HV(normalized,ones(1,size(normalized,2)));
end
