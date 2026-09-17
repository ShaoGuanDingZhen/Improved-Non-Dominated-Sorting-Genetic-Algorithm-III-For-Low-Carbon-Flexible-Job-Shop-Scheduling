function [pChrom,mChrom] = InitializeRandomFeasible(populationSize)
%INITIALIZERANDOMFEASIBLE Create feasible random two-layer chromosomes.

    global N H SH NM M
    pChrom = zeros(populationSize,SH);
    mChrom = zeros(populationSize,SH);
    baseSequence = zeros(1,SH);
    c = 1;
    for i = 1:N
        for j = 1:H(i)
            baseSequence(c) = i;
            c = c + 1;
        end
    end
    for r = 1:populationSize
        pChrom(r,:) = baseSequence(randperm(SH));
        for i = 1:N
            for j = 1:H(i)
                offset = sum(H(1:i-1)) + j;
                eligibleCount = NM{i,j};
                mChrom(r,offset) = M{i,j,randi(eligibleCount)};
            end
        end
    end
end
