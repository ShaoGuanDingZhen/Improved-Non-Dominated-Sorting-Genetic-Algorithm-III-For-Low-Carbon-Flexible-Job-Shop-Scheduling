function [fit1,fit2]=fit(pro_m,mac_m)%���ô�ͳ��˫����뷽ʽ ������깤ʱ��makespan ��ʾ���һ����ɹ����ʱ��
    global N H SH TM time;
    
    Ep=0.5;%�ӹ����� 500kwÿs 0.5Mw
    Es=0.04;%�ȴ����� 40kwÿs
    Et=0.06;%�����ػ����� 60kwÿs
    
    e=[0 0 0 0 0];
    ARRY=ones(1,5);
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
    
    s1=pro_m;
    s2=zeros(1,SH);
    p=zeros(1,N);
    
    for i=1:SH
        p(s1(i))=p(s1(i))+1;%��¼�����Ƿ�ӹ���� ���һ�μ�һ
        s2(i)=p(s1(i));%��¼�ӹ������У������Ĵ���
    end
    
    for i=1:SH
        t1=s1(i);%��¼����ǰ���Ǹ�����
        t2=s2(i);%��¼��ǰ�����Ǽӹ����ڼ���
        mm(i)=mac_m(1,sum(H(1,1:t1-1))+t2);%��ȡ�ù���ôμӹ��Ļ���ѡ����Ϊ����������б�ʾ�ù����ڼ��μӹ���ѡ�Ļ�������һ�α�ʾһ������
    end
    total=e;
    Idletime=e;%�ܵĹ���ȴ�ʱ��
    for i=1:SH
        if(s2(i)==1)
         mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%�ۼƼ���ÿһ̨�����ļӹ�ʱ��
         finish{s1(i),s2(i)}= mt{mm(i)};%�Ĺ�����ǰ��������ʱ���ǵ�ǰ�������ۼ�ʱ��
         total=total+time{s1(i),s2(i),mm(i)};%�ܵĻ�������
        else
            if(~com(mt{mm(i)},finish{s1(i),s2(i)-1}))%�������������ʱ��С�ڸù�����һ�����ʱ��
              Idletime=Idletime+finish{s1(i),s2(i)-1}-mt{mm(i)};%���ʱ��������ֿ���ʱ�䣬����Ҫ���Ĺ��ʡ�
              mt{mm(i)}= finish{s1(i),s2(i)-1}+time{s1(i),s2(i),mm(i)};%һ����ȥ��һ�����ʱ��͸û��������ӹ�ʱ��������      
              finish{s1(i),s2(i)}= mt{mm(i)};
              total=total+time{s1(i),s2(i),mm(i)};
            else%����������ʱ����ڵ��ڸù�����һ����������ʱ��
              mt{mm(i)}= mt{mm(i)}+time{s1(i),s2(i),mm(i)};
              finish{s1(i),s2(i)}= mt{mm(i)};
              total=total+time{s1(i),s2(i),mm(i)};
            end
        end
    end
    
    fit1=mt{1};
    for i=2:TM
        if(com(mt{i},fit1))%�������i������깤ʱ�����fit�����
            fit1=mt{i};
        end
    end
    fit2=total.*Ep+Idletime.*Es+Et.*ARRY;
%     fit={fit1 fit2};
    %����ɾ����ÿһ�����������һ�������ʱ������� �����ܵĹ������ʱ��total flow time
%     fit2=e;
%     for i=1:N 
%        fit2=fit2+finish{i,H(i)};
%     end
% ������Ӧֵ�������Է���һ������پ��������ʱ������
