function [classification_success, posterior_all, class_all, class_shuf, group_ID, p_sections_norm, trial_type_idx, p_sections_NotNormed, p_sections_numpix] = decodehist(eptrials, cells, bins, window, slide, vect2mat_idx, shuffs, varargin) 

%This code takes eptrials, and outputs a gif of the decoded
%position probability heat maps
%
%EPTRIALS is output by trials or trials_II.
%
%cells should be clusters or a subset of clusters output by trials(_III)
%
%bins is the number of bins on one side of a square grid encompassing the
%maze. Total number of bins is equal to bins^2. Higher values of bins 
%result in a finer (less coarse) grid, and increase the difficulty of the
%classification problem. Try: 40
%

%sliding window size
%window = .25; %try .1


%ESTABILISHING MAZE SECTIONS
%establishes maze section boundaries [xlow xhigh ylow yhigh] closely based on
%rectangle plots
%{
sections = nan(10,4);
sections(1,:) = (1:bins*.3000, bins*0.3750:bins*0.62500); %start area 1 1
sections(2,:) = (bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250); %low common stem 2 2
sections(3,:) = (bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250); %high common stem 3 3
sections(4,:) = (bins*0.7625:bins, bins*0.3750:bins*0.6250); %choice area 4 4
sections(5,:) = (bins*0.7125:bins, bins*0.2000:bins*0.3750); %approach arm left 5 5
sections(6,:) = (bins*0.7125:bins, bins*0.6250:bins*0.8000); %approach arm right 6 5
sections(7,:) = (bins*0.7125:bins, 1:bins*0.2000); %reward area left 7 6
sections(8,:) = (bins*0.7125:bins, bins*0.8000:bins); %reward area right 8 6
sections(9,:) = (1:bins*0.7125, 1:bins*0.3750); %return arm left 9 7
sections(10,:) = (1:bins*0.7125, bins*0.6250:bins); %return arm right 10 7
%}


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
min_visits = ceil(length(trials)*0.13); %use for correct only
%min_visits = round(length(trials)*0.10); %use for all trials
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
train_id_all = nan(length(time_set), 1);
trial_type_idx = nan(length(time_set), 1);

count = 0;
for trial = trials
    
    
    %trial
    %[stem_runs(trial,1) stem_runs(trial,2)]
    
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
    
    %class
    
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
        trial_type_idx(index, :) = trial_type;
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


