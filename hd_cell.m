function [rate_distributions, info_content] = hd_cell(varargin)
% function hd_cell(eptrials, clusters, angle_window, smooth_window, smooth_multiplier)
%
% hd_cell plots the firing rate of a single cells "clusters" over 360 
% degrees of head direction. eptrials, clusters, and angle_window are 
% required inputs, while smooth_window and smooth_multiplier are optional.
%
% INPUTS:
%   eptrials
%       eptrials is a data preprocessing matrix output by the function
%       "trials"
%   clusters
%       clusters is a vector of ID numbers of cells that will be plotted
%   angle_window
%       angle_window is the number of head direction samples that will be
%       averaged to produce an instantaneous head direction. angle_window
%       must be odd, and will be reduced by one if an even input is given. 
%       Try: 11.
%   smooth_window
%       smooth_window is an optional input that defines the width of the
%       sliding average used to smooth the distribution of firing rates
%       over 360 degrees. If only 3 inputs, no smoothing will occur.
%   smooth_multiplier
%       smooth_multiplier is an optional input that defines the number of
%       times smoothing will be repeated. If only 4 inputs, 
%       smooth_multiplier defaults to 1.
%        


%CHECK INPUTS
%
switch nargin
    case 0
        error(message('Need more input arguments'))
    case 1
        error(message('Need more input arguments'))
    case 2
        error(message('Need more input arguments'))
    case 3
        eptrials = varargin{1};
        clusters = varargin{2};
        angle_window = varargin{3};
        smooth_window = 0;
        smooth_multiplier = 0;
    case 4
        eptrials = varargin{1};
        clusters = varargin{2};
        angle_window = varargin{3};
        smooth_window = varargin{4};
        smooth_multiplier = 1;
    case 5
        eptrials = varargin{1};
        clusters = varargin{2};
        angle_window = varargin{3};
        smooth_window = varargin{4};
        smooth_multiplier = varargin{5};
    otherwise
        error(message('Too many input arguments'))
end
%
%force angle_window and smooth_window to be odd
if rem(angle_window, 2) ~= 0
    angle_window = ceil(angle_window) -1;
end
if rem(smooth_window, 2) ~= 0
    smooth_window = ceil(smooth_window) -1;
end


%WORKING VARIABLES
%
%how many video samples to skip in each iteration
iteration_jump = 20;
%
%window length
window_to_seconds = 0.01; %can change time conversion here
window_length = angle_window * window_to_seconds;
%
%cluster vectors
clust_pop = unique(eptrials(~isnan(eptrials(:,4)),4));
desired_clusters = sort(clusters);
%
%time point vectors
all_time_pts = eptrials(eptrials(:,14)==1, 1);
%begin_time_pts = all_time_pts(1:floor(angle_window/2));
%end_time_pts = all_time_pts((length(all_time_pts) - floor(angle_window/2)+1):end);
mid_time_pts = all_time_pts((floor(angle_window/2)+1):(length(all_time_pts) - floor(angle_window/2)));
%
%calculate instantaneous head direction
inst_hd = ceil(circ_smooth(eptrials(eptrials(:,14) == 1, 15), [0 360], angle_window));
inst_hd((length(inst_hd) - floor(angle_window/2)+1):end) = [];%trim end
inst_hd(1:floor(angle_window/2)) = [];%trim begining
inst_hd = inst_hd(1:iteration_jump:end);
%
%preallocate spike counts vector
spike_counts = nan(length(clust_pop), length(mid_time_pts));%length(all_time_pts)
%
%preallocate rate distribution matrix
count_distr = nan(length(clust_pop), 360);
rate_distr = nan(length(clust_pop), 360);
%
%set counter for angle window loop
iteration = 0;%length(begin_time_pts);


%CALCULATE INSTANTANEOUS SPIKE COUNTS
%
%iterate through middle time points (ignoring very ends)
for time_sample = 1:iteration_jump:length(mid_time_pts)
    
    %counter
    iteration = iteration + 1;

    %current time window
    %wndw_low = eptrials(eptrials(:,14) == 1 & eptrials(:,1) == all_time_pts(time_sample), 1);
    %wndw_high = eptrials(eptrials(:,14) == 1 & eptrials(:,1) == all_time_pts(time_sample + angle_window -1), 1);
    wndw_index = eptrials(:,1) >= all_time_pts(time_sample)...
        & eptrials(:,1) <= all_time_pts(time_sample + angle_window -1);
    
    %identify spike counts during window for each cluster
    current_spk_evts = eptrials(wndw_index, 4);
    spike_counts(:,iteration) = histc(current_spk_evts(~isnan(current_spk_evts)), unique(clust_pop));   
