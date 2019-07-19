function [time_class, prop_pages, pp_idx, class_all_comb, time_class_sesh_shuf, prop_pages_shuf, class_shuf_comb, p_sections, accuracy, posterior_all_cell, sessions_cell, sesh_vel_pos_comb, time_class_sesh, trial_type_idx_comb, group_ID_comb, p_sections_nnorm, p_sections_area] = rev_ALL_decode_accuracy_ShufCellID(learning_stages, bins, window, slide, page_overlap, vect2mat_idx, shuffs)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.


 counter = 0;

%reminder displays
if floor(learning_stages) == 1
    display('acclimation sessions')
elseif floor(learning_stages) == 2
    if learning_stages == 2
        display('learning sessions (all)')
    elseif learning_stages == 2.1
        display('learning sessions: first')    
    elseif learning_stages == 2.2
        display('learning sessions: mid')    
    elseif learning_stages == 2.3
        display('learning sessions: last (crit)')    
    end
elseif floor(learning_stages) == 3
    display('delay sessions')
elseif floor(learning_stages) == 4
    display('overtraining sessions')
end

radius = bins*.075; %less than
radius = 7;

count = 0;

prop_pages = [];
pp_idx = [];
class_all_comb = [];
class_shuf_comb = [];
group_ID_comb = [];
%trial_type_idx_comb = [];
class_success = [];
sesh_vel_pos_comb = [];

if shuffs == 0
    decode_accuracy_comb_dists_shuf = [];
    constrained_pre_mean_shuf = []; 
    prop_pages_shuf = [];
    class_shuf_comb = [];
end


%names %get all the things in neurodata folder...
file_list_subjects = dir('neurodata\');
file_list_subjects(1:2) = [];
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};
length_subjects = size(file_names_subjects{:},1);

