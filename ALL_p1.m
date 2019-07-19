function [p_decodes] = ALL_p1(count_matrices)
%[p_matrix, p_decodes, bins] = ALL_p1
%
%take decoder half way, you can then finish normally or shuffle with p2
%
%ALL_p1 runs decodesection (actually decodesection_shuffle_p1) on every
%session in the indicated learning stage that has at least min_cells number
%of clusters. It outputs a cell matrix, with one cell for each session.
%Each cell contains a matrix where the rows correspond to time samples and
%the first 10 columns contain the total probability that the rat is in
%each unfolded maze section. 
%
%The additional 6 columns contain the trial number, the current maze 
%section, the trial type (L/R), accuracy (C/E), how long it took the rat 
%to make that stem run, and and index for whether the time point is in the 
%official stem run time range (1) or not (0).

%controls pop size
min_cells = 8;
%try 8

%which learning stages?
learning_stages = 4;
%1 accl
%2 cont
%3 delay
%4 ot


%p_matrices = cell(num_sessions(min_cells,learning_stages), 1);
p_decodes = cell(num_sessions(min_cells,learning_stages), 1);
%ts_details = cell(size(p_matrices));
%ts_pmatrix = cell(size(p_matrices));

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
                    %[p_matrix, timesample_details, timesample_pmatrix, bins] = decoder_correlation_p1(eptrials, clusters(clusters(:,2)>2,1), 60, 80);
                    [unfolded_section_pdecode] = decodesection_shuffle_p1(eptrials, clusters(:,1), 60, 60, stem_runs);


                    %adding pages to 3d matrix
                    %p_matrices{counter,1} = p_matrix;
                    p_decodes{counter,1} = unfolded_section_pdecode;
                    %ts_details{counter,1} = timesample_details;
                    %ts_pmatrix{counter,1} = timesample_pmatrix;
                    
                    %end
                end
            
            
        end
    end
    
    
end
   
end