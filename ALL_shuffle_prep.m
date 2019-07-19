function [shuffle_prep_output_stem, shuffle_prep_output_rwd, error_counter] = ALL_shuffle_prep
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

%builds a matrix of firing rates for each cell during the first 10 correct,
%typical L and R trials. 
%
%shuffle_prep_output(:,1:4) = firing rates for maze sectors 1:4
%shuffle_prep_output(:,5) = 1 for left 2 for right
%shuffle_prep_output(:,6) = stage
%shuffle_prep_output(:,7) = session
%shuffle_prep_output(:,8) = cell number within that rat-session
%shuffle_prep_output(:,9) = cell number within that stage (all rats)


shuffle_prep_output_stem = nan(1, 11);
shuffle_prep_output_rwd = nan(1, 9);

within_stage_count_2 = 0;
sesh_within_stage_count_2 = 0;
within_stage_count_3 = 0;
sesh_within_stage_count_3 = 0;
within_stage_count_4 = 0;
sesh_within_stage_count_4 = 0;

index_counter = 1;
error_counter = 0;
sesh_stage_count = 0;

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])}

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

%iterate through subjects
for subject = 1:length_subjects

    %print update
    rat = file_names_subjects{:}(subject,1).name
    
    %get all the things in subject folder...
    file_list_stages = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name)));

    %hard coded erasure of irrelevant directory folders
    file_list_stages(1:2) = [];

    %exclude non-folders
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = [2 4]%1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
        
                
        %%%FIGURE%%%
        %figure
        %hold on
        %title([num2str(rat), ', ',num2str(task)],'fontsize', 16)
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %exclude non-folders
        %file_list_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
           
        %number of folders
        length_sessions = size(file_list_sessions,1);
    
        %iterate through sessions
        for session = 1:length_sessions+1
           
            %day = session;
            strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
            
                
            try
                %load session
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            catch
                display('no file')
                error_counter = error_counter + 1;
                continue
            end

            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = [1];
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            clusts = clusters(cluster_idx,1);
            

                if stage ==2
                                        
                    within_sesh_count = 0;
                    sesh_within_stage_count_2 = sesh_within_stage_count_2 + 1;

                    for clust = clusts'

                        within_sesh_count = within_sesh_count + 1;
                        within_stage_count_2 = within_stage_count_2 + 1;
                        

                        %number of stem-differenting
                        [~, ~, firing_rates_stem, first_trials] = plotratestem(eptrials, clust, stem_runs, 0);
                        shuffle_prep_output_stem(index_counter:index_counter+(2*first_trials -1), :) = [firing_rates_stem repmat([stage session within_sesh_count within_stage_count_2 subject sesh_within_stage_count_2], 2*first_trials,1)];

                        
                        %number of rwd cells
                        [rwd_summary, firing_rates_rwd] = rwdcell(eptrials, clust, 1, 1, stem_runs);
                        shuffle_prep_output_rwd(index_counter:index_counter+(2*first_trials -1), :) = [firing_rates_rwd repmat([stage session within_sesh_count within_stage_count_2 subject sesh_within_stage_count_2], 2*first_trials,1)];
                        

                        %update index counter
                        index_counter = index_counter+2*first_trials;
                        
                    end
                    
     
                elseif stage ==3
                    
                    within_sesh_count = 0;
                    sesh_within_stage_count_3 = sesh_within_stage_count_3 + 1;

                    for clust = clusts'

                        within_sesh_count = within_sesh_count + 1;
                        within_stage_count_3 = within_stage_count_3 + 1;
                        

                        %number of stem-differenting
                        [~, ~, firing_rates_stem, first_trials] = plotratestem(eptrials, clust, stem_runs, 0);
                        shuffle_prep_output_stem(index_counter:index_counter+(2*first_trials -1), :) = [firing_rates_stem repmat([stage session within_sesh_count within_stage_count_3 subject sesh_within_stage_count_3], 2*first_trials,1)];

                        
                        %number of rwd cells
                        [rwd_summary, firing_rates_rwd] = rwdcell(eptrials, clust, 1, 1, stem_runs);
                        shuffle_prep_output_rwd(index_counter:index_counter+(2*first_trials -1), :) = [firing_rates_rwd repmat([stage session within_sesh_count within_stage_count_3 subject sesh_within_stage_count_3], 2*first_trials,1)];
                        

                        %update index counter
                        index_counter = index_counter+2*first_trials;
                        
                    end
                    
    
                elseif stage ==4
                    
                    within_sesh_count = 0;
                    sesh_within_stage_count_4 = sesh_within_stage_count_4 + 1

                    for clust = clusts'

                        within_sesh_count = within_sesh_count + 1;
                        within_stage_count_4 = within_stage_count_4 + 1;
                        

                        %number of stem-differenting
                        [~, ~, firing_rates_stem, first_trials] = plotratestem(eptrials, clust, stem_runs, 0);
                        shuffle_prep_output_stem(index_counter:index_counter+(2*first_trials -1), :) = [firing_rates_stem repmat([stage session within_sesh_count within_stage_count_4 subject sesh_within_stage_count_4], 2*first_trials,1)];

                        
                        %number of rwd cells
                        [rwd_summary, firing_rates_rwd] = rwdcell(eptrials, clust, 1, 1, stem_runs);
                        shuffle_prep_output_rwd(index_counter:index_counter+(2*first_trials -1), :) = [firing_rates_rwd repmat([stage session within_sesh_count within_stage_count_4 subject sesh_within_stage_count_4], 2*first_trials,1)];
                        

                        %update index counter
                        index_counter = index_counter+2*first_trials;
                        
                    end

                end                

        end
    end
    
    
end

end