%iterate through subjects
for subject = [4 5 7 11 12]

    rat = file_names_subjects{:}(subject,1).name;
    file_list_stages = dir(strcat('neurodata\', num2str(file_names_subjects{:}(subject,1).name)));
    file_list_stages(1:2) = [];
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = floor(learning_stages)

        task = file_names_stages{:}(stage,1).name;
        file_list_sessions = dir(strcat('neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        file_list_sessions(1:2) = [];
        length_sessions = size(file_list_sessions,1);
        
        %trials corresponding to learning stage
        if floor(learning_stages) == 2
            sesh_rng = first_mid_last(length_sessions, learning_stages, 0);
        else
            sesh_rng = 1:length_sessions+1;
        end
            
        %iterate through sessions
        for session = sesh_rng
            
            if isnan(session)
                continue
            end
            
            counter = counter + 1;
            
            if ~ismember(counter, [3, 10, 11, 17:21, 24, 28:32, 34])
                continue
            end
            
            try
                
                %load session
                stem_runs = [];
                string_load = strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat')
                load(string_load)
                velocity_column = vid_velocity(eptrials);
                [~, reward_times] = rewards(eptrials); reward_times = [reward_times reward_times+1 (reward_times+1)-reward_times];
                
            catch
                disp('no file')
                continue
            end    
                
            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = [1];
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            clusts = clusters(cluster_idx,1);

            if length(clusters(:,1))>=8

                %
                all_trials = unique(eptrials(eptrials(:,8)==1, 5));
                %accepted_stem_runs = all_trials(stem_runs(ismember(unique(eptrials(:, 5)), all_trials),3)<1.25);
                %{
                left_errors = unique(eptrials(eptrials(:,8)==2 & eptrials(:,7)==1, 5));
                right_errors = unique(eptrials(eptrials(:,8)==2 & eptrials(:,7)==2, 5));

                errors = [length(intersect(accepted_stem_runs,left_errors)) length(intersect(accepted_stem_runs,right_errors))]

                if errors(1)<1 || errors(2)<1
                    continue
                end
                %}
                %classify 
                %stems
                [classification_success, posterior_all, class_all, class_shuf, group_ID, p_sections_norm, trial_type_idx, p_sections_NoNorm, p_sections_numpix] = rev_decodehist_ShufCellID(eptrials, clusts, bins, window, slide, vect2mat_idx, shuffs, stem_runs);
                %all
                %[classification_success, posterior_all, class_all, class_shuf, group_ID, p_sections_norm, trial_type_idx, p_sections_NoNorm, p_sections_numpix] = rev_decodehist_ShufCellID(eptrials, clusts, bins, window, slide, vect2mat_idx, shuffs);
                %rewards
                %[classification_success, posterior_all, class_all, class_shuf, group_ID, p_sections_norm, trial_type_idx, p_sections_NoNorm, p_sections_numpix] = decodehist(eptrials, clusts, bins, window, slide, vect2mat_idx, shuffs, reward_times);
                %

                class_success = [class_success classification_success];


                count = count+1

                proportions = nan(bins^2,1);
                dists_hold = iter_lin_dist([bins,bins], class_all, group_ID);
                for i = unique(group_ID)'
                    proportions(i) = nansum(class_all(group_ID==i,1)==group_ID(group_ID==i))\nansum(group_ID==i);  
                    %proportions(i) = nansum(dists_hold(~isnan(dists_hold) & group_ID==i)<radius)\nansum(group_ID(~isnan(dists_hold))==i); 
                end
                prop_pages(:,:,count) = reshape(proportions, bins, bins);

                class_success_time = sum(dists_hold(~isnan(dists_hold))<radius)\length(dists_hold(~isnan(dists_hold)));
                class_success_space = smoke_fig(prop_pages(:,:,count), 0, 0);

                num_bins = sum(posterior_all(~isnan(posterior_all(:,1)),1));

                pp_idx = [pp_idx; [str2double(rat) stage session num_bins class_success_time class_success_space]];

                class_all_comb = [class_all_comb; [repmat([str2double(rat) stage session], size(class_all,1),1) class_all repmat(count, size(class_all,1),1)]];
                trial_type_idx_comb{count} = trial_type_idx;

                class_shuf_comb = [class_shuf_comb; class_shuf];

                group_ID_comb = [group_ID_comb; group_ID];

                p_sections(:,:,count) = p_sections_norm;
                
                p_sections_nnorm(:,:,count) = p_sections_NoNorm;
                
                p_sections_area(:,:,count) = p_sections_numpix;

                accuracy(count) = length(unique(eptrials(eptrials(:,8)==1,5)))\length(unique(eptrials(eptrials(:,8)>0,5)));

                posterior_all_cell{count} = posterior_all;

                sessions_cell{count} = string_load;


                %velocity and lateral position
                trials = unique(eptrials(eptrials(:,8)>0,5)); trials = trials(stem_runs(2:end,3)<1.25);
                sr_accept = stem_runs(ismember(trials, intersect(trials, unique(eptrials(eptrials(:,8)==1,5)))), :);
                pos_trls = nan(size(sr_accept,1),3);
                for i = 1:size(sr_accept,1)
                    pos_trls(i,1) = mean(eptrials(eptrials(:,1)>sr_accept(i, 1) & eptrials(:,1)<sr_accept(i, 2), 2)); %trial lat pos
                    pos_trls(i,2) = nanmean(velocity_column(eptrials(:,1)>sr_accept(i, 1) & eptrials(:,1)<sr_accept(i, 2))); %trial veloc
                    pos_trls(i,3) = mode(eptrials(eptrials(:,1)>sr_accept(i, 1) & eptrials(:,1)<sr_accept(i, 2), 7)); %trial type
                end
                sesh_vel_pos = nan(1,2);
                sesh_vel_pos(1,1) = 1.2\mean(pos_trls(:,2)); %sesh velocity m\s
                sesh_vel_pos(1,2) = abs(mean(pos_trls(pos_trls(:,3)==1, 1))-mean(pos_trls(pos_trls(:,3)==2, 1)));

                sesh_vel_pos_comb = [sesh_vel_pos_comb; sesh_vel_pos];

                %
                for shuf = 1:shuffs
                    proportions_shuf = nan(bins^2,1);
                    dists_hold = iter_lin_dist([bins,bins], class_shuf(:,shuf), group_ID);
                    for i = unique(group_ID)'
                        %proportions_shuf(i) = nansum(class_shuf(group_ID==i,shuf)==group_ID(group_ID==i))\nansum(group_ID==i); 
                        proportions_shuf(i) = nansum(dists_hold(group_ID==i)<radius)\nansum(group_ID==i);
                    end
                    prop_pages_shuf(:, :, count, shuf) = reshape(proportions_shuf, bins, bins);
                end
                %}

            end
        end
    end
end

    %total decode accuracy
    %decode_accuracy_comb = sum(class_all_comb(:,4)==repmat(group_ID_comb, 1, size(class_all_comb(:,4),2)))\length(class_all_comb(:,4));    
    
    %
    time_class_dists = iter_lin_dist([bins,bins], class_all_comb(:,4), group_ID_comb);
    time_class = sum(time_class_dists<radius)\length(time_class_dists);
    
    time_class_sesh = nan(length(unique(class_all_comb(:,5))), 1);
    for i = unique(class_all_comb(:,5))'
        time_class_sesh(i) = sum(time_class_dists(~isnan(time_class_dists) & class_all_comb(:,5)==i)<radius)\length(time_class_dists(~isnan(time_class_dists) & class_all_comb(:,5)==i));
    end
    time_class = time_class_dists;
    
    %total shuff decode accuracy
    decode_accuracy_comb_shuf = sum(class_shuf_comb==repmat(group_ID_comb, 1, size(class_shuf_comb,2)))\ length(class_shuf_comb);
    time_class_dists_shuf = nan(size(class_shuf_comb,1), shuffs);    
    time_class_sesh_shuf = nan(size(time_class_sesh,1), shuffs);
    
    for shf = 1:shuffs
        time_class_dists_shuf = iter_lin_dist([bins,bins], class_shuf_comb(:,shf), group_ID_comb);
        for i = unique(class_all_comb(:,5))'
            time_class_sesh_shuf(i, shf) = sum(time_class_dists_shuf(~isnan(time_class_dists_shuf) & class_all_comb(:,5)==i)<radius)\length(time_class_dists_shuf(~isnan(time_class_dists_shuf) & class_all_comb(:,5)==i));
        end
    end

   
end
