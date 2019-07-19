function [subj] = ALL_accl_v_decodeacc
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

output = [];
pops = [];
out = [];
subj = [];
accl_out = [];
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
    for stage = [2]
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
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
        
        if stage==1
            %number of folders
            length_accl = size(file_list_sessions,1);

                out = [out length_accl];
            
        elseif stage==2
        
            
            
            %trials corresponding to learning stage
            if floor(stage) == 2
                sesh_rng = first_mid_last(length_sessions, 2.3, 0); %1 for single day, 0 for range
            else
                sesh_rng = 1:length_sessions+1;
                %sesh_rng = 1:length_sessions;
            end
            
            
            %iterate through sessions
            for session = sesh_rng

                %day = file_list_sessions{:}(sessions,1).name
                day = session;

                %load session
                try
                    load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
                catch
                    continue
                end
                %INSERT FUNCTION HERE
                %runtime = max(eptrials(:,1));
                
                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                numcells = length(clusters(:,1));
                
                if numcells >= 8
                    %accl_out = [accl_out out(subject)];
                    
                    subj = [subj subject];
                    
                    %pops = [pops 1];
                else
                    %pops = [pops 0];
                end
                
                %subj = [subj subject];
                
                
                
                %HOW GOOD IS DECODING!?
                %[classification_success, ~, ~] = decodehist(eptrials, clusters(:,1), 60, 80)

                %output = [output; [str2num(rat) length_accl runtime numcells classification_success]]


            end
        end
    end
    
    
end
   
%filename = strcat('decodematx_345_ot_8plus(', num2str(shuf), ')');
%save(filename)
%clear

out = out(subj(logical(pops)));

end

