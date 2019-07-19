%get correlation matrix
%
bins=100; min_visit=3; learning_stages = 2.2; 
halves = 1;

%full session
if halves == 0
    
    redundant =1; rwd_on= 0; half = 0;
    [rate_matrices, fig_eight_matrix, figeight_corr_matx, all_bins_dwell_times, test_row, hold_cellcount, sorting_vector, sect_bins, pop_sessions] = ...
        ALL_ballistic_times(bins, min_visit, learning_stages, redundant, rwd_on, half);

%half sessions
elseif halves == 1

    redundant = 1; rwd_on= 0; 
    
    half = 1;
    [rate_matrices1, fig_eight_matrix1, figeight_corr_matx1, all_bins_dwell_times1, test_row1, hold_cellcount1, sorting_vector1, sect_bins1, pop_sessions] = ...
        ALL_ballistic_times(bins, min_visit, learning_stages, redundant, rwd_on, half);
    
    half = 2;
    [rate_matrices2, fig_eight_matrix2, figeight_corr_matx2, all_bins_dwell_times2, test_row2, hold_cellcount2, sorting_vector2, sect_bins2, pop_sessions] = ...
        ALL_ballistic_times(bins, min_visit, learning_stages, redundant, rwd_on, half);


    %correlate two halves to get figeight_corr_matx
    figeight_corr_matx = corm_func(fig_eight_matrix1, fig_eight_matrix2);

end
%}

%remove 1 stem
mtx_1stem = remove_1stem(figeight_corr_matx, sect_bins1);
figure; imagesc(mtx_1stem); title('all cells')
set(gca,'TickLength',[0, 0]); box off;
%connect_peaks(mtx_1stem)
hold on; plot([1 size(mtx_1stem,2)], [1, size(mtx_1stem,1)], 'k--')
colormap jet; caxis([-1 1]); colorbar; axis square
var_name = ['corm_allcells_' num2str(learning_stages*10) '.pdf']; print(...
    ['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\space_corr_by_distance\ot_pop_sesh\' var_name],...
    '-dpdf', '-painters', '-bestfit')

%CALCULATE CORRELATION OVER SPATIAL DISTANCE
%
plot_corr_v_space(mtx_1stem)
title('all cells')
ylim([-.2 .7])
var_name = ['r_by_dist_allcells_' num2str(learning_stages*10) '.pdf']; print(...
    ['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\space_corr_by_distance\ot_pop_sesh\' var_name],...
    '-dpdf', '-painters', '-bestfit')


%individual population session correlation matrices
for ipopsesh = unique(pop_sessions(pop_sessions>0))'

    %pop vectors only
    pop_vects_1 = fig_eight_matrix1(:, pop_sessions==ipopsesh);
    pop_vects_2 = fig_eight_matrix2(:, pop_sessions==ipopsesh);

    %compute local correlation matrix
    pop_corm = corm_func(pop_vects_1, pop_vects_2);

    %remove stem
    pop_corm = remove_1stem(pop_corm, sect_bins1);

    %plot
    figure; imagesc(pop_corm);
    set(gca,'TickLength',[0, 0]); box off;
    %connect_peaks(pop_corm);
    hold on; plot([1 size(pop_corm,2)], [1, size(pop_corm,1)], 'k--')
    title(['population ' num2str(ipopsesh)])
    colormap jet; caxis([-1 1]); colorbar; axis square
    var_name = ['corm_pop' num2str(ipopsesh) '_' num2str(learning_stages*10) '.pdf']; print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\space_corr_by_distance\ot_pop_sesh\' var_name], '-dpdf', '-painters', '-bestfit')

    %plot correlations as a function of distance from current position
    plot_corr_v_space(pop_corm)
    title(['population ' num2str(ipopsesh)])
    ylim([-.2 .7])
    xlabel('Distance along track (cm)')
    ylabel('Correlation (r)')
    xlabel('Distance along track (cm)')
    ylabel('Correlation (r)')
    var_name = ['r_by_dist_pop' num2str(ipopsesh) '_' num2str(learning_stages*10) '.pdf']; print(['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\space_corr_by_distance\ot_pop_sesh\' var_name], '-dpdf', '-painters', '-bestfit')

end
    
    
    
    
    %correlation matrix function
    function comr_out = corm_func(vects1, vects2)
        count = 0;
        comr_out = nan(size(vects1,1), size(vects2,1));
        for bin_test = 1:size(vects1,1)
            for bin_comp = 1:size(vects2,1)
                count = count+1;

                %compare these two rows
                test_row = vects1(bin_test, :);
                comp_row = vects2(bin_comp, :);

                %common cell idx
                com_cells = ~isnan(test_row) & ~isnan(comp_row);
                %hold_cellcount(count) = sum(com_cells);

                %catch insufficient overlap
                if sum(com_cells)<2
                    comr_out(bin_test, bin_comp) = nan;
                    continue
                end

                %corr inputs
                test_row = test_row(com_cells)';
                comp_row = comp_row(com_cells)';

                %fill correllation matrix
                comr_out(bin_test, bin_comp) = corr(test_row, comp_row); 

            end
        end
    end
    
    %removing second stem from corm
    function corm_out = remove_1stem(corm_in, sect_bins)
        stem1_pxls = [1:floor(size(corm_in,1)/2)...
            floor(size(corm_in,1)/2)+sect_bins(2)+1 : size(corm_in,1)];
        corm_out = corm_in(stem1_pxls, stem1_pxls);
    end
    
    %plot all correlations as a function of distance from current position
    function plot_corr_v_space(corm_in)
        current_pos_mtx = nan(size(corm_in,1), size(corm_in,2));
        for i = 1:size(corm_in,1)
            current_pos_mtx(i,:) = circshift(corm_in(i,:), -(i-1)+floor(size(corm_in,1)/2));
        end
        %figure; imagesc(current_pos_mtx);

        %plot mean
        mean_current_pos = nanmean(current_pos_mtx);

        %fold
        %unity_pos = find(mean_current_pos==max(mean_current_pos));
        unity_pos = ceil(size(corm_in,2)/2);
        left_half = fliplr(mean_current_pos(1: unity_pos-1));
        right_half = mean_current_pos(unity_pos+1: end);
        if length(left_half) ~= length(right_half)
            left_half = left_half(1:min([length(left_half) length(right_half)]));
            right_half = left_half(1:min([length(left_half) length(right_half)]));
        end
        folded_mean_current_pos = [mean_current_pos(unity_pos)... 
            nanmean([left_half; right_half])];
        figure; hold on
        plot(folded_mean_current_pos)
        plot(folded_mean_current_pos, '.')
        set(gca,'TickLength',[0,0]); box off;
        hold on; plot(xlim, [0 0], 'k--')
        xticks(1:6:length(folded_mean_current_pos))
        xticklabels((xticks.*3)-3)
    end
    
    %overlay black line connecting peaks of every row
    function connect_peaks(corm_in)
    
        num_rows = size(corm_in,1);
        peak_cols = nan(num_rows,1);
        for irow = 1:num_rows
            peak_cols(irow) = find(corm_in(irow,:)==max(corm_in(irow,:)));
        end

        hold on
        plot(peak_cols, 1:num_rows, 'k-', 'linewidth', 3)

    end
    
    
    
