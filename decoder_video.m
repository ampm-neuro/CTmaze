function decoder_video(eptrials, cells, bins, window, slide, varargin)

%This code takes eptrials, and outputs a gif of the decoded
%position probability heat maps

vid_trials = unique(eptrials(eptrials(:,8)>0,5));

if nargin == 6
    vid_trials = varargin{1}
    vid_trials = vid_trials + ones(size(vid_trials));
elseif nargin == 7
    vid_trials = varargin{1}
     vid_trials = vid_trials + ones(size(vid_trials));
    stem_runs = varargin{2};
end

if size(vid_trials,1)>size(vid_trials,2)
    vid_trials = vid_trials';
end

%pre-index for speed
spike_index = isfinite(eptrials(:,4));
vid_sample_index = eptrials(:,14)==1;

%all available time points given window size (cuts window/2 off each end)
time_set = eptrials(vid_sample_index & eptrials(:,1) >= min(eptrials(:,1)) + window/2 & eptrials(:,1) <= max(eptrials(:,1)) - window/2, 1);
time_set_pos = eptrials(vid_sample_index & eptrials(:,1) >= min(eptrials(:,1)) + window/2 & eptrials(:,1) <= max(eptrials(:,1)) - window/2, [2 3]);
time_set_indices = eptrials(vid_sample_index & eptrials(:,1) >= min(eptrials(:,1)) + window/2 & eptrials(:,1) <= max(eptrials(:,1)) - window/2, [5 6 7 8 9]); %trial_num, maze_section, LR, acc, stem_section

%reduce time_set by sliding Xms per time point
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
    if exist('stem_runs', 'var')
        trials = trials(stem_runs(2:end,3)<1.25);
    end
