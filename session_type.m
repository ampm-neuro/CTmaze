function mtx = session_type(min_pop_size)
%iterates through neurodata folders, finds qualifying sessions, and outputs
%a matrix of session number 1:#found and whether they are learning, OT, or
%delay

%counter
count = 0;

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
    for stage = 1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
           
        %number of folders
        length_sessions = size(file_list_sessions,1);
    
        %iterate through sessions
        for session = 1:length_sessions
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session;
            
            %load session
            load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            
            %INSERT FUNCTION HERE
            if length(clusters)>1%screens empty cluster files to avoid errors
                if length(clusters(clusters(:,2)>2,1))>=min_pop_size %CONTROL POPULATION SIZE
                
                count = count+1;
                
                mtx(count, 1) = count;
                mtx(count, 2) = stage;
                
                end
            end
            
        end
    end
    
    
end

end
