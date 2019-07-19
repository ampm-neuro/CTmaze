function [corrmtx_oppose, corrmtx_redund, combined_output_L, combined_output_R, combined_output_LR] = corr_matrix_wndw(training_stage, bins, winback, winforw, event, varargin)
%build a correllation matrix comparing firing over window to itself

if nargin ==2
    split = varargin{1};
end

combined_output_L = [];
combined_output_R = [];
combined_output_LR = [];
means_and_stds = [];

%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);

%iterate through subjects
for subject = 1:length_subjects

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
    for stage = floor(training_stage)
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
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
        if training_stage == 2
            
            sesh_rng = 1:length(sesh_list);
            
        elseif training_stage == 2.1
            
            sesh_rng = 1:round(length(sesh_list)/2);
            
        elseif training_stage == 2.2
            
            sesh_rng = (round(length(sesh_list)/2)+1):length(sesh_list);
            
        else
            sesh_rng = 1:length(sesh_list);
        end
        
        for session = sesh_rng
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session
            
            if exist(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'), 'file')
                %load session
                load(strcat('/Users/ampm/Documents/MATLAB/neurodata/',num2str(rat),'/' ,num2str(task),'/' ,num2str(session), '.mat'));
            else
                display('no file')
                continue
            end
            
            %only stable cells
            clusters = clusters(clusters(:,4)==1, :);
            
            if isempty(clusters)
                continue
            end
            
            if training_stage == 1
                eptrials(isnan(eptrials(:,5)),:) = [];
            end
            
            for cluster = 1:size(clusters(:,1))
                %rate
                [~, ~, ~, left_back, left_forward, right_back, right_forward] = ratewindow(eptrials, clusters(cluster,1), bins, winback, winforw, event);
                
                %poisson distribution means and stds over entire session
                [rate_mean, poisson_std] = rate_hist_window(eptrials, clusters(cluster,1), winback+winforw/bins);
                
                %load variables
                combined_output_L = [combined_output_L [left_back; left_forward]];
                combined_output_R = [combined_output_R [right_back; right_forward]];
                combined_output_LR = [combined_output_LR [mean([left_back right_back],2); mean([left_forward right_forward],2)]];
                means_and_stds = [means_and_stds [rate_mean; poisson_std]];
                


            end
            
        end
    end
end
    %
    corrmtx_oppose = nan(bins);
    corrmtx_redund = nan(bins);
    
    %normalize based on rate data in time window
    %{ 
    combined_output_LR = combined_output_LR-repmat(nanmean(combined_output_LR), size(combined_output_LR,1), 1); %remove means
    %combined_output_LR = combined_output_LR./repmat(nanstd(combined_output_LR), size(combined_output_LR,1), 1); %remove stdevs
    combined_output_LR = combined_output_LR./repmat(sqrt(nanmean(combined_output_LR)), size(combined_output_LR,1), 1); %remove poisson stdevs
    
    %combined_output_L = combined_output_L-repmat(nanmean([combined_output_L; combined_output_R]), size(combined_output_L,1), 1); %remove means
    %combined_output_R = combined_output_R-repmat(nanmean([combined_output_L; combined_output_R]), size(combined_output_R,1), 1); %remove means
    %combined_output_L = combined_output_L./repmat(nanstd([combined_output_L; combined_output_R]), size(combined_output_L,1), 1); %remove stdevs
    %combined_output_R = combined_output_R./repmat(nanstd([combined_output_L; combined_output_R]), size(combined_output_R,1), 1); %remove stdevs
    
    %combined_output_L = combined_output_L-repmat(nanmean(combined_output_L), size(combined_output_L,1), 1); %remove means
    %combined_output_R = combined_output_R-repmat(nanmean(combined_output_R), size(combined_output_R,1), 1); %remove means
    %combined_output_L = combined_output_L./repmat(nanstd(combined_output_L), size(combined_output_L,1), 1); %remove stdevs
    %combined_output_R = combined_output_R./repmat(nanstd(combined_output_R), size(combined_output_R,1), 1); %remove stdevs
    
    %if all rates are the same for a particular cell, then removing means
    %will drop to 0 and dividing by std will give NaN. This puts back to 0.
    combined_output_LR(isnan(combined_output_LR))=0;
    combined_output_L(isnan(combined_output_L))=0;
    combined_output_R(isnan(combined_output_R))=0;
    %}
    
    %normalize based on rate data over entire session and a poisson std
    %
    combined_output_L = combined_output_L - repmat(means_and_stds(1,:), size(combined_output_L,1), 1); %subtract by means
    combined_output_L = combined_output_L./repmat(means_and_stds(2,:), size(combined_output_L,1), 1); %divide by stds
    combined_output_R = combined_output_R - repmat(means_and_stds(1,:), size(combined_output_R,1), 1); %subtract by means
    combined_output_R = combined_output_R./repmat(means_and_stds(2,:), size(combined_output_R,1), 1); %divide by stds
    combined_output_LR = combined_output_LR - repmat(means_and_stds(1,:), size(combined_output_LR,1), 1); %subtract by means
    combined_output_LR = combined_output_LR./repmat(means_and_stds(2,:), size(combined_output_LR,1), 1); %divide by stds
    %}

    
    %perform correllations
    for row = 1:bins
        for col = 1:bins
            
            corrmtx_oppose(row, col) = corr(combined_output_L(row,:)', combined_output_R(col,:)');
            corrmtx_redund(row, col) = corr(combined_output_LR(row,:)', combined_output_LR(col,:)');
            
        end
    end
        
    
    %plot weighted_dist_comb
    %figure; imagesc(corrmtx_oppose); title('oppose'); colormap jet; colorbar; set(gca,'TickLength',[0, 0]); caxis([-1 1])
    %figure; imagesc(corrmtx_redund); title('redundant'); colormap jet; colorbar; set(gca,'TickLength',[0, 0]); caxis([-1 1])
    %}
    
    
    
end