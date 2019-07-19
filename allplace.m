function [weighted_dist_comb, proportion_w_fields, fields_comb, visit_proportions, fields_all, folded_section_area, meta_mtx_all, information_scores, field_sizes, rate_ratios, reliability_scores] = allplace(learning_stages)
% find total number of place fields and the total number of place fields
% located in each of the maze sectors
%
%
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

information_scores = [];
field_sizes = [];
rate_ratios = [];
reliability_scores = [];

figure; hold on

%title(['Cell ',num2str(cluster)],'fontsize', 16)
comx = 1000;
comy = 1000;


%preallocate
fields_one = [];
fields_two = [];
fields_three = [];
fields_four = [];
fields_five = [];
fields_six = [];
fields_seven = [];
folded_section_area = [];

meta_mtx_all = [];


subject_combined_place = [];
subject_combined_field_loc = [];

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
    
    %iterate through stages
    for stage = floor(learning_stages)
        
        %print update
        task = file_names_stages{:}(stage,1).name;
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];

        %number of folders
        length_sessions = size(file_list_sessions,1);
        
        %trials corresponding to learning stage
        if ceil(learning_stages) == 3
            sesh_rng = first_mid_last(length_sessions, learning_stages, 0);
            min_visits = 2;
        else
            sesh_rng = 1:length_sessions+1;
            %sesh_rng = 1:length_sessions;
            min_visits = 2;
        end
        
        for session = sesh_rng
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session;
            
            if exist(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'), 'file')
                %load session
                strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat')
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            else
                display('no file')
                continue
            end
            %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusters = clusters(cluster_idx,1);
            
            if isempty(clusters)
                continue
            end
            
            %if training_stage == 1
            %    eptrials(isnan(eptrials(:,5)),:) = [];
            %end
            
            %INSERT FUNCTION HERE
            [dms_place, field_loc_matrix, fsa, meta_mtx_batch, field_sizes, rate_ratios, reliability_scores] = spatialfield_batch(eptrials, clusters, min_visits, field_sizes, rate_ratios, reliability_scores);
            
            inf_scores_hold = info_score(eptrials, 25, min_visits, stage);
            information_scores = [information_scores;inf_scores_hold(logical(dms_place))']; %placecells only
            %information_scores = [information_scores; inf_scores_hold']; %all cells

            
            %combining the outputs
            subject_combined_place = [subject_combined_place; dms_place];
            subject_combined_field_loc = [subject_combined_field_loc; field_loc_matrix];
            folded_section_area = [folded_section_area; fsa'];
            meta_mtx_all = cat(3,meta_mtx_all,meta_mtx_batch);
        end
    end
    %reporting the combined outputs, and then resetting
    %subject_combined_place = [];
    
    if isempty(subject_combined_field_loc)
        continue
    end
    
        fields_one = [fields_one; subject_combined_field_loc(:,1)];
        fields_two = [fields_two; subject_combined_field_loc(:,2)];
        fields_three = [fields_three; subject_combined_field_loc(:,3)];
        fields_four = [fields_four; subject_combined_field_loc(:,4)];
        fields_five = [fields_five; subject_combined_field_loc(:,5)];
        fields_six = [fields_six; subject_combined_field_loc(:,6)];
        fields_seven = [fields_seven; subject_combined_field_loc(:,7)];

    subject_combined_field_loc = [];
    
end

axis([800 1200 800 1200])

    %one variable for all fields
    fields_all = [fields_one fields_two fields_three fields_four fields_five fields_six fields_seven];
    
    %combine stems and approaches (this leaves start stem choice approach and return) 
    fields_comb = [fields_all(:,1) sum(fields_all(:,2:3),2) sum(fields_all(:,4:6),2) fields_all(:,7)];
    
    %what proportion of the cells had place fields?
    proportion_w_fields = sum(subject_combined_place)/length(subject_combined_place);
    length(subject_combined_place)
    %sum(fields_comb, 2); proportion_w_fields = sum(proportion_w_fields>0)/length(proportion_w_fields);
    
    
    
    %combine visit distribution
    folded_section_area_comb = [folded_section_area(:,1) sum(folded_section_area(:,2:3),2) sum(folded_section_area(:,4:6),2) folded_section_area(:,7)];
    
    %calculate visit proportions
    visit_proportions = mean(folded_section_area_comb)./sum(mean(folded_section_area_comb))
    
    
    %equal distribution chi square test
    observed = sum(fields_comb)
    expected = sum(fields_comb(:)).*visit_proportions
    
    chisqr(observed, expected)
    
    
    %weighted place cell distribution
    weighted_dist_comb = (sum(fields_comb)./visit_proportions)./sum((sum(fields_comb)./visit_proportions))./(1/length(visit_proportions));
    
    %plot weighted_dist_comb
    figure; bar(weighted_dist_comb);
    box off
    ylim([0 2.5])
    xlim([.5 4.5])
    hold on
    plot([.5 5.5], [1 1], 'k--')
    
    
    
end