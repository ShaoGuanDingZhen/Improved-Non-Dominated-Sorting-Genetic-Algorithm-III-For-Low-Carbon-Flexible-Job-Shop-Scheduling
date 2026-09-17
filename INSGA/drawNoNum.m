function drawNoNum(pro_m,mac_m)%采用传统的双层解码方式 求最大完工时间makespan 表示最后一个完成工序的时间
    global N H SH TM time;
    e=[0 0 0 0 0];
    number_size=8;
    O_size=8;
    dot_size=6;
    O_up=2.0;
    dot_up=1.6;
    O_down=0.5;
    dot_down=1.0;
     axis([0,350,0,22]);
     plot([0 0],[0 22]);
     hold on;
     plot([0 350],[2 2]);%画横线 x=0-50 y=2-2
     hold on;
     plot([0 350],[6 6]);
     hold on;
     plot([0 350],[10 10]);
     hold on;
     plot([0 350],[14 14]);
      hold on;
     plot([0 350],[18 18]);
      hold on;
     plot([0 350],[22 22]);
%       hold on;
%      plot([0 70],[26 26]);
%       hold on;
%      plot([0 70],[30 30]);
%       hold on;
%      plot([0 70],[34 34]);
%       hold on;
%      plot([0 70],[38 38]);
     hold on;
text(-30, 2, 'M_{6}', 'FontSize', 12, 'FontWeight', 'bold');
text(-30, 6, 'M_{5}', 'FontSize', 12, 'FontWeight', 'bold');
text(-30, 10, 'M_{4}', 'FontSize', 12, 'FontWeight', 'bold');
text(-30, 14, 'M_{3}', 'FontSize', 12, 'FontWeight', 'bold');
text(-30, 18, 'M_{2}', 'FontSize', 12, 'FontWeight', 'bold');
text(-30, 22, 'M_{1}', 'FontSize', 12, 'FontWeight', 'bold');
%       text(-3,26,'M_{4}');
%      text(-3,30,'M_{3}');
%      text(-3,34,'M_{2}');
%       text(-3,38,'M_{1}')
c = {[1 0 0] [0 1 0] [0 0 1] [1 1 0] [0 1 1] [1 0 1] [0.5 0.5 0.5] [0.8 0.1 0.1] [0.1 0.8 0.1] [0.1 0.1 0.8]
     [1 0.5 0] [0 0.5 1] [0.5 0 1] [1 0 0.5] [0.5 1 0] [0.1 0.1 0.5] [0.5 0.1 0.1] [0.1 0.5 0.1] [1 0.8 0.5] [0.5 0.8 1]};

