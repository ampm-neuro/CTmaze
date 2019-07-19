function [class_accuracy, pop_size] = ALL_decode_accuracy_popsize(learning_stages, bins, window, slide)
%[class_accuracy, pop_size] = ALL_decode_accuracy_popsize(4, 50, .2, .1) 
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.


%reminder displays
if floor(learning_stages) == 1
    display('acclimation sessions')
elseif floor(learning_stages) == 2
    if learning_stages == 2
        display('learning sessions (all)')
    elseif learning_stages == 2.1
        display('learning sessions: first')    
    elseif learning_stages == 2.2
        display('learning sessions: mid')    
    elseif learning_stages == 2.3
        display('learning sessions: last (crit)')    
    end
elseif floor(learning_stages) == 3
    display('delay sessions')
elseif floor(learning_stages) == 4
    display('overtraining sessions')
end

radius = 7;
count = 0;

class_accuracy = [];
pop_size = [];

%names%get all the things in neurodata folder...
file_list_subjects = dir('C:\Users\ampm1\Desktop\oldmatlab\neurodata\');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

%iterate through subjects
for subject = 1:length_subjects

    %print update
    rat = file_names_subjects{:}(subject,1).name
    
    %get all the things in subject folder...
    file_list_stages = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name)));

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
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %number of folders
        length_sessions = size(file_list_sessions,1);
        
        %trials corresponding to learning stage
        if floor(learning_stages) == 2
            sesh_rng = first_mid_last(length_sessions, learning_stages, 0);
        else
            sesh_rng = 1:length_sessions+1;
        end
            
        

        %iterate through sessions
        for session = sesh_rng
            
            if isnan(session)
                continue
            end
            
            %in ot
            if stage == 4
            %cancel last two (dropped) 1860 sessions
                if subject==11 && session>length_sessions-2
                    continue
                end
            end
            
            
            try
                
                %load session
                stem_runs = [];
                string_load = strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat');
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'))
                
                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                if length(clusters(:,1))>=1

                    %classify 
                    [classification_success, dists] = decodehist_popsize(eptrials, clusts, bins, window, slide);

                    %class_accuracy = [class_accuracy; classification_success];
                    class_accuracy = [class_accuracy; sum(dists<=radius)/length(dists)];
                    pop_size = [pop_size; length(clusters(:,1)) ];

                end
                
             catch
                 display('no file')
             end
        end
    end
end

