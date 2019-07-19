function [count_matrix, group_ID] = countmatrix(eptrials, cells, bins, window)

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
    %count_matrix(i,:) = histc(eptrials(spike_index & eptrials(:,1)>=time_point-window/2 & eptrials(:,1)<=time_point+window/2, 4), cells)';
   
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
status = 'training classifier...'

end