function [unfolded_section_pdecode, class, posterior] = decodesection_shuffle_p1(eptrials, bins, percent, stem_runs, count_matrix) 
% [p_matrix, unfolded_section_pdecode, bins] = decodesection_shuffle_p1(eptrials, cells, bins, percent, stem_runs) 

%This is part 1 of the shuffle compliment to decodesection
%
%

status = 'begin code'

coord_reconfig = bins:-1:1;%changes row coordinate/index from x,y (used by sections and the rectangle function) to i,j (used for matrix indexing)

%ESTABILISHING MAZE SECTIONS
%establishes maze section boundaries [xlow xhigh ylow yhigh] closely based on
%rectangle plots
sections = nan(10,4);
sections(1,:) = [bins*0.3750 bins*0.6250  1 bins*.3000]; %start area 1 1
sections(2,:) = [bins*0.3750 bins*0.6250 bins*.3000 bins*0.5375]; %low common stem 2 2
sections(3,:) = [bins*0.3750 bins*0.6250 bins*0.5375 bins*0.7625]; %high common stem 3 3
sections(4,:) = [bins*0.3750 bins*0.6250 bins*0.7625 bins]; %choice area 4 4
sections(5,:) = [bins*0.2000 bins*0.3750 bins*0.7125 bins]; %approach arm left 5 5
sections(6,:) = [bins*0.6250 bins*0.8000 bins*0.7125 bins]; %approach arm right 6 5
sections(7,:) = [1 bins*0.2000 bins*0.7125 bins]; %reward area left 7 6
sections(8,:) = [bins*0.8000 bins bins*0.7125 bins]; %reward area right 8 6
sections(9,:) = [1 bins*0.3750 1 bins*0.7125]; %return arm left 9 7
sections(10,:) = [bins*0.6250 bins 1 bins*0.7125]; %return arm right 10 7

%replace out of bounds
sections(sections<1) = 1;
sections(sections>80) = 80;
sections=round(sections);

%{
%pre-index for speed
spike_index = isfinite(eptrials(:,4)) & eptrials(:,4)~=1;
vid_sample_index = eptrials(:,14)==1; %interpolated video points (ie not spikes / events)

%all available time points given window size (cuts window/2 off each end)
time_set = eptrials(vid_sample_index & eptrials(:,1) >= min(eptrials(:,1)) + window/2 & eptrials(:,1) <= max(eptrials(:,1)) - window/2, 1);


%SPATIAL BINS

%evenly spaced bins of x and y coordinate ranges
xbins = linspace(min(eptrials(:,2)), max(eptrials(:,2))+.0001, bins + 1);
ybins = linspace(min(eptrials(:,3)), max(eptrials(:,3))+.0001, bins + 1);


%DETERMINE FIRING RATES AND SPATIAL LOCATIONS

%preallocate
count_matrix = NaN(length(time_set), length(cells));
group_ID = NaN(length(time_set), 1);

time_window_trial_numbers = eptrials(vid_sample_index & eptrials(:,1)>=time_set(1) & eptrials(:,1)<=time_set(end), 5);

size(count_matrix)
size(time_window_trial_numbers)

status = ['building rate matrix... ',num2str(length(time_set)), ' time windows by ',num2str(length(cells)), ' neurons']
progress = [];local_progress = '0%'

%iterate through time bins with sliding window
for i = 1:length(time_set)
  time_point = time_set(i);
  
    %fill rate matrix with instantaneous rates
    count_matrix(i,:) = histc(eptrials(spike_index & eptrials(:,1)>=time_point-window/2 & eptrials(:,1)<=time_point+window/2, 4), cells)';
   
    %grid position
    x = histc(eptrials(eptrials(:,1) == time_point & vid_sample_index, 2), xbins);
    y = histc(eptrials(eptrials(:,1) == time_point & vid_sample_index, 3), ybins);
    
    %fill group vector with spatial bin ID number
    group_ID(i) = find(y==1) + (find(x==1)-1)*bins;
    
    %report local progress
    if i/length(time_set) > .90 && progress == 81         
        progress = 91;local_progress = '91%';     
    elseif i/length(time_set) > .80 && progress == 71        
        progress = 81;local_progress = '81%'        
    elseif i/length(time_set) > .70 && progress == 61        
        progress = 71;local_progress = '71%';  
    elseif i/length(time_set) > .60 && progress == 51       
        progress = 61;local_progress = '61%'    
    elseif i/length(time_set) > .50 && progress == 41        
        progress = 51;local_progress = '51%';  
    elseif i/length(time_set) > .40 && progress == 31        
        progress = 41;local_progress = '41%'   
    elseif i/length(time_set) > .30 && progress == 21  
        progress = 31;local_progress = '31%';
    elseif i/length(time_set) > .20 && progress == 11 
        progress = 21;local_progress = '21%'        
    elseif i/length(time_set) > .10 && progress == 1   
        progress = 11;local_progress = '11%'; 
    elseif i/length(time_set) > .01 && isempty(progress)    
        progress = 1;local_progress = '1%'     
    end
    
end

status = 'rate matrix complete'
%}

status = 'training classifier...'

%CLASSIFY

%random index
%matrix_length = length(count_matrix(:,1));
%index = ismember(1:matrix_length, randsample(matrix_length, round(matrix_length*(percent/100))))';

%trial index
all_trials = unique(eptrials(:,5));

