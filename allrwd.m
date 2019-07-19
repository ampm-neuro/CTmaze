function [anova_rwd] = allrwd(learning_stages, window_size)
%find number of reward cells by running rwdbatch on all sessions
%
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

anova_rwd = [];

%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);

%names
%file_names_subjects{:}(1:length_subjects,1).name;

%iterate through subjects
for subject = 7%1:length_subjects %

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
            sesh_rng = 1:length_sessions+1;
            %sesh_rng = first_mid_last(length_sessions, learning_stages, 1); %1 for single day, 0 for range
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
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
                %strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
            catch
                strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
                display('could not load file')
                continue
            end
            
            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = [1];
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            clusts = clusters(cluster_idx,1);
            
            if isempty(clusts)
                continue
            end
            
            %INSERT FUNCTION HERE
            
            %anova 
            file = strcat(num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat');
            [summary_batch] = rwdcell(eptrials, clusts, window_size, 1, stem_runs, file);
            anova_rwd = [anova_rwd; summary_batch];

        end
    end
end

end