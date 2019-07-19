
%load(revisions_confusion_mtx_prep)

%see:
%temp_decode_script
%for info on the organization of prep file

%ideal maze coordinates (50x50) 
right_choice = [27 44]; %1
right_arm = [30 45; 33 45; 36 45; 39 45; 42 43; 44 41]; %2:7
right_rtn = [46 38; 46 34; 46 31; 46 28; 45 26; 45 23; 44 21; 43 19; 42 16; 41 13; 39 11; 38 9; 35 9; 32 9]; %8:21
right_start = [29 9; 27 12]; %22:23
stem = [26 15; 26 18; 26 21; 26 24; 26 27; 26 30; 26 33; 26 36; 26 39]; %24:32
left_choice = [26 42; 25 44]; %33:34
left_arm =  [22 45; 19 45; 16 45; 13 45; 10 43; 8  41]; %35:40
left_rtn = [6 38; 6 34; 6 31; 7 28; 8 26; 8 23; 9 21; 10 19; 11 16; 12 13; 13 11; 14 9; 17 9; 20 9]; %41:54
left_start = [23 9; 25 12]; %55:56

%ideal_maze_cords = [right_choice; right_arm; right_rtn; right_start; stem; left_choice; left_arm; left_rtn; left_start];
ideal_maze_cords = [right_arm; right_rtn; right_start; stem; left_choice; left_arm; left_rtn];               
all_class_counts = [];
peak_error = [];
stage_cell = all_decode_vars_4;
                    