%HEAT MAP GIF
%{
%index time points
sample_times = time_set(time_set>first_timepoint);
%minpositions
%minx = min(time_set_pos(time_set>first_timepoint,1));
%miny = min(time_set_pos(time_set>first_timepoint,2));
%range (pcolor drops last column and row)
%rngx = (max(time_set_pos(time_set>first_timepoint,1)) - minx);%bins;%(bins-1);
%rngy = (max(time_set_pos(time_set>first_timepoint,2)) - miny);%bins;%(bins-1);

%find actual position
pos_actual = nan(size(posterior_all,1),1);
for samp = 1:size(posterior_all,1)
    actual_loc = zeros(size(posterior_all(samp,:)));
    actual_loc(samp, group_ID(samp)) = 1;
    actual_loc = reshape(actual_loc(samp,:), bins, bins);
    [y_actual,x_actual] = find(actual_loc==1);
    pos_actual(samp, 1) = x_actual+.5;
    pos_actual(samp, 2) = y_actual+.5;    
end
pos_actual(:,1) = smooth(pos_actual(:,1), 5);
pos_actual(:,2) = smooth(pos_actual(:,2), 5);



figure;

size(posterior_all,1)

%iterate through sample time points to make gif of probability heatmaps
for samp = 1:size(posterior_all,1) %a:1:b %

    %replace grid ID values with corresponding probabilities from posterior
    %grid_sort(1:vis_bin) = posterior_all(samp,:);
    
    
    
    %probability matrix
    %p_matrix = reshape(grid_sort(unsort_index), bins, bins);
    p_matrix = reshape(posterior_all(samp,:), bins, bins);
    
    %probability heat map
    pcolor(p_matrix);
    shading('flat')
    ylim([0 bins+2]);
    xlim([0 bins+1]);
    axis equal
    
    %plot actual and predicted positions
    hold on
    time_point = sample_times(samp);
    %[px,py] = find(p_matrix'==max(max(p_matrix(1:end-1, 1:end-1))));
    %plot(px+.5, py+.5, 'o', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'linewidth', 5) %predicted
    
    %xpos = (eptrials(eptrials(:,1) == time_point & vid_sample_index, 2) - minx)/rngx;
    %ypos = (eptrials(eptrials(:,1) == time_point & vid_sample_index, 3) - miny)/rngy;
    %xpos = (xpos*(bins-1))+.5;
    %ypos = (ypos*(bins-1))+.5;
    %plot(xpos, ypos, 'o', 'MarkerEdgeColor', [.6 .6 .6], 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'linewidth', 5) %actual
    
    plot(pos_actual(samp,1), pos_actual(samp,2), 'o', 'MarkerEdgeColor', [.6 .6 .6], 'MarkerFaceColor', 'none', 'MarkerSize', 20, 'linewidth', 5) %group_ID
    
    caxis([0 .05])
    colorbar
    colormap jet
    
    hold off
    
    box off
    set(gca, 'Ticklength', [0 0])
    set(gca, 'XTick', [])
    set(gca, 'YTick', [])
    
    %plot section boundaries
    %for i = 1:10
    %    rectangle('Position', [sections(i,1), sections(i,3), (sections(i,2) - sections(i,1)),  (sections(i,4) - sections(i,3))]);
    %end
    %hold off

    title(num2str(eptrials(eptrials(:,1) == time_point & vid_sample_index, 5)-1));
    
    %capture image (LEAVE COMPUTER ALONE DURING THIS PROCESS)
    frame = getframe;
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    outfile = 'decoder_1836_ot_4.gif';

    %on the first loop, create the file. In subsequent loops, append.
    %
    if samp== a
        imwrite(imind,cm,outfile,'gif','DelayTime',0,'loopcount',inf);
    else
        imwrite(imind,cm,outfile,'gif','DelayTime',0,'writemode','append');
    end
    
   %} 
%}  


%SHUFFLE
class_shuf = nan(size(count_matrix,1), shuffs);
jitter_direction = [-1 1];

for shuf = 1:shuffs
    
    count_matrix_shuf = nan(size(count_matrix));
    
    %shuffle index matrix
    %randomly shuffle time bins for each cell
    %{
    for i = 1:size(count_matrix,2)
        count_matrix_shuf(:,i) = count_matrix(randperm(size(count_matrix,1)), i);
    end
    %}
    
    %Alternative shuffle
    %jitter time series uniformly (indv for each cell) between 10 and 30 s
    for i = 1:size(count_matrix,2)
        
        jitter_s = 10 + rand(1)*20;
        jitter_direction = jitter_direction(randperm(length(jitter_direction)));
        jitter_s = jitter_s.*jitter_direction(1);
        num_window_shift = round(jitter_s/window);
        
        count_matrix_shuf(:,i) = circshift(count_matrix(:,i), num_window_shift);
    end
    %count_matrix_shuf = circshift(count_matrix, num_window_shift, 1);
    
    %classify and report success
    %class_shuf = nan(size(count_matrix_shuf,1),2);
    for trial = trials
        
        index = time_set_indices(:,1) == trial;
        sample = count_matrix_shuf(index,:);
        %samp_ID = group_ID(index);
        training = count_matrix_shuf(~index,:);
        train_ID = group_ID(~index);
        
        [class, ~] = bayesian_decode(sample, training, train_ID, window, bins);
        
        class_shuf(index, shuf) = class;
        
    end
end

