function [Pchrom,Mchrom]=initialmix5()%将三种初始化策略结合起来共生成三个子种群大小为ps/3 ps/3 ps/3剩下不足 ps的用随机初始化补齐

global  N H SH NM ps time TM M;

Pchrom=[];
Mchrom=[];


subpopsize=ps*0.2;
chrom=zeros(1,SH-N);
% 策略1

m_chrom=zeros(subpopsize,SH);%机器码
p_chrom=zeros(subpopsize,SH);%工序码
%生成工序码 工序码后续随机数生成
k=1;
for i=1:N%将工序按顺序排开
    for j=1:H(i)-1 %每一个工件拿一个工序出来
        chrom(k)=i;
        k=k+1;
    end
end
tmp1=(1:N);%取每个工件的工序1出来
tmp2=chrom;
for i=1:subpopsize   
    tmp=tmp1(randperm(length(tmp1)));%扰乱工序1
    tmp3=tmp2(randperm(length(tmp2)));%扰乱后续工
    p_chrom(i,:)=[tmp tmp3];%前后合并成工序码
end
%工序码种群生成完毕
%生成机器码 选择当前最小负载机器
e=[0 0 0 0 0];
for k=1:subpopsize
    %先要对工序码进行解码
    mt=cell(1,TM);%机器加工时间
    
    for i=1:TM%初始化机器最大完成时间数组
        mt{i}=e;
    end
    mm=zeros(1,SH);
    
    %选择工序码进行解码
    s1=p_chrom(k,:);
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%记录过程是否加工完成 完成一次加一
        s2(i)=p(s1(i));%记录加工过程中，工件的次数
    end
    
    for i=1:SH
        %先要提取该工序能够使用的机器序号在可选的范围内选择最小的负载的机器
        n=NM{s1(i),s2(i)};
        if n==1
            mm(i)=M{s1(i),s2(i),1};
            mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%更新对应机器的负载
            continue;
        else
            avalible_m=zeros(1,n);
            avalible_m_load=cell(1,n);
            for j=1:n %提取当前工序可用机器的序号以及对应序号机器的负载
                avalible_m(j)=M{s1(i),s2(i),j};
                avalible_m_load{j}=mt{avalible_m(j)};
            end
             candidateM=selectMachine(avalible_m_load);%先找出最小的负载机器
             sizeM=size(candidateM,2);
             if(sizeM==1)%如果只有一台则选最小的负载机器
                mm(i)=avalible_m(candidateM);
                mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%更新对应机器的负载
             else
                 t=time{s1(i),s2(i),avalible_m(candidateM(1))};
                 mm(i)=avalible_m(candidateM(1));
                 for kk=2:sizeM
                     tmp=time{s1(i),s2(i),avalible_m(candidateM(kk))};
                     if(com(t,tmp))
                        mm(i)=avalible_m(candidateM(kk));
                     end
                 end
                 mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%更新对应机器的负载
             end
        end
        
    end
    
    %机器选择完成要将解码的机器码mm重新编码成机器码m_chrom
    for i=1:SH
        t1=s1(i);%记录到当前是那个工件
        t2=s2(i);%记录当前工件是加工到第几次
        m_chrom(k,sum(H(1,1:t1-1))+t2)=mm(i);%提取该工序该次加工的机器选择，因为机器码的排列表示该工件第几次加工所选的机器，是一段表示一个工件
    end
      
end
%机器码种群生成完毕
Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];



%策略2
m_chrom=zeros(subpopsize,SH);%机器码
p_chrom=zeros(subpopsize,SH);%工序码
chrom=zeros(1,SH);

%生成工序码  工序码需要随机生成 局部搜索策略只针对机器码
for i=1:N%将工序按顺序排开
    for j=1:H(i)
        k=sum(H(1,1:i))-H(i)+j;
        chrom(k)=i;
    end
end
tmp=chrom;
p_chrom(1,:)=tmp(randperm(length(tmp)));%将工序码打乱

for i=2:subpopsize   
    tmp=p_chrom(i-1,:);
    p_chrom(i,:)=tmp(randperm(length(tmp)));%再根据上一个生成后续的种群个体
end
%工序码种群生成完毕

