function drawNoNum(pro_m,mac_m)%���ô�ͳ��˫����뷽ʽ ������깤ʱ��makespan ��ʾ���һ����ɹ����ʱ��
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
     plot([0 350],[2 2]);%������ x=0-50 y=2-2
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
%         [0.000, 0.447, 0.741], % ��ɫ
%         [0.850, 0.325, 0.098], % ��ɫ
%         [0.929, 0.694, 0.125], % ��ɫ
%         [0.494, 0.184, 0.556], % ��ɫ
%         [0.466, 0.674, 0.188], % ��ɫ
%         [0.301, 0.745, 0.933], % ����
%         [0.635, 0.078, 0.184], % ����
%         [0.300, 0.300, 0.300], % ����
%         [0.600, 0.600, 0.600], % ����
%         [0.000, 0.000, 0.000]  % ��ɫ
%     };
    
    finish={};
    start={};
    for i=1:N%��ʼ�����ʱ�����
        for j=1:H(i)
            finish{i,j}=e;
            start{i,j}=e;
        end
    end
    
    mt=cell(1,N);
    for i=1:N%��ʼ������������ʱ������
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
         mt{mm(i)}=mt{mm(i)}+time{s1(i),s2(i),mm(i)};%�ۼƼ���ÿһ̨�����ļӹ�ʱ��
         finish{s1(i),s2(i)}= mt{mm(i)};%�Ĺ�����ǰ��������ʱ���ǵ�ǰ�������ۼ�ʱ��
         
         patch([ finish{s1(i),s2(i)}(1) finish{s1(i),s2(i)}(2)  finish{s1(i),s2(i)}(3)],[mx mx mx+1.5],c{s1(i)});
         patch([ finish{s1(i),s2(i)}(3) finish{s1(i),s2(i)}(4)  finish{s1(i),s2(i)}(5)],[mx+1.5 mx mx],c{s1(i)});
         
         text(finish{s1(i),s2(i)}(3),mx+O_up,'O','FontSize',O_size);
         text(finish{s1(i),s2(i)}(3)+0.8,mx+dot_up, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);  
        else
            if(~com(mt{mm(i)},finish{s1(i),s2(i)-1}))%�������������ʱ��С�ڸù�����һ�����ʱ��
              mx=mm(i);
              mx=26-mx*4;
         
              start{s1(i),s2(i)}= finish{s1(i),s2(i)-1};
              patch([ start{s1(i),s2(i)}(1) start{s1(i),s2(i)}(2)  start{s1(i),s2(i)}(3)],[mx mx mx-1.5],c{s1(i)});
            patch([ start{s1(i),s2(i)}(3) start{s1(i),s2(i)}(4)  start{s1(i),s2(i)}(5)],[mx-1.5 mx mx ],c{s1(i)});
              
              text(start{s1(i),s2(i)}(3),mx-O_down,'O','FontSize',O_size);
              text(start{s1(i),s2(i)}(3)+0.8,mx-dot_down, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);
                 
              mt{mm(i)}= finish{s1(i),s2(i)-1}+time{s1(i),s2(i),mm(i)};%һ����ȥ��һ�����ʱ��͸û��������ӹ�ʱ��������
              finish{s1(i),s2(i)}= mt{mm(i)};
              
             patch([ finish{s1(i),s2(i)}(1) finish{s1(i),s2(i)}(2)  finish{s1(i),s2(i)}(3)],[mx mx mx+1.5],c{s1(i)});
         patch([ finish{s1(i),s2(i)}(3) finish{s1(i),s2(i)}(4)  finish{s1(i),s2(i)}(5)],[mx+1.5 mx mx],c{s1(i)});

              text(finish{s1(i),s2(i)}(3),mx+O_up,'O','FontSize',O_size);
              text(finish{s1(i),s2(i)}(3)+0.8,mx+dot_up, strcat(int2str(s1(i)),strcat('.',int2str(s2(i)))),'FontSize',dot_size);  
            
            else%����������ʱ����ڵ��ڸù�����һ����������ʱ��
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
%         if(com(mt{i},fit1))%�������i������깤ʱ�����fit�����
%             fit1=mt{i};
%         end
%     end
%set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w');
set(gca, 'ytick', []);  % ���Y��̶�
alpha(0.6)
hold off
end