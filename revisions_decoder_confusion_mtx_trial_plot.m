%load('revisions_confusion_mtx_prep_alltrials_2.mat')

%true positions (1:53)
%true_pos_track;

%decoded_positions
%class_pos_track;

%time bins
time_bins = 1:length(true_pos_track);

%start area
start_area_ids = [21:22];
%reward area
rwd_area_ids = [1:6 34:39];


%trial ids
trial_ids = zeros(size(true_pos_track));
trial_number = 1;
rwd_visit_flag = 0;
for itimebin = 1:length(true_pos_track)
    
    if rwd_visit_flag == 0 && ismember(true_pos_track(itimebin), rwd_area_ids)
        rwd_visit_flag = 1;
    end
    
    if rwd_visit_flag == 1 && ismember(true_pos_track(itimebin), start_area_ids)
        %trial_number = trial_number+1;
        rwd_visit_flag = 2;
    end
    
    if rwd_visit_flag == 2 && ismember(true_pos_track(itimebin), rwd_area_ids)
        %trial_number = trial_number+1;
        rwd_visit_flag = 3;
    end
    
    if rwd_visit_flag == 3 && ismember(true_pos_track(itimebin), start_area_ids)
        trial_number = trial_number+1;
        rwd_visit_flag = 0;
    end
    
    %rwd_visit_flag
    trial_ids(itimebin) = trial_number;
end

%plot decoding over each trial seperately
unique_trial_ids = unique(trial_ids); unique_trial_ids = unique_trial_ids(unique_trial_ids>0)';

trl_decoding_mtx = nan(53, 53, max(unique_trial_ids));

for itrl = unique_trial_ids
    
    
    tru_pos_trl = true_pos_track(trial_ids==itrl);
    class_pos_trl = class_pos_track(trial_ids==itrl);
    posterior_pos_trl = posterior_pos_track(trial_ids==itrl,:);
    

    %iterate through spatial bins
    unique_spatial_bins = unique(tru_pos_trl)';
    for ibin = unique_spatial_bins
        
        
        %decoded positions at this true position
        %class_pos_trl_bin = histcounts(class_pos_trl(tru_pos_trl==ibin), 1:54);
        class_pos_trl_bin = sum(posterior_pos_trl(tru_pos_trl==ibin, :), 1);
        
        %normalize
        %class_pos_trl_bin = norm_mtx(class_pos_trl_bin);
        class_pos_trl_bin = class_pos_trl_bin./sum(class_pos_trl_bin);
        
        %temp
        trl_decoding_mtx(:, ibin, itrl) =  class_pos_trl_bin;
    
    end
    
    visited_bins = unique(tru_pos_trl);
    figure; imagesc(trl_decoding_mtx(visited_bins,visited_bins,itrl))
    caxis([0 .35])
    
    axis square
    set(gca,'TickLength',[0, 0]); box off;
    
    section_lines = cumsum([0 size(right_arm,1) size(right_rtn,1) size(right_start,1) size(stem,1) size(left_choice,1) size(left_arm,1) size(left_rtn,1)])+.5;
    tick_labels = {'rArm', 'rRtn', 'rSta', 'Stem', 'lCho', 'lArm', 'lRtn'};
    tick_lines = mean([section_lines(1:end-1);section_lines(2:end)]); 
    
    %{
    if any(visited_bins<20)
        section_lines = section_lines([1:5]);
        tick_lines = mean([section_lines(1:end-1);section_lines(2:end)]);
        tick_labels = {'rArm', 'rRtn', 'rSta', 'Stem'};
    else
        section_lines = section_lines([4:end]) - min(floor(section_lines([4:end])));
        tick_lines = mean([section_lines(1:end-1);section_lines(2:end)]);
        tick_labels = {'Stem', 'lCho', 'lArm', 'lRtn'};
    end
    %}
    
    hold on
    plot([section_lines; section_lines], ylim, 'r-')
    plot(xlim, [section_lines; section_lines], 'r-')

    %tick_lines = mean([section_lines(1:end-1);section_lines(2:end)]); 
    %tick_labels = {'rArm', 'rRtn', 'rSta', 'Stem', 'lCho', 'lArm', 'lRtn'};
    xticks(tick_lines)
    xticklabels(tick_labels)
    yticks(tick_lines)
    yticklabels(tick_labels)
    
    % IF DAVID WANTS COLORMAP JET (LOOKS AWFUL)
    %{
    fig = gcf;
    if ismember(fig.Number, [128 154 156 173 277])
        savevarnum= savevarnum+1; 
        var_name = ['dec_trl_eg' num2str(savevarnum) '.pdf']; print(['E:\Projects\Submitted\RSC-FutureSim\figures\Current_Bio\revisions\wip\' var_name], '-dpdf', '-painters', '-bestfit')
    end
    %}
end
    
%mean of all trials
sesh_mean_of_trial_posteriors = nanmean(trl_decoding_mtx,3);
sesh_mean_of_trial_posteriors = sesh_mean_of_trial_posteriors./sum(sesh_mean_of_trial_posteriors);
figure; imagesc(sesh_mean_of_trial_posteriors)
caxis([0 .35])
%xticks([1:length(visited_bins)])
%xticklabels([visited_bins])
%yticks([1:length(visited_bins)])
%yticklabels([visited_bins])
axis square
set(gca,'TickLength',[0, 0]); box off;
title seshmean

hold on
    section_lines = cumsum([0 size(right_arm,1) size(right_rtn,1) size(right_start,1) size(stem,1) size(left_choice,1) size(left_arm,1) size(left_rtn,1)])+.5;

    plot([section_lines; section_lines], ylim, 'r-')
    plot(xlim, [section_lines; section_lines], 'r-')

    tick_lines = mean([section_lines(1:end-1);section_lines(2:end)]); 
    tick_labels = {'rArm', 'rRtn', 'rSta', 'Stem', 'lCho', 'lArm', 'lRtn'};
    xticks(tick_lines)
    xticklabels(tick_labels)
    yticks(tick_lines)
    yticklabels(tick_labels)
    
    