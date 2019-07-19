function [rate_matrices, fig_eight_matrix, figeight_corr_matx, overall_bins_dwell_times, test_row, hold_cellcount, sorting_vector, sect_bins, pop_sessions] = ALL_ballistic_times(bins, min_visit, learning_stages, redundant, rwd_on, half)
%all_ballistic_trials plots a correllation matrix for an ideal trial. The
%ideal trial is built from ballistic/typical runs along maze sections,
%binned along the length of the rat's trajectory
%
% bins is the number of times an ideal single trial (left or right) is
% split up spatially.
%
%min_visit is the number of ideal trajectories (min is applied independently
%for L and R trials, and both must pass) that the rat must run in a
%recording session or else the data from that section of the maze will not
%be included.
%
%learning stages is 2 (all learning), 2.1 (early half of learning), 2.2
%(late half of learning), and 4 (ot). Delay could be added, but the delay
%period would need to be dealt with differently - perhaps like rwd_on.
%
%redundant is 1 if you want the whole trial to be corrlelated with itself
%(diagonal is necessarily 1s). 0 if you want to compare L v R trials.

%
rate_matrices = [];
rate_matrices_complete = [];
means_and_stds = [];
test_row = [];
sorting_vector = [];
pop_sessions = []; ps_ct = 0; sesh_ct = 0;
hold_cellcount = [];

count = 0;

%reminder displays
if learning_stages == 1
    display('acclimation sessions')
elseif learning_stages == 2
    display('learning sessions')
elseif learning_stages == 2.1
    display('learning sessions 2.1')
elseif learning_stages == 2.2
    display('learning sessions 2.2')
elseif learning_stages == 2.3
    display('learning sessions 2.3')
elseif learning_stages == 3
    display('delay sessions')
elseif learning_stages == 4
    display('overtraining sessions')
