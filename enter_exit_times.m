function [enters, exits, times] = enter_exit_times(eptrials, folded_section)
%outputs when the rat "truly" entered and "truly" exited this section on
%each trial, as well as the difference between these (times spent in
%section)
%
%section input should be as follows:
% 1 = start area
% 2 = lower stem
% 3 = higher stem
% 4 = choice area

%preallocate vector of times
enters = nan(max(eptrials(:,5))-1, 1);
exits = nan(max(eptrials(:,5))-1, 1);
times = nan(max(eptrials(:,5))-1, 1);


%used later to make min max time measures more robust

%circular description of folded sections
circular_sections = [6 7 1 2 3 4 5 6 7 1 2];
go_left = [7 9 1 2 3 4 5 7 9 1 2];
go_right = [8 10 1 2 3 4 6 8 10 1 2];

%preparing to index circular description of folded sections
if folded_section >= 6
    section_index = find(circular_sections==folded_section, 1, 'last');
else
    section_index = find(circular_sections==folded_section, 1, 'first');
end

%unfolded sections two behind and two ahead
current_folded_section = folded_section;
curr_unf_LR = [go_left(section_index) go_right(section_index)];
past_unf_LR = [go_left(section_index-2) go_right(section_index-2)];
futr_unf_LR = [go_left(section_index+2) go_right(section_index+2)];

%the following loops will plot trajectories
figure
sections;
hold on

for trl = 1:((max(eptrials(:,5)))-1);
    trial = trl+1;
    
    %UNCORRECTED maximum timepoint in that section on that trial
    max_exit = max(eptrials(eptrials(:, 5)==trial & eptrials(:, 11)==folded_section, 1));
    
    %trying to rule out unrelated/accidental entrances into the section
    %last time point in section two-sections-back
    last_non_entrance = max(eptrials(eptrials(:, 5)<=trial & ismember(eptrials(:,6), past_unf_LR) & eptrials(:,1) < max_exit,1));
    if isempty(last_non_entrance)
        last_non_entrance = 0;
    end
        
    %trying to rule out unrelated returns to the section
    %first time point in section two-sections-forward
    first_true_departure = min(eptrials(eptrials(:, 5)>=trial & ismember(eptrials(:,6), futr_unf_LR) & eptrials(:,1) > last_non_entrance,1));
    if isempty(first_true_departure)
        first_true_departure = max(eptrials(:,1));
    end

    
    %UNCORRECTED maximum timepoint in that section on that trial
    if trial == min(eptrials(:,5)) && folded_section == 1
        enter = min(eptrials(eptrials(:, 5)==trial & eptrials(:, 11)==folded_section & eptrials(:,1) > last_non_entrance, 1));
    else
        enter = max(eptrials(eptrials(:, 5)<=trial & eptrials(:, 11)==circular_sections(section_index-1) & eptrials(:,1) > last_non_entrance & eptrials(:,1) < first_true_departure, 1));
    end
    
    %STILL UNcorrected maximum timepoint in that section on that trial
    if trial == max(eptrials(:,5)) && folded_section == 7
        exit = max(eptrials(eptrials(:, 5)==trial & eptrials(:,11)==folded_section & eptrials(:,1) < first_true_departure, 1));
    else
        exit = min(eptrials(eptrials(:, 5)>=trial & eptrials(:, 11)==circular_sections(section_index+1) & eptrials(:,1) > last_non_entrance & eptrials(:,1) < first_true_departure, 1));
    end
    
    if exit < enter
    
        %corrected minumum timepoint in that section on that trial
        if trial == min(eptrials(:,5)) && folded_section == 1
            enter = min(eptrials(eptrials(:, 5)==trial & eptrials(:, 11)==folded_section & eptrials(:,1) > last_non_entrance, 1));
        else
            enter = max(eptrials(eptrials(:, 5)<=trial & eptrials(:, 11)==circular_sections(section_index-1) & eptrials(:,1) > last_non_entrance & eptrials(:,1) < exit, 1));
        end
    
    end
    
    
    %time in section
    time = exit - enter;
    
    %load preallocated vectors
    enters(trl) = enter;
    exits(trl) = exit;
    times(trl) = time;
    
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
        error('negative time is impossible. fix shit, yo.')
    end
    
    %load preallocated vectors
    enters(trl) = enter;
    exits(trl) = exit;
    times(trl) = time;
    
    %plot location during time in section
    %if trial == 50
    plot(eptrials(eptrials(:,1)>enter & eptrials(:,1)<exit, 2), eptrials(eptrials(:,1)>enter & eptrials(:,1)<exit, 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
    %end
end

end