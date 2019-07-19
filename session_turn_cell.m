function [fstat, pvals] = session_turn_cell(eptrials, clusts)
% 
% bin by video samples
% compute change in HD in each bin
% compute FR in each bin for each cell

%downsampel
ds = 20; %1 is none, 10 is for 0.1s bins
num_ang_vel_bins = 3;

% bin times
bin_lo = eptrials(eptrials(:,14)==1,1); 
bin_lo = bin_lo(1:ds:end);
bin_lo = bin_lo(1:end-1);
bin_hi = eptrials(eptrials(:,14)==1,1);
bin_hi = bin_hi(1:ds:end);
bin_hi = bin_hi(2:end);
bin_ctrs = mean([bin_lo bin_hi],2);

% samp rate
samprate = bin_ctrs(2)-bin_ctrs(1);

% compute delta HD at each time bin
HD_start = eptrials(eptrials(:,14)==1,15); 
HD_start = HD_start(1:ds:end);
HD_start = HD_start(1:end-1);
HD_end = eptrials(eptrials(:,14)==1,15); 
HD_end = HD_end(1:ds:end);
HD_end = HD_end(2:end);
[HD_delt,cw] = circ_distance(HD_start, HD_end, [0 360]);
HD_delt = HD_delt.*cw;

% firing rates at each time bin
clust_FRs = nan(length(bin_ctrs),length(clusts));
for iclust = 1:length(clusts)
    current_clust = clusts(iclust);
    
    % eptrials with just spike times
    spike_times = eptrials(eptrials(:,4)==current_clust,1);
    
    % count spikes in time bins
    clust_FRs(:,iclust) = histcounts(spike_times, [bin_lo-realmin; bin_hi(end)+realmin])./samprate;
    
end

%zscore rates
%clust_FRs = zscore_mtx(clust_FRs);


% bin delta HD
delta_HD_bin_edges = linspace(-180-realmin, 180+realmin, num_ang_vel_bins+1);
[bin_ct_dHD, ~, bin_idx] = histcounts(HD_delt, delta_HD_bin_edges);
%[bin_ct_dHD, ~, bin_idx] = histcounts(abs(HD_delt), delta_HD_bin_edges);

% compute means and ses
dHD_FRs_mean = nan(length(bin_ct_dHD), length(clusts));
dHD_FRs_se = nan(length(bin_ct_dHD), length(clusts));
for idhd = 1:length(bin_ct_dHD)
    dHD_FRs_mean(idhd,:) = mean(clust_FRs(bin_idx==idhd,:));
    dHD_FRs_se(idhd,:) = std(clust_FRs(bin_idx==idhd,:))./sqrt(sum(bin_idx==idhd));
end



% compute F statistics
fstat = nan(length(clusts),1);
pvals = nan(length(clusts),1);
for iclust = 1:length(clusts)
    [~,T] = anovan(clust_FRs(:,iclust),bin_idx, 'display', 'off');
    fstat(iclust) = T{2,6};
    pvals(iclust) = T{2,7};
end

%{
for iclust = 1:length(clusts)
    figure
    errorbar(xpos(:,iclust), dHD_FRs_mean(:,iclust), dHD_FRs_se(:,iclust), '-', 'linewidth', 0.5, 'color', .5.*[1 1 1])
    set(gca,'TickLength',[0, 0]); box off; axis square
    title(['fstat=' num2str(fstat(iclust)) '; pval=' num2str(pvals(iclust))])
end
%}

%{
xpos = mean([delta_HD_bin_edges(1:end-1); delta_HD_bin_edges(2:end)])';
xpos = repmat(xpos,1, size(dHD_FRs_mean,2));
xpos = xpos./samprate;
errorbar(xpos, dHD_FRs_mean, dHD_FRs_se)
plot(xpos, dHD_FRs_mean, '-', 'linewidth', 0.5, 'color', .5.*[1 1 1])
%}



