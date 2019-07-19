function [dist_vect, shuffle_mtx] = delay_spkct_popdists(all_time_windows, variables, bins, shufs)
%plots output from ALL_spikects_delay
%
% green is visited-left-reward
% blue is visited-right-reward
%
% over the delay, colors go from dark to light

 

%~input variables
num_imeans = bins; %number of along-the-way means to plot
num_seconds = 0; %seconds to take off end(s) of delay

%preallocate
dist_vect = nan(bins, 1);
shuffle_mtx = nan(bins, shufs);

%timewindow count
bins = length(all_time_windows(:,1,1));
bookend_bins = floor((num_seconds/30)*bins);

%cut off bookend_bins 
%all_time_windows = all_time_windows((bookend_bins+1):(end-bookend_bins), :, :); %off begining AND end
all_time_windows = all_time_windows(1:(end-bookend_bins), :, :); %off end only

%combine desired axes
all_mtx = [];
for ivar = 1:length(variables)
    all_mtx = [all_mtx; all_time_windows(:,:,variables(ivar))];
end

%zscore
all_mtx_z = all_mtx - repmat(mean(all_mtx), size(all_mtx,1),1);
all_mtx_z = all_mtx_z./std(all_mtx_z);

%reshape back to dimensions ofall_time_windows
length(axes)
all_mtx_z = permute(reshape(all_mtx_z', size(all_time_windows,2), size(all_time_windows,1), size(all_time_windows,3)),[2 1 3]);

%for pca version
%{
[all_mtx_pca, ~, ~, ~, EXPLAINED] = pca(all_mtx_z');
all_mtx_z = permute(reshape(all_mtx_pca', size(all_time_windows,2)-1, size(all_time_windows,1), 2),[2 1 3]); all_mtx_z = all_mtx_z(:, 1:10, :);
%}

%group intermediate means
im_bounds = round(linspace(0, size(all_mtx_z, 1), num_imeans+1));   
            
%iterate through im_bounds of all_mtx_z 
%calculating distances and shuffles
for i_im = 1:num_imeans
    
    %bin bounds
    lo_tw = im_bounds(i_im)+1;
    hi_tw = im_bounds(i_im+1);
    
    %clusters within bounds
    clusters = all_mtx_z(lo_tw:hi_tw, :, :);

    %calculate and load distance
    %dist_vect(i_im) = dist(mean(clusters(:,:,1)), mean(clusters(:,:,2))')./sqrt(size(clusters,2)); %euclid
    %dist_vect(i_im) = mahal_2cluster_dist(clusters(:, :, 1), clusters(:, :, 2)); %mahal
    dist_vect(i_im) = zscore_2cluster_dist(clusters(:,:,1), clusters(:,:,2)); %zdist
    
    %SHUFFLES
    %
    % shuffling cells between groups (L/R) at each time window
    %
    %combo_mtx = [cluster_a; cluster_b]; %prepare to shuffle cells between timewindows
    clusters_shuf = clusters;
    
    %iterate through shuffles
    for ishuf = 1:shufs
        
        %for each time window
        for tw = 1:size(clusters, 1)
        
            %shuffle each cell individually
            for icell = 1:size(clusters, 2)

                clusters_shuf(tw, icell, :) = clusters_shuf(tw, icell, randperm(2));
            end
        end
        
        %load shuffle distance
        %shuffle_mtx(i_im, ishuf) = dist(mean(clusters_shuf(:,:,1)), mean(clusters_shuf(:,:,2))')./sqrt(size(clusters,2));
        %shuffle_mtx(i_im, ishuf) = mahal_2cluster_dist(clusters_shuf(:, :, 1), clusters_shuf(:, :, 2));
        shuffle_mtx(i_im, ishuf) = zscore_2cluster_dist(clusters_shuf(:,:,1), clusters_shuf(:,:,2));
        
    end
end

%sort shuffles
%shuffle_mtx = sort(shuffle_mtx,2);

%plot
figure; bar(dist_vect); title zdist; 
hold on
%plot(1:num_imeans, shuffle_mtx(:,ceil(.975*shufs)), 'k-')
%ylim([1 inf])


end