%生成机器码 选择最小处理时间机器
for k=1:subpopsize
    for i=1:N
        for j=1:H(i)
            t1=sum(H(1,1:i-1))+j;
            index=M{i,j,1};
            f=time{i,j,index};
            for t=1:NM{i,j} %找到最小的处理时间机器
                d=M{i,j,t};
                if(com(f,time{i,j,d}))%如果f>time{i,j,t} 则更新f
                    f=time{i,j,d};
                    index=d;
                end
            end
            m_chrom(k,t1)=index;
        end
    end
end
%机器码种群生成完毕

Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];

%策略3
m_chrom=zeros(subpopsize,SH);%机器码
p_chrom=zeros(subpopsize,SH);%工序码

chrom=zeros(1,SH);

%生成工序码  工序码需要随机生成 局部搜索策略只针对机器码
for i=1:N%将工序按顺序排开
    for j=1:H(i)
        k=sum(H(1,1:i))-H(i)+j;
        chrom(k)=i;
    end
end
tmp=chrom;
p_chrom(1,:)=tmp(randperm(length(tmp)));%将工序码打乱

for i=2:subpopsize   
    tmp=p_chrom(i-1,:);
    p_chrom(i,:)=tmp(randperm(length(tmp)));%再根据上一个生成后续的种群个体
end
%工序码种群生成完毕

%生成机器码 选择最小处理时间机器
for k=1:subpopsize   
    e=[0 0 0 0 0];

    finish={};%工序完工时间
    for i=1:N%初始化完成时间矩阵
        for j=1:H(i)
            finish{i,j}=e;
        end
    end
    
    mt=cell(1,TM);
    for i=1:TM%初始化机器最大完成时间数组
        mt{i}=e;
    end
    
    s1=p_chrom(k,:);
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%记录过程是否加工完成 完成一次加一
        s2(i)=p(s1(i));%记录加工过程中，工件的次数
    end
    new_m=zeros(1,SH);
    for i=1:SH
        t1=s1(i);%记录到当前是那个工件
        t2=s2(i);%记录当前工件是加工到第几次
        if s2(i)==1
            [MachineIndex]=FindMinFinishTimeMachine(t1,t2,mt);
            mm(i)=FindMinProcessTimeMachine(t1,t2,MachineIndex);%则该工序对应的机器选择应该是最小加工时间的机器
            mt{mm(i)}=mt{mm(i)}+time{t1,t2,mm(i)};%累计计算每一台机器的加工时间
            finish{t1,t2}= mt{mm(i)};%改工件当前工序的完成时间是当前机器的累计时间
        else
            %如果不是第一个工序就需要计算上一个工序的加工时间是否大于当前机器的完成时间，如果大于则机器会出现等待时间，
            %如果小于则不会出现等待时间。如果都是大于则选择等待时间最小的机器。
            [MachineIndex]=FindMinFinishTimeMachine(t1,t2,mt);
            mm(i)=FindMinProcessTimeMachine(t1,t2,MachineIndex);%则该工序对应的机器选择应该是最小加工时间的机器
            if(~com(mt{mm(i)},finish{t1,t2-1}))%如果机器最大完成时间小于该工序上一步完成时间
              mt{mm(i)}= finish{t1,t2-1}+time{t1,t2,mm(i)};%一定是去上一步完成时间和该机器结束加工时间的最大者      
              finish{t1,t2}= mt{mm(i)};
            else%如果机器完成时间大于等于该工件上一个工序的完成时间
              mt{mm(i)}= mt{mm(i)}+time{t1,t2,mm(i)};
              finish{t1,t2}= mt{mm(i)};            
            end
        end
       new_m(1,sum(H(1,1:t1-1))+t2)=mm(i);%将机器选择进行编码

    end
    m_chrom(k,:)=new_m;
    
end
Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];
%策略4

m_chrom=zeros(subpopsize,SH);%机器码
p_chrom=zeros(subpopsize,SH);%工序码

chrom=zeros(1,SH);

%生成工序码  工序码需要随机生成 局部搜索策略只针对机器码
for i=1:N%将工序按顺序排开
    for j=1:H(i)
        k=sum(H(1,1:i))-H(i)+j;
        chrom(k)=i;
    end
