function [classification_success, dists] = decodehist_popsize(eptrials, cells, bins, window, slide) 

%This code takes eptrials, and outputs a gif of the decoded
%position probability heat maps
%
%EPTRIALS is output by trials or trials_II.
%
%cells should be clusters or a subset of clusters output by trials(_II)
%
%bins is the number of bins on one side of a square grid encompassing the
%maze. Total number of bins is equal to bins^2. Higher values of bins 
%result in a finer (less coarse) grid, and increase the difficulty of the
%classification problem. Try: 40
%

%sliding window size
%window = .25; %try .1

if nargin == 8
    stem_runs = varargin{1};
end

%pre-index for speed
spike_index = isfinite(eptrials(:,4));
vid_sample_index = eptrials(:,14)==1;

%all available time points given window size (cuts window/2 off each end)
time_set = eptrials(vid_sample_index & eptrials(:,1) >= min(eptrials(:,1)) + window/2 & eptrials(:,1) <= max(eptrials(:,1)) - window/2, 1);
time_set_pos = eptrials(vid_sample_index & eptrials(:,1) >= min(eptrials(:,1)) + window/2 & eptrials(:,1) <= max(eptrials(:,1)) - window/2, [2 3]);
time_set_indices = eptrials(vid_sample_index & eptrials(:,1) >= min(eptrials(:,1)) + window/2 & eptrials(:,1) <= max(eptrials(:,1)) - window/2, [5 6 7 8 9]); %trial_num, maze_section, LR, acc, stem_section

%reduce time_set by sliding Xms per time point
%slide = 0.05;
if slide > 0.01
   time_slide_idx = zeros(size(time_set)); time_slide_idx(1) = 1;
   time_hold = time_set(1);
   for i = 2:length(time_set)
       if time_hold <= time_set(i)-slide
           time_slide_idx(i)=1;
           time_hold = time_set(i);
       end
   end
   time_slide_idx = logical(time_slide_idx);
   time_set = time_set(time_slide_idx,:);
   time_set_pos = time_set_pos(time_slide_idx,:);
   time_set_indices = time_set_indices(time_slide_idx,:);
end


%SPATIAL BINS

%evenly spaced bins of x and y coordinate ranges
%xbins = linspace(min(eptrials(:,2)), max(eptrials(:,2))+.0001, bins + 1);
%ybins = linspace(min(eptrials(:,3)), max(eptrials(:,3))+.0001, bins + 1);
xlow = 1000-200;
xhi = 1000+200;
ylow = 1000-200;
yhi = 1000+220;
xbins = linspace(xlow, xhi+.0001, bins + 1);
ybins = linspace(ylow, yhi+.0001, bins + 1);


%cut time bins with x,y positions outside of range
in_bounds = time_set_pos(:,1) > xlow & time_set_pos(:,1) < xhi & time_set_pos(:,2) > ylow & time_set_pos(:,2) < yhi;
time_set = time_set(in_bounds,:);
time_set_pos = time_set_pos(in_bounds,:);
time_set_indices = time_set_indices(in_bounds,:);


%DETERMINE FIRING RATES AND SPATIAL LOCATIONS

%preallocate
count_matrix = NaN(length(time_set), length(cells));
group_ID = NaN(length(time_set), 1);

%iterate through time bins with sliding window
for i = 1:length(time_set)
  time_point = time_set(i);
    
    %fill rate matrix with instantaneous rates
    count_matrix(i,:) = histc(eptrials(spike_index & eptrials(:,1)>=time_point-window/2 & eptrials(:,1)<=time_point+window/2, 4), cells)';
   
    %grid position
    x = histc(time_set_pos(i,1), xbins);
    y = histc(time_set_pos(i,2), ybins);
    
    %fill group vector with spatial bin ID number
    group_ID(i) = find(y==1) + (find(x==1)-1)*bins;
    
end


