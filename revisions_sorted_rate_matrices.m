%check whether ALL_ballistic_times is set to just population days or all
%cells!
%{
bins=100; min_visit=3; learning_stages = 4; halves = 1;redundant =1; rwd_on= 0; half = 0; [rate_matrices, fig_eight_matrix, figeight_corr_matx, all_bins_dwell_times, test_row, hold_cellcount, sorting_vector, sect_bins, pop_sessions] = ALL_ballistic_times(bins, min_visit, learning_stages, redundant, rwd_on, half);
%
[rate_matrices_pop21, fig_eight_matrix_pop21, figeight_corr_matx_pop21, ...
    all_bins_dwell_times_pop21, test_row_pop21, hold_cellcount_pop21, ...
    sorting_vector_pop21, sect_bins_pop21, pop_sessions_pop21] = ...
    ALL_ballistic_times(bins, min_visit, 2.1, redundant, rwd_on, half);
%
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

%figure; imagesc(sort_rows_by_peak(norm_mtx([rate_matrices_pop21(:,:,1); rate_matrices_pop21(:,:,2)])'))
%figure; imagesc(sort_rows_by_peak(norm_mtx([rate_matrices_pop22(:,:,1); rate_matrices_pop22(:,:,2)])'))
%figure; imagesc(sort_rows_by_peak(norm_mtx([rate_matrices_pop23(:,:,1); rate_matrices_pop23(:,:,2)])'))

c21 = [rate_matrices_pop21(:,:,1); rate_matrices_pop21(:,:,2)];
for i = 1:size(c21,1)
    %c21(i,:) = nanfastsmooth(c21(i,:), 5, 1, .25);
end
c22 = [rate_matrices_pop22(:,:,1); rate_matrices_pop22(:,:,2)];
for i = 1:size(c22,1)
    %c22(i,:) = nanfastsmooth(c22(i,:), 5, 1, .25);
end
c23 = [rate_matrices_pop23(:,:,1); rate_matrices_pop23(:,:,2)];
for i = 1:size(c23,1)
    %c23(i,:) = nanfastsmooth(c23(i,:), 5, 1, .25);
end
c40 = [rate_matrices_pop4(:,:,1); rate_matrices_pop4(:,:,2)];
for i = 1:size(c40,1)
    %c40(i,:) = nanfastsmooth(c40(i,:), 5, 1, .25);
end

figure; imagesc(sort_rows_by_peak(norm_mtx([c21 c22 c23])'))
figure; imagesc(sort_rows_by_peak(norm_mtx(c40)'))