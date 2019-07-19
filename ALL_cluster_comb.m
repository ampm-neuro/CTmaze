function [cluster_comb, clustahs] = ALL_cluster_comb
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

cluster_comb = [];
clustahs = [];

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

%counts = zeros(1, length_subjects);

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
                load(strcat('neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));

                clustahs = [clustahs; clusters];
                
                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                %INSERT FUNCTION HERE

                %{
                if ~isempty(clusters)%screens empty cluster files to avoid errors
                  
                    try
                    %number of place cells
                    dms_place = spatialfield_batch(eptrials, clusts);
                    catch
                        dms_place = nan(size(clusts));
                        'error'
                    end

                    try
                    %number of rwd cells
                    [rwd_summary] = rwdcell(eptrials, clusts, 1, 1, stem_runs);
                    catch
                        rwd_summary = nan(size(clusts));
                    end

                    try
                    %number of stem-differenting
                    [stem_diff] = plotratestem(eptrials, clusts, stem_runs, 0);
                    catch
                        stem_diff = nan(size(clusts));
                    end

                    try
                    %reward cells that are also differentiating on stem
                    rwd_stem_comb = nansum([rwd_summary stem_diff],2)>1;
                    catch
                        rwd_stem_comb = nan(size(clusts));
                    end
                    
                end
                %}
                
                
                cluster_comb = [cluster_comb; [clusters(cluster_idx,:) repmat([stage subject session], size(clusters(cluster_idx,1))) dms_place rwd_summary stem_diff rwd_stem_comb]];
                
                
                
                
                
                
            catch
                
                display('no file')
            end
            
            
            
                       
            
        end
    end
    
    
end

end
