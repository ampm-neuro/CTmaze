%compute miller info score on every cell after linearizing track and
%excluding atypical behavior

%get trial-by-trial binned rates
%
[all_smoothed_rates_21, all_dwell_times_21] = all_nitzlines(2.1);
[all_smoothed_rates_22, all_dwell_times_22] = all_nitzlines(2.2);
[all_smoothed_rates_23, all_dwell_times_23] = all_nitzlines(2.3);
[all_smoothed_rates_40, all_dwell_times_40] = all_nitzlines(4);
%}


%calculate MIS
%
[mis_score_21, good_var_21, bad_var_21] = rev_mis_fn(all_smoothed_rates_21);
    disp(['Early learning passed ' num2str(100*sum(~isnan(mis_score_21))/length(mis_score_21)) ' percent of cells'])
[mis_score_22, good_var_22, bad_var_22] = rev_mis_fn(all_smoothed_rates_22);
    disp(['Middle learning passed ' num2str(100*sum(~isnan(mis_score_22))/length(mis_score_22)) ' percent of cells'])
[mis_score_23, good_var_23, bad_var_23] = rev_mis_fn(all_smoothed_rates_23);
    disp(['Late learning passed ' num2str(100*sum(~isnan(mis_score_23))/length(mis_score_23)) ' percent of cells'])
[mis_score_40, good_var_40, bad_var_40] = rev_mis_fn(all_smoothed_rates_40);
    disp(['Overtraining passed ' num2str(100*sum(~isnan(mis_score_40))/length(mis_score_40)) ' percent of cells'])
%}
    
%calculate positional information content
[mean_pos_info_21, pos_infos_21] = pos_info_shell(all_smoothed_rates_21, all_dwell_times_21);
    disp(['Early learning passed ' num2str(100*sum(~isnan(mean_pos_info_21))/length(mean_pos_info_21)) ' percent of cells'])
[mean_pos_info_22, pos_infos_22] = pos_info_shell(all_smoothed_rates_22, all_dwell_times_22);
    disp(['Middle learning passed ' num2str(100*sum(~isnan(mean_pos_info_22))/length(mean_pos_info_22)) ' percent of cells'])
[mean_pos_info_23, pos_infos_23] = pos_info_shell(all_smoothed_rates_23, all_dwell_times_23);
    disp(['Late learning passed ' num2str(100*sum(~isnan(mean_pos_info_23))/length(mean_pos_info_23)) ' percent of cells'])
[mean_pos_info_40, pos_infos_40] = pos_info_shell(all_smoothed_rates_40, all_dwell_times_40);
    disp(['Overtraining passed ' num2str(100*sum(~isnan(mean_pos_info_40))/length(mean_pos_info_40)) ' percent of cells'])

%load for plot
celle_mis{1} = mis_score_21(~isnan(mis_score_21));
celle_mis{2} = mis_score_22(~isnan(mis_score_22));
celle_mis{3} = mis_score_23(~isnan(mis_score_23));
celle_mis{4} = mis_score_40(~isnan(mis_score_40));   
figure; errorbar_barplot(celle_mis)
ylim([-1 1])
[obs_mse, shuf_mses] = oneway_anova_shuffle(celle_mis, 10000); 
p = sum(shuf_mses>=obs_mse)/length(shuf_mses)
title(['MIS; ' num2str(p)])
%hold on; boxplot([celle_mis{1}; celle_mis{2}; celle_mis{3}; celle_mis{4}], [ones(size(celle_mis{1})); ones(size(celle_mis{2})).*2; ones(size(celle_mis{3})).*3; ones(size(celle_mis{4})).*4])


%load for plot
celle_pi{1} = mean_pos_info_21(~isnan(mean_pos_info_21));
celle_pi{2} = mean_pos_info_22(~isnan(mean_pos_info_22));
celle_pi{3} = mean_pos_info_23(~isnan(mean_pos_info_23));
celle_pi{4} = mean_pos_info_40(~isnan(mean_pos_info_40));   
figure; errorbar_barplot(celle_pi)
[obs_mse, shuf_mses] = oneway_anova_shuffle(celle_pi, 10000); 
p = sum(shuf_mses>=obs_mse)/length(shuf_mses)
title(['PosInfo; ' num2str(p)])
%hold on; boxplot([celle_pi{1}; celle_pi{2}; celle_pi{3}; celle_pi{4}], [ones(size(celle_pi{1})); ones(size(celle_pi{2})).*2; ones(size(celle_pi{3})).*3; ones(size(celle_pi{4})).*4])