%remove group_IDs that weren't visited on a minimum number of unique trials
trials = unique(eptrials(eptrials(:,8)>0,5))';
min_visits = 6;%ceil(length(trials)/10);
visited_ids = zeros(length(trials), bins^2);
for trial = trials
    visited_ids(trial, unique(group_ID(time_set_indices(:,1)==trial))') = 1; 
end



nonvisited_ids = find(sum(visited_ids)<min_visits);
purge_idx = ismember(group_ID, nonvisited_ids);

    %purge
    time_set(purge_idx,:) = [];
    time_set_pos(purge_idx,:) = [];
    time_set_indices(purge_idx,:) = [];
    count_matrix(purge_idx,:) = [];
    group_ID(purge_idx,:) = [];

    total_visited_pixles = length(unique(group_ID));
    
%CLASSIFY trial by trial
if exist('stem_runs', 'var')
    %good stemrun trials
    trials = trials(stem_runs(2:end,3)<1.25);
    
    posterior_all = nan(length(trials), bins^2);%preallocate
else
    posterior_all = nan(length(time_set), bins^2);%preallocate
end
%posterior_all = nan(length(time_set), bins^2);%preallocate

%preallocate
class_all = nan(length(time_set), 1);
trial_type_idx = nan(length(time_set), 1);

count = 0;
for trial = trials
    count = count + 1;
    %index for current trial
            %trial_num, maze_section, LR, acc, stem_section
    index = time_set_indices(:,1) == trial;
    
    
    %left or right
    trial_type = mode(eptrials(eptrials(:,5)==trial,7));
    
    %index for sample matrix
    %sample = count_matrix(index,:);
    if exist('stem_runs', 'var')
        stem_index = time_set > stem_runs(trial,1) & time_set < stem_runs(trial,2);  %WIP WIP WIP WIP WIP WIP WIP
        sample = count_matrix(index & stem_index,:);
    else 
        sample = count_matrix(index,:);
    end

    %index for sample ID numbers
    %samp_ID = group_ID(index);

    %~index for training matrix
    training = count_matrix(~index,:);

    %~index for group ID numbers
    train_ID = group_ID(~index);

    %classifier
    %
    %[class,~,posterior] = classify(sample,training,train_ID,'diagLinear','empirical');
    %[class,~,posterior] = classify(sample,training,train_ID,'diagLinear');
    %
    [class, posterior] = bayesian_decode(sample, training, train_ID, window, bins);
    %
    %class = the group assignment
    %posterior = p(group j (unique(train_ID)) | obs i (time_set(~index)))

    %ouput classification success rate
    %classification_success = sum(samp_ID==class)/length(samp_ID);
    
    if exist('stem_runs', 'var')
        class_all(stem_index, :) = class; %%%%%
        posterior_all(count, unique(train_ID)) = nanmean(posterior);
        trial_type_idx(stem_index, :) = trial_type;
        %posterior_all(index & stem_index, unique(train_ID)) = nanmean(posterior);
        %posterior_all(stem_index, unique(train_ID)) = nanmean(posterior);
    else
        class_all(index, :) = class;
        posterior_all(index, unique(train_ID)) = posterior;
        %trial_type_idx(stem_index, :) = trial_type;
    end
end

%trim output (remove probe trial)
first_timepoint = min(time_set(time_set_indices(:,1) == min(trials)));
class_all = class_all(time_set>first_timepoint, :);
trial_type_idx = trial_type_idx(time_set>first_timepoint, :);
%posterior_all = posterior_all(time_set>first_timepoint, :);
group_ID = group_ID(time_set>first_timepoint, :);
count_matrix = count_matrix(time_set>first_timepoint, :);
time_set_indices = time_set_indices(time_set>first_timepoint, :);

%ouput classification success rate
classification_success = sum(class_all(:,1)==group_ID)/size(class_all,1);

%calculate distance between correct and guessed bins
dists = all_spatial_dists(class_all, group_ID, bins);

    function d = all_spatial_dists(c, g, b)

        [ic, jc] = ind2sub([b b], c);
        [ig, jg] = ind2sub([b b], g); 
        
        d = dist([ic jc], [ig, jg]');
        d = d(diag_mask(b));
        
    end



end




