function [trial_hd, mean_stem_diff, F_scores, L_R, percent_correct] = posstem_hd(eptrials, stem_runs, clusters)
%posplotstem_hd calcuates the abs circular difference betweent hds on left
%and right trials.
%
%it calculate the difference in each maze section, then averages those
%differences.

%preallocate
trial_hd = nan(size(stem_runs,1),4);
trial_fr = nan(size(stem_runs,1),4, sum(clusters(:,2)>2));
L_R = nan(size(trial_hd,1),1);

all_trials = unique(eptrials(ismember(eptrials(:,8), [1 2]), 5));
typical_trials = all_trials(stem_runs(2:end,3)<1.24);
correct_trials = unique(eptrials(eptrials(:,8)==1, 5));
correct_typical_trials = intersect(correct_trials, typical_trials);
percent_correct = length(correct_typical_trials)/length(typical_trials);
%percent_correct = length(correct_trials)/length(all_trials);

%determine firing rate and trialtype for each trial

for trial = 1:size(stem_runs,1)
    
    %screen for shitty stem runs
    if stem_runs(:,3) > 1.24
        continue
    %or error trials
    elseif mode(eptrials(eptrials(:,5)==trial,8)) ~= 1
        continue
    end
    
    %for each stem section
    for section = 1:4
        
        %calculate circular mean
        hds = eptrials(eptrials(:, 14)==1 & eptrials(:, 5)==trial...
            & eptrials(:,9)==section & eptrials(:,1)>stem_runs(trial,1)...
            & eptrials(:,1)<stem_runs(trial,2), 15);
        hds(hds<180) = hds(hds<180)+360;
        m_hds = mean(hds);
        m_hds(m_hds>360) = m_hds(m_hds>360)-360;

        %load HDs
        trial_hd(trial, section) = m_hds; %HD
        
        %load FRs
        %for each cell
        count = 0;
        for ic = clusters(:,1)'
            count = count+1;
            %number of spikes
            spike_count = sum(eptrials(:, 4)==ic & eptrials(:, 5)==trial...
                & eptrials(:,9)==section & eptrials(:,1)>stem_runs(trial,1)...
                & eptrials(:,1)<stem_runs(trial,2));
            %spikes/time
            trial_fr(trial, section, count) = spike_count/stem_runs(trial,3);
        end
        
        %L_R_idx
        L_R(trial) = mode(eptrials(eptrials(:, 5)==trial, 7)); %L/R
    end
end

% absolute difference between mean positions on left and right trials (at that section)
% then distance is averaged across sections
mean_stem_diff = nan(4,1);

%mean difference across all stem sections
for section = 1:4
    left_trial_mean = circ_mean(trial_hd(L_R==1, section));
    right_trial_mean = circ_mean(trial_hd(L_R==2, section));
    mean_stem_diff(section) = circ_distance(left_trial_mean, right_trial_mean, [0 360]);
end
mean_stem_diff = mean(mean_stem_diff);


%anova on firing rates
F_scores = nan(size(clusters,1), 2);
count = 0;
for ic = 1:size(clusters,1)
    count = count +1;
    left_trial_rates = trial_fr(L_R==1, :, count);
        left_trial_rates = left_trial_rates(1:10, :, :);
    right_trial_rates = trial_fr(L_R==2, :, count);
        right_trial_rates = right_trial_rates(1:10, :, :);
    
    
    
    %RM ANOVA
    Y = [left_trial_rates(:); right_trial_rates(:)];
    
    F1_l = ones(size(left_trial_rates));
    F1_2 = ones(size(left_trial_rates)).*2;
    Factor1_id = [F1_l(:); F1_2(:)];
    
    F2_1 = repmat(1:4, size(left_trial_rates,1),1);
    F2_2 = repmat(1:4, size(left_trial_rates,1),1);
    Factor2_id = [F2_1(:); F2_2(:)];
    
    S1 = repmat((1:10)', 4, 1);
    S2 = repmat((1:10)', 4, 1);
    Subject_id = [S1(:); S2(:)];
    
    stats = rm_anova2(Y, Subject_id, Factor1_id, Factor2_id, {'type', 'section'});
    
    %LOAD F_SCORES
    F_scores(ic, 1) = stats{2,5}; %main effect type
    F_scores(ic, 2) = stats{4,5}; %typeXsection interaction

end

F_scores = max(F_scores, [], 2);
mean_stem_diff = repmat(mean_stem_diff, size(F_scores));

end
%INTERNAL FUNCTION
function hds = circ_mean(hds)
    %calcuate mean hd
    hds(hds<180) = hds(hds<180)+360;
    hds = mean(hds);
    hds(hds>360) = hds(hds>360)-360;
end

