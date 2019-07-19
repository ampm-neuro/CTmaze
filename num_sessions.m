function count = num_sessions(min_cells, learning_stages)
%counts the total number of recording sessions with min_cells number of cells

count = 0;

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);

counts = zeros(1, length_subjects);

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
    %length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = learning_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name;

        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
     
        %session folders
        if size(file_list_sessions,1) == 0
            continue
        elseif size(file_list_sessions,1) == 1
            sesh_list = {file_list_sessions.name};
        else
            sesh_list = vertcat({file_list_sessions.name});
        end

        %iterate through sessions
        for session = 1:length(sesh_list)
            
            file = char(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,sesh_list(session)));
            
            %load session
            load(file);

            %INSERT FUNCTION HERE

            if length(clusters(:,1)) >= min_cells
                count = count + 1;
                session_idx = count;
                cell_count = length(clusters(:,1));
                %file;
                %display('next');
            end

        end
    end
    
    
end

end