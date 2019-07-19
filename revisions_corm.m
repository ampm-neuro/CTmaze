load('revisions_corm_explain');

vects_learn = mean(cat(3,hold2_1_1stem(:,sorting_vector_learning),hold2_2_1stem(:,sorting_vector_learning)),3);

[correlation_matrix21, ~, ~, ~, incl_c_21] = c_mtx(hold2_1_1stem, hold2_2_1stem, sorting_vector_learning, 50, 1);
vects_learn_21 = zscore_mtx(vects_learn(:,incl_c_21))'; vects_learn_21(isinf(vects_learn_21)) = nan;
%figure; imagesc(vects_learn_21)
%set(gca,'TickLength',[0, 0]); caxis([-1.5 3]); colorbar; title 21
%var_name = 'rm_21.pdf'; 
%print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\Corm\' var_name], '-dpdf', '-painters', '-bestfit')

[correlation_matrix22, ~, ~, ~, incl_c_22] = c_mtx(hold2_1_1stem, hold2_2_1stem, sorting_vector_learning, 50, 2);
vects_learn_22 = zscore_mtx(vects_learn(:,incl_c_22))'; vects_learn_22(isinf(vects_learn_22)) = nan;
%figure; imagesc(vects_learn_22)
%set(gca,'TickLength',[0, 0]); caxis([-1.5 3]); colorbar; title 22
%var_name = 'rm_22.pdf'; 
%print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\Corm\' var_name], '-dpdf', '-painters', '-bestfit')

[correlation_matrix23, ~, ~, ~, incl_c_23] = c_mtx(hold2_1_1stem, hold2_2_1stem, sorting_vector_learning, 50, 3);
vects_learn_23 = zscore_mtx(vects_learn(:,incl_c_23))'; vects_learn_23(isinf(vects_learn_23)) = nan;
%figure; imagesc(vects_learn_23)
%set(gca,'TickLength',[0, 0]); caxis([-1.5 3]); colorbar; title 23
%var_name = 'rm_23.pdf'; 
%print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\Corm\' var_name], '-dpdf', '-painters', '-bestfit')


vects_ot = mean(cat(3,hold4_1_1stem(:,sorting_vector_ot),hold4_2_1stem(:,sorting_vector_ot)),3);

[correlation_matrix40, ~, ~, ~, incl_c_43] = c_mtx(hold4_1_1stem, hold4_2_1stem, sorting_vector_ot, 50, 3);
vects_learn_43 = zscore_mtx(vects_learn(:,incl_c_43))'; vects_learn_43(isinf(vects_learn_43)) = nan;
%figure; imagesc(vects_learn_43)
%set(gca,'TickLength',[0, 0]); caxis([-1.5 3]); colorbar; title 43
%var_name = 'rm_43.pdf'; 
%print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\Corm\' var_name], '-dpdf', '-painters', '-bestfit')

%{
figure;hold on
colors = get(gca,'ColorOrder');
plot(nanmean(vects_learn_21), '-', 'color', colors(1,:), 'linewidth', 2)
    plot(nanmean(vects_learn_21)+nanstd(vects_learn_21)./sqrt(sum(~isnan(vects_learn_21))), '-', 'color', colors(1,:))
    plot(nanmean(vects_learn_21)-nanstd(vects_learn_21)./sqrt(sum(~isnan(vects_learn_21))), '-', 'color', colors(1,:))
plot(nanmean(vects_learn_22), '-', 'color', colors(2,:), 'linewidth', 2)
    plot(nanmean(vects_learn_22)+nanstd(vects_learn_22)./sqrt(sum(~isnan(vects_learn_22))), '-', 'color', colors(2,:))
    plot(nanmean(vects_learn_22)-nanstd(vects_learn_22)./sqrt(sum(~isnan(vects_learn_22))), '-', 'color', colors(2,:))
plot(nanmean(vects_learn_23), '-', 'color', colors(3,:), 'linewidth', 2)
    plot(nanmean(vects_learn_23)+nanstd(vects_learn_23)./sqrt(sum(~isnan(vects_learn_23))), '-', 'color', colors(3,:))
    plot(nanmean(vects_learn_23)-nanstd(vects_learn_23)./sqrt(sum(~isnan(vects_learn_23))), '-', 'color', colors(3,:))
plot(nanmean(vects_learn_43), '-', 'color', colors(4,:), 'linewidth', 2)
    plot(nanmean(vects_learn_43)+nanstd(vects_learn_43)./sqrt(sum(~isnan(vects_learn_43))), '-', 'color', colors(4,:))
    plot(nanmean(vects_learn_43)-nanstd(vects_learn_43)./sqrt(sum(~isnan(vects_learn_43))), '-', 'color', colors(4,:))
    
plot(repmat([25;62; 75;100;126;165],1,2), ylim, 'k-')
set(gca,'TickLength',[0, 0]);
%}

figure; cod21 = corm_offdiag(correlation_matrix21); title 21
figure; cod22 = corm_offdiag(correlation_matrix22); title 22
figure; cod23 = corm_offdiag(correlation_matrix23); title 23
figure; cod40 = corm_offdiag(correlation_matrix40); title 40
error_by_training_stage = [cod21 cod22 cod23 cod40]

