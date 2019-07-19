function subj_cell = ALL_learning_curves
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])}

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

%preallocate
subj_cell = cell(12,4);
subj_count = 0;


%iterate through subjects
for subject = 1:length_subjects
    subj_count = subj_count+1;

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
    
    day_count = 0;
    crit_day = nan;
    pct_correct = [];
    num_cells = [];
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = [2 4]%1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
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
            end
            
           
            day = session
            
            try
                %load session
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));

                %cluster index specifications
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                    if stage==4 && session==1
                        crit_day = day_count;
                    end
                
                    day_count = day_count+1;
                    pct_correct = [pct_correct; length(unique(eptrials(eptrials(:,8)==1,5)))/length(unique(eptrials(ismember(eptrials(:,8), [1 2]),5)))];
                    num_cells = [num_cells; length(clusts)];
                
            catch
                
                display('no file')
            end
        end
    end
    
    subj_cell{subj_count, 1} = day_count;
    subj_cell{subj_count, 2} = crit_day;
    subj_cell{subj_count, 3} = pct_correct;
    subj_cell{subj_count, 4} = num_cells;
    
    
    %plot learning curves
    %{
    figure; hold on
    plot((1:day_count), pct_correct, 'k-')
    plot((1:day_count), pct_correct, 'ko')
    ylim([.45 1.05])
    xlim([.1 day_count+.9])
    plot([crit_day crit_day], ylim, 'r-')
    plot(xlim, [.5 .5], 'k--')
    set(gca,'TickLength',[0, 0]);
    %}
    
    figure; bar([subj_cell{subj_count,4}])
    ylim([0 15.5])
    xlim([.5 15.5])
    set(gca,'TickLength',[0, 0]); box off
    yticks(0:15)
        
    
    
    
    var_name = ['CellCount ' num2str(subj_count) ' ' num2str(rat)];
    title(var_name)
    %print(['C:\Users\ampm1\Desktop\Maze_Revisions\learning_curves\' var_name], '-dpdf', '-painters', '-bestfit')
    
end



% plot overall learning curve
fml_code = [2.1 2.2 2.3];
pct_cor_cell = cell(1,4);
stage_cell = cell(1,4);
subj_cell_model = cell(1,4);
for isubj = 1:size(subj_cell,1)
    for fml_ct = 1:4
        if ismember(fml_ct,1:3)
            if isnan(subj_cell{isubj,2})
                if fml_ct==1
                    pc_days = 1;
                else
                    continue
                end
            else
                isubj
                fml_ct
                subj_cell{isubj,2}
                fml_code(fml_ct)
                pc_days = first_mid_last(subj_cell{isubj,2},fml_code(fml_ct),0);
            end
        else
            if isnan(subj_cell{isubj,2}) 
                continue
            end
            pc_days = subj_cell{isubj,2}+1 : subj_cell{isubj,1};
        end
        pct_cor_cell{fml_ct} = [pct_cor_cell{fml_ct}; nanmean(subj_cell{isubj,3}(pc_days))];
        stage_cell{fml_ct} = [stage_cell{fml_ct}; fml_ct];
        subj_cell_model{fml_ct} = [subj_cell_model{fml_ct}; isubj];
    end
end

figure; errorbar_plot(pct_cor_cell)

%   dv      stage_num         subj_id
data_mtx = [cell2mat(pct_cor_cell(:)) cell2mat(stage_cell(:)) cell2mat(subj_cell_model(:))]; 
tbl = table(cell2mat(pct_cor_cell(:)), cell2mat(stage_cell(:)), cell2mat(subj_cell_model(:)), 'VariableNames',{'pct_correct','training_stage','subject_id'});
lme = fitlme(tbl,'pct_correct~training_stage+(training_stage|subject_id)+(1|subject_id)')



