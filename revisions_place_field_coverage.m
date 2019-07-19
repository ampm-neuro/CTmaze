
%load('revisions_fieldcover.mat')

    %OR

    %get trial-by-trial binned rates
     %{
    [all_smoothed_rates_21, all_dwell_times_21] = all_nitzlines(2.1);
    [all_smoothed_rates_22, all_dwell_times_22] = all_nitzlines(2.2);
    [all_smoothed_rates_23, all_dwell_times_23] = all_nitzlines(2.3);
    [all_smoothed_rates_40, all_dwell_times_40] = all_nitzlines(4);
    %}

    
bins= 100;
traj_lens = [145 200 250 320]; %ALL ALL
sect_bins = round(bins*(traj_lens./sum(traj_lens)));
cum_sect_bins = cumsum([sect_bins sect_bins]); cum_sect_bins = cum_sect_bins(1:end-1);
    
%combine into one super cell
all_smoothed_rates{1} = all_smoothed_rates_21;
all_smoothed_rates{2} = all_smoothed_rates_22;
all_smoothed_rates{3} = all_smoothed_rates_23;
all_smoothed_rates{4} = all_smoothed_rates_40;

%preallocate
all_field_locs = cell(1,4);

%figure
figure; hold on



%iterate through super cell
for istage = 1:length(all_smoothed_rates)
    
    all_field_locs{istage} = [];
    
    %iterate through each cluster
    for iclust = 1:size(all_smoothed_rates{istage},1)
    
        %average rates across trials
        
        %figure; 
        %subplot(4,2,1) ; imagesc(all_smoothed_rates{istage}{iclust,1}) 
        %subplot(4,2,2) ; imagesc(all_smoothed_rates{istage}{iclust,2})
        
        bin_means = [nanmean(all_smoothed_rates{istage}{iclust,1}) nanmean(all_smoothed_rates{istage}{iclust,2})];
        %subplot(4,2,5:6) ; plot(bin_means)
        bin_means([sum(~isnan(all_smoothed_rates{istage}{iclust,1})) sum(~isnan(all_smoothed_rates{istage}{iclust,2}))]<3) = nan;
        %subplot(4,2,5:6) ; hold on;  plot(bin_means, 'r')
        %subplot(4,2,3:4) ; plot([sum(~isnan(all_smoothed_rates{istage}{iclust,1})) sum(~isnan(all_smoothed_rates{istage}{iclust,2}))])
        %subplot(4,2,3:4) ; hold on; plot([sum(~isnan(all_smoothed_rates{istage}{iclust,1})) sum(~isnan(all_smoothed_rates{istage}{iclust,2}))]<10)
        
        
        
        %find outlying bins using std
        hi_info_bins = find(bin_means>nanmean(bin_means)+nanstd(bin_means)*1.0 | bin_means<nanmean(bin_means)-nanstd(bin_means)*1.0);
        %hi_info_bins = find(bin_means>nanmean(bin_means)+nanstd(bin_means));
        %hi_info_bins = find(bin_means>nanmean(bin_means));
        
        %load outlying bins
        field_zeros = zeros(size(bin_means));
        field_zeros(hi_info_bins) = iclust;
        field_zeros(isnan(bin_means)) = nan;
        all_field_locs{istage} = [all_field_locs{istage}; field_zeros];
        
        %plot
        %{
        bin_x = nan(size(bin_means));
        bin_x(hi_info_bins) = hi_info_bins;
        bin_y = nan(size(bin_means));
        bin_y(hi_info_bins) = iclust;
        
        subplot(4,2,istage); hold on
        plot(bin_x, bin_y, 'k-')
        %}
        
    end
    
    istage_1 = [1 3 5 7];
    subplot(4,2,istage_1(istage))
    line_plot_hold = all_field_locs{istage};
    line_plot_hold(line_plot_hold==0) = nan;
    plot(line_plot_hold', 'k-')
    axis([0.5 length(bin_means)+0.5 0.5 iclust+0.5])
    set(gca,'TickLength',[0, 0])
    
    for isect = 1:length(cum_sect_bins)
        hold on; plot(cum_sect_bins(isect).*[1 1], ylim, 'r-')
    end
    
    istage_2 = [2 4 6 8];
    subplot(4,2,istage_2(istage))
    bar(sum(all_field_locs{istage}>0)./sum(~isnan(all_field_locs{istage})))
    set(gca,'TickLength',[0, 0])
    ylim([0 .75])
    
    for isect = 1:length(cum_sect_bins)
        hold on; plot(cum_sect_bins(isect).*[1 1], ylim, 'r-')
    end
    
    %figure; hold on
    %plot(sum(all_field_locs{istage}>0)./size(all_field_locs{istage},1))
    %plot(sum(all_field_locs{istage}>0)./sum(~isnan(all_field_locs{istage})))
    
    
    mean(sum(all_field_locs{istage}>0)./sum(~isnan(all_field_locs{istage})))

end