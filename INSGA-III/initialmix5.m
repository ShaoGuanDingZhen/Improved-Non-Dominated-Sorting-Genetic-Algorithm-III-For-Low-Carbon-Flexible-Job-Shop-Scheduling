function [Pchrom,Mchrom]=initialmix5()%�����ֳ�ʼ�����Խ��������������������Ⱥ��СΪps/3 ps/3 ps/3ʣ�²��� ps���������ʼ������

global  N H SH NM ps time TM M;

Pchrom=[];
Mchrom=[];


subpopsize=ps*0.2;
chrom=zeros(1,SH-N);
% ����1

m_chrom=zeros(subpopsize,SH);%������
p_chrom=zeros(subpopsize,SH);%������
%���ɹ����� ������������������
k=1;
for i=1:N%������˳���ſ�
    for j=1:H(i)-1 %ÿһ��������һ���������
        chrom(k)=i;
        k=k+1;
    end
end
tmp1=(1:N);%ȡÿ�������Ĺ���1����
tmp2=chrom;
for i=1:subpopsize   
    tmp=tmp1(randperm(length(tmp1)));%���ҹ���1
    tmp3=tmp2(randperm(length(tmp2)));%���Һ�����
    p_chrom(i,:)=[tmp tmp3];%ǰ��ϲ��ɹ�����
end
%��������Ⱥ�������
%���ɻ����� ѡ��ǰ��С���ػ���
e=[0 0 0 0 0];
for k=1:subpopsize
    %��Ҫ�Թ�������н���
    mt=cell(1,TM);%�����ӹ�ʱ��
    
    for i=1:TM%��ʼ������������ʱ������
        mt{i}=e;
    end
    mm=zeros(1,SH);
    
    %ѡ��������н���
    s1=p_chrom(k,:);
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%��¼�����Ƿ�ӹ���� ���һ�μ�һ
        s2(i)=p(s1(i));%��¼�ӹ������У������Ĵ���
    end
    
    for i=1:SH
        %��Ҫ��ȡ�ù����ܹ�ʹ�õĻ�������ڿ�ѡ�ķ�Χ��ѡ����С�ĸ��صĻ���
        n=NM{s1(i),s2(i)};
        if n==1
            mm(i)=M{s1(i),s2(i),1};
            mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%���¶�Ӧ�����ĸ���
            continue;
        else
            avalible_m=zeros(1,n);
            avalible_m_load=cell(1,n);
            for j=1:n %��ȡ��ǰ������û���������Լ���Ӧ��Ż����ĸ���
                avalible_m(j)=M{s1(i),s2(i),j};
                avalible_m_load{j}=mt{avalible_m(j)};
            end
             candidateM=selectMachine(avalible_m_load);%���ҳ���С�ĸ��ػ���
             sizeM=size(candidateM,2);
             if(sizeM==1)%���ֻ��һ̨��ѡ��С�ĸ��ػ���
                mm(i)=avalible_m(candidateM);
                mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%���¶�Ӧ�����ĸ���
             else
                 t=time{s1(i),s2(i),avalible_m(candidateM(1))};
                 mm(i)=avalible_m(candidateM(1));
                 for kk=2:sizeM
                     tmp=time{s1(i),s2(i),avalible_m(candidateM(kk))};
                     if(com(t,tmp))
                        mm(i)=avalible_m(candidateM(kk));
                     end
                 end
                 mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%���¶�Ӧ�����ĸ���
             end
        end
        
    end
    
    %����ѡ�����Ҫ������Ļ�����mm���±���ɻ�����m_chrom
    for i=1:SH
        t1=s1(i);%��¼����ǰ���Ǹ�����
        t2=s2(i);%��¼��ǰ�����Ǽӹ����ڼ���
        m_chrom(k,sum(H(1,1:t1-1))+t2)=mm(i);%��ȡ�ù���ôμӹ��Ļ���ѡ����Ϊ����������б�ʾ�ù����ڼ��μӹ���ѡ�Ļ�������һ�α�ʾһ������
    end
      
end
%��������Ⱥ�������
Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];



%����2
m_chrom=zeros(subpopsize,SH);%������
p_chrom=zeros(subpopsize,SH);%������
chrom=zeros(1,SH);

