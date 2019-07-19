function [cell_count, pop_count, stem_diff_prop, rwd_cell_prop, rwd_stem_comb_prop, stem_diff_all, rwd_sum_all, fs_and_ts_comb_rwd, accuracy, pop_size, prop_stem] = cell_type_counts(min_pop_size, learning_stages)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.
%
%stage numbers
%   1 = acclimation
%   2 = continuous (learning)
%   3 = delay
%   4 = overtraining

%{
[cell_count_21, pop_count_21, stem_diff_prop_21, rwd_cell_prop_21,rwd_stem_comb_prop_21, stem_diff_all_21, rwd_sum_all_21] = cell_type_counts(8, 2.1); close all;
[cell_count_22, pop_count_22, stem_diff_prop_22, rwd_cell_prop_22, rwd_stem_comb_prop_22, stem_diff_all_22, rwd_sum_all_22] = cell_type_counts(8, 2.2); close all;
[cell_count_23, pop_count_23, stem_diff_prop_23, rwd_cell_prop_23, rwd_stem_comb_prop_23, stem_diff_all_23, rwd_sum_all_23] = cell_type_counts(8, 2.3); close all;
[cell_count_4, pop_count_4, stem_diff_prop_4, rwd_cell_prop_4, rwd_stem_comb_prop_4, stem_diff_all_4, rwd_sum_all_4] = cell_type_counts(8, 4); close all;
%}

%set counter
cell_count = 0;
pop_count = 0;
stem_diff_all = [];
rwd_sum_all = [];
fs_and_ts_comb_rwd = [];
accuracy = [];
pop_size = [];
prop_stem = [];
%place_stem_comb = 0;
%stem_diff_fs = [];

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

%iterate through subjects
for subject = 1:length_subjects %

    %print update
    rat = file_names_subjects{:}(subject,1).name;
    
    %get all the things in subject folder...
    file_list_stages = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name)));

    %hard coded erasure of irrelevant directory folders
    file_list_stages(1:2) = [];

    %exclude non-folders
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = floor(learning_stages)
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
        
        %number of folders
        length_sessions = size(file_list_sessions,1);
        
        %trials corresponding to learning stage
        if floor(learning_stages) == 2
            sesh_rng = first_mid_last(length_sessions, learning_stages, 0); %1 for single day, 0 for range
        else
            sesh_rng = 1:length_sessions+1;
            %sesh_rng = 1:length_sessions;
        end

        %iterate through sessions
        for session = sesh_rng

            if isnan(session)
                continue
            end
            
            %load session
            try
                load(strcat('neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
                strcat('neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat')
            catch
                %strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
                %display('could not load file')
                continue
            end
            
            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = [1];
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            clusts = clusters(cluster_idx,1);
            
            if length(clusters)>1%screens empty cluster files to avoid errors
                
                if ~isempty(clusts)
                                    
                    %number of stem-differenting
                    [stem_diff, stem_fs] = plotratestem(eptrials, clusts, stem_runs, 0);
                    stem_diff_all = [stem_diff_all; stem_diff];

                    %number of rwd cells WINDOWSIZE IS BEFORE +
                    %AFTER RWD INSTANCE (e.g., 1s is .5s bin before and
                    %after)
                    [rwd_summary, ~, fs_and_ts] = rwdcell(eptrials, clusts, 1, 1, stem_runs);
                    rwd_sum_all = [rwd_sum_all; rwd_summary];
                    
                    fs_and_ts_comb_rwd = [fs_and_ts_comb_rwd; fs_and_ts];
                    
                    %{
                    examples = clusts(fs_and_ts(:,1) <.005 & fs_and_ts(:,2) <.005 & stem_fs(:,1) < 0.5)
                    if ~isempty(examples)
                        for i = examples'
                            ratewindow(eptrials, i, 50, 3, 1, 0)
                            title(num2str(i))
                        end
                    end
                    %}
                    %error('too bad')
                    
                    %number of place cells
                    %dms_place = spatialfield_batch(eptrials, clusts);
                    %place_cell_count = place_cell_count + sum(dms_place);

                    %place cells that are also differentiating on stem
                    %place_stem_comb = place_stem_comb + sum(sum([rwd_summary stem_diff],2)>1);


                    %number of cells
                    cell_count = cell_count + length(clusts);
 
                                   
                    accuracy_hold = (length(unique(eptrials(eptrials(:,8)==1,5)))-1)/(length(unique(eptrials(:,5)))-1);
                    
                    prop_stem = [prop_stem sum(stem_diff(~isnan(stem_diff)))/sum(~isnan(stem_diff))];
                    accuracy = [accuracy; accuracy_hold];
                    pop_size = [pop_size; length(clusts)];
                    

                
                if length(clusts)>=min_pop_size %CONTROL POPULATION SIZE
                
                    pop_count = pop_count+1;
                
                end
                
                end
            end
            
        end
    end
    
    
end

stem_diff_prop = nansum(stem_diff_all)/sum(~isnan(stem_diff_all));
rwd_cell_prop = nansum(rwd_sum_all)/sum(~isnan(rwd_sum_all));
rwd_stem_comb_prop = sum(stem_diff_all==1 & rwd_sum_all==1)/sum(~isnan(stem_diff_all) & ~isnan(rwd_sum_all));

end
