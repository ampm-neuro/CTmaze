function [all_path_cell, incl_path_cell, excl_path_cell] = plot_filter_paths_learning(rat_num)
%plot the filtered paths from first, mid, crit, and last ot day from one
%subject

count = 0;

all_path_cell = {};
incl_path_cell = {};
excl_path_cell = {};

%print update
rat = rat_num;

%get all the things in subject folder...
file_list_stages = dir(['C:\Users\ampm1\Desktop\oldmatlab\neurodata\' num2str(rat_num)]);

%hard coded erasure of irrelevant directory folders
file_list_stages(1:2) = [];

%exclude non-folders
file_names_stages = {file_list_stages([file_list_stages(:).isdir])};

%number of folders
length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = [2 4]
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(rat_num), '\',...
            num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
        
        %number of folders
        length_sessions = size(file_list_sessions,1);
        
        %trials corresponding to learning stage
        if stage == 2
            %{
            sesh_rng = [];
            for istage = [2.1 2.2 2.3]
                snum = first_mid_last(length_sessions, istage, 1); %1 for single day, 0 for range
                sesh_rng = [sesh_rng snum];
            end
            %}
            %sesh_rng = [1 3 5];
            sesh_rng = [2 4 6];
            %sesh_rng = [2 3 4];
        elseif stage==4
            %sesh_rng = length_sessions-1;
            sesh_rng = length_sessions;
        end

        %iterate through sessions
        for session = sesh_rng

            if isnan(session)
                continue
            end
            
            %load session
            try
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
                strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat');
            catch
                strcat('\Users\ampm\Documents\MATLAB\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat')
                display('could not load file')
                continue
            end
            
            %plot each path
            count = count+1;
            [all_paths, incl_paths, excl_paths] = filter_paths(eptrials, stem_runs, count);
            all_path_cell{count} = all_paths;
            incl_path_cell{count} = incl_paths;
            excl_path_cell{count} = excl_paths;

        end
    end