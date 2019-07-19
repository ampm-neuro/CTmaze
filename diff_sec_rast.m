function [cell_vislengths, spike_times, visit_lengths] = diff_sec_rast(ep, clusters, varargin)
%function [visit_lengths] = diff_sec_rast(eptrials, clusters, folded_section)
%
%plots left and right rasters for visits to a folded section over all
%trials
%
%section is folded section
if nargin ==3
    section = varargin{1};
elseif nargin == 4
    enter_section = varargin{1};
    exit_section = varargin{2};
    visit_lengths = exit_section - enter_section;
else
    error('incorrect inputs')
end


if exist('section', 'var')
    %sectionIDs
    if section == 1
        section_id_L = 'StartArea';
        section_id_R = 'StartArea';
    elseif section == 2
        section_id_L = 'Stem';
        section_id_R = 'Stem';
    elseif section == 3
        section_id_L = 'Stem';
        section_id_R = 'Stem';
    elseif section == 4
        section_id_L = 'ChoicePoint';
        section_id_R = 'ChoicePoint';
    elseif section == 5
        section_id_L = 'LeftArm';
        section_id_R = 'RightArm';
    elseif section == 6
        section_id_L = 'LeftReward';
        section_id_R = 'RightReward';
    elseif section == 7
        section_id_L = 'LeftReturn';
        section_id_R = 'RightReturn';
    end
end
%loop controlers
clusters = sort(clusters);
num_trials = max(ep(:,5))-1;

%preallocate cells
spike_times = cell(length(clusters), num_trials);

%identify entrance and exit times
if ~exist('enter_section', 'var')
    [enter_section, exit_section, visit_lengths] = enter_exit_times(ep, section);
end

%I only want stem sections 3:6
%sect = 2;

for cluster = 1:length(clusters)
    cluster_id = clusters(cluster);

        for trial= 1:num_trials
            
            %current ep indices
            cluster_indx = ep(:,4)==cluster_id;
            
            
            %time_index
            time_index = ep(:,1) > enter_section(trial) & ep(:,1) < exit_section(trial);
            
            
            if exist('section', 'var')
                trial_index = ep(:,5)==trial+1;
                section_index = ep(:,11) == section;
                times = ep(cluster_indx & trial_index & section_index & time_index, 1);
            end            
            
            
            %indexing for spike times
            times = ep(cluster_indx & time_index, 1);
            
            %setting begining of each trial to t=0
            time_correction = ones(size(times)).*enter_section(trial);
            times = times - time_correction;
            
            %load spike times
            spike_times(cluster, trial) = {times};

        end
end

%plot histogram of times to check for outliers that may be misrepresented
%by a warped-time presentation
%figure; hist(visit_lengths)
%title('Length of Visit', 'fontsize', 20)
%ylabel('Number of Trials', 'fontsize', 20)
%xlabel('Time (seconds)', 'fontsize', 20)

%reshaped = reshape(spike_times(1, 1, :), num_trials);
spike_times = cellfun(@transpose,spike_times,'un',0);

%CONORM TIME POINTS MEDIAN VISIT LENGTH (WARP TIME)
%cell_vislengths = num2cell(visit_lengths');
%spike_times = gdivide(spike_times, cell_vislengths);
%spike_times = gmultiply(spike_times,{median(visit_lengths)});

%LR indices (ignoring probe trial)
left_trials = unique(ep(ep(:,7)==1 & ep(:,5)>1, 5));left_trials = left_trials(2:end);
left_trials = left_trials - ones(size(left_trials));
right_trials = unique(ep(ep(:,7)==2 & ep(:,5)>1, 5));right_trials = right_trials(2:end);
right_trials = right_trials - ones(size(right_trials));

%plotting details
LineFormat = struct();
LineFormat.Color = [0 0 0];
LineFormat.LineWidth = 0.35;
LineFormat.LineStyle = '-';



spike_times
left_trials

%plot two rasters (LR) for every cluster
for cluster = 1:length(clusters)
    cluster_id = clusters(cluster);
        
    figure
    plotSpikeRaster(spike_times(1,left_trials),'PlotType','vertline', 'LineFormat', LineFormat);
%   	title(strcat(num2str(cluster_id), ' .', section_id_L), 'fontsize', 20)
  	ylabel('Left Trials', 'fontsize', 20)
  	xlabel('Time (seconds)', 'fontsize', 20)
    
    figure
    plotSpikeRaster(spike_times(1,right_trials),'PlotType','vertline', 'LineFormat', LineFormat);
   	%title(strcat(num2str(cluster_id), ' .', section_id_R), 'fontsize', 20)
  	ylabel('Right Trials', 'fontsize', 20)
  	xlabel('Time (seconds)', 'fontsize', 20)
        
end

end