%���ɹ�����  ��������Ҫ������� �ֲ���������ֻ��Ի�����
for i=1:N%������˳���ſ�
    for j=1:H(i)
        k=sum(H(1,1:i))-H(i)+j;
        chrom(k)=i;
    end
end
tmp=chrom;
p_chrom(1,:)=tmp(randperm(length(tmp)));%�����������

for i=2:subpopsize   
    tmp=p_chrom(i-1,:);
    p_chrom(i,:)=tmp(randperm(length(tmp)));%�ٸ�����һ�����ɺ�������Ⱥ����
end
%��������Ⱥ�������

%���ɻ����� ѡ����С����ʱ�����
for k=1:subpopsize
    for i=1:N
        for j=1:H(i)
            t1=sum(H(1,1:i-1))+j;
            index=M{i,j,1};
            f=time{i,j,index};
            for t=1:NM{i,j} %�ҵ���С�Ĵ���ʱ�����
                d=M{i,j,t};
                if(com(f,time{i,j,d}))%���f>time{i,j,t} �����f
                    f=time{i,j,d};
                    index=d;
                end
            end
            m_chrom(k,t1)=index;
        end
    end
end
%��������Ⱥ�������

Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];

%����3
m_chrom=zeros(subpopsize,SH);%������
p_chrom=zeros(subpopsize,SH);%������

chrom=zeros(1,SH);

%���ɹ�����  ��������Ҫ������� �ֲ���������ֻ��Ի�����
for i=1:N%������˳���ſ�
    for j=1:H(i)
        k=sum(H(1,1:i))-H(i)+j;
        chrom(k)=i;
    end
end
tmp=chrom;
p_chrom(1,:)=tmp(randperm(length(tmp)));%�����������

for i=2:subpopsize   
    tmp=p_chrom(i-1,:);
    p_chrom(i,:)=tmp(randperm(length(tmp)));%�ٸ�����һ�����ɺ�������Ⱥ����
end
%��������Ⱥ�������

%���ɻ����� ѡ����С����ʱ�����
for k=1:subpopsize   
    e=[0 0 0 0 0];

    finish={};%�����깤ʱ��
    for i=1:N%��ʼ�����ʱ�����
        for j=1:H(i)
            finish{i,j}=e;
        end
    end
    
    mt=cell(1,TM);
    for i=1:TM%��ʼ������������ʱ������
        mt{i}=e;
    end
    
    s1=p_chrom(k,:);
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%��¼�����Ƿ�ӹ���� ���һ�μ�һ
        s2(i)=p(s1(i));%��¼�ӹ������У������Ĵ���
    end
    new_m=zeros(1,SH);
    for i=1:SH
        t1=s1(i);%��¼����ǰ���Ǹ�����
        t2=s2(i);%��¼��ǰ�����Ǽӹ����ڼ���
        if s2(i)==1
            [MachineIndex]=FindMinFinishTimeMachine(t1,t2,mt);
            mm(i)=FindMinProcessTimeMachine(t1,t2,MachineIndex);%��ù����Ӧ�Ļ���ѡ��Ӧ������С�ӹ�ʱ��Ļ���
            mt{mm(i)}=mt{mm(i)}+time{t1,t2,mm(i)};%�ۼƼ���ÿһ̨�����ļӹ�ʱ��
            finish{t1,t2}= mt{mm(i)};%�Ĺ�����ǰ��������ʱ���ǵ�ǰ�������ۼ�ʱ��
        else
            %������ǵ�һ���������Ҫ������һ������ļӹ�ʱ���Ƿ���ڵ�ǰ���������ʱ�䣬����������������ֵȴ�ʱ�䣬
            %���С���򲻻���ֵȴ�ʱ�䡣������Ǵ�����ѡ��ȴ�ʱ����С�Ļ�����
            [MachineIndex]=FindMinFinishTimeMachine(t1,t2,mt);
            mm(i)=FindMinProcessTimeMachine(t1,t2,MachineIndex);%��ù����Ӧ�Ļ���ѡ��Ӧ������С�ӹ�ʱ��Ļ���
            if(~com(mt{mm(i)},finish{t1,t2-1}))%�������������ʱ��С�ڸù�����һ�����ʱ��
              mt{mm(i)}= finish{t1,t2-1}+time{t1,t2,mm(i)};%һ����ȥ��һ�����ʱ��͸û��������ӹ�ʱ��������      
              finish{t1,t2}= mt{mm(i)};
            else%����������ʱ����ڵ��ڸù�����һ����������ʱ��
              mt{mm(i)}= mt{mm(i)}+time{t1,t2,mm(i)};
              finish{t1,t2}= mt{mm(i)};            
            end
        end
       new_m(1,sum(H(1,1:t1-1))+t2)=mm(i);%������ѡ����б���

    end
    m_chrom(k,:)=new_m;
    
