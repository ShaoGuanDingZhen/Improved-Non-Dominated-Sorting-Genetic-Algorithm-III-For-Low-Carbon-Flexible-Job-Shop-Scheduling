function Len = calculateLen(pop, baseProportion, scaleFactor)
    diversityScores = calculateDiversityScores(pop);
    meanDiversity = mean(diversityScores);
    stdDiversity = std(diversityScores);

    % ��̬����Len���ڶ����Ե÷�����ֵ�Ĳ���
    diversityThreshold = meanDiversity - 0.5 * stdDiversity;  % �趨��̬��ֵ
    diversityGap = meanDiversity - diversityThreshold;

    if diversityGap < 0
        % ��������Ե÷ֵ�����ֵ�����ݲ���С����Len
        adjustment = scaleFactor * (-diversityGap / stdDiversity);
        Len = round((baseProportion + adjustment) * length(pop));
    else
        Len = round(baseProportion * length(pop));
    end
end

function diversityScores = calculateDiversityScores(pop)
    n = numel(pop);
    positions = vertcat(pop.Position);  % ����Position��һ������
    maxDist = max(pdist(positions));  % ������ܵ�������
    diversityScores = zeros(n, 1);
    for i = 1:n
        dists = sqrt(sum((positions - positions(i, :)).^2, 2));  % �������
        diversityScores(i) = mean(dists) / maxDist;  % ��һ���÷�
    end
end