%section probabilities by trial type
%p_sections_norm = [];
%
min_traj_dec = 0.01;
correct_trials = unique(eptrials(eptrials(:,8)==1, 5));
error_trials = unique(eptrials(eptrials(:,8)==2, 5));

left_trials = intersect(trials, unique(eptrials(eptrials(:,7)==1, 5)));
left_trials = intersect(left_trials, correct_trials); %CORRECT ONLY
%left_trials = intersect(left_trials, error_trials);

%length(left_trials)

if length(left_trials)>1
    hold1 = posterior_all(ismember(trials,left_trials),:);
    hold_idx = nansum(hold1(:, vect2mat_idx==4), 2) >= min_traj_dec;
    hold1 = nanmean(hold1(hold_idx,:),1);
    left_probs = reshape(hold1, 50, 50);
    
    %fliphold = fliplr(left_probs);
    %fliphold(~isnan(fliphold))=1;
    
    %left_probs = left_probs.*fliphold;
    
    
    
else
    size(posterior_all(ismember(trials,left_trials),:))
    left_probs = reshape(posterior_all(ismember(trials,left_trials),:), 50, 50);
end

right_trials = intersect(trials, unique(eptrials(eptrials(:,7)==2, 5)));
right_trials = intersect(right_trials, correct_trials); %CORRECT ONLY
%right_trials = intersect(right_trials, error_trials);

%length(right_trials)


if length(right_trials)>1
    hold1 = posterior_all(ismember(trials,right_trials),:);
    hold_idx = nansum(hold1(:, vect2mat_idx==4), 2) >= min_traj_dec;
    hold1 = nanmean(hold1(hold_idx,:),1);
    right_probs = reshape(hold1, 50, 50);
    
    %right_probs = right_probs.*fliphold;
else
    right_probs = reshape(posterior_all(ismember(trials,right_trials),:), 50, 50);
end
warning('off','all')

%sum probabilities / number of pixles
p_sections_NotNormed = nan(12,2);
p_sections_NotNormed(1,:) = [nansum(nansum(left_probs(1:bins*.3000, bins*0.3750:bins*0.62500))) nansum(nansum(right_probs(1:bins*.3000, bins*0.3750:bins*0.62500)))]; %start area 1 1
p_sections_NotNormed(2,:) = [nansum(nansum(left_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250)))]; %low common stem 2 2
p_sections_NotNormed(3,:) = [nansum(nansum(left_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250)))]; %high common stem 3 3
p_sections_NotNormed(4,:) = [nansum(nansum(left_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250)))]; %choice area 4 4
p_sections_NotNormed(5,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750)))]; %approach arm left 5 5
p_sections_NotNormed(6,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000)))]; %approach arm right 6 5
p_sections_NotNormed(7,:) = [nansum(nansum(left_probs(bins*0.7125:bins, 1:bins*0.2000))) nansum(nansum(right_probs(bins*0.7125:bins, 1:bins*0.2000)))]; %reward area left 7 6
p_sections_NotNormed(8,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.8000:bins))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.8000:bins)))]; %reward area right 8 6
p_sections_NotNormed(9,:) = [nansum(nansum(left_probs(1:bins*0.7125, 1:bins*0.3750))) nansum(nansum(right_probs(1:bins*0.7125, 1:bins*0.3750)))]; %return arm left 9 7
p_sections_NotNormed(10,:) = [nansum(nansum(left_probs(1:bins*0.7125, bins*0.6250:bins))) nansum(nansum(right_probs(1:bins*0.7125, bins*0.6250:bins)))]; %return arm right 10 7
p_sections_NotNormed(11,:) = [nansum(nansum(left_probs(bins*0.7625:bins, bins*0.3750:bins*0.5))) nansum(nansum(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.5)))]; %choice area left 4 4
p_sections_NotNormed(12,:) = [nansum(nansum(left_probs(bins*0.7625:bins, bins*0.5:bins*0.6250))) nansum(nansum(right_probs(bins*0.7625:bins, bins*0.5:bins*0.6250)))]; %choice area right 4 4

