function [stem_mean_rates, rwd_mean_rates, IDs, percent_correct] = ALL_keytimes_LR_err(stages, varargin)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

if nargin == 2
    rng_ = varargin{1};
end

trial_type_hold = [];
trial_accuracy_hold = [];
stem_mean_rates_hold = [];
stem_mean_rates_L = [];
stem_mean_rates_R = [];
stem_mean_rates_L_err = [];
stem_mean_rates_R_err = [];
rwd_mean_rates_hold = [];
rwd_mean_rates_L = [];
rwd_mean_rates_R = [];
rwd_mean_rates_L_err = [];
rwd_mean_rates_R_err = [];
learning_progress = [];

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
    for stage = floor(stages)%4%1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
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
                sesh_rng = 1:round(length(sesh_list)/2);
            elseif stages == 2.2
                sesh_rng = floor(round((length(sesh_list)/2+1)/2)):ceil(length(sesh_list)*.75);
            elseif stages == 2.3
                sesh_rng = (round(length(sesh_list)/2)+1):length(sesh_list);
            else
                sesh_rng = 1:length(sesh_list);
            end
            %}
            
            %day
            %
            if stages == 2
                sesh_rng = 1:length(sesh_list);
            elseif stages == 2.1
                sesh_rng = 1;
            elseif stages == 2.2
                sesh_rng = floor(length(sesh_list)/2);
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
            
           
            
            try
                %load session
                eptrials = [];
                %strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            catch
                display('no file')
                continue
            end
                
                
            %learn_prog = day/length(sesh_list); %when in rats training
            learn_prog = length(unique(eptrials(eptrials(:,8)==1,5)))/length(unique(eptrials(eptrials(:,8)>0,5))); %percent correct
            
            
            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = 1;
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            clusts = clusters(cluster_idx,1);
            
            %included trials
            all_trials = unique(eptrials(eptrials(:,8)>0,5));
            error_trials = unique(eptrials(eptrials(:,8)==2,5));
            %included_trials = setdiff(all_trials, error_trials);
            included_trials = all_trials;
            
                        
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
                stem_exit = min(local_eptrials(local_eptrials(:,6)==4 & local_eptrials(:,1)<rwd_vis & local_eptrials(:,1)>stem_enter,1));
                choice_exit = min(local_eptrials(ismember(local_eptrials(:,6), [5 6]) & local_eptrials(:,1)<rwd_vis & local_eptrials(:,1)>stem_enter,1));
                    
                    %calculate rates of each cell
                    if ~isempty(stem_exit) && ~isempty(stem_enter) && ~isempty(rwd_vis)
                        stem_mean_rates_hold = [stem_mean_rates_hold ratewdw(eptrials, stem_enter, stem_exit, clusts)];
                        rwd_mean_rates_hold = [rwd_mean_rates_hold ratewdw(eptrials, stem_exit, choice_exit+1, clusts)];
                        
                    end
                    
                    %calculate trial type
                    trial_type_hold = [trial_type_hold; mode(eptrials(eptrials(:,5) == trial, 7))];
                    trial_accuracy_hold = [trial_accuracy_hold; mode(eptrials(eptrials(:,5) == trial, 8))];
            end
            
                   
            %filter for sessions with a minimum number of error trials
            %min_trials = 1;
            %session
            L_err = trial_type_hold==1 & trial_accuracy_hold==2;
            %Ls = sum(L_err)
            R_err = trial_type_hold==2 & trial_accuracy_hold==2;
            %Rs = sum(R_err)
            
            %pct_corr_idxbounds = [1 78; 79 142; 143 223; 224 313];
            %pct_corr_pctbounds = [0.8400 0.9000; 0.9167 0.9388; 0.9400 0.9592; 0.9600 1.0000];
            pct_corr_pctbounds = [0.8400 0.8800; 0.881 0.92; 0.921 0.96; 0.961 1.0000];
            %pct_corr_pctbounds = [0.8400 0.9000; 0.901 0.95; 0.951 1.0000];
            %pct_corr_pctbounds = [0.8400 0.8900; 0.891 0.9200; 0.9210 0.9500; 0.9510 1.0000];
            pct_corr_pctbounds = pct_corr_pctbounds(rng_,:);
            
            %if 0
            if learn_prog < pct_corr_pctbounds(1) || learn_prog > pct_corr_pctbounds(2)
            %if sum(L_err) < 2 || sum(R_err) < 2 %|| sum(R_err) ~= 0
            %if sum(trial_type_hold==1 & trial_accuracy_hold==2) ~= 1
                %clear hold variable
                stem_mean_rates_hold = [];
                rwd_mean_rates_hold = [];
                trial_type_hold = [];
                trial_accuracy_hold = [];
                continue
            end
            
            %display('keep')
            
            %conform trial number to minimum correct L
            L_cor_idx = trial_type_hold==1 & trial_accuracy_hold==1;
            if ~isempty(stem_mean_rates_L)
                if sum(L_cor_idx) > size(stem_mean_rates_L,2)
                    L_cor_idx(find(L_cor_idx, sum(L_cor_idx)-size(stem_mean_rates_L,2), 'first')) = 0;                    
                elseif sum(L_cor_idx) < size(stem_mean_rates_L,2)
                    stem_mean_rates_L = stem_mean_rates_L(:,1:sum(L_cor_idx));
                    rwd_mean_rates_L = rwd_mean_rates_L(:,1:sum(L_cor_idx));
                end
                
            end
            
            %conform trial number to minimum correct R
            R_cor_idx = trial_type_hold==2 & trial_accuracy_hold==1;
            if ~isempty(stem_mean_rates_R)
                if sum(R_cor_idx) > size(stem_mean_rates_R,2)
                    R_cor_idx(find(R_cor_idx, sum(R_cor_idx)-size(stem_mean_rates_R,2), 'first')) = 0;                    
                elseif sum(R_cor_idx) < size(stem_mean_rates_R,2)
                    stem_mean_rates_R = stem_mean_rates_R(:,1:sum(R_cor_idx));
                    rwd_mean_rates_R = rwd_mean_rates_R(:,1:sum(R_cor_idx));
                end
            end
            
            %{
            %conform trial number to minimum error L
            L_err_idx = trial_type_hold==1 & trial_accuracy_hold==2;
            if ~isempty(stem_mean_rates_L_err)
                if sum(L_err_idx) > size(stem_mean_rates_L_err,2)
                    L_err_idx(find(L_err_idx, sum(L_err_idx)-size(stem_mean_rates_L_err,2), 'first')) = 0;                    
                elseif sum(L_err_idx) < size(stem_mean_rates_L_err,2)
                    stem_mean_rates_L_err = stem_mean_rates_L_err(:,1:sum(L_err_idx));
                    rwd_mean_rates_L_err = rwd_mean_rates_L_err(:,1:sum(L_err_idx));
                end
                
            end
            
            %conform trial number to minimum error R
            R_err_idx = trial_type_hold==2 & trial_accuracy_hold==2;
            if ~isempty(stem_mean_rates_R_err)
                if sum(R_err_idx) > size(stem_mean_rates_R_err,2)
                    R_err_idx(find(R_err_idx, sum(R_err_idx)-size(stem_mean_rates_R_err,2), 'first')) = 0;                    
                elseif sum(R_err_idx) < size(stem_mean_rates_R_err,2)
                    stem_mean_rates_R_err = stem_mean_rates_R_err(:,1:sum(R_err_idx));
                    rwd_mean_rates_R_err = rwd_mean_rates_R_err(:,1:sum(R_err_idx));
                end
            end
%}
            
            %load
            stem_mean_rates_L = [stem_mean_rates_L; stem_mean_rates_hold(:, L_cor_idx)];
            stem_mean_rates_R = [stem_mean_rates_R; stem_mean_rates_hold(:, R_cor_idx)];

            %stem_mean_rates_L_err = [stem_mean_rates_L_err; stem_mean_rates_hold(:, L_err_idx)];
            %stem_mean_rates_R_err = [stem_mean_rates_R_err; stem_mean_rates_hold(:, R_err_idx)];
            
            
            rwd_mean_rates_L = [rwd_mean_rates_L; rwd_mean_rates_hold(:, L_cor_idx)];
            rwd_mean_rates_R = [rwd_mean_rates_R; rwd_mean_rates_hold(:, R_cor_idx)];
            %rwd_mean_rates_L_err = [rwd_mean_rates_L_err; rwd_mean_rates_hold(:, L_err_idx)];
            %rwd_mean_rates_R_err = [rwd_mean_rates_R_err; rwd_mean_rates_hold(:, R_err_idx)];
            

            if ~isempty(stem_mean_rates_hold(:, trial_type_hold==1))
                learning_progress = [learning_progress; repmat(learn_prog, size(stem_mean_rates_hold(:, trial_type_hold==1), 1), 1)];
            end
            
            %clear hold variable
            stem_mean_rates_hold = [];
            rwd_mean_rates_hold = [];
            trial_type_hold = [];
            trial_accuracy_hold = [];

        end
    end
