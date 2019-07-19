function [all_aysm_scores, all_zscore_sections] = allposstem
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

grn=[52 153 70]./255;
blu=[46 49 146]./255;

subject_combined_l_means = [];
subject_combined_r_means = [];
all_l_means = [];
all_r_means = [];

%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);

%names
%file_names_subjects{:}(1:length_subjects,1).name;

%iterate through subjects
for subject = 1:1

    %print update
    rat = file_names_subjects{:}(subject,1).name
    
    %get all the things in subject folder...
    file_list_stages = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name)));

    %hard coded erasure of irrelevant directory folders
    file_list_stages(1:2) = [];

    %exclude non-folders
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    length_stages = size(file_names_stages{:},1);
    
    %iterate through stages
    for stage = 1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
        
        %%%FIGURE%%%
        %figure
        %hold on
        %title([num2str(rat), ', ',num2str(task)],'fontsize', 16)
        
        
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %exclude non-folders
        %file_names_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
                
        %number of folders
        length_sessions = size(file_list_sessions,1);
    
        %iterate through sessions
        for session = 1:length_sessions
            
            %day = file_list_sessions{:}(sessions,1).name
            %day = session
            
            %load session
            load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            
            %INSERT FUNCTION HERE
            %[l_means, r_means] = posstem(eptrials);
            [trialxpos, mean_stem_diff] = posstem_hd(eptrials, stem_runs);
            %combining the within-rat outputs
            subject_combined_l_means = [subject_combined_l_means; l_means];
            subject_combined_r_means = [subject_combined_r_means; r_means];
            
            
            
            
        end
    end
    %combining across rats
    all_l_means = [all_l_means; subject_combined_l_means];
    all_r_means = [all_r_means; subject_combined_r_means];
    
    
    subject_combined_r_means = [];
    subject_combined_l_means = [];
    
end

leftmeans = nanmean(all_l_means);
rightmeans = nanmean(all_r_means);
leftstds = nanstd(all_l_means);
rightstds = nanstd(all_r_means);
leftlens = sum(~isnan(all_l_means));
rightlens = sum(~isnan(all_r_means));

figure

h1=errorbar(1:8, leftmeans, leftstds./sqrt(leftlens), 'Color', grn, 'linewidth', 2.0);
hold on
h2=errorbar(1:8, rightmeans, rightstds./sqrt(rightlens), 'Color', blu, 'linewidth', 2.0);
hold off

box 'off'

axis([0.5, 8.5, 0, 100])
view(-90,90) 
%daspect([1 10 1])
axis 'auto y'
set(gca, 'XTickLabel',{'Start1','Start2', 'LowStem1', 'LowStem2', 'HighStem1', 'HighStem2', 'Choice1', 'Choice2'}, 'fontsize', 12)
ylabel('X position', 'fontsize', 20)
xlabel('Stem Section', 'fontsize', 20)
legend([h1, h2],'Left Trials', 'Right Trials', 'location', 'northeastoutside')
    
end