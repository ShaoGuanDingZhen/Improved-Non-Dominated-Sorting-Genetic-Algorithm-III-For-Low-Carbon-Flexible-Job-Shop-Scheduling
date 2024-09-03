
function y=Mutate(x)


% nVar=numel(x);
%
% nMu=ceil(mu*nVar);
%
% j=randsample(nVar,nMu);
%
% y=x;
%
% y(j)=x(j)+sigma*randn(size(j));

pchrom=x(1:length(x)/2);
mchrom=x(length(x)/2+1:end);
global SH N H NM M;
%进行工序变异
p1=ceil(rand*SH);   %第一个变异位点
p2=ceil(rand*SH);   %第二个变异位点
while (p1==p2)||(pchrom(p1)==pchrom(p2))   %确保两个变异位点不同，且所对应的工序号不同
    p2=ceil(rand*SH);
end
t=pchrom(p1);
pchrom(p1)=pchrom(p2);            %将两个工序进行交换
pchrom(p2)=t;

%进行机器变异
s1=pchrom;
s2=zeros(1,SH);
p=zeros(1,N);
for i=1:SH
    p(s1(i))=p(s1(i))+1;
    s2(i)=p(s1(i));
end

s3=mchrom;
p1=ceil(rand*SH);       %第一个变异位点
p2=ceil(rand*SH);       %第二个变异位点
while(p1==p2)
    p2=ceil(rand*SH);
end
n=NM{s1(p1),s2(p1)};
m=ceil(rand*n);
x=M{s1(p1),s2(p1),m};
if n>1
    while(s3(p1)==m)
        m=ceil(rand*n);
        x=M{s1(p1),s2(p1),m};
    end
end
mchrom(1,sum(H(1,1:s1(p1)-1))+s2(p1))=x;

n=NM{s1(p2),s2(p2)};
m=ceil(rand*n);
x=M{s1(p2),s2(p2),m};
if n>1
    while(s3(p1)==m)
        m=ceil(rand*n);
        x=M{s1(p2),s2(p2),m};
    end
end
mchrom(1,sum(H(1,1:s1(p2)-1))+s2(p2))=x;

y=[pchrom,mchrom];