end

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata\');

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
    rat = file_names_subjects{:}(subject,1).name
    
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
        %{
        if learning_stages == 2
            
            sesh_rng = 1:length(sesh_list);
            
        elseif learning_stages == 2.1
            
            sesh_rng = 1:round(length(sesh_list)/2);
            
        elseif learning_stages == 2.2
            
            sesh_rng = floor(round((length(sesh_list)/2+1)/2)):ceil(length(sesh_list)*.75);
            
        elseif learning_stages == 2.3
            
            sesh_rng = (round(length(sesh_list)/2)+1):length(sesh_list);
            
        else
            sesh_rng = 1:length(sesh_list);
        end
        %}
        %
        length_sessions = size(file_list_sessions,1);
        if learning_stages == 2
            sesh_rng = 1:length_sessions+1;
        elseif floor(learning_stages) == 2
            sesh_rng = first_mid_last(length_sessions, learning_stages, 0);
        else
            sesh_rng = 1:length_sessions+1;
            %sesh_rng = 1:length_sessions;
        end
        %}
        
        for session = sesh_rng

            
            
            %load session
            try
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
            catch
                %disp('no file')
                continue
            end
            count = count+1;
            if count == 1
                figure; hold on;
            end
            
            %clusters
            %clusts = clusters(clusters(:,4)==1,1);
            %clusts = clusters(clusters(:,2)>2,1);
            %clusts = clusters(:,1);
            
            %cluster index specifications
            cluster_confidence = [3 4 5];
            waveform_shape = [0 1 2 3];
            stability = [1];
            hemisphere = [0 1];
            cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
            %clusts = clusters(cluster_idx,1);
            if learning_stages == 2.1
                cluster_confidence = [2 3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [0 1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                %pop session index
                if length(clusts(:,1))>=8
                    ps_ct = ps_ct+1;
                    %clusters
                    sesh_ct = sesh_ct +1;
                    pop_sessions = [pop_sessions; [repmat(ps_ct, size(clusts)) repmat(sesh_ct, size(clusts))]];
                else

                    %CONTROL POPULATION SELCTION HERE
                    %continue
                    sesh_ct = sesh_ct +1;
                    pop_sessions = [pop_sessions; [zeros(size(clusts)) repmat(sesh_ct, size(clusts))]];
                end
                
            elseif learning_stages == 2.2
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [0 1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                %pop session index
                if length(clusts(:,1))>=8
                    ps_ct = ps_ct+1;
                    %clusters
                    sesh_ct = sesh_ct +1;
                    pop_sessions = [pop_sessions; [repmat(ps_ct, size(clusts)) repmat(sesh_ct, size(clusts))]];
                else

                    %CONTROL POPULATION SELCTION HERE
                    continue
                    sesh_ct = sesh_ct +1;
                    pop_sessions = [pop_sessions; [zeros(size(clusts)) repmat(sesh_ct, size(clusts))]];
                end    
                
            else
                cluster_confidence = [3 4 5];
                waveform_shape = [0 1 2 3];
                stability = [1];
                hemisphere = [0 1];
                cluster_idx = ismember(clusters(:,2),cluster_confidence) & ismember(clusters(:,3),waveform_shape) & ismember(clusters(:,4),stability) & ismember(clusters(:,7),hemisphere);
                clusts = clusters(cluster_idx,1);
                
                %pop session index
                if length(clusts(:,1))>=8
                    ps_ct = ps_ct+1;
                    %clusters
                    sesh_ct = sesh_ct +1;
                    pop_sessions = [pop_sessions; [repmat(ps_ct, size(clusts)) repmat(sesh_ct, size(clusts))]];
                else

                    %CONTROL POPULATION SELCTION HERE
                    %continue
                    sesh_ct = sesh_ct +1;
                    pop_sessions = [pop_sessions; [zeros(size(clusts)) repmat(sesh_ct, size(clusts))]];
                end
            end
            
           
            
            
            %find rates
            eptrials_complete = eptrials;
            stem_runs_complete = stem_runs;
            if half == 1
                eptrials = eptrials(eptrials(:,5)<ceil(max(eptrials(:,5))/2),:);
                [rate_matrix, cs, all_bins_dwell_times, sect_bins] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusts);
                [rate_matrix_complete] = correllate_trialtypepaths(eptrials_complete, stem_runs_complete, bins, clusts);
            elseif half == 2
                eptrials = eptrials(eptrials(:,5)>=ceil(max(eptrials(:,5))/2),:);             
                stem_runs = stem_runs(ceil(max(eptrials(:,5))/2)-1:end, :);
                stem_runs(:,1:2) = stem_runs(:,1:2) - repmat(min(eptrials(:,1)), size(stem_runs(:,1:2)));
                eptrials(:,1) = eptrials(:,1) - repmat(min(eptrials(:,1)), size(eptrials(:,1)));
                eptrials(:,5) = eptrials(:,5) - repmat(min(eptrials(:,5))-2, size(eptrials(:,5)));
                [rate_matrix, cs, all_bins_dwell_times, sect_bins] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusts);
                [rate_matrix_complete] = correllate_trialtypepaths(eptrials_complete, stem_runs_complete, bins, clusts);
            else
                %[rate_matrix, cs, all_bins_dwell_times, sect_bins] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusts);
                [rate_matrix, cs, all_bins_dwell_times, sect_bins] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusts);
                rate_matrix_complete = rate_matrix;
            end
            
            sorting_vector = [sorting_vector repmat(session/length(sesh_list), size(rate_matrix(1,:,1)))];
            rate_matrices = cat(2, rate_matrices, rate_matrix);
            rate_matrices_complete = cat(2, rate_matrices_complete, rate_matrix_complete);
            overall_bins_dwell_times{count} = all_bins_dwell_times;

            %poisson distribution means and stds over entire session
            %for cluster = 1:size(clusters(clusters(:,4)==1,1))
            %    [rate_mean, poisson_std] = rate_hist_window(eptrials, clusters(cluster,1), winback+winforw/bins);
            %    means_and_stds = [means_and_stds [rate_mean; poisson_std]];
            %end
            
        end
    end
end
%}

%figure 8
fig_eight_matrix_complete = [rate_matrices_complete(:,:,1); rate_matrices_complete(:,:,2)];
fig_eight_matrix = [rate_matrices(:,:,1); rate_matrices(:,:,2)];

%rotate first cs bins
fig_eight_matrix_complete(end+1:end+cs, :, :) = fig_eight_matrix_complete(1:cs, :, :);
fig_eight_matrix_complete(1:cs, :, :) = [];

