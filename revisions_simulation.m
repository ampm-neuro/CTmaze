%make data with clear peak locations
%
pop_rows = 136:145;

%warp firing rates into spike counts using dwell times for each bin
asr = all_smoothed_rates_40(pop_rows,:);
adt = all_dwell_times_40(pop_rows,:); %asr.*adt should equal whole numbers, but don't (~ALL<1)
    mean_dwell_time = nanmean([nanmean(nanmean(cell2mat(adt(:,1)))) nanmean(nanmean(cell2mat(adt(:,2))))]);
asc = cell(size(asr));
for clust = 1:size(asr,1)
    for trialtype = 1:2
        asc{clust,trialtype} = round(asr{clust,trialtype}.*mean_dwell_time);
    end
end

%draw a single population's worth of spike count data
count_mtx_R = [];
count_mtx_L = [];
for clust = 1:length(pop_rows)
    count_mtx_R = cat(3, count_mtx_R, cell2mat(asc(clust,1)));
    count_mtx_L = cat(3, count_mtx_L, cell2mat(asc(clust,2)));
end

%equal number of L and R trials for ease
%{
if size(rate_mtx_R,1) > size(rate_mtx_L,2)
    rate_mtx_L = rate_mtx_L(1:size(rate_mtx_R,1),:, :);
elseif size(rate_mtx_R,1) < size(rate_mtx_L,2)
    rate_mtx_R = rate_mtx_R(1:size(rate_mtx_L,1),:, :);
end
%}

%combine matrices
%comb_mtx = [rate_mtx_L rate_mtx_R];

%find peak of merged matrices
clust_peaks = nan(size(count_mtx_L,1),1);
for i = 1:size(count_mtx_L,1)
    clust_peaks(i) = find(comb_mtx(i, :) == nanmax(comb_mtx(i,:)), 1);
end

%find distance to nearest reward
cum_sect_bins = [16    38    65   100   116   138   165];
rwd_bins_RL = [cum_sect_bins(3) cum_sect_bins(7)];

%observed reward decoding preference
[all_class, all_posterior] = future_dec_linearized(count_mtx_R, count_mtx_L, cum_sect_bins, mean_dwell_time);

%plan was to see if observed deocidng preference varied as i shifted peak
%of each cell toward the reward locations.