end
Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];
%����4

m_chrom=zeros(subpopsize,SH);%������
p_chrom=zeros(subpopsize,SH);%������

chrom=zeros(1,SH);

%���ɹ�����  ��������Ҫ������� �ֲ���������ֻ��Ի�����
for i=1:N%������˳���ſ�
    for j=1:H(i)
        k=sum(H(1,1:i))-H(i)+j;
        chrom(k)=i;
    end
end
s1=chrom;
s2=zeros(1,SH);
p=zeros(1,N);
for i=1:SH
   p(s1(i))=p(s1(i))+1;%��¼�����Ƿ�ӹ���� ���һ�μ�һ
   s2(i)=p(s1(i));%��¼�ӹ������У������Ĵ���
end
OPM=zeros(1,SH);
for i=1:SH
  OPM(i)=NM{s1(i),s2(i)};  
end
[~,index]=sort(OPM,'ascend');
chrom=chrom(index);
for i=1:subpopsize
    p_chrom(i,:)=chrom;   
end
e=[0 0 0 0 0];
for k=1:subpopsize
     %��Ҫ�Թ�������н���
    mt=cell(1,TM);%�����ӹ�ʱ��
    
    for i=1:TM%��ʼ������������ʱ������
        mt{i}=e;
    end
    mm=zeros(1,SH);
    
    %ѡ��������н���
    s1=p_chrom(k,:);
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%��¼�����Ƿ�ӹ���� ���һ�μ�һ
        s2(i)=p(s1(i));%��¼�ӹ������У������Ĵ���
    end
    
    for i=1:SH
        %��Ҫ��ȡ�ù����ܹ�ʹ�õĻ�������ڿ�ѡ�ķ�Χ��ѡ����С�ĸ��صĻ���
        n=NM{s1(i),s2(i)};
        if n==1
            mm(i)=M{s1(i),s2(i),1};
            mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%���¶�Ӧ�����ĸ���
            continue;
        else
            avalible_m=zeros(1,n);
            avalible_m_load=cell(1,n);
            for j=1:n %��ȡ��ǰ������û���������Լ���Ӧ��Ż����ĸ���
                avalible_m(j)=M{s1(i),s2(i),j};
                avalible_m_load{j}=mt{avalible_m(j)};
            end
             candidateM=selectMachine(avalible_m_load);%���ҳ���С�ĸ��ػ���
             sizeM=size(candidateM,2);
             if(sizeM==1)%���ֻ��һ̨��ѡ��С�ĸ��ػ���
                mm(i)=avalible_m(candidateM);
                mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%���¶�Ӧ�����ĸ���
             else
                 t=time{s1(i),s2(i),avalible_m(candidateM(1))};
                 mm(i)=avalible_m(candidateM(1));
                 for kk=2:sizeM
                     tmp=time{s1(i),s2(i),avalible_m(candidateM(kk))};
                     if(com(t,tmp))
                        mm(i)=avalible_m(candidateM(kk));
                     end
                 end
                 mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%���¶�Ӧ�����ĸ���
             end
        end
    end
    %����ѡ�����Ҫ������Ļ�����mm���±���ɻ�����m_chrom
    for i=1:SH
        t1=s1(i);%��¼����ǰ���Ǹ�����
        t2=s2(i);%��¼��ǰ�����Ǽӹ����ڼ���
        m_chrom(k,sum(H(1,1:t1-1))+t2)=mm(i);%��ȡ�ù���ôμӹ��Ļ���ѡ����Ϊ����������б�ʾ�ù����ڼ��μӹ���ѡ�Ļ�������һ�α�ʾһ������
    end
