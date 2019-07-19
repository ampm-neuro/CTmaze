function [subj_cell_MIS, subj_cell_PosInfo] = ALL_MIS
%iterates through sessions computing scores for each cell


%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');
file_list_subjects(1:2) = [];
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};
length_subjects = size(file_names_subjects{:},1);

%preallocate
subj_cell_MIS = cell(12,2); %learn, ot
subj_cell_PosInfo = cell(12,2);
subj_count = 0;


%iterate through subjects
for subject = 1:length_subjects
    subj_count = subj_count+1;

    %print update
    rat = file_names_subjects{:}(subject,1).name
    file_list_stages = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name)));
    file_list_stages(1:2) = [];
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    length_stages = size(file_names_stages{:},1);
    
    day_count = 0;
    crit_day = nan;
    pct_correct = [];
    num_cells = [];
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = [2 4]%1:length_stages
        
        task = file_names_stages{:}(stage,1).name;
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        file_list_sessions(1:2) = [];
        length_sessions = size(file_list_sessions,1);
    
        %iterate through sessions
        for session = 1:length_sessions+1
            day = session;
            
            MIS_scores = [];
            PosInfo_scores = [];
            
            
            try
                %load session
                stem_runs = [];
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));

                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                %compute info scores
                [MIS_scores, PosInfo_scores] = MIS_single_sesh(eptrials, clusts, stem_runs);
            catch
                
                display('no file')
            end
            
            subj_cell_MIS{subj_count, stage/2} = [subj_cell_MIS{subj_count, stage/2} {MIS_scores}];
            subj_cell_PosInfo{subj_count, stage/2} = [subj_cell_PosInfo{subj_count, stage/2} {PosInfo_scores}];
            
        end
    end
end
end
