function [F1,F]=INSGA_III(File,nPop,Zr,ps,MaxIt,pCrossover,CostFunction,pMutation)


%% Colect Parameters

params.nPop = nPop;
params.Zr = Zr;
params.nZr = size(Zr,2);
params.zmin = [];
params.zmax = [];
params.smin = [];

%% Initialization

disp('Staring NSGA-III ...');

empty_individual.Position = [];
empty_individual.Cost = [];
empty_individual.Rank = [];
empty_individual.DominationSet = [];
empty_individual.DominatedCount = [];
empty_individual.NormalizedCost = [];
empty_individual.AssociatedRef = [];
empty_individual.DistanceToAssociatedRef = [];



[p_chrom,m_chrom]=initialmix5();               % 种群初始化，优化变量为p_chrom,m_chrom，根据global变量定义
p_chrom=p_chrom(1:ps,:);
m_chrom=m_chrom(1:ps,:);


fitness=cell(ps,2);
for i=1:ps
    [fitness{i,1},fitness{i,2}]=fit(p_chrom(i,:),m_chrom(i,:));  % 多目标适应度计算
end
obj=finalvalue(fitness);           % 适应度归一化处理

% Lenn=round(nPop*0.1);              % 精英策略保存个数

pop = repmat(empty_individual, nPop, 1);
for i = 1:nPop
    pop(i).Position = [p_chrom(i,:), m_chrom(i,:)];
    pop(i).Cost = [obj(i,1),obj(i,2)];
end



% Sort Population and Perform Selection
[pop, F, params] = SortAndSelectPopulation(pop, params);

% k=0.01;
Rc=0;
Rm=0;
%% NSGA-III Main Loop


for it = 1:MaxIt
    

      p1Crossover = pCrossover;       % Crossover Percentage
    p1Mutation = pMutation;       % Mutation Percentage

    nCrossover=2*round(p1Crossover*nPop/2);
    nMutation =round(p1Mutation*nPop);  % Number of Mutants
    %
    %     pCrossover = 0.6;       % Crossover Percentage
    %     pMutation = 0.2;       % Mutation Percentage
    
    % Crossover
    popc = repmat(empty_individual, nCrossover, 2);
    
    % 交叉
    for k = 1:nCrossover
        i1 = randi([1 length(pop)]);
        p1 = pop(i1);
        
        i2 = randi([1 nPop]);
        p2 = pop(i2);
        
        [popc(k, 1).Position, popc(k, 2).Position] = Crossover(p1.Position, p2.Position);
        
        
        popc(k, 1).Cost = CostFunction(popc(k, 1).Position);
        popc(k, 2).Cost = CostFunction(popc(k, 2).Position);
    end
    
    popc = popc(:);
    
    % 变异
    popm = repmat(empty_individual, nMutation, 1);
    for k = 1:nMutation
        i = randi([1 length(pop)]);
        p = pop(i);
        popm(k).Position = Mutate(p.Position);
        popm(k).Cost = CostFunction(popm(k).Position);
    end
    
    
    % Merge
    pop = [pop
        popc
        popm]; %#ok


            % 在主算法循环中调用
          baseProportion = 0.06;  % 基础精英保留比例为4%
        scaleFactor = 0.02;     % 在多样性低时额外增加4%
        Len = calculateLen(pop, baseProportion, scaleFactor);
      
   

   
    if it==1
        
        jy_cost=[];
        jy_pop=[];
        
        cost=[];
        for s=1:length(pop)
            cost(s)=sum(pop(s).Cost);
        end
        [~,idx]=sort(cost);
        for s=1:round(Len/3)
            jy_cost(s,:)= pop(idx(s)).Cost;      % 记录给体
            jy_pop(s,:)= pop(idx(s)).Position;
        end
        
        cost=[];
        for s=1:length(pop)
            cost(s)=pop(s).Cost(1);
        end
        [~,idx]=sort(cost);
        for s=1:round(Len/3)
            jy_cost(round(Len/3)+s,:)= pop(idx(s)).Cost;      % 记录给体
            jy_pop(round(Len/3)+s,:)= pop(idx(s)).Position;
        end
        
        cost=[];
        for s=1:length(pop)
            cost(s)=pop(s).Cost(2);
        end
        [~,idx]=sort(cost);
        for s=1:round(Len/3)
            jy_cost(round(Len/3)*2+s,:)= pop(idx(s)).Cost;      % 记录给体
            jy_pop(round(Len/3)*2+s,:)= pop(idx(s)).Position;
        end
        
        
    else
        
        cost=[];
        NN1=length(pop);
        NN2=size(jy_pop,1);
        %         for s=1:NN1
        %             cost(s)=sum(pop(s).Cost);
        %         end
        %         [~,idx]=sort(cost,'descend');
        %         % 完成替换
        %         for s=1:NN2
        %             pop(idx(s)).Cost=jy_cost(s,:);
        %             pop(idx(s)).Position=jy_pop(s,:);
        %         end
        
        % 新增
        for s=1:NN2
            pop(NN1+s).Cost=jy_cost(s,:);
            pop(NN1+s).Position=jy_pop(s,:);
        end
        
        
        % 确定当前精英个体
        cost=[];
        for s=1:length(pop)
            cost(s)=sum(pop(s).Cost);
        end
        [~,idx]=sort(cost);
        for s=1:round(Len/5)
            jy_cost(s,:)= pop(idx(s)).Cost;      % 记录给体
            jy_pop(s,:)= pop(idx(s)).Position;
        end
        
        cost=[];
        for s=1:length(pop)
            cost(s)=pop(s).Cost(1);
        end
        [~,idx]=sort(cost);
        for s=1:round(Len/5)
            jy_cost(round(Len/5)+s,:)= pop(idx(s)).Cost;      % 记录给体
            jy_pop(round(Len/5)+s,:)= pop(idx(s)).Position;
        end
        
        cost=[];
        for s=1:length(pop)
            cost(s)=pop(s).Cost(2);
        end
        [~,idx]=sort(cost);
        for s=1:round(Len/5)
            jy_cost(round(Len/5)*2+s,:)= pop(idx(s)).Cost;      % 记录给体
            jy_pop(round(Len/5)*2+s,:)= pop(idx(s)).Position;
        end
    end
    
    
    
    
    
    
    
    
    
    
    
    
    % Sort Population and Perform Selection
    [pop, F, params] = SortAndSelectPopulation(pop, params);   % F为帕累托最优解
    



    F1= pop(F{1});  % F{1}为第一级非劣解
    
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Number of F1 Members = ' num2str(numel(F1))]);
    
    %         Plot F1 Costs
    figure(File);
    PlotCosts(F1);
 
% 保存原始种群大小
original_nPop = length(pop);

% 去重 - 假设我们基于成本去重
costs = vertcat(pop.Cost);  % 提取所有成本
[~, ia] = unique(costs, 'rows', 'stable');  % 找出唯一成本的索引
pop = pop(ia);  % 更新pop数组

% 更新 nPop 为当前 pop 的大小
nPop = length(pop);

% 根据新的 nPop 更新后续依赖
for i = 1:nPop
    % 后续的随机选择或其它依赖 nPop 的操作
    i2 = randi([1 nPop]);  % 确保 i2 不会超出新的 pop 大小
    p2 = pop(i2);
end
    
    
   






end