end
Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];



m_chrom = zeros(subpopsize, SH); % ������
p_chrom = zeros(subpopsize, SH); % ������
chrom = zeros(1, SH);

% ���ɹ�����
for i = 1:N % ������˳���ſ�
    for j = 1:H(i)
        k = sum(H(1, 1:i)) - H(i) + j;
        chrom(k) = i;
    end
end
tmp = chrom;
p_chrom(1, :) = tmp(randperm(length(tmp))); % �����������

for i = 2:subpopsize
    tmp = p_chrom(i - 1, :);
    p_chrom(i, :) = tmp(randperm(length(tmp))); % �ٸ�����һ�����ɺ�������Ⱥ����
end
% ��������Ⱥ�������

% ���ɻ�����
for k = 1:subpopsize
    for i = 1:N
        for j = 1:H(i)
            t1 = sum(H(1, 1:i - 1)) + j;
            n = NM{i, j};
            if isempty(n) || n == 0
                continue;
            end

            % ��ʼ����С�ܺĵĻ���
            MinEnergyMachine = M{i, j, 1};
            minEnergy = time{i, j, MinEnergyMachine}(1);

            % �������л�����ѡ���ܺ���С�Ļ���
            for m = 2:n
                currentMachine = M{i, j, m};
                currentEnergy = time{i, j, currentMachine}(1);
                if com([minEnergy 0 0 0 0], [currentEnergy 0 0 0 0]) == 0
                    MinEnergyMachine = currentMachine;
                    minEnergy = currentEnergy;
                end
            end

            m_chrom(k, t1) = MinEnergyMachine;
        end
    end
end
% ��������Ⱥ�������
Pchrom = [Pchrom; p_chrom];
Mchrom = [Mchrom; m_chrom];



end

function [ProtenialMachine]=FindMinFinishTimeMachine(JobIndex,OperationIndex,mt)
global TM M NM;
L=NM{JobIndex,OperationIndex};
CandidateM=zeros(1,L);
for i=1:L
    CandidateM(1,i)=M{JobIndex,OperationIndex,i};
end

    if L<2
        ProtenialMachine=CandidateM;
        return
    end
    ProtenialMachine=[];
    MinFinishMIndex=CandidateM(1);
    ProtenialMachine=[ProtenialMachine,MinFinishMIndex];
    for j=2:L
       if eql(mt{MinFinishMIndex},mt{CandidateM(j)})%�������ȵĻ�����ѿ��ܵĻ����������鲢��һ��
           ProtenialMachine=[ProtenialMachine,CandidateM(j)];
       else
           if com(mt{MinFinishMIndex},mt{CandidateM(j)})%������ָ�С������Ҫ���֮ǰ�Ļ���
               ProtenialMachine=[];
               MinFinishMIndex=CandidateM(j);
               ProtenialMachine=[ProtenialMachine,MinFinishMIndex];
           end
       end
    end
end

function [MinProessTimeMachine]=FindMinProcessTimeMachine(JobIndex,OperationIndex,MachineIndex)
global time M;
z=[0 0 0 0 0];
L=length(MachineIndex);
    if L<2
       MinProessTimeMachine=MachineIndex;
       return 
    end
    MinProessTimeMachine=MachineIndex(1);
    MinTime=time{JobIndex,OperationIndex,MinProessTimeMachine};
        if isempty(MinTime)
            MinTime=z;
        end
    for i=2:L
        temp=time{JobIndex,OperationIndex,MachineIndex(i)};
        if isempty(temp)
            temp=z;
        end
        if (com(MinTime,temp)&&~eql(temp,z))%������ָ�С�Ļ���
            MinProessTimeMachine=MachineIndex(i);
            MinTime=time{JobIndex,OperationIndex,MachineIndex(i)};
        end
    end
   % fprintf('%s %d %s %d %d %d\r\n','MinProessTimeMachine=',MinProessTimeMachine,'MinTime=',MinTime(1),MinTime(2),MinTime(3));
end
