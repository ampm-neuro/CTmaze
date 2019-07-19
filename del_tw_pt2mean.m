function del_tw_pt2mean(all_time_windows, axes, num_imeans)
%computes average firing rate from every cell in every time window (tw)
% during the the 30s delay (del), and then computes the distance from that 
% tw to the mean of the tws in the local intermediate bin (im_bin).
%
% for example, if the im_bin is 1s and the window_duration is 0.1s, then on
% a given left-trial tw, we calculate the euclid distance from that tw to
% the mean of the remaining left-trial tws in that 1s bin, and to the mean of
% the right-trial tws in that bin.
%
% error trials are treated similarly, except that the distance is always to
% the mean of the corresponding correct trial type, e.g., error-left tw to
% correct-left bin mean.
%
%
% num_imeans = number of along-the-way means to calculate


%HARD CODED INPUT
%

%~input variables
num_seconds = 0; %seconds to take off end(s) of delay


%PREPROCESS INPUT
%

%timewindow count
bins = length(all_time_windows(:,1,1));
bookend_bins = floor((num_seconds/30)*bins);

%cut off bookend_bins 
%all_time_windows = all_time_windows((bookend_bins+1):(end-bookend_bins), :, :); %off begining AND end
all_time_windows = all_time_windows(1:(end-bookend_bins), :, :); %off end only

%combine desired axes
all_mtx = [];
for ivar = 1:length(axes)
    all_mtx = [all_mtx; all_time_windows(:,:,axes(ivar))];
end

%zscore
all_mtx_z = all_mtx - repmat(nanmean(all_mtx), size(all_mtx,1), 1);
all_mtx_z = all_mtx_z./nanstd(all_mtx_z);

%reshape back to dimensions of all_time_windows (after indexing for axes)
all_mtx_z = permute(reshape(all_mtx_z', size(all_time_windows,2), size(all_time_windows,1), length(axes)),[2 1 3]);


%BEGIN DISTANCE COMPUTATIONS
%

%calculate time bounds on bins
im_bounds = round(linspace(0, size(all_mtx_z, 1), num_imeans+1));

%preallocate distance matrix (time window, bin, trial type, dist to left/right)
dist_mtx_shouldve = nan(size(all_time_windows,1), num_imeans, length(axes));
dist_mtx_other = nan(size(all_time_windows,1), num_imeans, length(axes));

%iterate through im_bounds of all_mtx_z 
%calculating distances and shuffles
for i_im = 1:num_imeans
    
    %bin bounds
    lo_tw = im_bounds(i_im)+1;
    hi_tw = im_bounds(i_im+1);
    
    %time windows within bounds 
    %(timewindows, cells, trialtype)
    local_tws = all_mtx_z(lo_tw:hi_tw, :, :);
    
    for trial_type = 1:length(axes)
        for time_window = 1:size(local_tws,1)
    
            %test vector
            ctw = local_tws(time_window, :, trial_type);
            
            %remove test vector from local time windows
            ltws_hold = local_tws;
            ltws_hold(time_window, :, trial_type) = nan;
    
            %local correct means (sans ctw; only cells in common with ctw)
            ctw_idx_left = ~isnan(ctw) & ~isnan(local_tws(1, :, 1));
            mean_correct_left = nanmean(ltws_hold(:, ctw_idx_left, 1), 1);
            ctw_idx_right = ~isnan(ctw) & ~isnan(local_tws(1, :, 2));
            mean_correct_right = nanmean(ltws_hold(:, ctw_idx_right, 2), 1);
            ctw_L = ctw(ctw_idx_left);
            ctw_R = ctw(ctw_idx_right);
            
            %calculate and load distance to (1) side THE RAT SHOULD HAVE
            %VISITED, (2) other side
            %
            
            %tw index for loading
            overall_tw = lo_tw - 1 + time_window;
            
            %should have
            if ismember(trial_type, [1 4])
                
                dist_mtx_shouldve(overall_tw, i_im, trial_type) = dist(mean_correct_left, ctw_L')/sqrt(length(mean_correct_left)); %dist to left
                dist_mtx_other(overall_tw, i_im, trial_type) = dist(mean_correct_right, ctw_R')/sqrt(length(mean_correct_right)); %dist to right
            %    
            %other    
            elseif ismember(trial_type, [2 3])

                %{
                if trial_type ==3
                    %mean_correct_left
                    %ctw
                    dist(mean_correct_left, ctw')
                end
                %}
                
                dist_mtx_shouldve(overall_tw, i_im, trial_type) = dist(mean_correct_right(1:30), ctw_R(1:30)')/sqrt(length(mean_correct_right(1:30))); %dist to right
                dist_mtx_other(overall_tw, i_im, trial_type) = dist(mean_correct_left(1:30), ctw_L(1:30)')/sqrt(length(mean_correct_left(1:30))); %dist to left
            end
        end
    end
end


%COMPUTE DISCRIMINATION INDEX
%


%combine correct trials and combine error trials
%results in (tw, bins, cor/err, shouldve/other)
dist_mtx_shouldve_II(:, :, 1) = mean(dist_mtx_shouldve(:,:,[1 2]), 3);
dist_mtx_shouldve_II(:, :, 2) = mean(dist_mtx_shouldve(:,:,[3 4]), 3);
dist_mtx_other_II(:, :, 1) = mean(dist_mtx_other(:,:,[1 2]), 3);
dist_mtx_other_II(:, :, 2) = mean(dist_mtx_other(:,:,[3 4]), 3);

%abs(dist to same - dist to other) / dist to both
%resuts in (timewindows, bins, cor/err)
discrim_idx_correct = (dist_mtx_other_II(:,:,1) - dist_mtx_shouldve_II(:,:,1))./(dist_mtx_shouldve_II(:,:,1) + dist_mtx_other_II(:,:,1));
discrim_idx_error = (dist_mtx_other_II(:,:,2) - dist_mtx_shouldve_II(:,:,2))./(dist_mtx_other_II(:,:,2) + dist_mtx_other_II(:,:,2));


%PLOT DISCRIMINATION INDICES
%

figure; hold on

%plot corrects and errors
errorbar(1:num_imeans, nanmean(discrim_idx_correct), nanstd(discrim_idx_correct)./sqrt(im_bounds(2)), 'b-')
errorbar(1:num_imeans, nanmean(discrim_idx_error), nanstd(discrim_idx_error)./sqrt(im_bounds(2)), 'r-')

plot(1:num_imeans, smooth(smooth(nanmean(discrim_idx_correct), 10)), 'color', [24 16 205]./255, 'linewidth', 2)
plot(1:num_imeans, smooth(smooth(nanmean(discrim_idx_error), 10)), 'color', [180 0 0]./255, 'linewidth', 2)


for im = 1:num_imeans
    plot(im, discrim_idx_correct(:, im), 'o', 'color', [24 16 205]./255)
    plot(im, discrim_idx_error(:, im), 'o', 'color', [180 0 0]./255)
end

