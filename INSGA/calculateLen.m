function Len = calculateLen(pop, baseProportion, scaleFactor)
    diversityScores = calculateDiversityScores(pop);
    meanDiversity = mean(diversityScores);
    stdDiversity = std(diversityScores);

    % 动态调整Len基于多样性得分与阈值的差异
    diversityThreshold = meanDiversity - 0.5 * stdDiversity;  % 设定动态阈值
    diversityGap = meanDiversity - diversityThreshold;

    if diversityGap < 0
        % 如果多样性得分低于阈值，根据差距大小增加Len
        adjustment = scaleFactor * (-diversityGap / stdDiversity);
        Len = round((baseProportion + adjustment) * length(pop));
    else
        Len = round(baseProportion * length(pop));
    end
end

function diversityScores = calculateDiversityScores(pop)
    n = numel(pop);
    positions = vertcat(pop.Position);  % 假设Position是一个数组
    maxDist = max(pdist(positions));  % 计算可能的最大距离
    diversityScores = zeros(n, 1);
    for i = 1:n
        dists = sqrt(sum((positions - positions(i, :)).^2, 2));  % 计算距离
        diversityScores(i) = mean(dists) / maxDist;  % 归一化得分
    end
end
