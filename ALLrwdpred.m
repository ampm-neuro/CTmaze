function [outputs] = ALLrwdpred(learning_stages)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.
%
%gathers the outputs associated with rwdpredict

outputs = [];

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
    for stage = floor(learning_stages)
                
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %exclude non-folders
        %file_list_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
           
        %number of folders
        length_sessions = size(file_list_sessions,1)
        
        %trials corresponding to learning stage
        if floor(learning_stages) == 2
            sesh_rng = first_mid_last(length_sessions, learning_stages, 0);
        else
            sesh_rng = 1:length_sessions+1;
            %sesh_rng = 1:length_sessions;
        end
    
        %iterate through sessions
        for session = sesh_rng
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session
            
            %load session
            try
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            catch
                display('no file')
                continue
            end
            %INSERT FUNCTION HERE
            %if length(unique(eptrials(eptrials(:,8)==2,5))) > 1
                if length(clusters)>1%screens empty cluster files to avoid errors
                    if length(clusters(clusters(:,2)>2,1))>=8 %CONTROL POPULATION SIZE

                        [Cmean_same, Emean_same, Cmean_opp, Emean_opp, Cmean, Emean, zdist] = rwdpredict(eptrials, clusters(clusters(:,2)>2,1));

                        %adding to output matrix
                        outputs = [outputs;[Cmean_same, Emean_same, Cmean_opp, Emean_opp, Cmean, Emean, zdist]];

                    end
                end
            %end
            
        end
    end
    
    
end

end