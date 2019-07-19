function [all_time_windows, num_of_errors] = ALL_spikects_delay(window_duration, min_error_trials)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

all_left_correct = [];
all_right_correct = [];
all_left_error = [];
all_right_error = [];

num_of_errors = [];

%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');
file_list_subjects(1:2) = [];
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};
length_subjects = size(file_names_subjects{:},1);

%iterate through subjects
for subject = 1:length_subjects
    rat = file_names_subjects{:}(subject,1).name;
    file_list_stages = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name)));
    file_list_stages(1:2) = [];
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    %length_stages = size(file_names_stages{:},1);
    
    %DELAY ONLY
    for stage = 3
        task = file_names_stages{:}(stage,1).name;
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        file_list_sessions(1:2) = [];
    
        %session folders
        if size(file_list_sessions,1) == 0
            continue
        elseif size(file_list_sessions,1) == 1
            sesh_list = {file_list_sessions.name};
        else
            sesh_list = vertcat({file_list_sessions.name});
        end
       
        for session = 1:length(sesh_list)+1
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session;
            
            %learn_prog = day/length(sesh_list);
            
            %load session
            eptrials = [];
            try
            strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
            load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            catch
                %strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
                continue
            end

            %SHUFFLES
            % lefts and rights of correct trials
            %
            
            trial_type_corrects = eptrials(eptrials(:,8)==1,[5 7]);
            trl_nums = unique(trial_type_corrects(:,1));
            tt_order = nan(length(trl_nums),1);
            for itt = 1:length(trl_nums')
                tt_order(itt) = mode(trial_type_corrects(trial_type_corrects(:,1)==trl_nums(itt), 2));
            end
            tt_order = tt_order(randperm(length(tt_order)));
            for itt2 = 1:length(trl_nums')
                eptrials(eptrials(:,5)==trl_nums(itt2),7) = tt_order(itt2);
            end
            
            
            
            %figure; plot(eptrials(:,8)); title preshuferrors
            
            %errors
            %{
            trial_type_corrects = eptrials(eptrials(:,8)>0,[5 8]);
            trl_nums = unique(trial_type_corrects(:,1));
            tt_order = nan(length(trl_nums),1);
            for itt = 1:length(trl_nums')
                tt_order(itt) = mode(trial_type_corrects(trial_type_corrects(:,1)==trl_nums(itt), 2));
            end
            tt_order = tt_order(randperm(length(tt_order)));
            for itt2 = 1:length(trl_nums')
                eptrials(eptrials(:,5)==trl_nums(itt2),8) = tt_order(itt2);
            end
            %}
            
            %figure; plot(eptrials(:,8)); title postshuferrors
            
            %figure; plot(eptrials(:,7)); title preshuftrials
            
            %{
            trial_type_corrects = eptrials(eptrials(:,8)==1,[5 7]);
            trl_nums = unique(trial_type_corrects(:,1));
            tt_order = nan(length(trl_nums),1);
            for itt = 1:length(trl_nums')
                tt_order(itt) = mode(trial_type_corrects(trial_type_corrects(:,1)==trl_nums(itt), 2));
            end
            tt_order = tt_order(randperm(length(tt_order)));
            for itt2 = 1:length(trl_nums')
                eptrials(eptrials(:,5)==trl_nums(itt2),7) = tt_order(itt2);
            end
            %}
            %figure; plot(eptrials(:,7)); title postshuftrials
            
            
            
            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = 1;
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            clusts = clusters(cluster_idx,1);
            
            %included trials
            all_trials = unique(eptrials(eptrials(:,8)>0,5));
            %all_trials = setdiff(all_trials, trl_nums(1:20));
                        
            %erase previous sessions
            sc_left_cor = [];
            sc_right_cor = [];
            sc_left_err = [];
            sc_right_err = [];
            
            %for all trials
            for trial = all_trials'
                
                %delay time bounds
                end_delay = min(eptrials(eptrials(:,5)==trial & ~isnan(eptrials(:,9)), 1));
                begining_delay = end_delay - 30;

                
                %spike counts and trial lables (L/R, C/E, sliding_window_number)
                [spike_counts] = slide_rate_window(eptrials(eptrials(:,1)>=begining_delay & eptrials(:,1)<=end_delay, :), clusts, window_duration);
                
                if isequal(mode(eptrials(eptrials(:,5)==trial, [7 8])), [1 1]) %left correct
                    sc_left_cor = cat(3, sc_left_cor, spike_counts);
                    
                elseif isequal(mode(eptrials(eptrials(:,5)==trial, [7 8])), [2 1]) %right correct
                    sc_right_cor = cat(3, sc_right_cor, spike_counts);
                    
                elseif isequal(mode(eptrials(eptrials(:,5)==trial, [7 8])), [1 2]) %left error
                    sc_left_err = cat(3, sc_left_err, spike_counts);
                    
                elseif isequal(mode(eptrials(eptrials(:,5)==trial, [7 8])), [2 2]) %right error
                    sc_right_err = cat(3, sc_right_err, spike_counts);
                    
                end
                
            end
            
            %keep track of errors
            noe_trl = sum(size(sc_left_err,3) + size(sc_right_err,3));
            num_of_errors = [num_of_errors; repmat(noe_trl, size(sc_left_cor, 2), 1)];
            
            %deal with sessions where error trial types did not occur
            %{
            num_left_corrects = size(sc_left_cor,3);
            if num_left_corrects < min_error_trials
                sc_left_cor = nan(30/window_duration, length(clusts));
            end   
            num_right_corrects = size(sc_right_cor,3);
            if num_right_corrects < min_error_trials
                sc_right_cor = nan(30/window_duration, length(clusts));
            end  
            num_left_errors = size(sc_left_err,3);
            if num_left_errors < min_error_trials
                sc_left_err = nan(30/window_duration, length(clusts));
            end   
            num_right_errors = size(sc_right_err,3);
            if num_right_errors < min_error_trials
                sc_right_err = nan(30/window_duration, length(clusts));
            end 
            %}
            
            %if shuffling randomly re-sort L and R trials
            %{
            comb_mtx = cat(3, sc_left_cor, sc_right_cor, sc_left_err, sc_right_err);
            comb_mtx_idx = randperm(size(comb_mtx,3));
            sc_left_cor = comb_mtx(:,:,comb_mtx_idx(1:size(sc_left_cor,3)));
            sc_right_cor = comb_mtx(:,:,comb_mtx_idx((size(sc_left_cor,3)+1):(size(sc_left_cor,3)+size(sc_right_cor,3))));
            sc_left_err = comb_mtx(:,:,comb_mtx_idx((size(sc_left_cor,3)+size(sc_right_cor,3)+1):(size(sc_left_cor,3)+size(sc_right_cor,3)+size(sc_left_err,3))));
            sc_right_cor = comb_mtx(:,:,comb_mtx_idx((size(sc_left_cor,3)+size(sc_right_cor,3)+size(sc_left_err,3)+1):end));
            %}
            
            %average by trial type and combine to get session averages
            all_left_correct = [all_left_correct mean(sc_left_cor,3)];
            all_right_correct = [all_right_correct mean(sc_right_cor,3)];
            all_left_error = [all_left_error mean(sc_left_err,3)];
            all_right_error = [all_right_error mean(sc_right_err,3)];
            
        end
    end
end

    %remove sessions with too few errors
    %{
    antinan_idx = ~isnan(all_left_error(1,:)) & ~isnan(all_right_error(1,:));
    %antinan_idx = ~antinan_idx; %only keep cells from sessions with too few errors
    all_left_correct = all_left_correct(:,antinan_idx);
    all_right_correct = all_right_correct(:,antinan_idx);
    all_left_error = all_left_error(:,antinan_idx);
    all_right_error = all_right_error(:,antinan_idx);
    %}
    
    %combine for output

    
    %all_time_windows = cat(3, all_left_correct, all_right_correct, all_left_error, all_right_error);
    %}
    all_time_windows = cat(3, all_left_correct, all_right_correct);
    
end