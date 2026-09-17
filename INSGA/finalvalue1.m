function cost = finalvalue1(position)
%FINALVALUE1 Evaluate a concatenated operation/machine chromosome.
%   This compatibility function was missing from the original release.

    nOperations = numel(position)/2;
    if mod(numel(position),2) ~= 0
        error('Chromosome length must be even.');
    end
    [f1,f2] = fit(position(1:nOperations),position(nOperations+1:end));
    values = finalvalue({f1,f2});
    cost = values(1,:);
end
