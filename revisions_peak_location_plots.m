%{
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


[length(unique(pop_sessions_pop21)) length(unique(pop_sessions_pop22)) ...
    length(unique(pop_sessions_pop23)) length(unique(pop_sessions_pop4))]
%}

sect_columns = cumsum([sect_bins_pop21 sect_bins_pop21]);
sect_columns = sect_columns(1:end-1);

conc_mtx_21 = [rate_matrices_pop21(:,:,1); rate_matrices_pop21(:,:,2)];
conc_mtx_22 = [rate_matrices_pop22(:,:,1); rate_matrices_pop22(:,:,2)];
conc_mtx_23 = [rate_matrices_pop23(:,:,1); rate_matrices_pop23(:,:,2)];
conc_mtx_4 = [rate_matrices_pop4(:,:,1); rate_matrices_pop4(:,:,2)];

%smooth
%
for i = 1:size(conc_mtx_21,2); conc_mtx_21(:,i) = smooth(conc_mtx_21(:,i),7); end
for i = 1:size(conc_mtx_22,2); conc_mtx_22(:,i) = smooth(conc_mtx_22(:,i),7); end
for i = 1:size(conc_mtx_23,2); conc_mtx_23(:,i) = smooth(conc_mtx_23(:,i),7); end
for i = 1:size(conc_mtx_4,2); conc_mtx_4(:,i) = smooth(conc_mtx_4(:,i),7); end

%}

[mtx_pop21, peaks_pop21, sort_peaks_pop21] = sort_rows_by_peak(norm_mtx(conc_mtx_21)');
[mtx_pop22, peaks_pop22, sort_peaks_pop22] = sort_rows_by_peak(norm_mtx(conc_mtx_22)');
[mtx_pop23, peaks_pop23, sort_peaks_pop23] = sort_rows_by_peak(norm_mtx(conc_mtx_23)');
[mtx_pop4, peaks_pop4, sort_peaks_pop4] = sort_rows_by_peak(norm_mtx(conc_mtx_4)');

figure; hold on
subplot(1,4,1); imagesc(mtx_pop21); plot_row_peaks(mtx_pop21); axis off square
    hold on; plot([sect_columns;sect_columns], ylim, 'k-', 'linewidth', 2)
subplot(1,4,2); imagesc(mtx_pop22); plot_row_peaks(mtx_pop22); axis off square
    hold on; plot([sect_columns;sect_columns], ylim, 'k-', 'linewidth', 2)
subplot(1,4,3); imagesc(mtx_pop23); plot_row_peaks(mtx_pop23); axis off square
    hold on; plot([sect_columns;sect_columns], ylim, 'k-', 'linewidth', 2)
subplot(1,4,4); imagesc(mtx_pop4); plot_row_peaks(mtx_pop4); axis off square
    hold on; plot([sect_columns;sect_columns], ylim, 'k-', 'linewidth', 2)
    
figure; hold on
vect21 = plot_row_peaks(mtx_pop21);
vect22 = plot_row_peaks(mtx_pop22); 
vect23 = plot_row_peaks(mtx_pop23); 
vect4 = plot_row_peaks(mtx_pop4); 
axis off square
set(gca,'TickLength',[0, 0])
set(gca,'TickLength',[0, 0])
set(gca, 'Ydir', 'reverse')
hold on; plot([sect_columns;sect_columns], ylim, 'k-', 'linewidth', 2)
%{
vect21(vect21>100) = vect21(vect21>100)-100; vect21 = sort(vect21);
vect22(vect22>100) = vect22(vect22>100)-100; vect22 = sort(vect22); 
vect23(vect23>100) = vect23(vect23>100)-100; vect23 = sort(vect23);
vect4(vect4>100) = vect4(vect4>100)-100; vect4 = sort(vect4); 

figure; hold on
plot(vect21, cumsum(vect21>0)./sum(vect21>0))
plot(vect22, cumsum(vect22>0)./sum(vect22>0))
plot(vect23, cumsum(vect23>0)./sum(vect23>0))
plot(vect4, cumsum(vect4>0)./sum(vect4>0))
hold on; plot([sect_columns(1:4);sect_columns(1:4)], ylim, 'k-', 'linewidth', 2)
set(gca,'TickLength',[0, 0])
%}

%{
rwd_peak_prop_pop21 = []; 
for i = unique(pop_sessions_pop21)' 
    pp = peaks_pop21; 
    p_idx = pop_sessions_pop21 == i; 
    rwd_peak_prop_pop21 = [rwd_peak_prop_pop21; sum(p_idx & ((pp>=48 & pp<=68) | (pp>=148 & pp<=168)))/length(pp(p_idx))]; 
end

rwd_peak_prop_pop22 = []; 
for i = unique(pop_sessions_pop22)' 
    pp = peaks_pop22; 
    p_idx = pop_sessions_pop22 == i; 
    rwd_peak_prop_pop22 = [rwd_peak_prop_pop22; sum(p_idx & ((pp>=48 & pp<=68) | (pp>=148 & pp<=168)))/length(pp(p_idx))]; 
end

rwd_peak_prop_pop23 = []; 
for i = unique(pop_sessions_pop23)' 
    pp = peaks_pop23; 
    p_idx = pop_sessions_pop23 == i; 
    rwd_peak_prop_pop23 = [rwd_peak_prop_pop23; sum(p_idx & ((pp>=48 & pp<=68) | (pp>=148 & pp<=168)))/length(pp(p_idx))]; 
end

rwd_peak_prop_pop4 = []; 
for i = unique(pop_sessions_pop4)' 
    pp = peaks_pop4; 
    p_idx = pop_sessions_pop4 == i; 
    rwd_peak_prop_pop4 = [rwd_peak_prop_pop4; sum(p_idx & ((pp>=48 & pp<=68) | (pp>=148 & pp<=168)))/length(pp(p_idx))]; 
end

%tank plot
h21 = histogram([peaks_pop21(peaks_pop21<=100); peaks_pop21(peaks_pop21>100)-100], 0:4:100, 'normalization', 'probability');
h22 = histogram([peaks_pop22(peaks_pop22<=100); peaks_pop22(peaks_pop22>100)-100], 0:4:100, 'normalization', 'probability');
h23 = histogram([peaks_pop23(peaks_pop23<=100); peaks_pop23(peaks_pop23>100)-100], 0:4:100, 'normalization', 'probability');
h4 = histogram([peaks_pop4(peaks_pop4<=100); peaks_pop4(peaks_pop4>100)-100], 0:4:100, 'normalization', 'probability');

figure; hold on
hv = [h21.Values; h21.Values]; plot([h21.BinEdges(1) sort([h21.BinEdges(2:end-1) h21.BinEdges(2:end-1)]) h21.BinEdges(end)], hv(:))
hv = [h22.Values; h22.Values]; plot([h22.BinEdges(1) sort([h22.BinEdges(2:end-1) h22.BinEdges(2:end-1)]) h22.BinEdges(end)], hv(:))
hv = [h23.Values; h23.Values]; plot([h23.BinEdges(1) sort([h23.BinEdges(2:end-1) h23.BinEdges(2:end-1)]) h23.BinEdges(end)], hv(:))
hv = [h4.Values; h4.Values]; plot([h4.BinEdges(1) sort([h4.BinEdges(2:end-1) h4.BinEdges(2:end-1)]) h4.BinEdges(end)], hv(:))
%}



