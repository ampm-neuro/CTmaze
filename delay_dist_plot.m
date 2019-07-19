function dist_out = delay_dist_plot(all_time_windows)
%dot plot of distances
%
%
%

%cut off bookend_bins 
%bookend_bins = length(all_time_windows(:,1,1));
%all_time_windows = all_time_windows(1:(end-bookend_bins), :, :); %off end only

%combine desired axes
all_mtx = [];

for ivar = 1:size(all_time_windows,3)
    all_mtx = [all_mtx; all_time_windows(:,:,ivar)];
end

%zscore
all_mtx_z = all_mtx - repmat(mean(all_mtx), size(all_mtx,1),1);
all_mtx_z = all_mtx_z./std(all_mtx_z);

%reshape
all_mtx_z = permute(reshape(all_mtx_z', size(all_time_windows,2), size(all_time_windows,1), size(all_time_windows,3)),[2 1 3]);

%dists
dist_out = nan(length(all_time_windows(:,1,1)),1);
for dist_h = 1:length(dist_out)
    
    %calculate and load distances
    dist_out(dist_h) = dist(all_mtx_z(dist_h, :, 1), all_mtx_z(dist_h, :, 2)')./sqrt(length(all_mtx_z(dist_h, :, 1)));
       
end


figure; bar(dist_out)

end