fig_eight_matrix(end+1:end+cs, :, :) = fig_eight_matrix(1:cs, :, :);
fig_eight_matrix(1:cs, :, :) = [];


if rwd_on == 1
    %compute reward rate matrices
    rwd_seconds = 1;
    rwd_bins = floor(bins/5)*rwd_seconds;
    [combined_output_L, combined_output_R, ~] = corr_matrix_wndw(learning_stages, rwd_bins, 0, rwd_seconds, 0);

    %stick reward rates into overall rate matrix
    fem_hold = fig_eight_matrix;
    fig_eight_matrix = nan(size(fem_hold,1)+rwd_bins*2, size(fem_hold,2));
    fig_eight_matrix(1:sum(sect_bins(1:3)),:) = fem_hold(1:sum(sect_bins(1:3)),:);
    fig_eight_matrix(sum(sect_bins(1:3))+1:sum(sect_bins(1:3))+rwd_bins,:) = combined_output_L;
    fig_eight_matrix(sum(sect_bins(1:3))+rwd_bins+1:sum(sect_bins) + sum(sect_bins(1:3)) + rwd_bins,:) = fem_hold(sum(sect_bins(1:3))+1:sum(sect_bins)+sum(sect_bins(1:3)),:);
    fig_eight_matrix(sum(sect_bins) + sum(sect_bins(1:3)) + rwd_bins + 1:sum(sect_bins) + sum(sect_bins(1:3)) + rwd_bins*2,:) = combined_output_R;
    fig_eight_matrix(sum(sect_bins) + sum(sect_bins(1:3)) + rwd_bins*2 + 1:end,:) = fem_hold(sum(sect_bins) + sum(sect_bins(1:3)) + 1:end,:);
end

if redundant == 1
    %standardization
    fig_eight_matrix = zscore_mtx(fig_eight_matrix);

    
    count = 0;
    %find correlation matrix
    figeight_corr_matx = nan(size(fig_eight_matrix,1), size(fig_eight_matrix,1));
    for bin_test = 1:size(fig_eight_matrix,1)
        for bin_comp = 1:size(fig_eight_matrix,1)
            count = count+1;

            %compare these two rows
            test_row = fig_eight_matrix(bin_test, :);
            comp_row = fig_eight_matrix(bin_comp, :);

            %common cell idx
            com_cells = ~isnan(test_row) & ~isnan(comp_row);
            hold_cellcount(count) = sum(com_cells);

            %catch insufficient overlap
            if sum(com_cells)<2
                figeight_corr_matx(bin_test, bin_comp) = nan;
                continue
            end

            %corr inputs
            test_row = test_row(com_cells)';
            comp_row = comp_row(com_cells)';

            %size(test_row)
            
            %CONSTRAIN CELLS? %%%CAUTION CAUTION CAUTION%%%
            %
            if size(test_row,1) > 50 || size(comp_row,1) > 50
                max_cells = 50;
                a = randperm(sum(com_cells));
                test_row = test_row(a(1:max_cells));
                comp_row = comp_row(a(1:max_cells));
            else
                %test_row = nan(50,1);
                %comp_row = nan(50,1);
            end
            
            length(test_row)
            %}

            %{
            if bin_test == 1 & bin_comp == 1
                min_size = min([size(test_row,1), size(comp_row,1)]);
            elseif min_size > min([size(test_row,1), size(comp_row,1)])
                min_size = min([size(test_row,1), size(comp_row,1)]);
            end
            %}


            %fill correllation matrix
            figeight_corr_matx(bin_test, bin_comp) = corr(test_row, comp_row); 
            
        end
    end

