

function PlotCosts(F1)


pop=F1;
Costs=[pop.Cost];



xx=Costs(1:2:end);
yy=Costs(2:2:end);


[xx1,idx]=sort(xx);
yy1=yy(idx);

plot(xx1,yy1,'r*','MarkerSize',8);
xlabel('1st Objective');
ylabel('2nd Objective');
grid on;
