function export_revised_figures()
%EXPORT_REVISED_FIGURES Create Figures 5 and 7 for the final 110 manuscript.
%   Figure 5 documents the final INSGA-III workflow (initialization + hybrid
%   crossover; no dynamic elitism). Figure 7 summarizes all 1,440 completed
%   factorial-ablation runs, rather than selecting a single representative
%   Pareto front.

    root = fileparts(fileparts(mfilename('fullpath')));
    resultsRoot = fullfile(root,'results');

    % Figure 5: compact final-algorithm workflow.
    fig = figure('Visible','off','Color','w','Position',[100 100 1100 390]);
    ax = axes(fig,'Position',[0 0 1 1]); axis(ax,[0 1 0 1]); axis(ax,'off');
    boxes = [0.02 0.56 0.14 0.18; 0.19 0.56 0.15 0.18; 0.37 0.56 0.15 0.18; ...
             0.55 0.56 0.16 0.18; 0.74 0.56 0.17 0.18];
    labels = {'Read T2FJSP instance\nand set parameters', ...
              'Five-strategy\ninitialization', ...
              'Evaluate objectives and\ninitialize population', ...
              'Generate and evaluate offspring:\nhybrid crossover + composite mutation', ...
              'Merge parent and offspring;\nNSGA-III reference-point selection'};
    % Neutral blue-grey palette shared with the statistical figures.
    colors = {[0.96 0.98 1.00],[0.90 0.95 0.99],[0.96 0.98 1.00],...
              [0.90 0.95 0.99],[0.96 0.98 1.00]};
    for k = 1:numel(labels)
        labelText = strrep(labels{k},'\n',newline);
        annotation(fig,'textbox',boxes(k,:),'String',labelText, ...
            'HorizontalAlignment','center','VerticalAlignment','middle', ...
            'FontName','Arial','FontSize',10,'LineWidth',0.9, ...
            'BackgroundColor',colors{k},'EdgeColor',[0.12 0.28 0.48], ...
            'Interpreter','none');
    end
    for k = 1:4
        x1 = boxes(k,1)+boxes(k,3); x2 = boxes(k+1,1);
        annotation(fig,'arrow',[x1+0.01 x2-0.01],[0.65 0.65], ...
            'LineWidth',1.1,'Color',[0.12 0.28 0.48]);
    end
    % Explicit termination decision and labelled Yes/No paths.
    annotation(fig,'textbox',[0.76 0.25 0.14 0.12], ...
        'String',sprintf('Maximum generations\nreached?'), ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontName','Arial','FontSize',10,'LineWidth',0.9, ...
        'BackgroundColor',[0.97 0.98 0.99],'EdgeColor',[0.12 0.28 0.48], ...
        'Interpreter','none');
    annotation(fig,'arrow',[0.825 0.825],[0.55 0.37], ...
        'LineWidth',1.1,'Color',[0.12 0.28 0.48]);
    annotation(fig,'arrow',[0.76 0.63],[0.31 0.31], ...
        'LineWidth',1.1,'Color',[0.12 0.28 0.48]);
    annotation(fig,'arrow',[0.63 0.63],[0.31 0.55], ...
        'LineWidth',1.1,'Color',[0.12 0.28 0.48]);
    annotation(fig,'textbox',[0.64 0.31 0.05 0.04],'String','No', ...
        'HorizontalAlignment','center','FontName','Arial', ...
        'FontSize',10,'EdgeColor','none');
    annotation(fig,'arrow',[0.83 0.83],[0.24 0.12], ...
        'LineWidth',1.1,'Color',[0.12 0.28 0.48]);
    annotation(fig,'textbox',[0.84 0.18 0.05 0.04],'String','Yes', ...
        'HorizontalAlignment','center','FontName','Arial', ...
        'FontSize',10,'EdgeColor','none');
    annotation(fig,'textbox',[0.72 0.02 0.22 0.08], ...
        'String','Output nondominated Pareto set', ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontName','Arial','FontSize',10,'EdgeColor','none');
    exportgraphics(fig,fullfile(resultsRoot,'revised_figure5_workflow.png'),'Resolution',600);
    close(fig);

    % Figure 6: composite-mutation sensitivity.  The plot uses all 600
    % completed runs (four instances, 30 common seeds, five Pm settings).
    runs = readtable(fullfile(resultsRoot,'mutation_sensitivity.csv'));
    rankSummary = readtable(fullfile(resultsRoot,'mutation_sensitivity_overall_rank.csv'));
    [pmValues,order] = sort(rankSummary.Pm,'ascend');
    meanRank = rankSummary.MeanRank(order);
    finalPosition = find(abs(pmValues-0.80) < eps,1);
    blockKeys = unique([runs.InstanceId,runs.Seed],'rows','stable');
    normalizedHV = nan(height(runs),1);
    for b = 1:size(blockKeys,1)
        isBlock = runs.InstanceId == blockKeys(b,1) & runs.Seed == blockKeys(b,2);
        normalizedHV(isBlock) = runs.HV(isBlock) ./ max(runs.HV(isBlock));
    end
    displayLabels = compose('%.2f',pmValues);
    displayLabels = cellstr(displayLabels);
    displayLabels{finalPosition} = '0.80*';
    colors = repmat([0.72 0.72 0.72],numel(pmValues),1);
    colors(finalPosition,:) = [0.12 0.35 0.68];

    fig = figure('Visible','off','Color','w','Position',[100 100 1200 450]);
    tl = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');
    ax1 = nexttile(tl); applyPaperAxisStyle(ax1); hold(ax1,'on'); grid(ax1,'on'); box(ax1,'on');
    bars = bar(ax1,1:numel(pmValues),meanRank,'FaceColor','flat', ...
        'EdgeColor',[0.15 0.15 0.15],'LineWidth',0.6);
    bars.CData = colors;
    xticks(ax1,1:numel(pmValues)); xticklabels(ax1,displayLabels);
    xlabel(ax1,'Composite-mutation probability P_m', ...
        'FontName','Arial','FontSize',10);
    ylabel(ax1,'Mean rank (lower is better)', ...
        'FontName','Arial','FontSize',10);
    ylim(ax1,[0 max(meanRank)+0.7]);
    text(ax1,0.02,0.96,'(a)','Units','normalized', ...
        'FontName','Arial','FontSize',10,'FontWeight','bold', ...
        'VerticalAlignment','top');

    ax2 = nexttile(tl); applyPaperAxisStyle(ax2); hold(ax2,'on'); grid(ax2,'on'); box(ax2,'on');
    x = []; y = [];
    for k = 1:numel(pmValues)
        values = normalizedHV(abs(runs.Pm-pmValues(k)) < eps);
        x = [x; repmat(k,numel(values),1)]; %#ok<AGROW>
        y = [y; values]; %#ok<AGROW>
    end
    boxchart(ax2,x,y,'MarkerStyle','none','BoxFaceColor',[0.83 0.83 0.83]);
    finalValues = normalizedHV(abs(runs.Pm-0.80) < eps);
    boxchart(ax2,repmat(finalPosition,numel(finalValues),1),finalValues, ...
        'MarkerStyle','none','BoxFaceColor',[0.12 0.35 0.68]);
    xticks(ax2,1:numel(pmValues)); xticklabels(ax2,displayLabels);
    xlabel(ax2,'Composite-mutation probability P_m', ...
        'FontName','Arial','FontSize',10);
    ylabel(ax2,'Normalized hypervolume (HV / block maximum)', ...
        'FontName','Arial','FontSize',10);
    ylim(ax2,[min(normalizedHV)-0.02 1.01]);
    text(ax2,0.02,0.96,'(b)','Units','normalized', ...
        'FontName','Arial','FontSize',10,'FontWeight','bold', ...
        'VerticalAlignment','top');
    exportgraphics(fig,fullfile(resultsRoot,'revised_figure6_mutation_sensitivity.png'),'Resolution',600);
    close(fig);

    % Figure 7: full factorial evidence from all 180 matched instance-seed
    % blocks. This avoids using a single selected run as the visual evidence.
    data = load(fullfile(resultsRoot,'factorial_ablation_analysis.mat'), ...
        'factorMap','rankMatrix','normalizedHV');
    labels = compose('%d%d%d',data.factorMap(:,1),data.factorMap(:,2),data.factorMap(:,3));
    meanRank = mean(data.rankMatrix,1);
    [rankOrder,order] = sort(meanRank,'ascend');
    orderedLabels = labels(order);
    orderedHV = data.normalizedHV(:,order);
    finalPosition = find(orderedLabels == "110",1);
    colors = repmat([0.72 0.72 0.72],numel(order),1);
    colors(finalPosition,:) = [0.12 0.35 0.68];

    fig = figure('Visible','off','Color','w','Position',[100 100 900 390]);
    tl = tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');

    ax1 = nexttile(tl); applyPaperAxisStyle(ax1); hold(ax1,'on'); grid(ax1,'on'); box(ax1,'on');
    b = bar(ax1,1:numel(order),rankOrder,'FaceColor','flat','EdgeColor',[0.18 0.18 0.18],'LineWidth',0.6);
    b.CData = colors;
    displayLabels = cellstr(orderedLabels);
    displayLabels{finalPosition} = '110*';
    xticks(ax1,1:numel(order)); xticklabels(ax1,displayLabels);
    xlabel(ax1,'Configuration [Initialization, Crossover, Elitism]', ...
        'FontName','Arial','FontSize',10);
    ylabel(ax1,'Mean rank (lower is better)', ...
        'FontName','Arial','FontSize',10);
    text(ax1,0.02,0.96,'(a)','Units','normalized', ...
        'FontName','Arial','FontSize',10,'FontWeight','bold', ...
        'VerticalAlignment','top');
    ylim(ax1,[0 max(rankOrder)+0.6]);

    ax2 = nexttile(tl); applyPaperAxisStyle(ax2); hold(ax2,'on'); grid(ax2,'on'); box(ax2,'on');
    x = repelem(1:numel(order),size(orderedHV,1))';
    y = orderedHV(:);
    boxchart(ax2,x,y,'MarkerStyle','none','BoxFaceColor',[0.83 0.83 0.83]);
    % Overlay the final configuration in blue to make the selected final
    % design identifiable without suppressing the other factorial results.
    boxchart(ax2,repmat(finalPosition,size(orderedHV,1),1), ...
        orderedHV(:,finalPosition),'MarkerStyle','none', ...
        'BoxFaceColor',[0.12 0.35 0.68]);
    xticks(ax2,1:numel(order)); xticklabels(ax2,displayLabels);
    xlabel(ax2,'Configuration [Initialization, Crossover, Elitism]', ...
        'FontName','Arial','FontSize',10);
    ylabel(ax2,'Normalized hypervolume (HV / block maximum)', ...
        'FontName','Arial','FontSize',10);
    text(ax2,0.02,0.96,'(b)','Units','normalized', ...
        'FontName','Arial','FontSize',10,'FontWeight','bold', ...
        'VerticalAlignment','top');
    ylim(ax2,[min(orderedHV(:))-0.02 1.01]);
    exportgraphics(fig,fullfile(resultsRoot,'revised_figure7_factorial_evidence.png'),'Resolution',600);
    close(fig);
    fprintf('Revised figures saved in %s\n',resultsRoot);
end

function applyPaperAxisStyle(ax)
    set(ax,'FontName','Arial','FontSize',9,'LineWidth',0.75, ...
        'GridColor',[0.82 0.82 0.82],'GridAlpha',0.45, ...
        'XColor',[0.15 0.15 0.15],'YColor',[0.15 0.15 0.15]);
end
