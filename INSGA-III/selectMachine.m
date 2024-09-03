function [candidateM]=selectMachine(mt)%输入机器负载向量 返回最小的机器负载 索引 可能是大于等于1
    L=size(mt,2);
    candidateM=[];
    f=mt{1};
    index=1;
    for i=2:L%先找到最小的
        if (com(f,mt{i}))
            f=mt{i};
            index=i;
        end
    end
    candidateM=[candidateM index];%将最小的索引值并入数组
    f=mt{index};
    for i=1:L%再找其中重复的
        if(i==index)
            continue;
        elseif(eql(f,mt{i}))
            candidateM=[candidateM i];
        end  
    end
end