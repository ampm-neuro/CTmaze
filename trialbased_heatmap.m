function [alltrials_rate, alltrials_spikes, alltrials_time] = trialbased_heatmap(eptrials, clust, bins, min_trialvisits, min_dwelltime, varargin)
%makes heatmap, excluding pixles visited on fewer than min_visits number of
%different trials
%
%eptrials, clust, bins (same for x and y), and varargin figure_on (default
%is off

%INPUT
%
%if figure_on is input
if nargin == 6
    figure_on = varargin{1};
else
    figure_on = 0;
end

%overall x y position bounds
min_max = [min(eptrials(:,2)) max(eptrials(:,2));... %xpos
           min(eptrials(:,3)) max(eptrials(:,3))]; %ypos

%number of trials
all_trials = unique(eptrials(:,5))';
left_trials = unique(eptrials(eptrials(:,7)==1,5))';
right_trials = unique(eptrials(eptrials(:,7)==2,5))';
correct_trials = unique(eptrials(eptrials(:,8)==1,5))';
error_trials = unique(eptrials(eptrials(:,8)==2,5))';

%included_vectors = intersect(correct_trials, left_trials);
%all_trials = intersect(all_trials, included_vectors);

all_trials = correct_trials;

%preallocate 3d rate matrix
alltrials_spikes = nan(bins, bins, length(all_trials));
alltrials_time = nan(bins, bins, length(all_trials));

%calculate rate maps individually for each trial
trl_count = 0;
for it = all_trials
    
    trl_count = trl_count+1;
    [~, alltrials_spikes(:,:,trl_count), alltrials_time(:,:,trl_count)] = ...
        trlfree_heatmap(eptrials(eptrials(:,5)==it,:), clust, bins, 0, min_max);
end

%identify number of visits to each pixle
visits_mtx = alltrials_time;
visits_mtx(visits_mtx>0) = 1;
visits_mtx = nansum(visits_mtx,3);

%identify pixles with sufficient
visits_mtx = visits_mtx >= min_trialvisits;

%eliminate pixles with insufficient visits
alltrials_spikes = alltrials_spikes.*visits_mtx;
alltrials_time = alltrials_time.*visits_mtx;

%sum across trials
alltrials_spikes = sum(alltrials_spikes, 3);
alltrials_time = sum(alltrials_time, 3);

%eliminate pixles with insufficient dwell time
alltrials_spikes(alltrials_time<min_dwelltime) = 0;
alltrials_time(alltrials_time<min_dwelltime) = 0;

%compute rate matrix
alltrials_rate = alltrials_spikes./alltrials_time;


%PLOT
%
%plot if desired
if figure_on == 1
    
    %smooth
    %alltrials_rate = smooth2a(alltrials_rate,1);
    
    figure; imagesc(alltrials_rate); colorbar; title([num2str(clust) ' minvisit' num2str(min_trialvisits)])
end