p_sections_numpix = nan(12,2);
p_sections_numpix(1,:) = [sum(sum(~isnan(left_probs(1:bins*.3000, bins*0.3750:bins*0.62500))))  sum(sum(~isnan(right_probs(1:bins*.3000, bins*0.3750:bins*0.62500))))]; %start area 1 1
p_sections_numpix(2,:) = [sum(sum(~isnan(left_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250))))  sum(sum(~isnan(right_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250))))]; %low common stem 2 2
p_sections_numpix(3,:) = [sum(sum(~isnan(left_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250))))  sum(sum(~isnan(right_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250))))]; %high common stem 3 3
p_sections_numpix(4,:) = [sum(sum(~isnan(left_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250))))  sum(sum(~isnan(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250))))]; %choice area 4 4
p_sections_numpix(5,:) = [sum(sum(~isnan(left_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750))))  sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750))))]; %approach arm left 5 5
p_sections_numpix(6,:) = [sum(sum(~isnan(left_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000))))  sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000))))]; %approach arm right 6 5
p_sections_numpix(7,:) = [sum(sum(~isnan(left_probs(bins*0.7125:bins, 1:bins*0.2000))))  sum(sum(~isnan(right_probs(bins*0.7125:bins, 1:bins*0.2000))))]; %reward area left 7 6
p_sections_numpix(8,:) = [sum(sum(~isnan(left_probs(bins*0.7125:bins, bins*0.8000:bins))))  sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.8000:bins))))]; %reward area right 8 6
p_sections_numpix(9,:) = [sum(sum(~isnan(left_probs(1:bins*0.7125, 1:bins*0.3750))))  sum(sum(~isnan(right_probs(1:bins*0.7125, 1:bins*0.3750))))]; %return arm left 9 7
p_sections_numpix(10,:) = [sum(sum(~isnan(left_probs(1:bins*0.7125, bins*0.6250:bins))))  sum(sum(~isnan(right_probs(1:bins*0.7125, bins*0.6250:bins))))]; %return arm right 10 7
p_sections_numpix(11,:) = [sum(sum(~isnan(left_probs(bins*0.7625:bins, bins*0.3750:bins*0.5))))  sum(sum(~isnan(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.5))))]; %choice area left 4 4
p_sections_numpix(12,:) = [sum(sum(~isnan(left_probs(bins*0.7625:bins, bins*0.5:bins*0.6250))))  sum(sum(~isnan(right_probs(bins*0.7625:bins, bins*0.5:bins*0.6250))))]; %choice area right 4 4

%average decoding per pixle in area
p_sections = nan(12,2);
p_sections(1,:) = p_sections_NotNormed(1,:)./p_sections_numpix(1,:); %start area 1 1
p_sections(2,:) = p_sections_NotNormed(2,:)./p_sections_numpix(2,:); %low common stem 2 2
p_sections(3,:) = p_sections_NotNormed(3,:)./p_sections_numpix(3,:); %high common stem 3 3
p_sections(4,:) = p_sections_NotNormed(4,:)./p_sections_numpix(4,:); %choice area 4 4
p_sections(5,:) = p_sections_NotNormed(5,:)./p_sections_numpix(5,:); %approach arm left 5 5
p_sections(6,:) = p_sections_NotNormed(6,:)./p_sections_numpix(6,:); %approach arm right 6 5
p_sections(7,:) = p_sections_NotNormed(7,:)./p_sections_numpix(7,:); %reward area left 7 6
p_sections(8,:) = p_sections_NotNormed(8,:)./p_sections_numpix(8,:); %reward area right 8 6
p_sections(9,:) = p_sections_NotNormed(9,:)./p_sections_numpix(9,:); %return arm left 9 7
p_sections(10,:) = p_sections_NotNormed(10,:)./p_sections_numpix(10,:); %return arm right 10 7
p_sections(11,:) = p_sections_NotNormed(11,:)./p_sections_numpix(11,:); %choice area left 4 4
p_sections(12,:) = p_sections_NotNormed(12,:)./p_sections_numpix(12,:); %choice area right 4 4

