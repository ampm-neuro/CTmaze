%check whether ALL_ballistic_times is set to just population days or all
%cells!

bins=100; min_visit=3; redundant =0; rwd_on= 0; half = 0;

[rate_matrices_pop21, fig_eight_matrix_pop21, figeight_corr_matx_pop21, ...
    all_bins_dwell_times_pop21, test_row_pop21, hold_cellcount_pop21, ...
    sorting_vector_pop21, sect_bins_pop21, pop_sessions_pop21] = ...
    ALL_ballistic_times(bins, min_visit, 2.1, redundant, rwd_on, half);

[rate_matrices_pop22, fig_eight_matrix_pop22, figeight_corr_matx_pop22, ...
    all_bins_dwell_times_pop22, test_row_pop22, hold_cellcount_pop22, ...
    sorting_vector_pop22, sect_bins_pop22, pop_sessions_pop22] = ...
    ALL_ballistic_times(bins, min_visit, 2.2, redundant, rwd_on, half);

[rate_matrices_pop23, fig_eight_matrix_pop23, figeight_corr_matx_pop23, ...
    all_bins_dwell_times_pop23, test_row_pop23, hold_cellcount_pop23, ...
    sorting_vector_pop23, sect_bins_pop23, pop_sessions_pop23] = ...
    ALL_ballistic_times(bins, min_visit, 2.3, redundant, rwd_on, half);

[rate_matrices_pop4, fig_eight_matrix_pop4, figeight_corr_matx_pop4, ...
    all_bins_dwell_times_pop4, test_row_pop4, hold_cellcount_pop4, ...
    sorting_vector_pop4, sect_bins_pop4, pop_sessions_pop4] = ...
    ALL_ballistic_times(bins, min_visit, 4, redundant, rwd_on, half);

%}

sesh_means_21 = [];
sesh_vars_21 = [];
for i = 1:length(all_bins_dwell_times_pop21)
    if ~isempty(all_bins_dwell_times_pop21{i})
        sesh_means_21 = [sesh_means_21 nanmean(all_bins_dwell_times_pop21{i}, 2)];
        sesh_vars_21 = [sesh_vars_21 nanvar(all_bins_dwell_times_pop21{i}, [], 2)];
    end
end
mean_means21 = nanmean(sesh_means_21,2);
mean_se21 = nanstd(sesh_means_21,[],2)./sqrt(sum(~isnan(sesh_means_21),2));
var_means21 = nanmean(sesh_vars_21,2);
var_se21 = nanstd(sesh_vars_21,[],2)./sqrt(sum(~isnan(sesh_vars_21),2));


sesh_means_22 = [];
sesh_vars_22 = [];
for i = 1:length(all_bins_dwell_times_pop22)
    if ~isempty(all_bins_dwell_times_pop22{i})
        sesh_means_22 = [sesh_means_22 nanmean(all_bins_dwell_times_pop22{i}, 2)];
        sesh_vars_22 = [sesh_vars_22 nanvar(all_bins_dwell_times_pop22{i}, [], 2)];
    end
end
mean_means22 = nanmean(sesh_means_22,2);
mean_se22 = nanstd(sesh_means_22,[],2)./sqrt(sum(~isnan(sesh_means_22),2));
var_means22 = nanmean(sesh_vars_22,2);
var_se22 = nanstd(sesh_vars_22,[],2)./sqrt(sum(~isnan(sesh_vars_22),2));

sesh_means_23 = [];
sesh_vars_23 = [];
for i = 1:length(all_bins_dwell_times_pop23)
    if ~isempty(all_bins_dwell_times_pop23{i})
        sesh_means_23 = [sesh_means_23 nanmean(all_bins_dwell_times_pop23{i}, 2)];
        sesh_vars_23 = [sesh_vars_23 nanvar(all_bins_dwell_times_pop23{i}, [], 2)];
    end
end
mean_means23 = nanmean(sesh_means_23,2);
mean_se23 = nanstd(sesh_means_23,[],2)./sqrt(sum(~isnan(sesh_means_23),2));
var_means23 = nanmean(sesh_vars_23,2);
var_se23 = nanstd(sesh_vars_23,[],2)./sqrt(sum(~isnan(sesh_vars_23),2));

sesh_means_4 = [];
sesh_vars_4 = [];
for i = 1:length(all_bins_dwell_times_pop4)
    if ~isempty(all_bins_dwell_times_pop4{i})
        sesh_means_4 = [sesh_means_4 nanmean(all_bins_dwell_times_pop4{i}, 2)];
        sesh_vars_4 = [sesh_vars_4 nanvar(all_bins_dwell_times_pop4{i}, [], 2)];
    end
end
mean_means4 = nanmean(sesh_means_4,2);
mean_se4 = nanstd(sesh_means_4,[],2)./sqrt(sum(~isnan(sesh_means_4),2));
var_means4 = nanmean(sesh_vars_4,2);
var_se4 = nanstd(sesh_vars_4,[],2)./sqrt(sum(~isnan(sesh_vars_4),2));

figure; hold on
errorbar(mean_means21, mean_se21)
errorbar(mean_means22, mean_se22)
errorbar(mean_means23, mean_se23)
errorbar(mean_means4, mean_se4)
title means
ylabel('dwell times (seconds; session means)')
for i = cumsum([sect_bins_pop4])+.5; hold on; plot([i i], ylim, 'r-'); end
for i = cumsum([sect_bins_pop4])+.5; hold on; plot([i i], ylim, 'r-'); end
xlim([0 bins+1])
set(gca,'TickLength',[0, 0]); box off;
xlabel('Spatial position')
xticklabels([])
legend({'early', 'mid', 'late', 'OT'}, 'location', 'northeastoutside')



figure; hold on
errorbar(var_means21, var_se21)
errorbar(var_means22, var_se22)
errorbar(var_means23, var_se23)
errorbar(var_means4, var_se4)
title Variance
ylabel('dwell time variances (seconds; session means)')
for i = cumsum([sect_bins_pop4])+.5; hold on; plot([i i], ylim, 'r-'); end
for i = cumsum([sect_bins_pop4])+.5; hold on; plot([i i], ylim, 'r-'); end
xlim([0 bins+1])
set(gca,'TickLength',[0, 0]); box off;
xlabel('Spatial position')
xticklabels([])
legend({'early', 'mid', 'late', 'OT'}, 'location', 'northeastoutside')


















