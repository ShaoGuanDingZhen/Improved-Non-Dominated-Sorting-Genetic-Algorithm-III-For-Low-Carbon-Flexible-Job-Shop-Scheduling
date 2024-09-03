function F11=soluation(pps)
clc
global  F1 F2 F3 F4 F5
cost=[];
pop=[];

for i=1:pps
    eval(['Len=length(F',num2str(i),');'])
    for j=1:Len
        eval(['cost=[cost;F',num2str(i),'(j).Cost];'])
        eval([' pop=[pop;F',num2str(i),'(j).Position];'])
    end
end


for i=1:length(cost)
    F11(i).Cost=cost(i,:);
    F11(i).Position =pop(i,:);
end
    

