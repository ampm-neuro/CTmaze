function [count_matrices, group_IDs] = ALL_p1_pre(window)
%builds a count matrix for every population day in a certain training stage
%controls pop size
min_cells = 8;
%try 8

%which learning stages?
learning_stages = 4;
%1 accl
%2 cont
%3 delay
%4 ot

count_matrices = cell(num_sessions(min_cells,learning_stages), 1);
group_IDs = cell(size(count_matrices));


sesh_count = 0;
counter = 0;

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);

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
    for stage = learning_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
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
            
            rat
            day = sesh_list(session)
            

                %load session
                load(char(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,sesh_list(session))));

                %INSERT FUNCTION HERE

                if size(clusters,1)>=min_cells %CONTROL POPULATION SIZE
                    
                    sesh_count = sesh_count +1;
                    %if sesh_count ==9;

                    %counter
                    counter = counter + 1;

                    %function
                    [count_matrix, group_ID] = countmatrix(eptrials, clusters(:,1), 60, window);

                    %adding pages to 3d matrix
                    count_matrices{counter,1} = count_matrix;
                    group_IDs{counter,1} = group_ID;

                    
                end

        end
    end
    
    
end
   
end

