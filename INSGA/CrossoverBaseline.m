function [child1,child2] = CrossoverBaseline(parent1,parent2)
%CROSSOVERBASELINE Baseline operator used only when hybrid crossover is off.
%   Operation sequences are inherited intact; machine genes are inherited
%   independently from either parent. This preserves feasibility and removes
%   the proposed POX operation-level exchange.

    half = numel(parent1)/2;
    op1 = parent1(1:half); op2 = parent2(1:half);
    mc1 = parent1(half+1:end); mc2 = parent2(half+1:end);
    mask = rand(1,half) < 0.5;
    child1 = [op1, mc1];
    child2 = [op2, mc2];
    child1(half+find(mask)) = mc2(mask);
    child2(half+find(mask)) = mc1(mask);
end
