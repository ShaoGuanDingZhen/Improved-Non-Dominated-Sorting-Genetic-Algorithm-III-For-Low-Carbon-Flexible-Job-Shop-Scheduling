function [fit1,fit2]=fit(pro_m,mac_m)%采用传统的双层解码方式 求最大完工时间makespan 表示最后一个完成工序的时间
    global N H SH TM time;
    
    Ep=0.5;%加工功率 500kw每s 0.5Mw
    Es=0.04;%等待功率 40kw每s
    Et=0.06;%开机关机功率 60kw每s
    
    e=[0 0 0 0 0];
    ARRY=ones(1,5);
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
    total=e;
    Idletime=e;%总的工序等待时间
    for i=1:SH
        if(s2(i)==1)
         mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%累计计算每一台机器的加工时间
         finish{s1(i),s2(i)}= mt{mm(i)};%改工件当前工序的完成时间是当前机器的累计时间
         total=total+time{s1(i),s2(i),mm(i)};%总的机器负载
        else
            if(~com(mt{mm(i)},finish{s1(i),s2(i)-1}))%如果机器最大完成时间小于该工序上一步完成时间
              Idletime=Idletime+finish{s1(i),s2(i)-1}-mt{mm(i)};%这个时候机器出现空闲时间，则需要消耗功率。
              mt{mm(i)}= finish{s1(i),s2(i)-1}+time{s1(i),s2(i),mm(i)};%一定是去上一步完成时间和该机器结束加工时间的最大者      
              finish{s1(i),s2(i)}= mt{mm(i)};
              total=total+time{s1(i),s2(i),mm(i)};
            else%如果机器完成时间大于等于该工件上一个工序的完成时间
              mt{mm(i)}= mt{mm(i)}+time{s1(i),s2(i),mm(i)};
              finish{s1(i),s2(i)}= mt{mm(i)};
              total=total+time{s1(i),s2(i),mm(i)};
            end
        end
    end
    
    fit1=mt{1};
    for i=2:TM
        if(com(mt{i},fit1))%如果机器i的最大完工时间大于fit则更新
            fit1=mt{i};
        end
    end
    fit2=total.*Ep+Idletime.*Es+Et.*ARRY;
%     fit={fit1 fit2};
    %把完成矩阵的每一个工件的最后一个工序的时间加起来 就是总的工序完成时间total flow time
%     fit2=e;
%     for i=1:N 
%        fit2=fit2+finish{i,H(i)};
%     end
% 两个适应值函数可以放在一起求减少矩阵检索的时间消耗
