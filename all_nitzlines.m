function [all_smoothed_rates, all_dwell_times] = all_nitzlines(learning_stages)
%, zscores)
%plot trial by trial line graphs showing smoothed rate over a linearized
%maze. Uses the new plotting functions of correllate_trialtypepath that were
%added March 29, 2017


% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.
all_dwell_times = [];
all_smoothed_rates = [];
pop_num = 0;
cell_list = [];
count_z = 0;

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

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
    file_list_stages = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name)));

    %hard coded erasure of irrelevant directory folders
    file_list_stages(1:2) = [];

    %exclude non-folders
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    %learning_stages = size(file_names_stages{:},1);
    
    %learning_stages = 4;
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = floor(learning_stages)
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %exclude non-folders
        %file_list_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
           
        %number of folders
        length_sessions = size(file_list_sessions,1);
    
        
        %trials corresponding to learning stage
        if floor(learning_stages) == 2
            %sesh_rng = first_mid_last(length_sessions, learning_stages, 1); %single day
            sesh_rng = first_mid_last(length_sessions, learning_stages, 0); %range
        else
            sesh_rng = 1:length_sessions+1;
        end
        
        
        %iterate through sessions
        for session = sesh_rng
           
            day = session

            try
                %load session
                %load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
                
            catch
                
                display('no file')
            end
            
                
                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                %{
                if length(clusts)>=8
                    pop_num = pop_num+1;
                elseif learning_stages == 2.1 && length(clusters)>=8
                    pop_num = pop_num+1;
                else
                    continue
                end
                %}
                
                %
                for c = clusts'
                    %figure;
                    
                    %if sum(eptrials(:,4)==c)/eptrials(end,1) > 10 %minimum firing rate
                     [~, ~, times_in_all_bins, ~, ~, smoothed_rates_out, trltype_idx]...
                        = correllate_trialtypepaths(eptrials, stem_runs, 100, c);
                    times_in_all_bins = times_in_all_bins';                    
                    all_smoothed_rates = [all_smoothed_rates; [smoothed_rates_out{1} smoothed_rates_out{2}]];
                    all_dwell_times = [all_dwell_times; [{times_in_all_bins(trltype_idx==1,:)}  {times_in_all_bins(trltype_idx==2,:)}]];
                    %else
                    %    continue
                    %end
                 
                    
                    %check if destination has appropriate folder, if not, create it.
                    %pathname = ['C:\Users\ampm1\Documents\manuscripts\Maze_Revisions\eLife\revisions\place_field_migration\nitzlines\pop' num2str(pop_num)];
                    %if ~exist(strcat(pathname), 'dir')
                    %    mkdir(strcat(pathname))
                    %end
                    
                    
                 %title(gca, [strcat(num2str(rat),'-' ,num2str(task),'-' ,num2str(session)),'-' , num2str(pop_num)])
                 %var_name = [strcat(num2str(rat),'-' ,num2str(task),'-' ,num2str(session)),'-', num2str(c*100),'-', num2str(pop_num)]; 
                 %print([pathname '\' var_name], '-dpdf', '-painters', '-bestfit')
                 %close all
                 
                end
                %}       
            
        end
    end
    
    
end

end
