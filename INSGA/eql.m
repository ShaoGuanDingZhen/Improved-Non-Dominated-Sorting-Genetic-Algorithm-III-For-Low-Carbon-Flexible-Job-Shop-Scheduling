function [c]=eql(a,b)
c=1;
    for i=1:5
        if(a(i)~=b(i))
            c=0;
        end
    end
end