%backup
%{
p_sections = nan(12,2);
p_sections(1,:) = [nansum(nansum(left_probs(1:bins*.3000, bins*0.3750:bins*0.62500))) nansum(nansum(right_probs(1:bins*.3000, bins*0.3750:bins*0.62500)))]./sum(sum(~isnan(right_probs(1:bins*.3000, bins*0.3750:bins*0.62500)))); %start area 1 1
p_sections(2,:) = [nansum(nansum(left_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250)))]./sum(sum(~isnan(right_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250)))); %low common stem 2 2
p_sections(3,:) = [nansum(nansum(left_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250)))]./sum(sum(~isnan(right_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250)))); %high common stem 3 3
p_sections(4,:) = [nansum(nansum(left_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250)))]./sum(sum(~isnan(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250)))); %choice area 4 4
p_sections(5,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750)))); %approach arm left 5 5
p_sections(6,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000)))); %approach arm right 6 5
p_sections(7,:) = [nansum(nansum(left_probs(bins*0.7125:bins, 1:bins*0.2000))) nansum(nansum(right_probs(bins*0.7125:bins, 1:bins*0.2000)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, 1:bins*0.2000)))); %reward area left 7 6
p_sections(8,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.8000:bins))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.8000:bins)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.8000:bins)))); %reward area right 8 6
p_sections(9,:) = [nansum(nansum(left_probs(1:bins*0.7125, 1:bins*0.3750))) nansum(nansum(right_probs(1:bins*0.7125, 1:bins*0.3750)))]./sum(sum(~isnan(right_probs(1:bins*0.7125, 1:bins*0.3750)))); %return arm left 9 7
p_sections(10,:) = [nansum(nansum(left_probs(1:bins*0.7125, bins*0.6250:bins))) nansum(nansum(right_probs(1:bins*0.7125, bins*0.6250:bins)))]./sum(sum(~isnan(right_probs(1:bins*0.7125, bins*0.6250:bins)))); %return arm right 10 7
p_sections(11,:) = [nansum(nansum(left_probs(bins*0.7625:bins, bins*0.3750:bins*0.5))) nansum(nansum(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.5)))]./sum(sum(~isnan(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.5)))); %choice area left 4 4
p_sections(12,:) = [nansum(nansum(left_probs(bins*0.7625:bins, bins*0.5:bins*0.6250))) nansum(nansum(right_probs(bins*0.7625:bins, bins*0.5:bins*0.6250)))]./sum(sum(~isnan(right_probs(bins*0.7625:bins, bins*0.5:bins*0.6250)))); %choice area right 4 4
%}

warning('on','all')

%set to percent
p_sections_NotNormed = [p_sections_NotNormed(:,1)./sum(p_sections_NotNormed(1:10,1)) p_sections_NotNormed(:,2)./sum(p_sections_NotNormed(1:10,2))];
p_sections_numpix = [p_sections_numpix(:,1)./sum(p_sections_numpix(1:10,1)) p_sections_numpix(:,2)./sum(p_sections_numpix(1:10,2))];
p_sections_norm = [p_sections(:,1)./sum(p_sections(1:10,1)) p_sections(:,2)./sum(p_sections(1:10,2))];

%combine stem
p_sections_NotNormed = [p_sections_NotNormed(1,:); sum(p_sections_NotNormed(2:3,:)); p_sections_NotNormed(4:end,:)]; %combine_stem
p_sections_numpix = [p_sections_numpix(1,:); sum(p_sections_numpix(2:3,:)); p_sections_numpix(4:end,:)]; %combine_stem
p_sections_norm = [p_sections_norm(1,:); sum(p_sections_norm(2:3,:)); p_sections_norm(4:end,:)]; %combine_stem
%}


end




