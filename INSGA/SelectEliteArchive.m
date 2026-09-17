function archive = SelectEliteArchive(pop,eliteCount)
%SELECTELITEARCHIVE Retain balanced elites for the next generation.

    if eliteCount <= 0
        archive = pop([]);
        return;
    end
    costs = vertcat(pop.Cost);
    score = sum((costs-min(costs,[],1))./(max(costs,[],1)-min(costs,[],1)+eps),2);
    [~,order] = sort(score,'ascend');
    archive = pop(order(1:min(eliteCount,numel(order))));
end
