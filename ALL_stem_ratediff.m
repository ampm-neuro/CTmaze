function [out, subject_ids, subj_centraltendency]  = ALL_stem_ratediff(learning_stages)
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.


%count = [];
tscores = [];
zscores = [];
sesh_count = 0;
subject_ids = [];
subj_centraltendency = [];

num_incl_trials = 10;

%names%get all the things in neurodata folder...
file_list_subjects = dir('C:\Users\ampm1\Desktop\oldmatlab\neurodata\');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

counts = zeros(1, length_subjects);

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
    for stage = floor(learning_stages)
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        
        %%%FIGURE%%%
        %figure
        %hold on
        %title([num2str(rat), ', ',num2str(task)],'fontsize', 16)
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %exclude non-folders
        %file_list_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
           
        %number of folders
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
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session;
            
            try
                %load session
                %strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat')
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
                
                
                
                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                
            catch
                continue
            end
            
            spike_index = isfinite(eptrials(:,4));
            vid_sample_index = eptrials(:,14)==1;

            %INSERT FUNCTION HERE
            if length(clusts)>=1%screens empty cluster files to avoid errors
                
                sesh_count = sesh_count+1;
                
                left_rates = [];
                right_rates = [];
                rates = [];
                
                for it = 2:size(stem_runs,1)
                    

                    %end when have 15 of each trial type
                    if min([size(left_rates, 1) size(right_rates, 1)]) == 14
                        [size(left_rates, 1) size(right_rates, 1)];
                        
                        break
                    %skip errors
                    elseif mode(eptrials(eptrials(:,5)==it, 8)) == 2
                        continue
                    %skip slow runs
                    elseif stem_runs(it,3) > 2
                        continue
                    end
                    
                    %stem firing rates this trial
                    %rates = histc(eptrials(spike_index & eptrials(:,1)>=stem_runs(it,1) & eptrials(:,1)<=stem_runs(it,2), 4), unique(eptrials(~isnan(eptrials(:,4)),4)))';
                    rates = histc(eptrials(spike_index & eptrials(:,1)>=stem_runs(it,1) & eptrials(:,1)<=stem_runs(it,2), 4), clusts)';
                    rates = rates./stem_runs(it,3);
                    
                    %load rates by trial types
                    if mode(eptrials(eptrials(:,5)==it, 7)) == 1
                        left_rates = [left_rates; rates];
                    elseif mode(eptrials(eptrials(:,5)==it, 7)) == 2
                        right_rates = [right_rates; rates];
                    end

                end

                
                
                try
                
                    left_rates = left_rates(1:num_incl_trials,:);
                    right_rates = right_rates(1:num_incl_trials,:);
                
                catch
                    continue
                end

                %accomodate number of cells
                scell_tscores = nan(size(left_rates,2),1);
                for ir = 1:size(left_rates,2)
                    
                    
                    [~, ~, ~, STATS] = ttest(left_rates(:,ir), right_rates(:,ir));
                    scell_tscores(ir) = STATS.tstat;
                end
                
                
                mean_diff = mean(left_rates) - mean(right_rates);
                pooled_var = mean([std(left_rates); std(right_rates)]);

                scell_zscores = (mean_diff./pooled_var)';

                scell_zscores(mean_diff==0) = 0;

                
                %load output
                tscores = [tscores; scell_tscores];
                zscores = [zscores; scell_zscores];
                subject_ids = [subject_ids; repmat(subject, size(scell_zscores))];
                
                
            end
            
        end
    end
    
    
end
out = zscores;

% central tendency by subject
for isubj = 1:12
    if sum(subject_ids==isubj)>=5
        subj_centraltendency = [subj_centraltendency; mean(abs(out(subject_ids==isubj)))]; 
    else
        subj_centraltendency = [subj_centraltendency; nan];
    end
end



%out = abs(scores);
figure; histogram(out, -10:.5:10, 'Normalization', 'Probability'); set(gca,'TickLength',[0, 0]); box off
end