end
s1=chrom;
s2=zeros(1,SH);
p=zeros(1,N);
for i=1:SH
   p(s1(i))=p(s1(i))+1;%记录过程是否加工完成 完成一次加一
   s2(i)=p(s1(i));%记录加工过程中，工件的次数
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
     %先要对工序码进行解码
    mt=cell(1,TM);%机器加工时间
    
    for i=1:TM%初始化机器最大完成时间数组
        mt{i}=e;
    end
    mm=zeros(1,SH);
    
    %选择工序码进行解码
    s1=p_chrom(k,:);
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%记录过程是否加工完成 完成一次加一
        s2(i)=p(s1(i));%记录加工过程中，工件的次数
    end
    
    for i=1:SH
        %先要提取该工序能够使用的机器序号在可选的范围内选择最小的负载的机器
        n=NM{s1(i),s2(i)};
        if n==1
            mm(i)=M{s1(i),s2(i),1};
            mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%更新对应机器的负载
            continue;
        else
            avalible_m=zeros(1,n);
            avalible_m_load=cell(1,n);
            for j=1:n %提取当前工序可用机器的序号以及对应序号机器的负载
                avalible_m(j)=M{s1(i),s2(i),j};
                avalible_m_load{j}=mt{avalible_m(j)};
            end
             candidateM=selectMachine(avalible_m_load);%先找出最小的负载机器
             sizeM=size(candidateM,2);
             if(sizeM==1)%如果只有一台则选最小的负载机器
                mm(i)=avalible_m(candidateM);
                mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%更新对应机器的负载
             else
                 t=time{s1(i),s2(i),avalible_m(candidateM(1))};
                 mm(i)=avalible_m(candidateM(1));
                 for kk=2:sizeM
                     tmp=time{s1(i),s2(i),avalible_m(candidateM(kk))};
                     if(com(t,tmp))
                        mm(i)=avalible_m(candidateM(kk));
                     end
                 end
                 mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%更新对应机器的负载
             end
        end
    end
    %机器选择完成要将解码的机器码mm重新编码成机器码m_chrom
    for i=1:SH
        t1=s1(i);%记录到当前是那个工件
        t2=s2(i);%记录当前工件是加工到第几次
        m_chrom(k,sum(H(1,1:t1-1))+t2)=mm(i);%提取该工序该次加工的机器选择，因为机器码的排列表示该工件第几次加工所选的机器，是一段表示一个工件
    end
end
Pchrom=[Pchrom;p_chrom];
Mchrom=[Mchrom;m_chrom];



m_chrom = zeros(subpopsize, SH); % 机器码
p_chrom = zeros(subpopsize, SH); % 工序码
chrom = zeros(1, SH);

% 生成工序码
for i = 1:N % 将工序按顺序排开
    for j = 1:H(i)
        k = sum(H(1, 1:i)) - H(i) + j;
        chrom(k) = i;
    end
end
tmp = chrom;
p_chrom(1, :) = tmp(randperm(length(tmp))); % 将工序码打乱

for i = 2:subpopsize
    tmp = p_chrom(i - 1, :);
    p_chrom(i, :) = tmp(randperm(length(tmp))); % 再根据上一个生成后续的种群个体
end
% 工序码种群生成完毕

% 生成机器码
for k = 1:subpopsize
    for i = 1:N
        for j = 1:H(i)
            t1 = sum(H(1, 1:i - 1)) + j;
            n = NM{i, j};
            if isempty(n) || n == 0
                continue;
            end

            % 初始化最小能耗的机器
            MinEnergyMachine = M{i, j, 1};
            minEnergy = time{i, j, MinEnergyMachine}(1);

            % 遍历所有机器，选择能耗最小的机器
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
% 机器码种群生成完毕
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
       if eql(mt{MinFinishMIndex},mt{CandidateM(j)})%如果有相等的机器则把可能的机器索引都归并到一起
           ProtenialMachine=[ProtenialMachine,CandidateM(j)];
       else
           if com(mt{MinFinishMIndex},mt{CandidateM(j)})%如果发现更小的则需要清空之前的缓存
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
        if (com(MinTime,temp)&&~eql(temp,z))%如果发现更小的机器
            MinProessTimeMachine=MachineIndex(i);
            MinTime=time{JobIndex,OperationIndex,MachineIndex(i)};
        end
    end
   % fprintf('%s %d %s %d %d %d\r\n','MinProessTimeMachine=',MinProessTimeMachine,'MinTime=',MinTime(1),MinTime(2),MinTime(3));
end
