function [out] = ALL_infoscores(learning_stages, all_vel)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

scores = [];
current_learning_stage = 0;
cell_count = 0;
%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

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
            sesh_rng = first_mid_last(length_sessions, learning_stages, 1);
        else
            sesh_rng = 1:length_sessions+1;
        end
            
        

        %iterate through sessions
        for session = sesh_rng
            
            %check for too many figures
            if size(findobj(0,'type','figure'),1) > 100
                error('too many figures')
            end
            
            %if session doesnt exist
            if isnan(session)
                continue
            end

            
            
            try
                %load session if it exists
                if ~isequal(learning_stages, current_learning_stage)
                    current_learning_stage = learning_stages
                end
                strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            catch
                continue
            end
            
            %inputs
            clusts = clusters(clusters(:,2)>=3 & clusters(:,4)==1, 1)';
            bins = 80;
            min_visits = 2;
            
            if ~isempty(clusts) %screens empty cluster files to avoid errors

                %interped velocity
                cell_count = cell_count + 1;
                vel_col = all_vel{cell_count};

                %constrain eptrials
                %eptrials = eptrials(eptrials(:,7)==2,:);
                eptrials = eptrials(vel_col > .20,:);
 
                    [dms_place] = spatialfield_batch(eptrials, clusts, min_visits, [], [], []);            
                
                    iscore = info_score(eptrials, bins, min_visits, clusts, learning_stages);
                    scores = [scores iscore(logical(dms_place))];
                    %scores = [scores iscore];

            end
        end
    end
    
    
end
out = scores;

end
