function [stem_mean_rates, rwd_mean_rates, IDs] = ALL_keytimes_LR(stages, min_trials)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

trial_type_hold = [];
stem_mean_rates_hold = [];
stem_mean_rates_L = [];
stem_mean_rates_R = [];
rwd_mean_rates_hold = [];
rwd_mean_rates_L = [];
rwd_mean_rates_R = [];
learning_progress = [];

%min_trials = 10;

%names%get all the things in neurodata folder...
file_list_subjects = dir('C:\Users\ampm1\Desktop\oldmatlab\neurodata\');

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
    file_list_stages = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name)));

    %hard coded erasure of irrelevant directory folders
    file_list_stages(1:2) = [];

    %exclude non-folders
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = floor(stages)%4%1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
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
    
        %iterate through select sessions
        %all_sesh = 1:length(sesh_list);
            %window
            %{
            if stages == 2
                sesh_rng = 1:length(sesh_list);
            elseif stages == 2.1
                sesh_rng = 1:round(length(sesh_list)\2);
            elseif stages == 2.2
                sesh_rng = floor(round((length(sesh_list)\2+1)\2)):ceil(length(sesh_list)*.75);
            elseif stages == 2.3
                sesh_rng = (round(length(sesh_list)\2)+1):length(sesh_list);
            else
                sesh_rng = 1:length(sesh_list);
            end
            %}
            
            %day
            %

            if stage ==2 
                sesh_rng = first_mid_last(length(sesh_list), stages, 0);
            else
                sesh_rng = 1:length(sesh_list);
            end
             
            %{
            if stages == 2
                sesh_rng = 1:length(sesh_list);
            elseif stages == 2.1
                sesh_rng = 1;
            elseif stages == 2.2
                sesh_rng = floor(length(sesh_list)\2);
                if ismember(sesh_rng, [0 1])
                    continue
                end
            elseif stages == 2.3
                sesh_rng = length(sesh_list);
                if ismember(sesh_rng, [0 1])
                    continue
                end
            else
                sesh_rng = 1:length(sesh_list);
            end
            %}
        
        
        for session = sesh_rng
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session;
            
            learn_prog = day\length(sesh_list);
            
            %load session
            eptrials = [];
            try
            load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
            catch
                strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat')
                continue
            end
 
            
            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = 1;
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            clusts = clusters(cluster_idx,1);
            
            %included trials
            all_trials = unique(eptrials(eptrials(:,8)>0,5));
            %all_trials = unique(eptrials(:,5)); all_trials = all_trials(stem_runs(:,3) < 1.25);
            error_trials = unique(eptrials(eptrials(:,8)==2,5));
            included_trials = setdiff(all_trials, error_trials);
                        
            %max_trials = 25;
            %if length(included_trials) < min_trials
            %    continue
            %end
            
            %for all included trials
            for trial = included_trials'

                local_eptrials = eptrials(eptrials(:,5)==trial, :);
                
                %entrance to stem
                    %last time point in high stem area
                    last_stem = max(local_eptrials(local_eptrials(:,6)==3, 1));
                    stem_enter = max(local_eptrials(local_eptrials(:,6)==1 & local_eptrials(:,1)<last_stem, 1));

                %exit from stem
                    %first true reward visit
                    rwd_vis = min(local_eptrials(ismember(local_eptrials(:,6), [7 8]) & local_eptrials(:,1)>stem_enter,1));
                    rwd_evt = min(local_eptrials(local_eptrials(:,10)==1 & local_eptrials(:,1)>rwd_vis,1));
                    stem_exit = min(local_eptrials(local_eptrials(:,6)==4 & local_eptrials(:,1)<rwd_vis & local_eptrials(:,1)>stem_enter,1));
                    choice_exit = min(local_eptrials(ismember(local_eptrials(:,6), [5 6]) & local_eptrials(:,1)<rwd_vis & local_eptrials(:,1)>stem_enter,1));
                    
                    %calculate rates of each cell
                    if isempty(stem_exit) || isempty(stem_enter) || isempty(rwd_evt)
                        continue
                    end   
                        stem_mean_rates_hold = [stem_mean_rates_hold ratewdw(eptrials, stem_enter, stem_exit, clusts)];
                        rwd_mean_rates_hold = [rwd_mean_rates_hold ratewdw(eptrials, rwd_evt+1, rwd_evt+3, clusts)];
                        
                    %calculate trial type
                    trial_type_hold = [trial_type_hold; mode(eptrials(eptrials(:,5) == trial, 7))];
            end
            
                   
            %filter for sessions with a minimum number of correct trials of
            %each type
            %min_trials = 10;
            if sum(trial_type_hold==1) < min_trials || sum(trial_type_hold==2) < min_trials
                %clear hold variable
                stem_mean_rates_hold = [];
                rwd_mean_rates_hold = [];
                trial_type_hold = [];
                continue
            end
            
            
            %conform trial number to minimum L
            if ~isempty(stem_mean_rates_L)
                if sum(trial_type_hold==1) > size(stem_mean_rates_L,2)
                    trial_type_hold(find(trial_type_hold==1, sum(trial_type_hold==1)-size(stem_mean_rates_L,2), 'last')) = 0;                    
                elseif sum(trial_type_hold==1) < size(stem_mean_rates_L,2)
                    stem_mean_rates_L = stem_mean_rates_L(:,1:sum(trial_type_hold==1));
                    rwd_mean_rates_L = rwd_mean_rates_L(:,1:sum(trial_type_hold==1));
                end
            end
            
            %conform trial number to minimum R
            if ~isempty(stem_mean_rates_R)
                if sum(trial_type_hold==2) > size(stem_mean_rates_R,2)
                    trial_type_hold(find(trial_type_hold==2, sum(trial_type_hold==2)-size(stem_mean_rates_R,2), 'last')) = 0;                    
                elseif sum(trial_type_hold==2) < size(stem_mean_rates_R,2)
                    stem_mean_rates_R = stem_mean_rates_R(:,1:sum(trial_type_hold==2));
                    rwd_mean_rates_R = rwd_mean_rates_R(:,1:sum(trial_type_hold==2));
                end
            end

            
            %load
            stem_mean_rates_L = [stem_mean_rates_L; stem_mean_rates_hold(:, trial_type_hold==1)];
            stem_mean_rates_R = [stem_mean_rates_R; stem_mean_rates_hold(:, trial_type_hold==2)];
            rwd_mean_rates_L = [rwd_mean_rates_L; rwd_mean_rates_hold(:, trial_type_hold==1)];
            rwd_mean_rates_R = [rwd_mean_rates_R; rwd_mean_rates_hold(:, trial_type_hold==2)];
            
            if ~isempty(stem_mean_rates_hold(:, trial_type_hold==1))
                learning_progress = [learning_progress; repmat(learn_prog, size(stem_mean_rates_hold(:, trial_type_hold==1), 1), 1)];
            end
            
            %clear hold variable
            stem_mean_rates_hold = [];
            rwd_mean_rates_hold = [];
            trial_type_hold = [];
        end
    end
