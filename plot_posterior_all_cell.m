function plot_posterior_all_cell(posterior_all_cell, trial_type_idx)
%posterior all cell from future_decode_script

%means
pac_means = [];
for i = 1:length(posterior_all_cell)
    
    %find trial types
    trial_types = nan(size(posterior_all_cell{i},1), 1);
    trial_type_idx{i}(isnan(trial_type_idx{i})) = 0;
    current = 0;
    trial_count = 1;
    for i2 = 1:size(trial_type_idx{i},1)
        if trial_type_idx{i}(i2) == current
            continue
        elseif ismember(current, [1 2])
            trial_types(trial_count) = current;
            trial_count = trial_count+1;
        end
        current = trial_type_idx{i}(i2);
    end
    
    %flip left trials
    for itrl = 1:size(posterior_all_cell{i})
        if trial_types(itrl)==1
            hold_vect = posterior_all_cell{i}(itrl, :);
            hold_vect = fliplr(reshape(hold_vect,50,50));
            posterior_all_cell{i}(itrl, :) = hold_vect(:);
        end
    end
    
    %load mean
    pac_means = [pac_means; nanmean(posterior_all_cell{i})]; 

end

%sessions with visits to each
visit_counts = nansum(pac_means>0);

%remove pixles that arent visited enough
min_vis = 2;
pac_means(:,visit_counts<min_vis) = nan;

%renorm
pac_means = pac_means./nansum(pac_means,2);

%overall mean
all_pac_mean = nanmean(pac_means);
all_pac_mean = all_pac_mean./nansum(all_pac_mean);

%reshape into square
all_pac_mean = reshape(all_pac_mean, sqrt(length(all_pac_mean)), sqrt(length(all_pac_mean)));

all_pac_mean(all_pac_mean==0) = nan;

%plot
figure; a = pcolor(reshape(all_pac_mean, 50, 50));
set(a, 'EdgeColor', 'none');
set(gca,'TickLength',[0, 0]); box off;
set(gca,'Ydir','normal')
axis off
axis square
colorbar; colormap jet; caxis([0 .005])