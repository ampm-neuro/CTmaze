function [mean_velocity, mean_pos_diff, percent_stem_diff] = ALL_confounds
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

mean_velocity = [];
mean_pos_diff = [];
percent_stem_diff = [];


%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])}

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

counts = zeros(1, length_subjects);

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
    for stage = [3 4]%1:length_stages
        
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

            %in ot
            if stage == 4
            %cancel last two (dropped) 1860 sessions
                if subject==11 && session>length_sessions-2
                    continue
                end
            end
            
           
            day = session
            
            try
                %load session
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));

                trialsxpos = posstem(eptrials, stem_runs);
                trial_pos = reshape(trialsxpos(:,1), [4 length(trialsxpos(:,1))/4])';
                
                trial_type = reshape(trialsxpos(:,3), [4 length(trialsxpos(:,3))/4])';
                trial_type = trial_type(:,1);
                trial_accuracy = reshape(trialsxpos(:,4), [4 length(trialsxpos(:,4))/4])';
                trial_accuracy = trial_accuracy(:,1);

                stem_runs_short = stem_runs(2:end,:);
                
                %criteria and first_trials
                sesh_pos_L = trial_pos(trial_type==1 & trial_accuracy==1 & stem_runs_short(:,3)<2, :);
                sesh_pos_L = sesh_pos_L(1:10,:);
                sesh_pos_R = trial_pos(trial_type==2 & trial_accuracy==1 & stem_runs_short(:,3)<2, :);
                sesh_pos_R = sesh_pos_R(1:10,:);
                
                vel_L = stem_runs_short(stem_runs_short(:,3)<2 & trial_accuracy==1 & trial_type==1, 3);
                vel_L = vel_L(1:10,:);
                vel_R = stem_runs_short(stem_runs_short(:,3)<2 & trial_accuracy==1 & trial_type==2, 3);
                vel_R = vel_R(1:10,:);
                
                
                
                mean_pos_diff = [mean_pos_diff; sum(abs(mean(sesh_pos_L) - mean(sesh_pos_R)))];
                mean_velocity = [mean_velocity; 1.2/mean([vel_L;vel_R])];
                
                
                
                %number of stem-differenting
                %[stem_diff] = plotratestem(eptrials, clusters(:,1), stem_runs, 0);
                %percent_stem_diff = [percent_stem_diff; [sum(stem_diff)/size(clusters,1) stage]];

                
            catch
                
                display('no file')
            end
            
            
            
                       
            
        end
    end
    
    
end

end
