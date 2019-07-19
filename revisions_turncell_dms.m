function [turn_cell_scores, lin_maze_all, lr_idx_all] = revisions_turncell_dms
% iterates through all sessions, comparing firing at left turn spatial
% locations to firing at right turn spatial locations


% figure out if lin_pos_col is outputing true locations (some bins, esp at
% stem, feel underrepresented).



% psuedo input
bins = 100;

% all session files
sesh_files = get_file_paths('C:\Users\ampm1\Desktop\oldmatlab\neurodata');
sesh_files = sesh_files(contains(sesh_files, 'continuous') | contains(sesh_files, 'overtraining'));

% preallocate
lin_maze_all = cell(size(sesh_files,1),1);
lr_idx_all = cell(size(sesh_files,1),1);

% session selections
session_selections = 1:size(sesh_files, 1);
num_sessions = length(session_selections)
final_sesh = session_selections(end)


% iterate through sessions
for isesh = session_selections 
    
    isesh
    
    % load session
    load(sesh_files{isesh}, 'eptrials', 'clusters')
    num_trials = length(unique(eptrials(:, 5)));
    
    % linearize position
    lin_pos_col = linearize_pos(eptrials, bins);
    lin_maze = nan(num_trials, bins, size(clusters, 1));

    % iterate through clusters
    for iclust = 1 : size(clusters, 1)
    
        % average by bin on each trial
        for itrl = 1 : num_trials
            for ibin = 1 : bins
                
                % firing rate ingredients
                num_spikes = sum(eptrials(:, 5)==itrl & lin_pos_col==ibin & eptrials(:, 4)==clusters(iclust, 1));
                dwell_time = sum(eptrials(:, 5)==itrl & lin_pos_col==ibin & eptrials(:, 14)==1)/100;
                
                % load
                lin_maze(itrl, ibin, iclust) = num_spikes/dwell_time;
                
            end
        end

        % left and right trials index
        lr_idx = nan(num_trials, 1);
        for itrl = 1 : num_trials
            lr_idx(itrl) = mode(eptrials(eptrials(:, 5)==itrl, 7));
        end
    
    end
    
    %concatenate
    lin_maze_all{isesh} = lin_maze;
    lr_idx_all{isesh} = lr_idx;
    
    
    %save progress
    save('revisions_turncell_dms_inprog')
    
end

% turn cell bins (hard coded for 100 bins)
left_turns = [{[60:65]'} {[91:95]'} {[98:bins 41:42]'}]; % choice return start
right_turns = [{[60 1:5]'} {[31:35]'} {[38:42]'}]; % choice return start

% compute turn cell scores
turn_cell_scores = [];
cell_count = 0;
for isesh = session_selections
    for iclust = 1:size(lin_maze_all{isesh},3)
        cell_count = cell_count + 1;
                
        %remove inf
        lin_maze_all{isesh}(isinf(lin_maze_all{isesh})) = nan;
        
        %compute mean firing rates
        left_turn_rates = nanmean(nanmean(lin_maze_all{isesh}(lr_idx_all{isesh}==1, cell2mat(left_turns'), iclust)));
        right_turn_rates = nanmean(nanmean(lin_maze_all{isesh}(lr_idx_all{isesh}==2, cell2mat(right_turns'), iclust)));
        turn_cell_scores(cell_count) = abs(left_turn_rates - right_turn_rates) / (left_turn_rates + right_turn_rates);
    end
end

%save final product
save('revisions_turncell_dms_final')




