function  [uni_obj,best_solu_p_chrom1,best_solu_m_chrom1]=unique_solu(best_obj,best_solu_p_chrom,best_solu_m_chrom)

aa=sum(best_obj,2);
[~,idx1]=unique(aa);
best_obj1=best_obj(idx1,:);
best_solu_p_chrom1=best_solu_p_chrom(idx1,:);
best_solu_m_chrom1=best_solu_m_chrom(idx1,:);

[~,idx2]=sort(best_obj1(:,1));
uni_obj=best_obj1(idx2,:);
best_solu_p_chrom1=best_solu_p_chrom1(idx2,:);
best_solu_m_chrom1=best_solu_m_chrom1(idx2,:);