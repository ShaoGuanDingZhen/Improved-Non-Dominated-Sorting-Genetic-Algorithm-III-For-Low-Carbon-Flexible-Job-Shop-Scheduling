function [eliteCount,stats] = CalculateDynamicEliteCount(pop,cfg)
%CALCULATEDYNAMICELITECOUNT Diversity-driven elite count.
%   p and r index individuals; d indexes normalized chromosome dimensions.

    positions = vertcat(pop.Position);
    n = size(positions,1);
    if n < 2
        eliteCount = 0;
        stats = struct('meanDiversity',0,'stdDiversity',0,'threshold',0,...
                       'lowDiversityFraction',0);
        return;
    end
    ranges = max(positions,[],1)-min(positions,[],1);
    ranges(ranges==0) = 1;
    z = (positions-min(positions,[],1))./ranges;
    distanceMatrix = zeros(n,n);
    for p = 1:n
        for r = p+1:n
            distanceMatrix(p,r) = norm(z(p,:)-z(r,:));
            distanceMatrix(r,p) = distanceMatrix(p,r);
        end
    end
    diversity = sum(distanceMatrix,2)/(n-1);
    muD = mean(diversity);
    sigmaD = std(diversity);
    threshold = muD - 0.5*sigmaD;
    lowFraction = mean(diversity < threshold);
    proportion = cfg.baseEliteProportion + cfg.eliteScaleFactor*lowFraction;
    proportion = min(cfg.maxEliteProportion,max(cfg.minEliteProportion,proportion));
    eliteCount = max(1,round(proportion*n));
    stats = struct('meanDiversity',muD,'stdDiversity',sigmaD,'threshold',threshold,...
                   'lowDiversityFraction',lowFraction);
end