else
    
    %normalization
    means_LR = nanmean(fig_eight_matrix);
    p_stds_LR = sqrt(means_LR);
    
    fig_eight_matrix = fig_eight_matrix-repmat(means_LR, size(fig_eight_matrix,1), 1); %remove means
    fig_eight_matrix = fig_eight_matrix./repmat(p_stds_LR, size(fig_eight_matrix,1), 1); %remove stdevs

    %split into L and R
    fig_eight_matrix_L = fig_eight_matrix(1:floor(size(fig_eight_matrix,1)/2), :);
    fig_eight_matrix_R = fig_eight_matrix(floor(size(fig_eight_matrix,1)/2)+1:end, :);

    %find correlation matrix LvR
    %
    figeight_corr_matx = nan(size(fig_eight_matrix_L,1), size(fig_eight_matrix_R,1));
    for bin_test = 1:size(fig_eight_matrix_L,1)
        for bin_comp = 1:size(fig_eight_matrix_R,1)

            %compare these two rows
            test_row = fig_eight_matrix_L(bin_test, :);
            comp_row = fig_eight_matrix_R(bin_comp, :);

            %common cell idx
            com_cells = ~isnan(test_row) & ~isnan(comp_row);

            %catch no overlap
            if sum(com_cells)<2
                figeight_corr_matx(bin_test, bin_comp) = nan;
                continue
            end

            %corr inputs
            test_row = test_row(com_cells)';
            comp_row = comp_row(com_cells)';

            %CONSTRAIN CELLS? %%%CAUTION CAUTION CAUTION%%%
            %{
            max_cells = 10;
            a = randperm(sum(com_cells));
            test_row = test_row(a(1:max_cells));
            comp_row = comp_row(a(1:max_cells));
            %}

            %{
            if bin_test == 1 & bin_comp == 1
                min_size = min([size(test_row,1), size(comp_row,1)]);
            elseif min_size > min([size(test_row,1), size(comp_row,1)])
                min_size = min([size(test_row,1), size(comp_row,1)]);
            end
            %}

            %fill correllation matrix
            figeight_corr_matx(bin_test, bin_comp) = corr(test_row, comp_row);
        end
    end
    %mirror
    %figeight_corr_matx_m = (figeight_corr_matx+figeight_corr_matx')./2;
    %figeight_corr_matx_m(isnan(figeight_corr_matx_m)) = figeight_corr_matx(isnan(figeight_corr_matx_m));
    %figeight_corr_matx = figeight_corr_matx_m;
    
    %}
    
    %find correlation matrix LvL and RvR combined
    %
    figeight_corr_matx_LL = nan(size(fig_eight_matrix_L,1),size(fig_eight_matrix_L,1));
    figeight_corr_matx_RR = nan(size(fig_eight_matrix_R,1),size(fig_eight_matrix_R,1));
    for bin_test = 1:size(fig_eight_matrix_L,1)
        
        for bin_comp = 1:size(fig_eight_matrix_L,1)
            %compare these two rows
            test_row = fig_eight_matrix_L(bin_test, :);
            comp_row = fig_eight_matrix_L(bin_comp, :);

            %common cell idx
            com_cells = ~isnan(test_row) & ~isnan(comp_row);

            %catch no overlap
            if sum(com_cells)<2
                figeight_corr_matx_LL(bin_test, bin_comp) = nan;
                continue
            end

            %corr inputs
            test_row = test_row(com_cells)';
            comp_row = comp_row(com_cells)';

            %fill correllation matrix
            figeight_corr_matx_LL(bin_test, bin_comp) = corr(test_row, comp_row);
        end
        
        for bin_comp = 1:size(fig_eight_matrix_R,1)
            %compare these two rows
            test_row = fig_eight_matrix_R(bin_test, :);
            comp_row = fig_eight_matrix_R(bin_comp, :);

            %common cell idx
            com_cells = ~isnan(test_row) & ~isnan(comp_row);

            %catch no overlap
            if sum(com_cells)<2
                figeight_corr_matx_RR(bin_test, bin_comp) = nan;
                continue
            end

            %corr inputs
            test_row = test_row(com_cells)';
            comp_row = comp_row(com_cells)';

            %fill correllation matrix
            figeight_corr_matx_RR(bin_test, bin_comp) = corr(test_row, comp_row);
        end
        
    end

    %combine
    figeight_corr_matx = (figeight_corr_matx_LL+figeight_corr_matx_RR)./2;
    %mirror
    figeight_corr_matx = (figeight_corr_matx+figeight_corr_matx')./2;
    %} 
     
end



%plot figure
figure; imagesc(figeight_corr_matx); hold on
title(num2str(learning_stages))
axis square
caxis([-1 1])
colorbar
%colormap jet
set(gca,'TickLength',[0, 0]);

%figure; hist(all_bins_dwell_times,50)
%xlim([0 1])
%title(num2str(learning_stages))



end