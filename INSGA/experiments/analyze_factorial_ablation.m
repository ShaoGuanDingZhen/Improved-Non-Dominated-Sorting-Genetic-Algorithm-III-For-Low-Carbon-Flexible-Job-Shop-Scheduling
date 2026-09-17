function analyze_factorial_ablation()
%ANALYZE_FACTORIAL_ABLATION Analyze the completed 2^3 factorial ablation.
%   Uses matched (instance, seed) blocks. HV is normalized within each block
%   before factorial effects are estimated, preventing large instances from
%   dominating the analysis simply because their HV has a larger magnitude.

    root = fileparts(fileparts(mfilename('fullpath')));
    resultsRoot = fullfile(root,'results');
    sourceFile = fullfile(resultsRoot,'factorial_ablation.csv');
    assert(isfile(sourceFile),'Completed ablation CSV not found: %s',sourceFile);
    T = readtable(sourceFile);
    required = {'InstanceId','VariantId','Seed','UseFiveStrategyInitialization',...
        'UseHybridCrossover','UseDynamicElitism','HV','RuntimeSeconds','NondominatedCount'};
    assert(all(ismember(required,T.Properties.VariableNames)),...
        'The source CSV does not have the expected columns.');
    assert(height(T) == 1440 && all(isfinite(T.HV)),...
        'Expected 1,440 finite HV observations; found %d.',height(T));

    instanceIds = unique(T.InstanceId,'sorted');
    seeds = unique(T.Seed,'sorted');
    variantIds = unique(T.VariantId,'sorted');
    nBlocks = numel(instanceIds)*numel(seeds);
    nVariants = numel(variantIds);
    assert(nVariants == 8,'Expected eight ablation variants.');
    factorMap = zeros(nVariants,3);
    for v = 1:nVariants
        row = T(T.VariantId == variantIds(v),:);
        factorMap(v,:) = [row.UseFiveStrategyInitialization(1),...
            row.UseHybridCrossover(1),row.UseDynamicElitism(1)];
    end

    hvMatrix = nan(nBlocks,nVariants);
    b = 0;
    for ii = 1:numel(instanceIds)
        for ss = 1:numel(seeds)
            b = b + 1;
            rows = T(T.InstanceId == instanceIds(ii) & T.Seed == seeds(ss),:);
            assert(height(rows) == nVariants,...
                'Missing variant in instance %d, seed %d.',instanceIds(ii),seeds(ss));
            for v = 1:nVariants
                value = rows.HV(rows.VariantId == variantIds(v));
                assert(isscalar(value),'Duplicate variant in a paired block.');
                hvMatrix(b,v) = value;
            end
        end
    end
    rankMatrix = zeros(nBlocks,nVariants);
    normalizedHV = zeros(nBlocks,nVariants);
    for b = 1:nBlocks
        rankMatrix(b,:) = tiedrank(-hvMatrix(b,:)); % rank one is best
        normalizedHV(b,:) = hvMatrix(b,:) ./ max(hvMatrix(b,:));
    end

    % Variant-level summary (natural units) and global rank comparison.
    [friedmanP,anovaTable,stats] = friedman(rankMatrix,1,'off');
    chiSquare = anovaTable{2,5};
    VariantId = variantIds;
    UseFiveStrategyInitialization = logical(factorMap(:,1));
    UseHybridCrossover = logical(factorMap(:,2));
    UseDynamicElitism = logical(factorMap(:,3));
    MeanRank = mean(rankMatrix,1)';
    MeanNormalizedHV = mean(normalizedHV,1)';
    MeanHV = zeros(nVariants,1); StdHV = zeros(nVariants,1);
    MeanRuntimeSeconds = zeros(nVariants,1); MeanNondominatedCount = zeros(nVariants,1);
    for v = 1:nVariants
        rows = T(T.VariantId == variantIds(v),:);
        MeanHV(v) = mean(rows.HV); StdHV(v) = std(rows.HV);
        MeanRuntimeSeconds(v) = mean(rows.RuntimeSeconds);
        MeanNondominatedCount(v) = mean(rows.NondominatedCount);
    end
    variantSummary = table(VariantId,UseFiveStrategyInitialization,...
        UseHybridCrossover,UseDynamicElitism,MeanRank,MeanNormalizedHV,...
        MeanHV,StdHV,MeanRuntimeSeconds,MeanNondominatedCount);
    variantSummary = sortrows(variantSummary,'MeanRank','ascend');
    writetable(variantSummary,fullfile(resultsRoot,'factorial_ablation_variant_summary.csv'));

    % Full INSGA (111) versus baseline NSGA-III implementation (000).
    baselineIndex = find(all(factorMap == [0 0 0],2),1);
    fullIndex = find(all(factorMap == [1 1 1],2),1);
    diffFullVsBase = normalizedHV(:,fullIndex) - normalizedHV(:,baselineIndex);
    fullVsBaseline = table(variantIds(baselineIndex),variantIds(fullIndex),...
        mean(diffFullVsBase),median(diffFullVsBase),sum(diffFullVsBase > 0),...
        signrank(diffFullVsBase,0,'method','approximate'),...
        'VariableNames',{'BaselineVariantId','FullVariantId',...
        'MeanNormalizedHVDifference','MedianNormalizedHVDifference',...
        'FullBetterBlocks','WilcoxonPValue'});
    writetable(fullVsBaseline,fullfile(resultsRoot,'factorial_ablation_full_vs_baseline.csv'));

    % Targeted contrast: 110 versus 111 isolates the effect of adding
    % dynamic elitism when initialization and crossover are both retained.
    labels = compose('%d%d%d',factorMap(:,1),factorMap(:,2),factorMap(:,3));
    selectedIndex = find(labels == "110",1);
    dynamicElitismIndex = find(labels == "111",1);
    assert(~isempty(selectedIndex) && ~isempty(dynamicElitismIndex),...
        'Expected configurations 110 and 111 were not found.');
    pairedDifference = normalizedHV(:,selectedIndex) - normalizedHV(:,dynamicElitismIndex);
    [rawPValue,~,contrastStats] = signrank(pairedDifference,0,'method','approximate');

    % Holm adjustment across the seven contrasts of 110 against every other
    % factorial configuration. This keeps the targeted result reproducible
    % without treating it as an unadjusted post-hoc comparison.
    alternativeIndices = setdiff(1:nVariants,selectedIndex);
    allContrastP = zeros(numel(alternativeIndices),1);
    for a = 1:numel(alternativeIndices)
        difference = normalizedHV(:,selectedIndex) - normalizedHV(:,alternativeIndices(a));
        allContrastP(a) = signrank(difference,0,'method','approximate');
    end
    [sortedP,sortOrder] = sort(allContrastP,'ascend');
    adjustedSortedP = cummax((numel(sortedP):-1:1)' .* sortedP);
    adjustedP = zeros(size(allContrastP));
    adjustedP(sortOrder) = min(adjustedSortedP,1);
    dynamicAlternativePosition = find(alternativeIndices == dynamicElitismIndex,1);
    holmAdjustedPValue = adjustedP(dynamicAlternativePosition);

    contrast110vs111 = table("110","111",nBlocks,mean(pairedDifference),...
        median(pairedDifference),sum(pairedDifference > 0),...
        contrastStats.signedrank,rawPValue,holmAdjustedPValue,...
        'VariableNames',{'ReferenceConfiguration','ComparisonConfiguration','N',...
        'MeanNormalizedHVDifference','MedianNormalizedHVDifference',...
        'ReferenceBetterBlocks','PositiveRankSum_Wplus','RawPValue',...
        'HolmAdjustedPValue'});
    writetable(contrast110vs111,...
        fullfile(resultsRoot,'factorial_ablation_110_vs_111.csv'));

    % Effect-coded 2^3 model in every matched block. A positive coefficient
    % means the factor increases normalized HV on average across other factors.
    signs = 2*factorMap - 1;
    X = [ones(nVariants,1),signs,signs(:,1).*signs(:,2),...
        signs(:,1).*signs(:,3),signs(:,2).*signs(:,3),prod(signs,2)];
    coefficients = zeros(nBlocks,size(X,2));
    for b = 1:nBlocks
        coefficients(b,:) = (X \ normalizedHV(b,:)')';
    end
    Effect = {'Initialization';'HybridCrossover';'DynamicElitism';...
        'Initialization_x_Crossover';'Initialization_x_Elitism';...
        'Crossover_x_Elitism';'Initialization_x_Crossover_x_Elitism'};
    MeanCoefficient = mean(coefficients(:,2:end),1)';
    MeanFactorEffect = 2*MeanCoefficient;
    MedianCoefficient = median(coefficients(:,2:end),1)';
    PValue = zeros(numel(Effect),1);
    for e = 1:numel(Effect)
        PValue(e) = signrank(coefficients(:,e+1),0,'method','approximate');
    end
    effectSummary = table(Effect,MeanCoefficient,MeanFactorEffect,...
        MedianCoefficient,PValue,min(PValue*numel(Effect),1),...
        'VariableNames',{'Effect','MeanCoefficient','MeanFactorEffect',...
        'MedianCoefficient','WilcoxonPValue','BonferroniPValue'});
    writetable(effectSummary,fullfile(resultsRoot,'factorial_ablation_effects.csv'));

    [rankOrder,order] = sort(mean(rankMatrix,1),'ascend');
    fig = figure('Color','w','Position',[100 100 820 440],'Visible','off');
    bar(1:nVariants,rankOrder,'FaceColor',[0.10 0.35 0.70]);
    grid on; box on; xlim([0.4,nVariants+0.6]);
    xticks(1:nVariants); xticklabels(labels(order));
    xlabel('Configuration [Initialization, Crossover, Elitism]');
    ylabel('Mean rank (lower is better)');
    title('Ablation study across 180 matched instance-seed blocks');
    exportgraphics(fig,fullfile(resultsRoot,'factorial_ablation_mean_rank.png'),'Resolution',300);
    close(fig);

    save(fullfile(resultsRoot,'factorial_ablation_analysis.mat'),...
        'T','factorMap','hvMatrix','rankMatrix','normalizedHV','variantSummary',...
        'fullVsBaseline','effectSummary','friedmanP','chiSquare','anovaTable','stats','-v7');
    bestLabel = labels{order(1)};
    fprintf(['Ablation analysis completed. Friedman chi-square=%.4f, p=%.6g. ',...
        'Best configuration=%s, mean rank=%.4f.\n'],...
        chiSquare,friedmanP,bestLabel,rankOrder(1));
end