end

[percent_correct, Lidx] = sort(learning_progress);


%size(stem_mean_rates_L)
%size(stem_mean_rates_R)

%prepare output
stem_mean_rates_L = stem_mean_rates_L(Lidx, 1:17); %trls begin of sesh
stem_mean_rates_R = stem_mean_rates_R(Lidx, 1:17); %trls begin of sesh
%stem_mean_rates_L = stem_mean_rates_L(Lidx, end-16:end); %trls end of sesh
%stem_mean_rates_R = stem_mean_rates_R(Lidx, end-16:end); %trls end of sesh

rwd_mean_rates_L = rwd_mean_rates_L(Lidx, 1:17); %trls begin of sesh
rwd_mean_rates_R = rwd_mean_rates_R(Lidx, 1:17); %trls begin of sesh
%rwd_mean_rates_L = rwd_mean_rates_L(Lidx, 1:13); %trls end of sesh
%rwd_mean_rates_R = rwd_mean_rates_R(Lidx, 1:13); %trls end of sesh
%[rwd_mean_rates_L = rwd_mean_rates_L(Lidx, end-12:end); %trls end of sesh
rwd_mean_rates = [rwd_mean_rates_L rwd_mean_rates_R]';

stem_mean_rates = [stem_mean_rates_L stem_mean_rates_R stem_mean_rates_L_err stem_mean_rates_R_err]';
IDs = [ones(size(stem_mean_rates_L, 2), 1); repmat(2, size(stem_mean_rates_R, 2), 1); repmat(3, size(stem_mean_rates_L_err, 2), 1); repmat(4, size(stem_mean_rates_R_err, 2), 1)];


end


function [rate] = ratewdw(eptrials, low, high, clusts)
%calculates rates for each cell in clusts during the time window from low
%to high

    rate = histc(eptrials(eptrials(:,1)>=low & eptrials(:,1)<=high, 4), clusts);
    rate = rate./repmat(high-low, size(rate));

end
