function [enters, exits, times, outliers] = ent_ext_cntr_stem(eptrials)
%calculates the entrance and exit times for each stem section 3:6

%preallocate matrices of times
enters = nan(max(eptrials(:,5))-1, 4);
exits = nan(max(eptrials(:,5))-1, 4);
times = nan(max(eptrials(:,5))-1, 4);
%preallocate outliers matrix
outliers = zeros(size(times));

%determine entrance and exit time for each section
for stem_section = 1:4
    secti = stem_section;
%the following loops will plot trajectories
figure
stem(eptrials);
hold on
    
    for trl = 1:((max(eptrials(:,5)))-1);
        trial = trl+1;
    
        %UNCORRECTED maximum timepoint in that section on that trial
        max_exit = max(eptrials(eptrials(:, 5)==trial & eptrials(:, 9)==stem_section, 1));
    
        %trying to rule out unrelated/accidental entrances into the section
        %last time point in section two-sections-back
        last_non_entrance = max(eptrials(eptrials(:, 5)<=trial & eptrials(:, 9)==stem_section-2 & eptrials(:,1) < max_exit,1));
        if isempty(last_non_entrance)
            last_non_entrance = 0;
        end
        
        %trying to rule out unrelated returns to the section
        %first time point in section two-sections-forward
        first_true_departure = min(eptrials(eptrials(:, 5)>=trial & eptrials(:, 9)==stem_section+2 & eptrials(:,1) > last_non_entrance,1));
        if isempty(first_true_departure)
            first_true_departure = max(eptrials(:,1));
        end

    
        %UNCORRECTED maximum timepoint in that section on that trial
        enter = max(eptrials(eptrials(:, 5)<=trial & eptrials(:, 9)==stem_section-1 & eptrials(:,1) > last_non_entrance & eptrials(:,1) < first_true_departure, 1));

        
        %STILL UNcorrected maximum timepoint in that section on that trial
        exit = min(eptrials(eptrials(:, 5)>=trial & eptrials(:, 9)==stem_section+1 & eptrials(:,1) > last_non_entrance & eptrials(:,1) < first_true_departure, 1));
    
        %if wonky, redefine enter
        if exit < enter

            %corrected minumum timepoint in that section on that trial
           	enter = max(eptrials(eptrials(:, 5)<=trial & eptrials(:, 9)==stem_section-1 & eptrials(:,1) > last_non_entrance & eptrials(:,1) < exit, 1));

        end


        %time in section
        time = exit - enter;

        %debugging
        if time <= 0
            trial_with_error = trial
            shit_time = sort([enter exit])
            if trl > 1
                figure; sections(eptrials); plot(eptrials(eptrials(:,1)>enters(trl-1) & eptrials(:,1)<exits(trl-1), 2), eptrials(eptrials(:,1)>enters(trl-1) & eptrials(:,1)<exits(trl-1), 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
            end
            figure; sections(eptrials); plot(eptrials(eptrials(:,1)>shit_time(1) & eptrials(:,1)<shit_time(2), 2), eptrials(eptrials(:,1)>shit_time(1) & eptrials(:,1)<shit_time(2), 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
            title('error trajectory')
            plottrials(eptrials, [trial-1 trial])
            error('negative time is impossible. fix that shit, yo.')
        end

        %load preallocated vectors
        enters(trl, secti) = enter;
        exits(trl, secti) = exit;
        times(trl, secti) = time;

        %plot location during time in section
        %if trial == 50
        plot(eptrials(eptrials(:,1)>enter & eptrials(:,1)<exit, 2), eptrials(eptrials(:,1)>enter & eptrials(:,1)<exit, 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
        title(strcat('Section .',num2str(stem_section-2)))
        %end
    end
    
    %CALCULATE OUTLYING VISIT TIMES
    median_vector = repmat(median(times(:,secti)), size(times(:,secti),1), size(times(:,secti),2));
    standardDeviation_vector = repmat(std(times(:,secti)), size(times(:,secti),1), size(times(:,secti),2));
    outliers(:,secti) = (times(:,secti)-median_vector) > 3.*standardDeviation_vector & times(:,secti) > 0.35; 
    
    %re-plot outlier trials in red
    rejects = find(outliers(:,secti)==1);
    for reject = 1:length(rejects)
        rejected_trial = rejects(reject);
        plot(eptrials(eptrials(:,1)>enters(rejected_trial, secti) & eptrials(:,1)<exits(rejected_trial, secti), 2), eptrials(eptrials(:,1)>enters(rejected_trial, secti) & eptrials(:,1)<exits(rejected_trial, secti), 3), 'Color', [1 0 0] , 'LineWidth', 0.5, 'LineStyle', '-')
    end
    
    hold off
end

end