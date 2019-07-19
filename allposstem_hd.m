function [all_trial_HDs, all_stem_diff_hd, all_F_scores, all_LR_trials, all_pop_day_idx, all_veloc, all_stem_diff_pos, all_pct_correct] = allposstem_hd
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

all_trial_HDs = [];
all_stem_diff_hd = [];
all_stem_diff_pos = [];
all_veloc = [];
all_F_scores = [];
all_LR_trials = [];
all_pop_day_idx = [];
all_pct_correct = [];
pop_day_count = 0;


sesh_count = 0;

%get all the things in neurodata folder...
file_list_subjects = dir('C:\Users\ampm1\Desktop\oldmatlab\neurodata\');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);

%names
%file_names_subjects{:}(1:length_subjects,1).name;

%iterate through subjects
for subject = 1:length_subjects

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
    
    %iterate through stages
    for stage = 4
        
        %print update
        task = file_names_stages{:}(stage,1).name

        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %exclude non-folders
        %file_names_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
                
        %number of folders
        length_sessions = size(file_list_sessions,1);
    
        %iterate through sessions
        for session = 1:length_sessions+1

            %in ot
            if stage == 4
            %cancel last two (dropped) 1860 sessions
                if subject==11 && session>length_sessions-2
                   continue
                end
                %no HD session
                if subject==10 && session==3
                   continue
                end
            end
            
            try
            %load session
            load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
            
            %INSERT FUNCTION HERE
            [trial_HDs, mean_stem_diff_hd, F_scores, LR_trials, percent_correct] = posstem_hd(eptrials, stem_runs, clusters);
            [~, mean_stem_diff_pos, vel_trls, ~] = posstem(eptrials, stem_runs);
            
            %%combining across rats
            all_trial_HDs = [all_trial_HDs; trial_HDs];
            all_stem_diff_hd = [all_stem_diff_hd; mean_stem_diff_hd];
            all_stem_diff_pos = [all_stem_diff_pos; mean_stem_diff_pos];
            all_veloc = [all_veloc; vel_trls];
            all_F_scores = [all_F_scores; F_scores];
            all_LR_trials = [all_LR_trials; LR_trials];
            all_pct_correct = [all_pct_correct; percent_correct];

            catch
                display('no file')
            end
            
            
            
            
            if sum(clusters(:,2)>2)>=8
                pop_day_count = pop_day_count+1;
                all_pop_day_idx(pop_day_count) = mode(mean_stem_diff_hd);
            end
            
        end
    end
end


%complicated histogram plot
a = all_trial_HDs; a(a<180) = a(a<180)+360;
for section=1:4
    figure; hold on; 
    set(gca,'TickLength',[0, 0]); 
    title(['HD section ' num2str(section)]);
    axis([260 460 0 320])
    
    histogram(a(all_LR_trials==1,section), 260:4:360+100); 
    histogram(a(all_LR_trials==2,section), 260:4:360+100);
    
    plot([nanmean(a(all_LR_trials==1,section)) nanmean(a(all_LR_trials==1,section))], ylim, 'k-'); 
    plot([nanmean(a(all_LR_trials==2,section)) nanmean(a(all_LR_trials==2,section))], ylim, 'k-'); 
    
    xticks(260:20:460); xticklabels([260:20:360 20:20:100])
end




end