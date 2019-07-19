function diff_stem_rast(ep, clusters)
%function [visit_lengths] = diff_stem_rast(eptrials, clusters)
%
%plots left and right rasters for visits to the stem. The four stem
%subsections are individually warp-timed and concatenated to create a
%uniform stem-running time length across all trials. Trials containing
%visits to any stem section that lasted longer than >3stds from the mean 
%time spent in that section are removed as outliers
%

%check input
if rem(clusters, round(clusters)) == 0
    error('cluster input is not in typical ampm format')
end


%loop controlers
clusters = sort(clusters);
all_trials = unique(ep(ep(:,5)>1,5))- ones(size(unique(ep(ep(:,5)>1,5))));
num_trials = length(all_trials);

%LR indices (ignoring probe trial)
left_trials = unique(ep(ep(:,7)==1 & ep(:,5)>1, 5));
left_trials = left_trials - ones(size(left_trials));
left_trials = ismember(1:num_trials, left_trials);
right_trials = unique(ep(ep(:,7)==2 & ep(:,5)>1, 5));
right_trials = right_trials - ones(size(right_trials));
right_trials = ismember(1:num_trials, right_trials);

%plotting details
LineFormat = struct();
LineFormat.Color = [0 0 0];
LineFormat.LineWidth = 0.35;
LineFormat.LineStyle = '-';

%identify entrance and exit times
[enter_section, exit_section, visit_lengths, outliers] = ent_ext_cntr_stem(ep);

%remove outliers (rat spent too long in any section)
outlier_trials = (sum(outliers,2)>0)';
left_trials = all_trials(left_trials & ~outlier_trials);
right_trials = all_trials(right_trials & ~outlier_trials);

%report outliers
rejects = find(outlier_trials==1);
if ~isempty(rejects)
    for reject = 1:length(rejects)
        rejected_trial = rejects(reject);
        rej_trl_type = mode(ep(ep(:,5)==rejected_trial, 7));
        if rej_trl_type == 1
            display(['Trial number ', num2str(rejected_trial),' (left trial type) removed as an outlier'])
        elseif rej_trl_type == 2
            display(['Trial number ', num2str(rejected_trial),' (right trial type) removed as an outlier'])
        else
            error(message('rejected trial type undetermined'))
        end
    end
end


%find spike times
for cluster = 1:length(clusters)
    cluster_id = clusters(cluster);

    %preallocate matrix
    median_visit = nan(1,4);
    %preallocate cells /clear
    stem_sections = cell(1,4);
    %preallocate/clear
    spike_times_final = cell(1, num_trials);
    
    for stem_sec = 1:4
        
        %preallocate/clear
        spike_times = cell(1, num_trials);
        
        for trial= 1:num_trials
            
            %entrance and exit times
            entrance_time = enter_section(trial,stem_sec);
           	exit_time = exit_section(trial,stem_sec);
            
                %current ep indices
                cluster_indx = ep(:,4)==cluster_id;
                trial_index = ep(:,5)==trial+1;
                section_index = ep(:,9) == stem_sec + 2;
                        
                %time_index
                time_index = ep(:,1) > entrance_time & ep(:,1) <= exit_time;
                
                %indexing for spike times
                times = ep(cluster_indx & trial_index & section_index & time_index, 1);
            
                %setting begining of each trial to t=0
                time_correction = ones(size(times)).*entrance_time;
                times = times - time_correction;
            
                %load spike times
                spike_times(trial) = {times'};%transposed to keep everything in rows
        end
        
        %CONFORM TIME POINTS TO MEDIAN VISIT LENGTH (WARP TIME)
        median_visit(1,stem_sec) = median(visit_lengths(~outlier_trials,stem_sec));
        cell_vislengths = num2cell(visit_lengths(:,stem_sec)');
        spike_times = gdivide(spike_times, cell_vislengths);
        spike_times = gmultiply(spike_times,{median_visit(1,stem_sec)});
        
        %correct times to indicate time since stem entrance (not time since stem section entrance)
        if stem_sec>1
            %time_REcorrection mirrors spike_times but is filled with the
            %median time from the previous section
            time_REcorrection = cell(size(spike_times));
            num_spikes_trlsec = cellfun('size', spike_times, 2);
            for i = 1:length(spike_times)
                time_REcorrection(i) = {ones(1,num_spikes_trlsec(i)).*sum(median_visit(1,1:stem_sec-1))};
            end
            spike_times = gadd(spike_times, time_REcorrection);
        end

        %load warped spike times for current section
        stem_sections{stem_sec} = spike_times;
   
        
        %PLOT HISTOGRAM
        if cluster == 1 && stem_sec == 1
            %plot histogram of times to check for outliers that may be misrepresented
            %by a warped-time presentation
            figure; hist(visit_lengths(~outlier_trials, :));
            legend('Section 1', 'Section 2', 'Section 3', 'Section 4')
            title(strcat('Time in Stem Section'), 'fontsize', 20)
            ylim([0 num_trials-length(rejects)+5])
            box off
            ylabel('Number of Trials', 'fontsize', 20)
            xlabel('Time (seconds)', 'fontsize', 20)
        end
        
        
    end
    
    %Reassemble split and warped sections into a continuous timesheet
    for trl = 1:num_trials
        spike_times_final{trl} = [stem_sections{1}{trl} stem_sections{2}{trl} stem_sections{3}{trl} stem_sections{4}{trl}];
    end    

    left_trials
    right_trials
    
    size(spike_times_final)
%plot two rasters (L and R) for every cluster
figure
    plotSpikeRaster(spike_times_final(left_trials),'PlotType','vertline', 'LineFormat', LineFormat);
    hold on
    plot([median_visit(1) median_visit(1)],[0 length(left_trials)+1],'r-', 'LineWidth',3)
    plot([median_visit(1)+median_visit(2) median_visit(1)+median_visit(2)],[0 length(left_trials)+1],'r-', 'LineWidth',3)
    plot([median_visit(1)+median_visit(2)+median_visit(3) median_visit(1)+median_visit(2)+median_visit(3)],[0 length(left_trials)+1],'r-', 'LineWidth',3)
   	title(strcat(num2str(cluster_id), ' .LeftTrials'), 'fontsize', 20)
    set(gca,'YTick',1:length(left_trials), 'YTickLabel', left_trials)
  	ylabel('Trial Number', 'fontsize', 20)
  	xlabel('Time (seconds)', 'fontsize', 20)
    xlim([0 sum(median_visit(:))])
    hold off
    
figure
    plotSpikeRaster(spike_times_final(right_trials),'PlotType','vertline', 'LineFormat', LineFormat);
    hold on
    plot([median_visit(1) median_visit(1)],[0 length(right_trials)+1],'r-', 'LineWidth',3)
    plot([median_visit(1)+median_visit(2) median_visit(1)+median_visit(2)],[0 length(right_trials)+1],'r-', 'LineWidth',3)
    plot([median_visit(1)+median_visit(2)+median_visit(3) median_visit(1)+median_visit(2)+median_visit(3)],[0 length(right_trials)+1],'r-', 'LineWidth',3)
   	title(strcat(num2str(cluster_id), ' .RightTrials'), 'fontsize', 20)
    set(gca,'YTick',1:length(right_trials), 'YTickLabel', right_trials)
  	ylabel('Trial Number', 'fontsize', 20)
  	xlabel('Time (seconds)', 'fontsize', 20)
    xlim([0 sum(median_visit(:))])
    hold off
        
end

end


