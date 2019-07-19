function [rr_out, rr_out_L, rr_out_R, subj_cell] = rwd_rates
% compute firing rate at the reward locations

% get all file paths
file_paths = get_file_paths('C:\Users\ampm1\Desktop\oldmatlab\neurodata');

% seperate the learning and ot paths
learning_paths = file_paths(contains(file_paths, 'continuous'));
ot_paths = file_paths(contains(file_paths, 'overtraining'));

% all subject IDs 44:47
all_subj_ids = [];
for ipath = 1:size(file_paths,1)
    all_subj_ids = [all_subj_ids; file_paths{ipath}(44:47)];
end
[unq_subjs, ~, unq_subj_num] = unique(all_subj_ids, 'rows');
unq_subjs = unq_subjs(3:end,:);

% prep subj id output
subj_cell_pre = cell(1,4);
subj_cell_pre{4} = unq_subj_num(contains(file_paths, 'overtraining'),:);
learning_path_subj_nums = unq_subj_num(contains(file_paths, 'continuous'),:);

% seperate learning paths by training stage
learning_paths_by_stage = cell(1,3); % 4 training stages
count = [0 0 0];
for subj_num = 1:length(unq_subjs)
    
    % all paths for this subject
    subj_paths = learning_paths(contains(learning_paths, unq_subjs(subj_num,:)));
    subj_paths_nums = learning_path_subj_nums(contains(learning_paths, unq_subjs(subj_num,:)),:);
    
    % identify which training stage each path belongs to
    for istage = 1:3

        % check for missing days
        if isnan(first_mid_last(size(subj_paths,1), 2+istage/10, 0))
            continue
        end
        
        % stage paths
        stage_paths = subj_paths(first_mid_last(size(subj_paths,1), 2+istage/10, 0));
        stage_paths_subj_nums = subj_paths_nums(first_mid_last(size(subj_paths,1), 2+istage/10, 0), :);
        
        % load stage paths
        for ispath = 1:size(stage_paths,1)
            count(istage) = count(istage)+1;
            learning_paths_by_stage{istage}{count(istage),1} = stage_paths{ispath};
            subj_cell_pre{istage} = [subj_cell_pre{istage}; stage_paths_subj_nums(ispath)];
            
        end
        
    end
end

% identify ot population days
pop_idx = false(size(ot_paths));
for iot_path = 1:size(ot_paths,1)
    load(ot_paths{iot_path}, 'clusters')
    if sum(clusters(:,2)>=3) >=8
        pop_idx(iot_path) = true;
    end
end
ot_paths = ot_paths(pop_idx);
ot_paths = ot_paths(~contains(ot_paths, '_'));
subj_cell_pre{4} = subj_cell_pre{4}(pop_idx);
subj_cell_pre{4} = subj_cell_pre{4}(~contains(ot_paths, '_'));

% identify learning population days
for istage = 1:3
    pop_idx = false(size(learning_paths_by_stage{istage}));
    for ilearn_path = 1:size(learning_paths_by_stage{istage},1)
        load(learning_paths_by_stage{istage}{ilearn_path}, 'clusters')
        if sum(clusters(:,2)>=3) >=8
            pop_idx(ilearn_path) = true;
        end
    end
    learning_paths_by_stage{istage} = learning_paths_by_stage{istage}(pop_idx);
    subj_cell_pre{istage} = subj_cell_pre{istage}(pop_idx);
end

% combine paths into 4 cells
four_stage_paths = [learning_paths_by_stage {ot_paths}];
subj_cell = cell(1,4);

% compute rewards area firing rates
rr_out = cell(1,4);
rr_out_L = cell(1,4);
rr_out_R = cell(1,4);
for ifs = 1:size(four_stage_paths,2)
    for ifsp = 1:size(four_stage_paths{ifs},1)
        load(four_stage_paths{ifs}{ifsp}, 'eptrials', 'clusters')
        clusts = clusters(clusters(:,2)>=3,1);
        for iclust = 1:length(clusts)
            windowrates = ratewindow_mean(eptrials, clusts(iclust), 1, 0, 3, 5);
            rr_out{ifs} = [rr_out{ifs}; nanmean(windowrates(:,1)) ];
            rr_out_L{ifs} = [rr_out_L{ifs}; nanmean(windowrates(windowrates(:,2)==1,1)) ];
            rr_out_R{ifs} = [rr_out_R{ifs}; nanmean(windowrates(windowrates(:,2)==2,1)) ];
            subj_cell{ifs} =[subj_cell{ifs}; subj_cell_pre{ifs}(ifsp)];
        end
    end
end


% all baseline rates
%{
    % combine all paths
    all_paths = [ot_paths; learning_paths_by_stage{1};...
        learning_paths_by_stage{2}; learning_paths_by_stage{3}];
    %iteratively load
    all_bfrs = [];
    for iap = 1:size(all_paths,1)
        load(all_paths{iap}, 'eptrials', 'clusters')
        all_bfrs = [all_bfrs; firingratebatch(eptrials, clusters(:,1))];
    end
%}
    