min_visits = 8;%floor(length(trials)/5);
visited_ids = zeros(length(trials), bins^2);
for trial = trials
    visited_ids(trial, unique(group_ID(time_set_indices(:,1)==trial))') = 1; 
end

nonvisited_ids = find(sum(visited_ids) < min_visits);
purge_idx = ismember(group_ID, nonvisited_ids);
purge_idx_trial = ~ismember(time_set_indices(:,1), trials);

    %purge
    time_set(purge_idx | purge_idx_trial,:) = [];
    time_set_pos(purge_idx | purge_idx_trial,:) = [];
    time_set_indices(purge_idx | purge_idx_trial,:) = [];
    count_matrix(purge_idx | purge_idx_trial,:) = [];
    group_ID(purge_idx | purge_idx_trial,:) = [];

    total_visited_pixles = length(unique(group_ID));
    
%CLASSIFY trial by trial
posterior_all = nan(length(time_set), bins^2);%preallocate

%preallocate
class_all = nan(length(time_set), 1);

for trial = vid_trials

    %index for current trial
            %trial_num, maze_section, LR, acc, stem_section
    index = time_set_indices(:,1) == trial;
    
    %index for sample ID numbers
    %samp_ID = group_ID(index);

    %~index for training matrix
    training = count_matrix(~index,:);

    %~index for group ID numbers
    train_ID = group_ID(~index);

    %index for sample matrix
    if exist('stem_runs', 'var')        
        stem_index = time_set > stem_runs(trial,1)-1 & time_set < stem_runs(trial,2)+2;
        index = index & stem_index;
    end
    sample = count_matrix(index,:);
    
    %bayesian classifier
    [class, posterior] = bayesian_decode(sample, training, train_ID, window, bins);
    %
    %class = the group assignment
    %posterior = p(group j (unique(train_ID)) | obs i (time_set(~index)))

    class_all(index, :) = class;
    posterior_all(index, unique(train_ID)) = posterior;

end

time_set

%trim output (remove probe trial)
first_timepoint = min(time_set(time_set_indices(:,1) == min(unique(eptrials(eptrials(:,8)>0,5)))))
time_set = time_set(time_set>first_timepoint, :);
class_all = class_all(time_set>first_timepoint, :);
posterior_all = posterior_all(time_set>first_timepoint, :);
group_ID = group_ID(time_set>first_timepoint, :);
count_matrix = count_matrix(time_set>first_timepoint, :);
time_set_indices = time_set_indices(time_set>first_timepoint, :);

%trim unclassified time samples
posterior_all = posterior_all(~isnan(class_all), :);
time_set = time_set(~isnan(class_all), :);
group_ID = group_ID(~isnan(class_all), :);
count_matrix = count_matrix(~isnan(class_all), :);
time_set_indices = time_set_indices(~isnan(class_all), :);
class_all = class_all(~isnan(class_all));

%ouput classification success rate
classification_success = sum(class_all(:,1)==group_ID)/size(class_all,1)

%if classification_success > .1 || classification_success < .05
%    return
%end

%HEAT MAP GIF
%
%index time points
sample_times = time_set;

%find actual position
pos_actual = nan(size(posterior_all,1),1);
for samp = 1:size(posterior_all,1)
    actual_loc = zeros(size(posterior_all(samp,:)));
    actual_loc(samp, group_ID(samp)) = 1;
    actual_loc = reshape(actual_loc(samp,:), bins, bins);
    [y_actual, x_actual] = find(actual_loc==1);
    pos_actual(samp, 1) = x_actual+.5;
    pos_actual(samp, 2) = y_actual+.5;    
end
for trl = 1:length(vid_trials)
    pos_actual(time_set_indices(:,1)==trl,1) = smooth(pos_actual(time_set_indices(:,1)==trl,1), 5);
    pos_actual(time_set_indices(:,1)==trl,2) = smooth(pos_actual(time_set_indices(:,1)==trl,2), 5);
end

figure;

%iterate through sample time points to make gif of probability heatmaps
for samp = 1:size(posterior_all,1)

    %probability matrix
    p_matrix = reshape(posterior_all(samp,:), bins, bins);
    
    %probability heat map
    pcolor(p_matrix);
    shading('flat')
    ylim([0 bins+2]);
    xlim([0 bins+1]);
    axis equal
    
    %plot actual and predicted positions
    hold on
    %time_point = sample_times(samp);
    [px,py] = find(p_matrix'==max(max(p_matrix(1:end-1, 1:end-1))));
    %plot(px+.5, py+.5, 'o', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'linewidth', 5) %predicted
    plot(pos_actual(samp,1), pos_actual(samp,2), 'o', 'MarkerEdgeColor', [.6 .6 .6], 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'linewidth', 5) %group_ID
    
    %caxis([0 .02])
    %colorbar
    colormap jet
    
    hold off
    
    box off
    set(gca, 'Ticklength', [0 0])
    set(gca, 'XTick', [])
    set(gca, 'YTick', [])
    
    %title(num2str(eptrials(eptrials(:,1) == time_point & vid_sample_index, 5)-1));
    
    if time_set_indices(samp,3) == 1
        title([num2str(time_set_indices(samp,1)-1) ' Left']);
    elseif time_set_indices(samp,3) == 2
        title([num2str(time_set_indices(samp,1)-1) ' Right']);
    end
    
    %capture image (LEAVE COMPUTER ALONE DURING THIS PROCESS)
    frame = getframe;
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    outfile = ['C:\Users\ampm1\Desktop\dec_vid\1825_5' num2str(vid_trials - ones(size(vid_trials))) '.gif'];
    %outfile = '/Users/ampm/Documents/MATLAB/decoded_hists/ftrtraj_1860_ot_4_stems.gif';

    
    %on the first loop, create the file. In subsequent loops, append. 
    if samp== 1
        imwrite(imind,cm,outfile,'gif','DelayTime',0,'loopcount',inf);
    elseif rem(samp,10)==0
        
        %if dist([px+.5, py+.5], [pos_actual(samp,1), pos_actual(samp,2)]') > 7
        %    continue
        %end
        
        
        imwrite(imind,cm,outfile,'gif','DelayTime',0,'writemode','append');
    end

end

end


