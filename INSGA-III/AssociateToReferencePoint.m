

function [pop, d, rho] = AssociateToReferencePoint(pop, params)

Zr = params.Zr;
nZr = params.nZr;

rho = zeros(1,nZr);

d = zeros(numel(pop), nZr);

for i = 1:numel(pop)
    for j= 1:nZr
        w = Zr(:,j)/norm(Zr(:,j));
        z = pop(i).NormalizedCost;
        d(i,j) = norm(z - w'*z*w);
    end
    
    [dmin, jmin] = min(d(i,:));
    
    pop(i).AssociatedRef = jmin;
    pop(i).DistanceToAssociatedRef = dmin;
    rho(jmin) = rho(jmin) + 1;
    
end

