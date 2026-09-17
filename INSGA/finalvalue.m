function [obj]=finalvalue(fitness)

L=size(fitness,1);
obj=zeros(L,2);
for i=1:L
    a=fitness{i,1};
    CAL=a(3)-((a(5)-a(4))*(a(5)+2*a(4)-a(2)-2*a(3))/(6*(a(4)-a(2))));
    CAU=a(3)+((a(5)+a(2)-2*a(3))*(a(5)+a(4)-2*a(2))/(6*(a(4)-a(2))));
    
    obj(i,1)=(CAL+CAU)/2;
    
    a=fitness{i,2};
    CAL=a(3)-((a(5)-a(4))*(a(5)+2*a(4)-a(2)-2*a(3))/(6*(a(4)-a(2))));
    CAU=a(3)+((a(5)+a(2)-2*a(3))*(a(5)+a(4)-2*a(2))/(6*(a(4)-a(2))));
    
    obj(i,2)=(CAL+CAU)/2;
    
end

