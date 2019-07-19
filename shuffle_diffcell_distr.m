function [shuffle_outcomes] = shuffle_diffcell_distr(spr, iterations)
%Shuffles every included day's learning stage.
%shuffle_pre_output (spr) is output by All_shuffle_prep.
%
%set iterations to 0 for observed data.
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

%preallocate
shuffle_outcomes = nan(iterations,1);

%first_day = [1 1 1 1 1 1 1 1 1 1 1 1]; %12 days
mid_day = [3 5 nan 4 3 3 4 3 4 3 3 nan]; %10 days
crit_day = [5 8 nan 7 5 5 6 5 6 4 4 nan]; %10 days

%create new spr with only relevant days
spr_new = [spr(spr(:,6)==4, :) repmat(4, 1, size(spr(spr(:,6)==4, :), 1))]; %add ot days
spr_new = [spr_new; [spr(spr(:,6)==2 & spr(:,7)==1, :) ones(1, size(spr(spr(:,6)==4, :), 1))]]; %add first days
    for subject = 1:12
        if ~isnan(mid_day(subject))
            %idx
            stg_sesh_subj_idx_mid = spr(:,6)==2 & spr(:,10)==subject & spr(:,7)==mid_day(subject);
            stg_sesh_subj_idx_crit = spr(:,6)==2 & spr(:,10)==subject & spr(:,7)==crit_day(subject);
            %fill
            spr_new = [spr_new; [spr(stg_sesh_subj_idx_mid, :)   repmat(4, 1, size(spr(stg_sesh_subj_idx_mid, :), 1))]];
            spr_new = [spr_new; [spr(stg_sesh_subj_idx_crit, :)   repmat(4, 1, size(spr(stg_sesh_subj_idx_crit, :), 1))]];
        end
    end

%number cells
cells = 1:(size(spr_new,1)/20);
spr11_hold = repmat(1:cells(end), 20, 1);
spr_new(:,11) = spr11_hold(:);

%determine which cell number belongs to which learning stage
%(affiliations)
affiliations = nan(1,cells(end));
for c = cells
    affiliations(c) = mode(spr_new(spr_new(:,11) == c));
end

%if shuffling, shuffle affiliations then calculate error 
if iterations > 0
    iterations = ceil(iterations);%check 
    
    for i = 1:iterations
        %shuffle
        affiliations = affiliations(randperm(length(affiliations)));
    
        %calculate error
        shuffle_outcomes(i) = local_func_err_calc(spr_new, cells, affiliations);
    end
    
    
    
  
%actual observed
elseif iterations == 0 
    
    %calculate error
    shuffle_outcomes(i) = local_func_err_calc(spr_new, cells, affiliations);
    
    
%catch    
else
    error('unacceptable iterations')
end

%calculates mean absolute error
function [mean_abs_err] = local_func_err_calc(rate_mtx, cell_ids, stage_affiliations)
%calculates proportion of cells in each learning stage that are splitters, 
%and then calculates mean absolute error from the four stages

%preallocate stage cells
unq_stages = unique(stage_affiliations);
stages = cell(size(unq_stages));
stage_proportions = nan(size(unq_stages));

    count_stage = 0;
    
    %for each stage
    for stage = unq_stages
        
        count_stage = count_stage+1;

        %preallocate cell mtx
        stages{count_stage} = nan(1, unique(cell_ids(stage_affiliations==stage)));

        count_cell = 0;
        
        %for each cell (in that stage)
        for cel = cell_ids(stage_affiliations==stage)

            count_cell = count_cell+1;

            %rates
            left_rates = rate_mtx(rate_mtx(:,11)==cel & rate_mtx(:,5)==1, 1:4);
            left_rates = left_rates(:);
            right_rates = rate_mtx(rate_mtx(:,11)==cel & rate_mtx(:,5)==2, 1:4);
            right_rates = right_rates(:);

            %grouping
            trial_type_grouping = [ones(size(left_rates)); repmat(2, size(right_rates))];
            sector_grouping = [ones(10,1); repmat(2, 10,1); repmat(3, 10,1); repmat(4, 10,1); ones(10,1); repmat(2, 10,1); repmat(3, 10,1); repmat(4, 10,1)];
            grouping_vars = {sector_grouping trial_type_grouping};

            %is it a splitter?
            [~, t, ~, ~] = anovan([left_rates; right_rates], grouping_vars, 'continuous', 1, 'model',2, 'sstype',3','varnames', strvcat('sector', 'trial_type'), 'display', 'off');
            splitter = sum([t{3,7}<.05 t{4,7}<.05])>0;

            stages{count_stage}(count_cell) = splitter; %0 or 1
        end
        
        %change to just proportion
        stage_proportions(count_stage) = sum(stages{count_stage})/length(stages{count_stage});
        
    end
    
mean_abs_err = sum(abs(stage_proportions - repmat(mean(stage_proportions), size(stage_proportions))));
    
    
end





    


end