%reassign observed and classified coordinates to ideal coordinates
for sesh = 1:length(stage_cell{15})

    %true and classified positions
    true_positions = stage_cell{20}(stage_cell{5}(:,5)==sesh);
    position_classifications = stage_cell{5}(stage_cell{5}(:,5)==sesh, 4);
    
    %full posterior
    %full_post_sesh = all_decode_vars_4{15}{sesh}((size(all_decode_vars_4{15}{sesh},1)-length(position_classifications)) : end, :);
    full_post_sesh = all_decode_vars_4{15}{sesh}(sum(~isnan(all_decode_vars_4{15}{sesh}),2)>0,:);
    full_post_sesh = full_post_sesh(2:end,:);
   

    [i,j] = ind2sub([50 50], true_positions); true_pos_sub = [j i];
    [i,j] = ind2sub([50 50], position_classifications); class_pos_sub = [j i];

    true_pos_reass = nan(length(true_pos_sub), 2);
    class_pos_reass = nan(length(class_pos_sub), 2);

    for ipos = 1:size(true_pos_sub,1)

        %true
        min_dists = pdist([true_pos_sub(ipos,:); ideal_maze_cords]); 
        min_dists = min_dists(1:length(ideal_maze_cords));
        true_pos_reass(ipos,:) = ideal_maze_cords(find(min_dists==min(min_dists),1), :);

        %classified
        min_dists = pdist([class_pos_sub(ipos,:); ideal_maze_cords]); 
        min_dists = min_dists(1:length(ideal_maze_cords));
        class_pos_reass(ipos,:) = ideal_maze_cords(find(min_dists==min(min_dists),1), :);

    end
    
    %reassign with track numbers
    true_pos_track = nan(size(true_pos_reass,1),1);
    class_pos_track = nan(size(class_pos_reass,1),1);
    for ipos = 1:size(true_pos_reass,1)

        true_pos_track(ipos) = find(ismember(ideal_maze_cords, true_pos_reass(ipos,:), 'rows')==1, 1);
        class_pos_track(ipos) = find(ismember(ideal_maze_cords, class_pos_reass(ipos,:), 'rows')==1, 1);
    end    
    
    %reclassification key
    original_and_reclass = [true_positions true_pos_track];
    [~,o_r_idx] = unique(original_and_reclass(:,1));
    original_and_reclass = original_and_reclass(o_r_idx,:);
    
    %reclassificy posterior
     posterior_pos_track = nan(size(class_pos_reass,1),length(ideal_maze_cords));
     for ibin = 1:length(ideal_maze_cords)
         %original columns corresponding to this bin
         o_cols = original_and_reclass(original_and_reclass(:,2)==ibin,1);
         posterior_pos_track(:,ibin) = sum(full_post_sesh(:,o_cols),2);
     end

     
    %count classifications at each true pos
    class_counts = nan(length(ideal_maze_cords), length(ideal_maze_cords));
    for ipos = 1:size(ideal_maze_cords,1)

        class_counts(:, ipos) = histcounts(class_pos_track(true_pos_track==ipos), 1:length(ideal_maze_cords)+1);

    end

    %normalize by the number of visited pixels assigned to each ideal pixel
    true_pos_sub_unq = unique(true_pos_sub,'rows');
    true_pos_unq_reass = nan(length(true_pos_sub_unq), 2);
    for ipos = 1:size(true_pos_sub_unq,1)

        %true
        min_dists = pdist([true_pos_sub_unq(ipos,:); ideal_maze_cords]); 
        min_dists = min_dists(1:length(ideal_maze_cords));
        true_pos_unq_reass(ipos,:) = ideal_maze_cords(find(min_dists==min(min_dists),1), :);

    end
    normvect = nan(size(ideal_maze_cords, 1), 1);
    for ipos = 1:size(ideal_maze_cords,1)
        normvect(ipos) = sum(ismember(true_pos_unq_reass, ideal_maze_cords(ipos,:), 'rows'));
    end
    class_counts = class_counts./normvect;
    
    
    column_peaks = nan(size(class_counts,2), 1);
    for ipos = 1:length(column_peaks)
        column_peaks(ipos) = find(class_counts(:,ipos)==max(class_counts(:,ipos)), 1);
    end
    peak_error = [peak_error; mean(abs(column_peaks - (1:length(column_peaks))'))];

    %plot each session
    %{
    figure; 
    imagesc(norm_mtx(class_counts));
    axis square
    colorbar
    xticks(1:56)
    yticks(1:56)
    title(num2str(sesh))
    %}

    %load each
    all_class_counts = cat(3, all_class_counts, class_counts);
    
    
    %plot decoded trials
    revisions_decoder_confusion_mtx_trial_plot
    
    

end

%plot overall mean
%overall_mean = norm_mtx(mean(norm_mtx(all_class_counts),3));

for i = 1:size(all_class_counts,3)
    figure; hold on
    mtx = all_class_counts(:,:,i)./sum(all_class_counts(:,:,i),1);
    
    imagesc(mtx);
    axis square
    axis off
    colorbar
    title('overall')
    set(gca, 'Ydir', 'reverse')
    caxis([0 1])
    
    column_peaks = nan(size(mtx,2), 1);
    for ipos = 1:length(column_peaks)
        column_peaks(ipos) = find(mtx(:,ipos)==max(mtx(:,ipos)), 1);
    end
    hold on; plot(column_peaks, 'r-', 'linewidth', 3)
    caxis([0 .25])
    title 40
end



overall_mean = mean(all_class_counts./sum(all_class_counts,1), 3);
overall_mean = overall_mean./sum(overall_mean);

figure; hold on
imagesc(overall_mean);
axis square
axis off
colorbar
title('overall')
set(gca, 'Ydir', 'reverse')
caxis([0 1])

%trace peaks
%
column_peaks = nan(size(overall_mean,2), 1);
for ipos = 1:length(column_peaks)
    column_peaks(ipos) = find(overall_mean(:,ipos)==max(overall_mean(:,ipos)));
end
hold on; plot(column_peaks, 'r-', 'linewidth', 3)
%}

%add vertical boundary lines
cumsum_pix = size(right_arm,1);
plot((cumsum_pix+0.5).*[1 1], ylim, 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(right_rtn,1);
plot((cumsum_pix+0.5).*[1 1], ylim, 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(right_start,1);
plot((cumsum_pix+0.5).*[1 1], ylim, 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(stem,1);
plot((cumsum_pix+0.5).*[1 1], ylim, 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(left_choice,1);
plot((cumsum_pix+0.5).*[1 1], ylim, 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(left_arm,1);
plot((cumsum_pix+0.5).*[1 1], ylim, 'k-', 'linewidth', 4)

%add horizontal boundary lines
cumsum_pix = size(right_arm,1);
plot(xlim, (cumsum_pix+0.5).*[1 1], 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(right_rtn,1);
plot(xlim, (cumsum_pix+0.5).*[1 1], 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(right_start,1);
plot(xlim, (cumsum_pix+0.5).*[1 1], 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(stem,1);
plot(xlim, (cumsum_pix+0.5).*[1 1], 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(left_choice,1);
plot(xlim, (cumsum_pix+0.5).*[1 1], 'k-', 'linewidth', 4)
cumsum_pix = cumsum_pix+size(left_arm,1);
plot(xlim, (cumsum_pix+0.5).*[1 1], 'k-', 'linewidth', 4)

%limits
ylim([0.5 length(ideal_maze_cords)+0.5])
xlim([0.5 length(ideal_maze_cords)+0.5])


%decode accuracy
figure; hold on
colors = get(gca,'ColorOrder');
dec_acc_vects = nan(size(all_class_counts,3),size(all_class_counts,1));
for i = 1:size(all_class_counts,3)

    acc_hold = all_class_counts(:,:,i)./sum(all_class_counts(:,:,i),1);
    %dec_acc_vects(i,:) = acc_hold(diag_mask(size(acc_hold,1)));
    for i2 = 1:size(acc_hold,1)
        y_incl = i2-1:i2+1; y_incl(y_incl==0) = length(acc_hold); y_incl(y_incl==length(acc_hold)+1) = 1;
        dec_acc_vects(i,i2) = sum(acc_hold(i2,y_incl));
    end
    
end
i = 4;
plot(mean(dec_acc_vects), '-', 'color', colors(i,:), 'linewidth', 2);
plot(mean(dec_acc_vects)+std(dec_acc_vects)./sqrt(size(dec_acc_vects,1)), '-', 'color', colors(i,:));
plot(mean(dec_acc_vects)-std(dec_acc_vects)./sqrt(size(dec_acc_vects,1)), '-', 'color', colors(i,:));


close all


