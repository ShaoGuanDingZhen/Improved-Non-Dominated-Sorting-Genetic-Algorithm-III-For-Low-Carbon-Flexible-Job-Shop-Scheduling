function [candidateM]=selectMachine(mt)%��������������� ������С�Ļ������� ���� �����Ǵ��ڵ���1
    L=size(mt,2);
    candidateM=[];
    f=mt{1};
    index=1;
    for i=2:L%���ҵ���С��
        if (com(f,mt{i}))
            f=mt{i};
            index=i;
        end
    end
    candidateM=[candidateM index];%����С������ֵ��������
    f=mt{index};
    for i=1:L%���������ظ���
        if(i==index)
            continue;
        elseif(eql(f,mt{i}))
            candidateM=[candidateM i];
        end  
    end
end