%{
celle_goodvar{1} = good_var_21(~isnan(good_var_21));
celle_goodvar{2} = good_var_22(~isnan(good_var_22));
celle_goodvar{3} = good_var_23(~isnan(good_var_23));
celle_goodvar{4} = good_var_40(~isnan(good_var_40));
[obs_mse, shuf_mses] = oneway_anova_shuffle(celle_goodvar, 10000);
p = sum(shuf_mses>=obs_mse)/length(shuf_mses);
title(['goodvar; ' num2str(p)])
hold on; boxplot([celle_goodvar{1}; celle_goodvar{2}; celle_goodvar{3}; celle_goodvar{4}], [ones(size(celle_goodvar{1})); ones(size(celle_goodvar{2})).*2; ones(size(celle_goodvar{3})).*3; ones(size(celle_goodvar{4})).*4])


celle_badvar{1} = bad_var_21(~isnan(bad_var_21));
celle_badvar{2} = bad_var_22(~isnan(bad_var_22));
celle_badvar{3} = bad_var_23(~isnan(bad_var_23));
celle_badvar{4} = bad_var_40(~isnan(bad_var_40));
[obs_mse, shuf_mses] = oneway_anova_shuffle(celle_badvar, 10000);
p = sum(shuf_mses>=obs_mse)/length(shuf_mses)
title(['badvar; ' num2str(p)])
hold on; boxplot([celle_badvar{1}; celle_badvar{2}; celle_badvar{3}; celle_badvar{4}], [ones(size(celle_badvar{1})); ones(size(celle_badvar{2})).*2; ones(size(celle_badvar{3})).*3; ones(size(celle_badvar{4})).*4])

%}


%calculate Info Content
%
[info_scores_21, mean_FRs_21] = rev_is_fn(all_smoothed_rates_21, all_dwell_times_21);
    disp(['Early learning passed ' num2str(100*sum(~isnan(info_scores_21))/length(info_scores_21)) ' percent of cells'])
[info_scores_22, mean_FRs_22] = rev_is_fn(all_smoothed_rates_22, all_dwell_times_22);
    disp(['Middle learning passed ' num2str(100*sum(~isnan(info_scores_22))/length(info_scores_22)) ' percent of cells'])
[info_scores_23, mean_FRs_23] = rev_is_fn(all_smoothed_rates_23, all_dwell_times_23);
    disp(['Late learning passed ' num2str(100*sum(~isnan(info_scores_23))/length(info_scores_23)) ' percent of cells'])
[info_scores_40, mean_FRs_40] = rev_is_fn(all_smoothed_rates_40, all_dwell_times_40);
    disp(['Overtraining passed ' num2str(100*sum(~isnan(info_scores_40))/length(info_scores_40)) ' percent of cells'])

%load for plot info content
celle_ic{1} = info_scores_21(~isnan(info_scores_21));
celle_ic{2} = info_scores_22(~isnan(info_scores_22));
celle_ic{3} = info_scores_23(~isnan(info_scores_23));
celle_ic{4} = info_scores_40(~isnan(info_scores_40));
figure; errorbar_plot(celle_ic)
[obs_mse, shuf_mses] = oneway_anova_shuffle(celle_ic, 10000); 
p = sum(shuf_mses>=obs_mse)/length(shuf_mses)
title(['InfoContent; ' num2str(p)])
%hold on; boxplot([celle_ic{1}; celle_ic{2}; celle_ic{3}; celle_ic{4}], [ones(size(celle_ic{1})); ones(size(celle_ic{2})).*2; ones(size(celle_ic{3})).*3; ones(size(celle_ic{4})).*4])

%load for plot mean firing rate
%{
celle_fr{1} = mean_FRs_21(~isnan(mean_FRs_21));
celle_fr{2} = mean_FRs_22(~isnan(mean_FRs_22));
celle_fr{3} = mean_FRs_23(~isnan(mean_FRs_23));
celle_fr{4} = mean_FRs_40(~isnan(mean_FRs_40));  
figure; errorbar_plot(celle_fr)
[obs_mse, shuf_mses] = oneway_anova_shuffle(celle_fr, 10000); 
p = sum(shuf_mses>=obs_mse)/length(shuf_mses)
title(['FR; ' num2str(p)])
%hold on; boxplot([celle_fr{1}; celle_fr{2}; celle_fr{3}; celle_fr{4}],[ones(size(celle_fr{1})); ones(size(celle_fr{2})).*2; ones(size(celle_fr{3})).*3; ones(size(celle_fr{4})).*4])
%}


%load for plot bits/second
%{
celle_ic_rate{1} = celle_pi{1}.*celle_fr{1};
celle_ic_rate{2} = celle_pi{2}.*celle_fr{2};
celle_ic_rate{3} = celle_pi{3}.*celle_fr{3};
celle_ic_rate{4} = celle_pi{4}.*celle_fr{4};   
[obs_mse, shuf_mses] = oneway_anova_shuffle(celle_ic_rate, 10000); 
p = sum(shuf_mses>=obs_mse)/length(shuf_mses)
%}
%[a b c d] = ttest2(celle{1}, celle{2})

%}

