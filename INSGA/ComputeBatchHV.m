function [hv,referencePoint] = ComputeBatchHV(fronts)
%COMPUTEBATCHHV Compute comparable HV values for a collection of fronts.

    allPoints = vertcat(fronts{:});
    lower = min(allPoints,[],1);
    upper = max(allPoints,[],1);
    referencePoint = upper + 0.1*(upper-lower+eps);
    hv = zeros(numel(fronts),1);
    for i = 1:numel(fronts)
        hv(i) = ComputeFixedReferenceHV(fronts{i},referencePoint);
    end
end
