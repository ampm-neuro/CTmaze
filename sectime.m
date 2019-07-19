function [enter, exit] = sectime(eptrials, section)

%this calculates how long the rat spent in the given maze section on each trial,
%and then plots the distribution of times as a histogram.
%
%section input should be as follows:
% 1 = start area
% 2 = lower stem
% 3 = higher stem
% 4 = choice area


%preallocate vector of times
times = nan(max(eptrials(:,5)), 1);


%folded section
folded_section = mode(eptrials(eptrials(:,6)==section, 11));

%used later to make min max time measures more robust

%circular description of folded sections
circular_sections = [4 5 6 7 1 2 3 4 5 6 7];

%preparing to index circular description of folded sections
if section > 6
    section_index = min(find(circular_sections==folded_section));
else
    section_index = max(find(circular_sections==folded_section));
end

%unfolded sections two behind and two ahead
past_unfolded_section_1 = min(eptrials(eptrials(:,11)==circular_sections(section_index-2), 6));
past_unfolded_section_2 = max(eptrials(eptrials(:,11)==circular_sections(section_index-2), 6));
future_unfolded_section_1 = min(eptrials(eptrials(:,11)==circular_sections(section_index+2), 6));
future_unfolded_section_2 = max(eptrials(eptrials(:,11)==circular_sections(section_index+2), 6));

figure
hold on

for trl = 1:(max(eptrials(:,5)));
    
    %maximum timepoint in that section on that trial
    max_exit = max(eptrials(eptrials(:, 5)==trl & eptrials(:, 6)==section, 1));
    
    %trying to rule out unrelated/accidental entrances into the section
    %last time point in section two-sections-back
    last_non_entrance = max(eptrials(eptrials(:, 5)==trl & eptrials(:,6)>=past_unfolded_section_1 & eptrials(:,6)<=past_unfolded_section_2 & eptrials(:,1) < max_exit,1));
    if isempty(last_non_entrance)
        last_non_entrance = 0;
    end
    
    %trying to rule out unrelated returns to the section
    %first time point in section two-sections-forward
    first_true_departure = min(eptrials(eptrials(:, 5)==trl & eptrials(:,6)>=future_unfolded_section_1 & eptrials(:,6)<=future_unfolded_section_2,1));
    if isempty(first_true_departure)
        first_true_departure = max(eptrials(:,1));
    end
    
    %corrected minumum timepoint in that section on that trial
    enter = min(eptrials(eptrials(:, 5)==trl & eptrials(:, 6)==section & eptrials(:,1) > last_non_entrance, 1));
    
    %corrected maximum timepoint in that section on that trial
    exit = max(eptrials(eptrials(:, 5)==trl & eptrials(:, 6)==section & eptrials(:,1) < first_true_departure, 1));
    
    %time in section
    time = exit - enter;
    
    %load preallocated vector of times
    times(trl) = time;
    
    %plot location during time in section
    plot(eptrials(eptrials(:,1)>enter & eptrials(:,1)<exit, 2), eptrials(eptrials(:,1)>enter & eptrials(:,1)<exit, 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')

end

hold off
sections(eptrials);

%plot hist
figure;
hist(times, 20);
xlabel('Time (Sec)', 'fontsize', 20)
ylabel('Frequency', 'fontsize', 20)

%plot bar
figure;
%times = sort(times);
bar(times)
ylabel('Time (Sec)', 'fontsize', 20)
xlabel('Trials', 'fontsize', 20)

end