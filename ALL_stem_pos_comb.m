function [stem_pos_comb] = ALL_stem_pos_comb
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

%calculates the rats average position in each maze section on each trial
%ever


stem_pos_comb = [];


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
        for session = 1:length_sessions
            
            day = session
            
            try
                %load session
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));

                %INSERT FUNCTION HERE

                %if length(clusters(:,1))>=8
                
                    [trialsxpos] = posstem(eptrials, stem_runs);
                                    
                    stem_pos_comb = [stem_pos_comb; [trialsxpos repmat([stage subject session], size(trialsxpos(:,1)))]];
                    
                %end
            
            catch
                
                display('no file')
            end
            
            
            
            %save session in correct destination folder
            %save(strcat('/Users/ampm/Documents/MATLAB/neurodata/', num2str(rat), '/', num2str(task), '/', num2str(session)), 'eptrials', 'clusters', 'origin_file')
            
            %clear variables
            %clear eptrials
            %clear clusters
            %clear clusts
            %clear origin_file
            %clear data
            
            
        end
    end
    
    
end

end