%training trials should all be correct, with equal numbers L and R
train_trials = [1;randsample(all_trials, floor(length(all_trials)*(percent/100)))]'; %always train on probe


time_window_trial_numbers = eptrials(vid_sample_index & eptrials(:,1)>=time_set(1) & eptrials(:,1)<=time_set(end), 5);
index = ismember(time_window_trial_numbers, train_trials);


%index for training matrix
training = count_matrix(index,:);

%index for group ID numbers
train_ID = group_ID(index);
    
%~index for sample matrix
sample = count_matrix(~index,:);
    
%index for sample ID numbers
samp_ID = group_ID(~index);

%classifier 
    %%%class is the group assignment
    %%%posterior is p(group j (unique(train_ID)) | obs i (time_set(~index)))
%[class,~,posterior] = classify(sample,training,train_ID,'diagLinear','empirical');
[class, posterior] = bayesian_decode(sample, training, train_ID, window, bins);

status = 'classifier complete'

%ouput classification success rate
classification_success = sum(samp_ID==class)/length(samp_ID)


status = 'building probability matrix...'
progress = [];local_progress = '0%'


%PROBABILITY MATRIX

%spatial grid IDs (number each pixle in bins x bins matrix)
grid = reshape((1:(bins^2))', bins, bins);

%replace non-visited bins with NaN.
grid(~ismember(grid, unique(samp_ID)')) = NaN;

%reshape grid to a column vector
grid = grid(:);

%sort grid to conform to ordering of posterior (an output of classify)
[grid_sort, sort_index] = sort(grid); 
    %identify unsort index
    unsort_index(sort_index) = 1:(bins^2);

%pre-index visited bin length for speed
vis_bin = length(posterior(1,:));

%pre-index time points for speed
sample_times = time_set(~index);

%preallocate p_distribution matrix for speed
unfolded_section_pdecode = nan(length(sample(:,1)), 14);


%iterate through sample time points
for samp = 1:length(sample(:,1))  %a:1:b

    %KEY STEP: replace grid ID values with corresponding probabilities from
    %posterior (an output of classify)
    grid_sort(1:vis_bin) = posterior(samp,:);
    
    %KEY STEP: use unsort index obtained above to reshape posterior vector
    %into probability matrix shaped like grid (heatmap-like matrix of
    %spatial positions)
    p_matrix = reshape(grid_sort(unsort_index), bins, bins);
    
    %flip p_matrix to match familiar orientation an
    p_matrix = flipud(p_matrix);

    %current time
    time_point = sample_times(samp);
    
    %sum pdecode within section boundaries, also include trial type and
    %section for subsequent indexing
    for sec = 1:10
        unfolded_section_pdecode(samp, sec) = nansum(nansum(p_matrix(coord_reconfig(sections(sec,4)):coord_reconfig(sections(sec,3)), sections(sec,1):sections(sec,2))));
    end
    
    unfolded_section_pdecode(samp, [11 12 13 14]) = eptrials(eptrials(:,1) == time_point & vid_sample_index, [5 6 7 8]);%trial number
    %unfolded_section_pdecode(samp, 12) = eptrials(eptrials(:,1) == time_point & vid_sample_index, 6);%current section
    %unfolded_section_pdecode(samp, 13) = eptrials(eptrials(:,1) == time_point & vid_sample_index, 7);%trial type
    %unfolded_section_pdecode(samp, 14) = eptrials(eptrials(:,1) == time_point & vid_sample_index, 8);%success/error
    unfolded_section_pdecode(samp, 15) = stem_runs(unfolded_section_pdecode(samp, 11), 3);%run_time
    
    %THIS CAN BE MODIFIED TO COUNT CENTER OF TIME POINT OR BOUNDS OF
    %TIME-SAMPLING WINDOW
    if time_point-window/2 >= stem_runs(unfolded_section_pdecode(samp, 11), 1) && time_point+window/2 <= stem_runs(unfolded_section_pdecode(samp, 11), 2)
        unfolded_section_pdecode(samp, 16) = 1;%a stem run
    else
        unfolded_section_pdecode(samp, 16) = 0;%not a stem run
    end
        
        
        
        
    %report local progress
    if samp/length(sample(:,1)) > .90 && progress == 81         
        progress = 91;local_progress = '91%'       
    elseif samp/length(sample(:,1)) > .80 && progress == 71        
        progress = 81;local_progress = '81%';        
    elseif samp/length(sample(:,1)) > .70 && progress == 61        
        progress = 71;local_progress = '71%'    
    elseif samp/length(sample(:,1)) > .60 && progress == 51       
        progress = 61;local_progress = '61%';    
    elseif samp/length(sample(:,1)) > .50 && progress == 41        
        progress = 51;local_progress = '51%'   
    elseif samp/length(sample(:,1)) > .40 && progress == 31        
        progress = 41;local_progress = '41%';   
    elseif samp/length(sample(:,1)) > .30 && progress == 21  
        progress = 31;local_progress = '31%'
    elseif samp/length(sample(:,1)) > .20 && progress == 11 
        progress = 21;local_progress = '21%';        
    elseif samp/length(sample(:,1)) > .10 && progress == 1   
        progress = 11;local_progress = '11%'   
    elseif samp/length(sample(:,1)) > .01 && isempty(progress)    
        progress = 1;local_progress = '1%';
    end
    
end

status = 'probability matrix complete'
%status = 'plotting decoder distributions...'


end





