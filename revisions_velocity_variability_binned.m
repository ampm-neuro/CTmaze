
learning_stage = 2; 

%approx 50 cells per bin
if learning_stage==2
    variance_bins = 7; %NUMBER OF BARS
elseif learning_stage==4
    variance_bins = 6; %NUMBER OF BARS
end

velocity_or_var = 2; %vel = 1, var = 2;

spatial_bins=100; min_visit=3; redundant =0; rwd_on=0; 
%{
[rate_matrices_pop4, fig_eight_matrix_pop4, figeight_corr_matx_pop4, ...
    all_bins_dwell_times_pop4, test_row_pop4, hold_cellcount_pop4, ...
    sorting_vector_pop4, sect_bins_pop4, pop_sessions_pop4] = ...
    ALL_ballistic_times(spatial_bins, min_visit, learning_stage, redundant, rwd_on, 0);
%}

%index to include all except second stem
sect_bins_pop4_cumsum = cumsum([sect_bins_pop4 sect_bins_pop4]);
omit_second_stem_idx = [1:sect_bins_pop4_cumsum(5) sect_bins_pop4_cumsum(6):sect_bins_pop4_cumsum(end)];


%comparison between cells recorded during sessions with low, medium, or
%high variability

%compute mean variability of each session
sesh_meanvars = nan(length(all_bins_dwell_times_pop4),1);
for isesh = 1:length(all_bins_dwell_times_pop4)
    if velocity_or_var == 1 %velocity
        sesh_meanvars(isesh) = nanmean(nanmean(all_bins_dwell_times_pop4{isesh}));
    elseif velocity_or_var == 2 %variability of velocity
        sesh_meanvars(isesh) = nanmean(nans(all_bins_dwell_times_pop4{isesh}));
    end
end

%find number of cells in each session
num_cells = nan(length(all_bins_dwell_times_pop4),1);
for isesh = 1:length(all_bins_dwell_times_pop4)
    num_cells(isesh) = sum(pop_sessions_pop4(:,2)==isesh);
end

%sort sessions by variability
[sorted_vars, sort_idx] = sort(sesh_meanvars);
sesh_ids = unique(pop_sessions_pop4(:,2));
sesh_ids_VarSorted = sesh_ids(sort_idx);
num_cells_VarSorted = num_cells(sort_idx);

%bins
bin_upper_bounds = linspace(0,size(pop_sessions_pop4,1), variance_bins+1);
bin_upper_bounds = floor(bin_upper_bounds(2:end));

%sort sessions into bins (bin 1 is lowest variance)
bin_sesh_list = cell(1, variance_bins);
cell_ct = 0;
current_bin = 1;
for isesh = 1:length(sesh_ids_VarSorted)
   
     cell_ct = cell_ct + num_cells_VarSorted(isesh); 
   %use bin bounds to determine correct bin
   if cell_ct > bin_upper_bounds(current_bin)
       disp(['Bin ' num2str(current_bin) ' has ' num2str(sum(bin_sesh_list{current_bin}(:,2))) ' cells'])
       current_bin = current_bin+1;
   end
   
    

   %load session id and number of cells in that session and mean variance of
   %that session
   bin_sesh_list{current_bin} = [bin_sesh_list{current_bin}; [sesh_ids_VarSorted(isesh) num_cells_VarSorted(isesh) sorted_vars(isesh)]];
end
disp(['Bin ' num2str(current_bin) ' has ' num2str(sum(bin_sesh_list{current_bin}(:,2))) ' cells'])



%compare halves
%{
[rm_1half, rm_1half_z] = ALL_ballistic_times(spatial_bins, min_visit, learning_stage, redundant, rwd_on, 1);
    rm_1half = [rm_1half(:,:,1); rm_1half(:,:,2)];
    rm_1half = rm_1half(omit_second_stem_idx, :);
[rm_2half, rm_2half_z] = ALL_ballistic_times(spatial_bins, min_visit, learning_stage, redundant, rwd_on, 2);
    rm_2half = [rm_2half(:,:,1); rm_2half(:,:,2)];
    rm_2half = rm_2half(omit_second_stem_idx, :);
%}

%create rate matrix for each bin
bin_rm_1half = cell(1,variance_bins);
bin_rm_2half = cell(1,variance_bins);
for ibin = 1:variance_bins
    bin_rm_1half{ibin} = rm_1half(:, ismember(pop_sessions_pop4(:,2), bin_sesh_list{ibin}(:,1))); 
    bin_rm_2half{ibin} = rm_2half(:, ismember(pop_sessions_pop4(:,2), bin_sesh_list{ibin}(:,1))); 
end


