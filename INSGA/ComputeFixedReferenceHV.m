function hv = ComputeFixedReferenceHV(front,referencePoint)
%COMPUTEFIXEDREFERENCEHV Exact 2-objective HV with a shared reference point.
%   Both objectives are minimized. Points outside the reference box are
%   discarded; dominated points are removed before the area is accumulated.

    valid = all(isfinite(front),2) & all(front < referencePoint,2);
    front = front(valid,:);
    if isempty(front), hv = 0; return; end
    front = sortrows(front,1);
    keep = true(size(front,1),1);
    bestY = inf;
    for i = 1:size(front,1)
        if front(i,2) >= bestY
            keep(i) = false;
        else
            bestY = front(i,2);
        end
    end
    front = front(keep,:);
    hv = 0;
    currentY = referencePoint(2);
    for i = 1:size(front,1)
        if front(i,2) < currentY
            hv = hv + (referencePoint(1)-front(i,1))*(currentY-front(i,2));
            currentY = front(i,2);
        end
    end
end
