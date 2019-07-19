load('revisions_explaindecsuc')

colors = get(gca,'ColorOrder');

%locs_of_interest = [18 32 41 63 89];
locs_of_interest = [10 37 51 63 94];

%normalized rates
all_smoothed_rates_norm = all_smoothed_rates(:,1);
figure; hold on
for i = 1:size(all_smoothed_rates_norm,1)
    
    
    
    %figure; imagesc(all_smoothed_rates_norm{i}); title(num2str(i)); set(gca,'TickLength',[0, 0]); axis off; colorbar
    
    min_ = min(min(all_smoothed_rates_norm{i}));
    max_ = max(max(all_smoothed_rates{i} - min_));
    
    %all_smoothed_rates_norm{i} = (all_smoothed_rates_norm{i} - min_)./max_;
    %all_smoothed_rates_norm{i} = round(all_smoothed_rates_norm{i});
    
    subplot(size(all_smoothed_rates_norm,1),1,i); hold on
    plot(all_smoothed_rates_norm{sort_idx(i)}', 'color', 0.8.*[1 1 1])
    plot(nanmean(all_smoothed_rates_norm{sort_idx(i)}), 'k-', 'linewidth', 3)
    set(gca,'TickLength',[0, 0]);
    
    %plot(nanmean(all_smoothed_rates_norm{i}))
    %plot(nanmean(all_smoothed_rates_norm{i}) + nanstd(all_smoothed_rates_norm{i})./sqrt(sum(~isnan(all_smoothed_rates_norm{i}))))
    %plot(nanmean(all_smoothed_rates_norm{i}) - nanstd(all_smoothed_rates_norm{i})./sqrt(sum(~isnan(all_smoothed_rates_norm{i}))))
    
    %all_smoothed_rates_norm{i} = zscore_mtx(all_smoothed_rates_norm{i});
end
set(gca,'TickLength',[0, 0]);
%hold on; plot([locs_of_interest; locs_of_interest], ylim, 'k-')

%{
%bar graph
figure; hold on
loc_x = [.9 .95 1 1.05 1.1];
loc_rates = nan(size(all_smoothed_rates_norm{1},1), size(all_smoothed_rates_norm,1),length(locs_of_interest)); %trials, cells, locs 
loc_rates_all = nan(size(all_smoothed_rates_norm{1},1), size(all_smoothed_rates_norm,1), size(all_smoothed_rates_norm{1},2));
for i = 1:size(all_smoothed_rates_norm,1)
    
    for i2 = 1:length(locs_of_interest)
        
        loc_rates(:,i,i2) = all_smoothed_rates_norm{i}(:,locs_of_interest(i2));
        
        %bar(loc_x(i2), nanmean(loc_rates(:,i,i2)))
        %errorbar(loc_x(i2), nanmean(loc_rates(:,i,i2)), nanstd(loc_rates(:,i,i2))./sqrt(sum(~isnan(loc_rates(:,i,i2)))));
       
    end

    bar(squeeze(nanmean(loc_rates))')
    
    xlocations_for_bars_prep = linspace(.6, 1.4, size(all_smoothed_rates_norm,1)+1);
    xlocations_for_bars_prep = mean([xlocations_for_bars_prep(1:end-1);xlocations_for_bars_prep(2:end)]);
    xlocations_for_bars = []; for i3 = 1:length(locs_of_interest); xlocations_for_bars = [xlocations_for_bars; xlocations_for_bars_prep+(i3-1)]; end
    
    
    %errorbar(xlocations_for_bars, squeeze(nanmean(loc_rates))', (squeeze(nanstd(loc_rates))')./sqrt(squeeze(sum(~isnan(loc_rates)))'), 'k.');
    errorbar(xlocations_for_bars, squeeze(nanmean(loc_rates))', squeeze(nanstd(loc_rates))', 'k.');
    set(gca,'TickLength',[0, 0])
    
    
    for i2 = 1:size(all_smoothed_rates_norm{1},2)
        loc_rates_all(:,i,i2) = all_smoothed_rates_norm{i}(:,i2);
    end
    
end


%pca plot
loc_rates_cocpag_idx = [];
loc_rates_cocpag = [];
for i = 1:size(loc_rates_all,3)
    loc_rates_cocpag = [loc_rates_cocpag; loc_rates_all(:,:,i)];
    loc_rates_cocpag_idx = [loc_rates_cocpag_idx; repmat(i,size(loc_rates_all(:,:,i),1), 1)];
end

nan_idx = isnan(sum(loc_rates_cocpag,2));
loc_rates_cocpag(nan_idx,:) = [];
loc_rates_cocpag_idx(nan_idx,:) = [];
loc_rates_cocpag_pca = pca(loc_rates_cocpag');

figure; imagesc(loc_rates_cocpag)
hold on;
for i = locs_of_interest
    a = 1:length(loc_rates_cocpag);
    b = a(loc_rates_cocpag_idx == i);
    plot(xlim,[b(1) b(1)], 'k-');
    plot(xlim,[b(end) b(end)], 'k-'); 
end

figure; hold on
for i = 1:length(locs_of_interest) 
    
    loi = locs_of_interest(i);
    
    idx = loc_rates_cocpag_idx == loi;
    plot(loc_rates_cocpag_pca(idx,1), loc_rates_cocpag(idx,2), '.', 'markersize', 20, 'color', colors(i,:))
    plot(mean(loc_rates_cocpag_pca(idx,1)), mean(loc_rates_cocpag(idx,2)), '.', 'markersize', 65, 'color', colors(i,:))
    
    %plot3(loc_rates_cocpag_pca(idx,1), loc_rates_cocpag(idx,2), loc_rates_cocpag(idx,3), '.', 'markersize', 20)
    %plot3(mean(loc_rates_cocpag_pca(idx,1)), mean(loc_rates_cocpag(idx,2)), mean(loc_rates_cocpag(idx,3)), '.', 'markersize', 80)
    
end



%bayesian decode
%
%for these, round firing rate to counts and turn off normalization

samp = 1001; all_samps = 1:size(loc_rates_cocpag,1);
all_posteriors = [];
for i = 1:size(loc_rates_cocpag,2)
    
%[class, posterior, f_x] = bayesian_decode(loc_rates_cocpag(samp,:), loc_rates_cocpag(setdiff(all_samps,samp),:), loc_rates_cocpag_idx(setdiff(all_samps,samp)), 1);
[class, posterior, f_x] = bayesian_decode(loc_rates_cocpag(samp,i), loc_rates_cocpag(setdiff(all_samps,samp),i), loc_rates_cocpag_idx(setdiff(all_samps,samp)), 1);
all_posteriors = [all_posteriors; posterior];

end

[~,sort_idx] = sort(all_posteriors(:,51));
all_posteriors = all_posteriors(sort_idx,:);

figure;
for i = 1:size(all_posteriors,1)
    subplot(size(loc_rates_cocpag,2), 1, i)
    plot(all_posteriors(i,:))
    ylim([0 .1])
    set(gca,'TickLength',[0, 0]);
    xticks([])
    yticks([0 0.1])
end


%for cumulative affect of adding neurons
%{
samp = 1001; all_samps = 1:size(loc_rates_cocpag,1);
all_posteriors = [];
for i = 1:size(loc_rates_cocpag,2)
    
%[class, posterior, f_x] = bayesian_decode(loc_rates_cocpag(samp,:), loc_rates_cocpag(setdiff(all_samps,samp),:), loc_rates_cocpag_idx(setdiff(all_samps,samp)), 1);
%[class, posterior, f_x] = bayesian_decode(loc_rates_cocpag(samp,i), loc_rates_cocpag(setdiff(all_samps,samp),i), loc_rates_cocpag_idx(setdiff(all_samps,samp)), 1);
[class, posterior, f_x] = bayesian_decode(loc_rates_cocpag(samp,sort_idx(1:i)), loc_rates_cocpag(setdiff(all_samps,samp),sort_idx(1:i)), loc_rates_cocpag_idx(setdiff(all_samps,samp)), 1);

all_posteriors = [all_posteriors; posterior];

end

%[~,sort_idx] = sort(all_posteriors(:,51));
%all_posteriors = all_posteriors(sort_idx,:);

figure;
for i = 1:size(all_posteriors,1)
    subplot(size(loc_rates_cocpag,2), 1, i)
    plot(all_posteriors(i,:))
    ylim([0 1])
    set(gca,'TickLength',[0, 0]);
    xticks([])
    yticks([0 1])
end
%}
%}