%    c = {
%         [0.000, 0.447, 0.741], % 蓝色
%         [0.850, 0.325, 0.098], % 橙色
%         [0.929, 0.694, 0.125], % 黄色
%         [0.494, 0.184, 0.556], % 紫色
%         [0.466, 0.674, 0.188], % 绿色
%         [0.301, 0.745, 0.933], % 天蓝
%         [0.635, 0.078, 0.184], % 暗红
%         [0.300, 0.300, 0.300], % 暗灰
%         [0.600, 0.600, 0.600], % 亮灰
%         [0.000, 0.000, 0.000]  % 黑色
%     };
    
    finish={};
    start={};
    for i=1:N%初始化完成时间矩阵
        for j=1:H(i)
            finish{i,j}=e;
            start{i,j}=e;
        end
    end
    
    mt=cell(1,N);
    for i=1:N%初始化机器最大完成时间数组
        mt{i}=e;
    end
    
    s1=pro_m;
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%记录过程是否加工完成 完成一次加一
        s2(i)=p(s1(i));%记录加工过程中，工件的次数
    end
    
    for i=1:SH
        t1=s1(i);%记录到当前是那个工件
        t2=s2(i);%记录当前工件是加工到第几次
        mm(i)=mac_m(1,sum(H(1,1:t1-1))+t2);%提取该工序该次加工的机器选择，因为机器码的排列表示该工件第几次加工所选的机器，是一段表示一个工件
    end
    for i=1:SH
        if(s2(i)==1)
         mx=mm(i);
         mx=26-mx*4;
         start{s1(i),s2(i)}= mt{mm(i)};
         if(start{s1(i),s2(i)}(1)==0)
           rectangle('position',[0,mx-1.5,0.5,1.5],'Facecolor',c{s1(i)});
           text(0.5,mx-O_down,'O','FontSize',O_size);
           text(1.2,mx-dot_down, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);
         else
            patch([ start{s1(i),s2(i)}(1) start{s1(i),s2(i)}(2)  start{s1(i),s2(i)}(3)],[mx mx mx-1.5],c{s1(i)});
            patch([ start{s1(i),s2(i)}(3) start{s1(i),s2(i)}(4)  start{s1(i),s2(i)}(5)],[mx-1.5 mx mx ],c{s1(i)});
            text(start{s1(i),s2(i)}(3),mx-O_down,'O','FontSize',O_size);
            text(start{s1(i),s2(i)}(3)+0.8,mx-dot_down, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);
         end
         mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%累计计算每一台机器的加工时间
         finish{s1(i),s2(i)}= mt{mm(i)};%改工件当前工序的完成时间是当前机器的累计时间
         
         patch([ finish{s1(i),s2(i)}(1) finish{s1(i),s2(i)}(2)  finish{s1(i),s2(i)}(3)],[mx mx mx+1.5],c{s1(i)});
         patch([ finish{s1(i),s2(i)}(3) finish{s1(i),s2(i)}(4)  finish{s1(i),s2(i)}(5)],[mx+1.5 mx mx],c{s1(i)});
         
         text(finish{s1(i),s2(i)}(3),mx+O_up,'O','FontSize',O_size);
         text(finish{s1(i),s2(i)}(3)+0.8,mx+dot_up, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);  
        else
            if(~com(mt{mm(i)},finish{s1(i),s2(i)-1}))%如果机器最大完成时间小于该工序上一步完成时间
              mx=mm(i);
              mx=26-mx*4;
         
              start{s1(i),s2(i)}= finish{s1(i),s2(i)-1};
              patch([ start{s1(i),s2(i)}(1) start{s1(i),s2(i)}(2)  start{s1(i),s2(i)}(3)],[mx mx mx-1.5],c{s1(i)});
            patch([ start{s1(i),s2(i)}(3) start{s1(i),s2(i)}(4)  start{s1(i),s2(i)}(5)],[mx-1.5 mx mx ],c{s1(i)});
              
              text(start{s1(i),s2(i)}(3),mx-O_down,'O','FontSize',O_size);
              text(start{s1(i),s2(i)}(3)+0.8,mx-dot_down, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);
                 
              mt{mm(i)}= finish{s1(i),s2(i)-1}+time{s1(i),s2(i),mm(i)};%一定是去上一步完成时间和该机器结束加工时间的最大者
              finish{s1(i),s2(i)}= mt{mm(i)};
              
             patch([ finish{s1(i),s2(i)}(1) finish{s1(i),s2(i)}(2)  finish{s1(i),s2(i)}(3)],[mx mx mx+1.5],c{s1(i)});
         patch([ finish{s1(i),s2(i)}(3) finish{s1(i),s2(i)}(4)  finish{s1(i),s2(i)}(5)],[mx+1.5 mx mx],c{s1(i)});

              text(finish{s1(i),s2(i)}(3),mx+O_up,'O','FontSize',O_size);
              text(finish{s1(i),s2(i)}(3)+0.8,mx+dot_up, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);  
            
            else%如果机器完成时间大于等于该工件上一个工序的完成时间
              mx=mm(i);
              mx=26-mx*4;
              start{s1(i),s2(i)}= mt{mm(i)};
              
             patch([ start{s1(i),s2(i)}(1) start{s1(i),s2(i)}(2)  start{s1(i),s2(i)}(3)],[mx mx mx-1.5],c{s1(i)});
            patch([ start{s1(i),s2(i)}(3) start{s1(i),s2(i)}(4)  start{s1(i),s2(i)}(5)],[mx-1.5 mx mx ],c{s1(i)});              
            text(start{s1(i),s2(i)}(3),mx-O_down,'O','FontSize',O_size);
              text(start{s1(i),s2(i)}(3)+0.8,mx-dot_down, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);

              mt{mm(i)}= mt{mm(i)}+time{s1(i),s2(i),mm(i)};
              finish{s1(i),s2(i)}= mt{mm(i)};
              
            patch([ finish{s1(i),s2(i)}(1) finish{s1(i),s2(i)}(2)  finish{s1(i),s2(i)}(3)],[mx mx mx+1.5],c{s1(i)});
            patch([ finish{s1(i),s2(i)}(3) finish{s1(i),s2(i)}(4)  finish{s1(i),s2(i)}(5)],[mx+1.5 mx mx],c{s1(i)});
              text(finish{s1(i),s2(i)}(3),mx+O_up,'O','FontSize',O_size);
              text(finish{s1(i),s2(i)}(3)+0.8,mx+dot_up, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);  
            end
        end
    end
    
%     fit1=mt{1};
%     for i=2:TM
%         if(com(mt{i},fit1))%如果机器i的最大完工时间大于fit则更新
%             fit1=mt{i};
%         end
%     end
%set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w');
set(gca, 'ytick', []);  % 清空Y轴刻度
alpha(0.6)
hold off
end