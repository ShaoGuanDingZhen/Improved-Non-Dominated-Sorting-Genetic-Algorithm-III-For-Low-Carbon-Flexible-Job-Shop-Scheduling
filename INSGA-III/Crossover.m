

function [y1 y2]=Crossover(x1,x2)


% alpha=rand(size(x1));
%
% y1=alpha.*x1+(1-alpha).*x2;
% y2=alpha.*x2+(1-alpha).*x1;
half_length = length(x1) / 2;


pchrom1=x1(1:length(x1)/2);
mchrom1=x1(length(x1)/2+1:end);
pchrom2=x2(1:length(x1)/2);
mchrom2=x2(length(x1)/2+1:end);


global N SH;
%整个交叉操作为POX交叉
p_parent_1=pchrom1; %以一定概率选取当前行与全局最优粒子做交换
m_parent_1=mchrom1;
p_parent_2=pchrom2;%J取全局最优粒子的索引
m_parent_2=mchrom2;
J1=[];%用于存储工件id的集合0表示集合Q1 1表示Q2
c1_p=zeros(1,SH);%用于标记p1中Q1集合id的位置
c2_p=zeros(1,SH);%用于标记p2中Q1集合id的位置

while size(J1,1)==0 && size(J1,2)==0
    J1=find(round(rand(1,N))==1);%随机产生标记id号的集合
end

for j=1:SH
    if ismember(p_parent_1(j),J1) %将P1中是J1的元素存储到
        c1_p(j)=p_parent_1(j);
    end
    
    if ~ismember(p_parent_2(j),J1) %将P2中不是J1的元素存储到c2
        c2_p(j)=p_parent_2(j);
    end
end

index_1_1=find(c1_p==0);%c1中的空位应该填补c2中非0的空位
index_1_2=find(c2_p~=0);

index_2_1=find(c2_p==0);%c2中的空位应该填补c2中非0的空位
index_2_2=find(c1_p~=0);

for j=1:size(index_1_1,2)%将p2中
    c1_p(index_1_1(j))=p_parent_2(index_1_2(j));
end

for j=1:size(index_2_1,2)
    c2_p(index_2_1(j))=p_parent_1(index_2_2(j));
end

p_parent_1=c1_p;
p_parent_2=c2_p;

%进行机器交叉 主要采用随机产生序列，交换对应点位机器码
s=round(rand(1,SH))==1;
for i=1:SH
    if(s(i)==1)
        t=m_parent_1(i);
        m_parent_1(i)=m_parent_2(i);
        m_parent_2(i)=t;
    end
end

y1=[p_parent_1,m_parent_1];
y2=[p_parent_2,m_parent_2];


