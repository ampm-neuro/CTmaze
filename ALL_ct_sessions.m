function [sesh_cts, subj_cell] = ALL_ct_sessions
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])}

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

%preallocate
sesh_cts = nan(12,4);
subj_count = 0;


%iterate through subjects
for subject = 1:length_subjects
    subj_count = subj_count+1;

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
    
    day_count = 0;
    crit_day = nan;
    pct_correct = [];
    num_cells = [];
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = [1 2 4]%1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %number of folders
        length_sessions = size(file_list_sessions,1);
    
        %iterate through sessions
        for session = 1:length_sessions+1

            %in ot
            %{
            if stage == 4
                %cancel last two (dropped) 1860 sessions
                if subject==11 && session>length_sessions-2
                    continue
                end
            end
            %}
            
           
            day = session;
            
            try
                %load session
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));

                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                
                    if stage==4 && session==1
                        crit_day = day_count;
                    end
                
                    day_count = day_count+1;
                    pct_correct = [pct_correct; length(unique(eptrials(eptrials(:,8)==1,5)))/length(unique(eptrials(ismember(eptrials(:,8), [1 2]),5)))];
                    num_cells = [num_cells; length(clusts)];
                
            catch
                
                display('no file')
            end
        end
        
        sesh_cts(subj_count, stage) = day_count;
        day_count = 0;
    end
 
end

% build a 2x2 cell of experience on the maze in days
subj_cell = cell(size(sesh_cts,1),2);
cols = [2 4];
for ir = 1:size(sesh_cts,1)
    for col = 1:length(cols)
        for iday = 1:sesh_cts(ir,cols(col))
            if cols(col)==2
                subj_cell{ir,col} = [subj_cell{ir,col} {sesh_cts(ir,1)+iday}];
                %subj_cell{ir,col} = [subj_cell{ir,col} {iday}]; %excluding acclimation
                
            elseif cols(col)==4
                subj_cell{ir,col} = [subj_cell{ir,col} {sum(sesh_cts(ir,1:2),2)+iday}];
                %subj_cell{ir,col} = [subj_cell{ir,col} {sesh_cts(ir,2)+iday}]; %excluding acclimation
            end
        end
    end
end

end
