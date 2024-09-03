
function b=Dominates(x,y)

    if isstruct(x)
        x=x.Cost;
    end

    if isstruct(y)
        y=y.Cost;
    end

    b=all(x<=y) && any(x<y);

end
% 
% function b = Dominates(x, y)
%     % 如果输入是结构体，提取其成本向量
%     if isstruct(x)
%         x = x.Cost;
%     end
% 
%     if isstruct(y)
%         y = y.Cost;
%     end
% 
%     % 设置阈值来定义何为 "接近相同"
%     threshold = 40; % F1的变化为773，5%大约是38.65，四舍五入到40
% 
%     % F1 主导的支配定义
%     if abs(x(1) - y(1)) <= threshold  % 当 F1 值非常接近时
%         % F1 相近时比较 F2
%         b = (x(2) < y(2));
%     else
%         % 否则只比较 F1
%         b = (x(1) < y(1));
%     end
% end