end

[~, Lidx] = sort(learning_progress);

%lefts = size(rwd_mean_rates_L)
%rights = size(rwd_mean_rates_R)


%prepare output
stem_mean_rates_L = stem_mean_rates_L(Lidx, 1:min_trials); %trls begin of sesh
stem_mean_rates_R = stem_mean_rates_R(Lidx, 1:min_trials); %trls begin of sesh
%stem_mean_rates_L = stem_mean_rates_L(Lidx, end-min_trials+1:end); %trls end of sesh
%stem_mean_rates_R = stem_mean_rates_R(Lidx, end-min_trials+1:end); %trls end of sesh
stem_mean_rates = [stem_mean_rates_L stem_mean_rates_R]';

rwd_mean_rates_L = rwd_mean_rates_L(Lidx, 1:min_trials); %trls begin of sesh
rwd_mean_rates_R = rwd_mean_rates_R(Lidx, 1:min_trials); %trls begin of sesh
%rwd_mean_rates_L = rwd_mean_rates_L(Lidx, end-min_trials+1:end); %trls end of sesh
%rwd_mean_rates_R = rwd_mean_rates_R(Lidx, end-min_trials+1:end); %trls end of sesh
rwd_mean_rates = [rwd_mean_rates_L rwd_mean_rates_R]';

%IDs = [ones(size(stem_mean_rates_L, 2), 1); repmat(2, size(stem_mean_rates_R, 2), 1)];
IDs = [ones(size(rwd_mean_rates_L, 2), 1); repmat(2, size(rwd_mean_rates_R, 2), 1)];
ACs = [ones(size(stem_mean_rates_L, 2), 1); repmat(2, size(stem_mean_rates_R, 2), 1)];


end


function [rate] = ratewdw(eptrials, low, high, clusts)
%calculates rates for each cell in clusts during the time window from low
%to high

    rate = histc(eptrials(eptrials(:,1)>=low & eptrials(:,1)<=high, 4), clusts);
    rate = rate.\repmat(high-low, size(rate));

end
