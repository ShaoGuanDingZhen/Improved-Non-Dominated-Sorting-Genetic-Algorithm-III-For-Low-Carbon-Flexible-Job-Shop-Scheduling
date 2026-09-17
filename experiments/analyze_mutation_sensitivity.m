function analyze_mutation_sensitivity()
%ANALYZE_MUTATION_SENSITIVITY Summarize the completed 600-run Pm study.
%   Creates instance-level summary tables, a rank-based global comparison,
%   paired Wilcoxon tests against Pm=0.80, and a publication-ready PNG figure.
%   HV values are compared as ranks within each (instance, seed) block, so
%   different objective scales among instances do not distort the comparison.

    root = fileparts(fileparts(mfilename('fullpath')));
    resultsRoot = fullfile(root,'results');
    sourceFile = fullfile(resultsRoot,'mutation_sensitivity.csv');
    assert(isfile(sourceFile), ...
        'Completed experiment file not found: %s',sourceFile);
    T = readtable(sourceFile);
    required = {'InstanceId','Pm','Seed','HV','RuntimeSeconds','NondominatedCount'};
    assert(all(ismember(required,T.Properties.VariableNames)), ...
        'The source CSV does not have the expected columns.');
    assert(height(T) == 600 && all(isfinite(T.HV)), ...
        'Expected 600 finite HV observations; found %d.',height(T));

    pmLevels = unique(T.Pm,'sorted');
    instanceIds = unique(T.InstanceId,'sorted');
    seeds = unique(T.Seed,'sorted');
    nPm = numel(pmLevels);
    nBlocks = numel(instanceIds)*numel(seeds);
    hvMatrix = nan(nBlocks,nPm);
    blockInstance = zeros(nBlocks,1);
    blockSeed = zeros(nBlocks,1);
    b = 0;
    for ii = 1:numel(instanceIds)
        for ss = 1:numel(seeds)
            b = b + 1;
            blockInstance(b) = instanceIds(ii);
            blockSeed(b) = seeds(ss);
            rows = T(T.InstanceId == instanceIds(ii) & T.Seed == seeds(ss),:);
            assert(height(rows) == nPm, ...
                'Missing Pm condition in instance %d, seed %d.',instanceIds(ii),seeds(ss));
            for pp = 1:nPm
                value = rows.HV(rows.Pm == pmLevels(pp));
                assert(isscalar(value),'Duplicate Pm result in a paired block.');
                hvMatrix(b,pp) = value;
            end
        end
    end

    % Rank one means the highest HV in the same instance/seed block.
    rankMatrix = zeros(nBlocks,nPm);
    normalizedHV = zeros(nBlocks,nPm);
    for b = 1:nBlocks
        rankMatrix(b,:) = tiedrank(-hvMatrix(b,:));
        normalizedHV(b,:) = hvMatrix(b,:) ./ max(hvMatrix(b,:));
    end

    % Instance-level descriptive statistics retain the natural HV units.
    nRows = numel(instanceIds)*nPm;
    InstanceId = zeros(nRows,1); Pm = zeros(nRows,1); N = zeros(nRows,1);
    MeanHV = zeros(nRows,1); StdHV = zeros(nRows,1);
    MeanRuntimeSeconds = zeros(nRows,1); StdRuntimeSeconds = zeros(nRows,1);
    MeanNondominatedCount = zeros(nRows,1);
    q = 0;
    for ii = 1:numel(instanceIds)
        for pp = 1:nPm
            q = q + 1;
            rows = T(T.InstanceId == instanceIds(ii) & T.Pm == pmLevels(pp),:);
            InstanceId(q) = instanceIds(ii); Pm(q) = pmLevels(pp); N(q) = height(rows);
            MeanHV(q) = mean(rows.HV); StdHV(q) = std(rows.HV);
            MeanRuntimeSeconds(q) = mean(rows.RuntimeSeconds);
            StdRuntimeSeconds(q) = std(rows.RuntimeSeconds);
            MeanNondominatedCount(q) = mean(rows.NondominatedCount);
        end
    end
    byInstance = table(InstanceId,Pm,N,MeanHV,StdHV,MeanRuntimeSeconds,...
        StdRuntimeSeconds,MeanNondominatedCount);
    writetable(byInstance,fullfile(resultsRoot,'mutation_sensitivity_by_instance.csv'));

    % Friedman uses 120 matched blocks (4 instances x 30 common seeds).
    [friedmanP,anovaTable,stats] = friedman(rankMatrix,1,'off');
    chiSquare = anovaTable{2,5};
    MeanRank = mean(rankMatrix,1)';
    StdRank = std(rankMatrix,0,1)';
    MeanNormalizedHV = mean(normalizedHV,1)';
    StdNormalizedHV = std(normalizedHV,0,1)';
    Overall = table(pmLevels,MeanRank,StdRank,MeanNormalizedHV,StdNormalizedHV, ...
        'VariableNames',{'Pm','MeanRank','StdRank','MeanNormalizedHV','StdNormalizedHV'});
    Overall = sortrows(Overall,'MeanRank','ascend');
    writetable(Overall,fullfile(resultsRoot,'mutation_sensitivity_overall_rank.csv'));

    % The planned setting is Pm=0.80. Pairwise tests use scale-free paired
    % normalized-HV differences in each of the same 120 blocks.
    baselinePm = 0.80;
    baselineIndex = find(abs(pmLevels-baselinePm) < eps,1);
    assert(~isempty(baselineIndex),'The planned Pm=0.80 condition is absent.');
    ComparisonPm = nan(nPm-1,1); PValue = nan(nPm-1,1);
    MedianDifference = nan(nPm-1,1); BetterBlocks = nan(nPm-1,1);
    q = 0;
    for pp = 1:nPm
        if pp == baselineIndex, continue; end
        q = q + 1;
        difference = normalizedHV(:,baselineIndex) - normalizedHV(:,pp);
        PValue(q) = signrank(difference,0,'method','approximate');
        ComparisonPm(q) = pmLevels(pp);
        MedianDifference(q) = median(difference);
        BetterBlocks(q) = sum(difference > 0);
    end
    pairwise = table(repmat(baselinePm,nPm-1,1),ComparisonPm,PValue,...
        min(PValue*(nPm-1),1),MedianDifference,BetterBlocks,...
        'VariableNames',{'BaselinePm','ComparisonPm','WilcoxonPValue',...
        'BonferroniPValue','MedianNormalizedHVDifference','BaselineBetterBlocks'});
    writetable(pairwise,fullfile(resultsRoot,'mutation_sensitivity_pairwise_tests.csv'));

    % One compact paper figure: mean normalized HV ± one standard error.
    fig = figure('Color','w','Position',[100 100 760 430],'Visible','off');
    meanNorm = mean(normalizedHV,1);
    seNorm = std(normalizedHV,0,1) ./ sqrt(nBlocks);
    errorbar(pmLevels,meanNorm,seNorm,'o-','LineWidth',1.5,...
        'MarkerSize',7,'MarkerFaceColor',[0.10 0.35 0.70],'Color',[0.10 0.35 0.70]);
    grid on; box on;
    xlabel('Mutation probability P_m');
    ylabel('Mean normalized hypervolume');
    title('Mutation probability sensitivity (120 matched instance-seed blocks)');
    xlim([min(pmLevels)-0.05,max(pmLevels)+0.05]);
    xticks(pmLevels);
    exportgraphics(fig,fullfile(resultsRoot,'mutation_sensitivity_normalized_hv.png'),'Resolution',300);
    close(fig);

    save(fullfile(resultsRoot,'mutation_sensitivity_analysis.mat'), ...
        'T','byInstance','Overall','pairwise','pmLevels','instanceIds','seeds',...
        'hvMatrix','rankMatrix','normalizedHV','blockInstance','blockSeed',...
        'friedmanP','chiSquare','anovaTable','stats','baselinePm','-v7');
    fprintf(['Analysis completed. Friedman chi-square=%.4f, p=%.6g. ',...
        'Best (lowest) mean rank: Pm=%.2f (%.4f).\n'], ...
        chiSquare,friedmanP,Overall.Pm(1),Overall.MeanRank(1));
end
