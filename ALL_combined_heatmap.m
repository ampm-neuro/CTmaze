function [rms] = ALL_combined_heatmap
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

rms = [];

%names%get all the things in neurodata folder...
file_list_subjects = dir('C:\Users\ampm1\Desktop\oldmatlab\neurodata\');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])}

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
    for stage = [4]%1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
        
        %%%FIGURE%%%
        %figure
        %hold on
        %title([num2str(rat), ', ',num2str(task)],'fontsize', 16)
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
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
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\'...
                    ,num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));

                %number of stem-differenting
                for clust = clusters(clusters(:,2)>=3,1)'
                    %[rate_matrix] = trlfree_heatmap(eptrials, clust, 20);
                    [rate_matrix] = trialbased_heatmap(eptrials, clust, 20, 3, .5);
                    
                    rm = smooth2a(rate_matrix,1);
                    rm = rm - nanmean(rm(:));
                    rm = rm ./ nanstd(rm(:));
                    
                    figure;imagesc(rm)
                    
                    rms = cat(3, rms, rm);
                end
                
            catch
                
                display('no file')
            end
            
            
            
                       
            
        end
    end
    
    
end

rms = nanmean(rms,3);

figure; imagesc(rms);

end
