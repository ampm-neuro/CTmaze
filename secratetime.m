function secratetime(eptrials, folded_section, cell)

%this calculates how long the rat spent in the given maze section on each trial,
%and then plots the distribution of times along with the firing rate
%for cell cell.
%
%Lick detection is required for folded_section input 5 (approach). Excluding
%error trials is strongly recommended.
%
%section input should be as follows:
% 1 = start area 
% 2 = lower stem 
% 3 = higher stem
% 4 = choice area 
% 5 = choice arms (approach)
% 6 = reward areas
% 7 = return arms

%EXCLUSIONS
%Exclude error trials (or replace 1 with 2 to exclude correct trials)
eptrials_ex = eptrials(eptrials(:,8)==1,:);
%eptrials_ex = eptrials; %if including all trials

%preallocate matrix of times and rates
times = nan(length(unique((eptrials_ex(:,5)))), 3);


%used later to make min max time measures more robust

%circular description of folded sections
circular_sections = [4 5 6 7 1 2 3 4 5 6 7];

%preparing to index circular description of folded sections
if folded_section > 5
    section_index = min(find(circular_sections==folded_section));
else
    section_index = max(find(circular_sections==folded_section));
end

%unfolded sections two behind and two ahead
past_unfolded_section_1 = min(eptrials_ex(eptrials_ex(:,11)==circular_sections(section_index-2), 6));
past_unfolded_section_2 = max(eptrials_ex(eptrials_ex(:,11)==circular_sections(section_index-2), 6));
future_unfolded_section_1 = min(eptrials_ex(eptrials_ex(:,11)==circular_sections(section_index+2), 6));
future_unfolded_section_2 = max(eptrials_ex(eptrials_ex(:,11)==circular_sections(section_index+2), 6));

figure
hold on

for trial = 1:length(unique((eptrials_ex(:,5))));
    trials = unique((eptrials_ex(:,5)));
    trl=trials(trial);
    
    %minumum timepoint in that section on that trial
    %min_enter = min(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:, 11)==folded_section, 1));
    
    %maximum timepoint in that section on that trial
    max_exit = max(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:, 11)==folded_section, 1));
    
    %trying to rule out unrelated/accidental entrances into the section
    %last time point in section two-sections-back
    last_non_entrance = max(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:,6)>=past_unfolded_section_1 & eptrials_ex(:,6)<=past_unfolded_section_2 & eptrials_ex(:,1) < max_exit,1));
    if isempty(last_non_entrance)
        last_non_entrance = 0;
    end
    
    %trying to rule out unrelated returns to the section
    
    %caveat to deal with special case: approach (use first lick detection
    %instead of future_unfolded_section)
    if folded_section == 5
        
      %stem entrance on this trial (max time point in start area)
      stement = max(eptrials_ex(eptrials_ex(:,5)==trl & eptrials_ex(:,6)==1, 1));
        
      if length(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1, 1)) < 1
          
        first_true_departure = max(eptrials_ex(:,1));
        warning('No Lick detection on trial. Lick detections are required to accurately calculate time in Approach section')
 
      %if left trial
      elseif eptrials_ex(eptrials_ex(:,5)==trl, 7)==1
                            
        %find the timestamp of first lick detection
        rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>stement & eptrials(:,10)==1 & eptrials(:,6)==7,1));
        
        first_true_departure = min(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:,1) < rwdevent & eptrials_ex(:,1) > last_non_entrance & eptrials_ex(:,6)>=7 & eptrials_ex(:,6)<=8,1));
      
      %if right trial
      elseif eptrials_ex(eptrials_ex(:,5)==trl, 7)==2
                            
        %find the timestamp of first lick detection
        rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>stement & eptrials(:,10)==1 & eptrials(:,6)==8,1));
        
        first_true_departure = min(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:,1) < rwdevent & eptrials_ex(:,1) > last_non_entrance & eptrials_ex(:,6)>=7 & eptrials_ex(:,6)<=8,1));
      
      end
        
        

    else
    
        %first time point in section two-sections-forward
        first_true_departure = min(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:,6)>=future_unfolded_section_1 & eptrials_ex(:,6)<=future_unfolded_section_2 & eptrials_ex(:,1) > last_non_entrance,1));
    
    
    end
    
    if isempty(first_true_departure)
        first_true_departure = max(eptrials_ex(:,1));
    end
   
    
    %corrected minumum timepoint in that section on that trial
    enter = min(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:, 11)==folded_section & eptrials_ex(:,1) > last_non_entrance, 1));
    
    %corrected maximum timepoint in that section on that trial
    exit = max(eptrials_ex(eptrials_ex(:, 5)==trl & eptrials_ex(:, 11)==folded_section & eptrials_ex(:,1) < first_true_departure, 1));
    
    %time in section
    time = exit - enter;
    
    %load preallocated vector of times
    times(trial,1) = time;
    
    %load preallocated vector of rates
    spikes = length(eptrials_ex(eptrials_ex(:,1)>enter & eptrials_ex(:,1)<exit & eptrials_ex(:,4)==cell, 7));
    rate = spikes/time;
    times(trial,2) = rate;
    
    %load L or R trial notation
    times(trial,3) = mode(eptrials_ex(eptrials_ex(:,1)>enter & eptrials_ex(:,1)<exit, 7));
    

    %plot location during time in section
    plot(eptrials_ex(eptrials_ex(:,1)>enter & eptrials_ex(:,1)<exit, 2), eptrials_ex(eptrials_ex(:,1)>enter & eptrials_ex(:,1)<exit, 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
    
    
end

hold off
sections(eptrials);

%plot hist
figure;
hist(times(:,1), 20);
xlabel('Time (Sec)', 'fontsize', 20)
ylabel('Frequency', 'fontsize', 20)

%sort by visit lengths
times = sortrows(times);

%plot bar
figure;
hold on
bar(times(:,1)./max(times(:,1)))
plot(times(:,2)./max(times(:,2)), '-', 'Color', [1 0 0], 'markersize', 20, 'linewidth', 2)
ylabel('Normalized Time (blue) and Firing Rate (red)', 'fontsize', 20)
xlabel('Trials', 'fontsize', 20)
axis([0, length(unique((eptrials_ex(:,5))))+1, 0, 1.05])
title('All Trials','fontsize', 20)

%left trials
figure;
hold on
bar(times(times(:,3)==1,1)./max(times(:,1)))
plot(times(times(:,3)==1,2)./max(times(:,2)), '-', 'Color', [1 0 0], 'markersize', 20, 'linewidth', 2)
ylabel('Normalized Time (blue) and Firing Rate (red)', 'fontsize', 20)
xlabel('Trials', 'fontsize', 20)
axis([0, length(unique((eptrials_ex(eptrials_ex(:,7)==1,5))))+1, 0, 1.05])
title('Left Trials','fontsize', 20)

%right trials
figure;
hold on
bar(times(times(:,3)==2,1)./max(times(:,1)))
plot(times(times(:,3)==2,2)./max(times(:,2)), '-', 'Color', [1 0 0], 'markersize', 20, 'linewidth', 2)
ylabel('Normalized Time (blue) and Firing Rate (red)', 'fontsize', 20)
xlabel('Trials', 'fontsize', 20)
axis([0, length(unique((eptrials_ex(eptrials_ex(:,7)==2,5))))+1, 0, 1.05])
title('Right Trials','fontsize', 20)

end