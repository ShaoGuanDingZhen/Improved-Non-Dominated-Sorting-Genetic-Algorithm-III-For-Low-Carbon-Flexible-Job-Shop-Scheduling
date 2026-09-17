function c= com(a,b) %比较两个三角模糊数，大于的时候返回true.

CAL=a(3)-((a(5)-a(4))*(a(5)+2*a(4)-a(2)-2*a(3))/(6*(a(4)-a(2))));
CAU=a(3)+((a(5)+a(2)-2*a(3))*(a(5)+a(4)-2*a(2))/(6*(a(4)-a(2))));

CA=(CAL+CAU)/2;

CBL=b(3)-((b(5)-b(4))*(b(5)+2*b(4)-b(2)-2*b(3))/(6*(b(4)-b(2))));
CBU=b(3)+((b(5)+b(2)-2*b(3))*(b(5)+b(4)-2*b(2))/(6*(b(4)-b(2))));

CB=(CBL+CBU)/2;

if(CA>CB)
    c=1;
else
    if(CA<CB)
      c=0;
    else
        if (a(3)>b(3))
            c=1;
        else
            if(a(3)<b(3))
                c=0;
            else
                if((a(5)-a(1))>(b(5)-b(1)))
                    c=1;
                else
                    c=0;
                end
            end
        end
    end
end
end

