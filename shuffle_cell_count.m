function [shuffle_outcomes, stem_diff_f_output, stem_dif] = shuffle_cell_count(spr, learning_stages, iterations)
%Shuffles the L and R trials of the first 10 trials of every day.
%shuffle_pre_output (spr) is output by All_shuffle_prep.
%
%set iterations to 1 for observed data.
%
%shuffle_prep_output(:,1:4) = firing rates for maze sectors 1:4
%shuffle_prep_output(:,5) = 1 for left 2 for right
%shuffle_prep_output(:,6) = stage
%shuffle_prep_output(:,7) = session
%shuffle_prep_output(:,8) = cell number within that rat-session
%shuffle_prep_output(:,9) = cell number within that stage (all rats)
%shuffle_prep_output(:,10) = subject *wrong*
%shuffle_prep_output(:,11) = session number within stage
%

%specific learning day?
%learn_day 1 is first, 2 is mid, 3 is crit
%sessions describes the overall session (:,11)
count=0;

single_day = 0; %1 for single days, 0 for thirds


if floor(learning_stages) == 2
    %find relevant session numbers for each subject
    sessions = cell(length(unique(spr(:,10))),1);
    for subj = 1:length(unique(spr(:,10)));
        length_sessions = max(spr(spr(:,10)==subj & spr(:,6)==2, 7));
        learn_day = first_mid_last(length_sessions, learning_stages, single_day);
        if ~isnan(learn_day)
            sessions{subj} = unique(spr(spr(:,6)==floor(learning_stages) & spr(:,10)==subj & ismember(spr(:,7),learn_day), 11));
        else
            sessions{subj} = nan;
        end
    end
    sessions = cell2mat(sessions); 
elseif learning_stages == 4
    sessions = unique(spr(spr(:,6)==4, 11));
else
    error('incorrect learning_stages input')
end
sessions = sessions(~isnan(sessions));

%precalculate
num_cells = numel(unique(spr(spr(:,6)==floor(learning_stages) & ismember(spr(:,11), sessions), 9)));

if size(spr,2) == 11 && sum(~isnan(spr(:,3)))>sum(isnan(spr(:,3)))
    num_sects = 4
else
    num_sects = 2
end

first_trials=10;

%preallocate
shuffle_outcomes = nan(iterations, 1);

for iteration = 1:iterations

    cell_count_idx = 0;

    %p-value outcomes for each cell
    %stem_diff = nan(num_cells,3);
    stem_diff = nan(num_cells,3);
    stem_diff_f_output = nan(num_cells,2);

    %for each session (trial randomization)
    for session = sessions'
        
        first_trials = size(spr(ismember(spr(:,6), floor(learning_stages)) & spr(:,11)==session & spr(:,8)==1, :),1)/2;
        LRs = [ones(first_trials,1); repmat(2, first_trials,1)];

        %randomize L/Rs if shuffling
        if iterations > 1
            LRs = LRs(randperm(first_trials*2));
        end

        %calculate stem_diff via anova2        
        for c = 1:max(spr(ismember(spr(:,6), floor(learning_stages)) & spr(:,11)==session, 8));

            cell_count_idx = cell_count_idx+1;
                        
            %firing rates
            rates = spr(ismember(spr(:,6), floor(learning_stages)) & spr(:,11)==session & spr(:,8)==c, 1:num_sects);
            
            %randomize sectors if shuffling
            if iterations > 1
                for i = 1: size(rates,1)
                    rates(i,:) = rates(randperm(num_sects));
                end
            end
            
            if sum(sum(isnan(rates)))>0
                continue
            end

            %anovan
            left_rates = rates(LRs==1, :);
            right_rates = rates(LRs==2, :);
            
            left_rates = left_rates(:);
            right_rates = right_rates(:);
            rates_in = [left_rates; right_rates];
            
           	trial_type_grouping = [ones(size(left_rates)); repmat(2, size(right_rates))];
            
            if num_sects == 4
                sector_grouping = [ones(first_trials,1); repmat(2, first_trials,1); repmat(3, first_trials,1); repmat(4, first_trials,1); ones(first_trials,1); repmat(2, first_trials,1); repmat(3, first_trials,1); repmat(4, first_trials,1)];
            elseif num_sects == 2
                sector_grouping = [ones(first_trials,1); repmat(2, first_trials,1); ones(first_trials,1); repmat(2, first_trials,1)];
            end
            
            grouping_vars = {sector_grouping trial_type_grouping};

            
            %size([left_rates; right_rates])
            %size(sector_grouping)
            %size(trial_type_grouping)
            
            

            %load outcomes
            if num_sects == 4
                [~, t, ~, ~] = anovan(rates_in, grouping_vars, 'continuous', 1, 'model',2, 'sstype',3','varnames', strvcat('sector', 'trial_type'), 'display', 'off');
                stem_diff_f_output(cell_count_idx, :) = [t{3,6} t{4,6}];
                
                stem_diff(cell_count_idx,:) = [t{2,7}<.05 t{3,7}<.05 t{4,7}<.05];
            else
                L_rates_bef = rates_in(trial_type_grouping==1 & sector_grouping==1);
                L_rates_aft = rates_in(trial_type_grouping==1 & sector_grouping==2);
                R_rates_bef = rates_in(trial_type_grouping==2 & sector_grouping==1);
                R_rates_aft = rates_in(trial_type_grouping==2 & sector_grouping==2);
                
                anov_inpt = [[L_rates_bef;L_rates_aft] [R_rates_bef;R_rates_aft]];
                tvals_posthoc = ttest2(L_rates_aft, R_rates_aft);

                p_vals = anova2(anov_inpt, 10, 'off');   

                %p_trl_type = p_vals(1);
                %p_before_after = p_vals(2);
                p_interact = p_vals(3);

                %on_off reward cell    
                %stem_diff(cell_count_idx,:) = any([p_before_after p_interact] < .05);

                %trial type specific reward cell
                stem_diff(cell_count_idx,:) = [0 p_interact < .05  tvals_posthoc == 1];
                
            end

        end
    end

    %summarize outcomes
    if num_sects == 4
        stem_dif = sum(stem_diff(~isnan(stem_diff(:,1)), 2:3),2)>0;
    elseif num_sects == 2
        stem_dif = sum(stem_diff(~isnan(stem_diff(:,1)), 2:3),2)>1;
    end
    
    %load proportion
    shuffle_outcomes(iteration) = nansum(stem_dif)/sum(~isnan(stem_dif));


    %print progress
    100-((iterations-iteration)/iterations)*100

end