end
spike_counts = spike_counts(:, ~isnan(sum(spike_counts)));


%USE SPIKE COUNTS TO BUILD RATE DISTRIBUTION MATRIX
%
%number of windows corresponding to each head direction 1:360
hd_counts = histc(inst_hd, 1:360);
%
%number of spikes corresponding to each head direction 1:360
for dir = 1:360
    
    %avoiding empty sets
    if sum(double(inst_hd == dir),2) > 0
    
        %rate distribution at degree dir is equal to the sum of all spike
        %counts occuring in windows corresponding to that head direction.
        count_distr(:, dir) = sum(spike_counts(:, inst_hd == dir), 2);
    else
        count_distr(:, dir) = zeros(size(rate_distr(:, dir)));
    end
end
%
%time spent at each head direction
hd_time = hd_counts.*window_length;
%
%divide counts by time to get rates
rate_distr = bsxfun(@rdivide, count_distr, hd_time);


%CIRCULAR SMOOTH RATE DISTRIBUTION MATRIX
%
%if inputs call for smoothing
if smooth_multiplier > 0
    %pad rate distribution matrix
    rate_distr = [rate_distr rate_distr rate_distr];
    %
    %smooth one row (cluster) at a time
    for current_cluster = 1:size(rate_distr,1)
    
        %smooth_multiplier is the number of times smoothing is performed
        for smoothing_round = 1:smooth_multiplier
            rate_distr(current_cluster,:) = smooth(rate_distr(current_cluster,:), smooth_window);        
        end 
    end
    %
    %extract the now-smoothed matrix from the padded matrix
    rate_distr = rate_distr(:,((size(rate_distr,2)/3)+1):(size(rate_distr,2)*(2/3)));
end

%isolate distributions from desired cells
rate_distributions = rate_distr(ismember(clust_pop, desired_clusters),:);

%PLOT DESIRED RATE DISTRIBUTIONS
%
info_content = nan(length(clusters),1);
for cluster_number = 1:length(clusters)
    
    %active clusters
    current_cluster = desired_clusters(cluster_number);
    rate_distr_row = find(clust_pop==current_cluster, 1);

    %{
    figure
    plot(rate_distr(rate_distr_row,:), 'k', 'linewidth', 1.1)
    set(gca,'TickLength',[0, 0]); box off
    axis([0 360 0 max(rate_distr(rate_distr_row,:))*1.2])
    set(gca,'XTick', [1 90 180 270 360], 'fontsize', 17)
    title(num2str(current_cluster), 'fontsize', 20)
    ylabel('Mean Firing Rate (Hz)', 'fontsize', 20)
    xlabel('Head Direction (clockwise degrees)', 'fontsize', 20) 
    %}
    
    %probability of facing each direction
    %(occupying each direction bin)
    direction_p = hd_counts./nansum(hd_counts(:));
    
    %remove unvisited bins
    rd_hold = rate_distributions(cluster_number, direction_p>0);
    p_hold = direction_p(direction_p>0);
    
    %overall mean firing rate
    R = nansum(nansum(rd_hold.*p_hold));
    
    %for each direction bin
    info_content_dir = nan(360,1);

    %all directions
    ad = 1:360;
    
    %info content for each bin
    for i_dir = ad(direction_p>0)
        Pi = direction_p(i_dir);%probability of occupancy of bin i
        Ri = rate_distributions(cluster_number, i_dir);%mean firing rate for bin i
        if Ri==0
            Ri = 0.0000001;
        end
        rr = Ri/R;%relative rate
        info_content_dir(i_dir) = Pi*(rr)*log2(rr);%load info content for each bin

    end
    info_content(cluster_number) = sum(info_content_dir(direction_p>0));
    

    
    %title([num2str(current_cluster) ', info content: ' num2str(info_content(cluster_number))], 'fontsize', 20)
        
end




end