%compute correlation matrices
bin_corr_matx = cell(1, variance_bins);
off_diag_error = nan(1, variance_bins);
for ibin = 1:variance_bins
    
    %combine halves to pretreat
    %comb_halv_mtx = [ bin_rm_1half{ibin}; bin_rm_2half{ibin} ];
    
    %smooth bin firing
    %for ismooth = 1:size(comb_halv_mtx,1)
    %    comb_halv_mtx(ismooth, :) = nanfastsmooth(comb_halv_mtx(ismooth, :), 5, 1, 0.5);
    %end
    
    
    %overall scoring
    %overall_z_mtx = [ bin_rm_1half{ibin}; bin_rm_2half{ibin} ];
    overall_z_mtx = zscore_mtx([ bin_rm_1half{ibin}; bin_rm_2half{ibin} ]);
    %overall_z_mtx = [ zscore_mtx(bin_rm_1half{ibin}); zscore_mtx(bin_rm_2half{ibin}) ];
    %overall_z_mtx = [ bin_rm_1half{ibin}; bin_rm_2half{ibin} ];
    %overall_z_mtx = zscore_mtx(comb_halv_mtx);
    
    %split back into L and R
    bin_rm_1half_z = overall_z_mtx(1:floor(size(overall_z_mtx,1)/2), :);
    bin_rm_2half_z  = overall_z_mtx(floor(size(overall_z_mtx,1)/2)+1:end, :);

    %find correlation matrix
    bin_corr_matx{ibin} = nan(size(bin_rm_1half_z,1), size(bin_rm_2half_z,1));
    for bin_test = 1:size(bin_rm_1half_z,1)
        for bin_comp = 1:size(bin_rm_2half_z,1)

            %compare these two rows
            test_row = bin_rm_1half_z(bin_test, :);
            comp_row = bin_rm_2half_z(bin_comp, :);

            %common cell idx
            com_cells = ~isnan(test_row) & ~isnan(comp_row);

            %catch no overlap
            if sum(com_cells)<2
                bin_corr_matx{ibin}(bin_test, bin_comp) = nan;
                continue
            end

            %corr inputs
            test_row = test_row(com_cells)';
            comp_row = comp_row(com_cells)';

            %fill correllation matrix
            bin_corr_matx{ibin}(bin_test, bin_comp) = corr(test_row, comp_row);
        end
    end
    
    bin_corr_matx{ibin}(bin_corr_matx{ibin}>.99 | bin_corr_matx{ibin}<-.99) = nan;
    
    %find maximum correlation in each row
    diag_peak = nan(size(bin_corr_matx{ibin},1), 2);
    for bin = 1:size(bin_corr_matx{ibin},1)
        diag_peak(bin, 1:2) = [bin find(bin_corr_matx{ibin}(bin,:) == nanmax(bin_corr_matx{ibin}(bin,:)),1)];
    end
    
    %sum distance off diagonal
    od_error = abs(diag_peak(:,2) - diag_peak(:,1));    
    od_error(od_error>max(diag_peak(:,1))/2) = repmat(max(diag_peak(:,1)), size(od_error(od_error>max(diag_peak(:,1))/2))) - od_error(od_error>max(diag_peak(:,1))/2); %correct for circularity
    off_diag_error(ibin) = sum(od_error);   
    %plot
    figure
    imagesc(bin_corr_matx{ibin})
    colormap jet
    hold on
    plot(diag_peak(:,2), diag_peak(:,1), 'k', 'LineWidth', 5)
    set(gca,'TickLength',[0, 0])
    axis square
    
    title(['Variance: ' num2str(nanmean(bin_sesh_list{ibin}(:,3)))])
    axis off
    var_name = ['decode_error_by_variability_corm' num2str(ibin) '_train' num2str(learning_stage) '_autosave.pdf']; print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\velocity_v_decode_acc\variability plots\' var_name], '-dpdf', '-painters', '-bestfit')

    
    
    
end

figure; bar(off_diag_error.*(45/2500)) %with cm conversion
set(gca,'TickLength',[0, 0])
xtls=[]; for i = 1:variance_bins; xtls = [xtls nanmean(bin_sesh_list{i}(:,3))];end 
xticklabels(xtls)
ylabel(['decode error (cm)'])
xlabel('standard deviation of dwell times (s; averaged across bins)')
bin_cell_ct=[]; for i = 1:variance_bins; bin_cell_ct = [bin_cell_ct sum(bin_sesh_list{i}(:,2))];end 
title(['Train' num2str(learning_stage) '; ' num2str(bin_cell_ct) ' cells'])
var_name = ['decode_error_by_variability_bar_train' num2str(learning_stage) '_autosave.pdf']; print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\velocity_v_decode_acc\variability plots\' var_name], '-dpdf', '-painters', '-bestfit')
hold_ylim = ylim; hold_ylim(2) = floor(hold_ylim(2)*1.1);
ylim(hold_ylim)

[r p] = fit_line(xtls', off_diag_error'.*(45/2500));
set(gca,'TickLength',[0, 0])
ylabel(['decode error (cm)'])
xlabel('standard deviation of dwell times (s; averaged across bins)')
ylim(hold_ylim)
title(['r=' num2str(r) '; p=' num2str(p)])
var_name = ['decode_error_by_variability_dot_train' num2str(learning_stage) '_autosave.pdf']; print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\velocity_v_decode_acc\variability plots\' var_name], '-dpdf', '-painters', '-bestfit')
