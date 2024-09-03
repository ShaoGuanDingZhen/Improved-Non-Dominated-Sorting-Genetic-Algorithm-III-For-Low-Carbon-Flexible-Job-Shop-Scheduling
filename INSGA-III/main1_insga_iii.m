
clc;
clear;
close all;
tic

%% 此函数用于计算改进的INSGA-3优化程序


%% 问题读入

DataPath='..\T2FJSP_instances\';
J={20,30,40,50,80,100};

M1={6,7,8,9,10};

name='Type2FJSP';line='_';txt='.txt';J_name='J';M_name='M';

[~,m]=size(J);[~,n]=size(M1);k=1;
for i=1:m
    for j=1:n
        RealPath{k}=[DataPath,name,line,num2str(J{i}),line,num2str(M1{j}),txt];
        ResultPath{k}=[J_name,num2str(J{i}),M_name,num2str(M1{j})];
        k=k+1;
    end
end
%RealPath=[DataPath,name,line,num2str(J{1}),line,num2str(M{1}),txt];

global  N H SH NM ps M TM time 
global F1 F2 F3 F4 F5

CostFunction = @(x) finalvalue1(x);  % Cost Function
nObj = 2;


%% NSGA-III Parameters

% Generating Reference Points
ps=100;%种群大小;
nDivision =100;
Zr = GenerateReferencePoints(nObj, nDivision);
MaxIt = 200;  % Maximum Number of Iterations
nPop = ps;  % Population Size
pCrossover = 0.8;       % Crossover Percentage
pMutation = 0.8;       % Mutation Percentage



% 算法参数


N_file=1;

best_solu_p_chrom=cell(N_file,1);
best_solu_m_chrom=cell(N_file,1);

% 
% Score_IGD= zeros(N_file,1);
Score_HV= zeros(N_file,1);
% Score_GD= zeros(N_file,1);
% Score_spacing= zeros(N_file,1);   % spacing指标


for File=1:N_file   % 处理文件数
    clc
    disp('当前处理文件编号为：')
    disp(File)
    
    b_obj=[];
    % 待处理文件
    [N,TM,H,NM,M,SH,time]=DataRead(RealPath{File}); % 读入实际问题
    
    % 结果写入
    % respath='result\';
    % tmp6='\';
    % respath=[respath,ResultPath{File},tmp6];
    % %清除无关变量
    % clear tmp6
    % a=['mkdir ' respath];%创立写结果的文件夹
    % system(a);%利用Windows命令行命令执行dos命令
    % fprintf('%s %s\r\n','Calculating ',RealPath{File});
    

    [F1,F]=INSGA_III(File,nPop,Zr,ps,MaxIt,pCrossover,CostFunction,pMutation);


    
  
    %% Results
    

  
   
    disp(['Final Iteration: Number of F1 Members = ' num2str(numel(F1))]);
    disp('Optimization Terminated.');
    

    clc
  
    for i=1:length(F{1, 1})
        aa=F1(i).Position(1:length(F1(i).Position)/2);   % 最优解存储在 best_solu_p_chrom
        best_solu_p_chrom{File}(i,:)=aa;
        bb=F1(i).Position(length(F1(i).Position)/2+1:end);  % 最优解存储在 best_solu_m_chrom
        best_solu_m_chrom{File}(i,:)=bb;
        b_obj(i,1)=F1(i).Cost(1);
        b_obj(i,2)=F1(i).Cost(2);
    end
    
    [best_obj{File},best_solu_p_chrom{File},best_solu_m_chrom{File}]=unique_solu(b_obj, best_solu_p_chrom{File},best_solu_m_chrom{File});  % 第一级帕累托前沿存储在best_obj
    

%     best_idx=F{1}(idx);
    

    % 确定帕累托前沿
    fit_data=best_obj{File};
    x_fit=fit_data(:,1);
    y_fit=fit_data(:,2);
    x_pre=x_fit(1):1:x_fit(end);
    y_pre=interp1(x_fit,y_fit,x_pre,'makima');
    pre_prato{File}=[x_pre',y_pre'];
    

    
%     Score_IGD(File)=IGD([x_fit,y_fit],pre_prato{File});
    Score_HV(File)=HV([x_fit,y_fit],pre_prato{File});
%     Score_GD(File)=GD([x_fit,y_fit],pre_prato{File});
%     Score_spacing(File) = Spacing([x_fit,y_fit]);   % spacing指标
    
    
    disp('当前第一级非劣解个数为：')
    disp(length(best_obj{File}))
    
    disp('最优解存储于best_solu_p_chrom及best_solu_m_chrom')
    
    disp('当前第一级非劣解为:')
    disp([x_fit,y_fit])
end


%%
for File=1:N_file
    for j=1:size(best_solu_p_chrom{File},1)
       figure((File-1)*size(best_solu_p_chrom{File},1) + j); % 为每个图形创建一个唯一编号
       drawNoNum(best_solu_p_chrom{File}(j,:),best_solu_m_chrom{File}(j,:));
       [bfitness{File,j}(1,:),bfitness{File,j}(2,:)]=fit(best_solu_p_chrom{File}(j,:),best_solu_m_chrom{File}(j,:));  % 模糊加工时间集F1及F2
    end
end



% for File=1:N_file
%     figure(i+1)
%     for j=1:size(best_solu_p_chrom{File},1)
%        subplot(3,3,j) 
%        drawNoNum(best_solu_p_chrom{File}(j,:),best_solu_m_chrom{File}(j,:));
%        [bfitness{File,j}(1,:),bfitness{File,j}(2,:)]=fit(best_solu_p_chrom{File}(j,:),best_solu_m_chrom{File}(j,:));  % 模糊加工时间集F1及F2
%     end
% end


beep
toc






