
function [N,TM,H,NM,M,SH,time]=DataRead(RealPath)

fin=fopen(RealPath,'r'); %��txt�ļ�
A=fscanf(fin,'%d');
A=A';

N=A(1);%�ܹ�����
TM=A(2);%�ܵĻ�����
H=zeros(1,N);%������������
NM={};%�������ѡ������
M={};%�������ѡ������
time={};
p=5;%��ǰλ��

z=[0,0,0,0,0];
for i=1:N
    H(i)=A(p);
    for j=1:H(i)
         %p=p+1;
        NM{i,j}=0;
        for k=1:TM
            %p=p+1;
            %M{i,j,k}=A(p);
            time{i,j,k}=A(1,p+1:p+5);
            if (~eql(time{i,j,k},z))
                NM{i,j}=NM{i,j}+1;
                M{i,j,NM{i,j}}=k;
            end
            p=p+5;
        end
    end
    p=p+3;
end
SH=sum(H);



end
