
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
all_dwell_times{1} = all_dwell_times_21;
all_dwell_times{2} = all_dwell_times_22;
all_dwell_times{3} = all_dwell_times_23;
all_dwell_times{4} = all_dwell_times_40;

%preallocate
all_field_locs = cell(1,4);

%figure
figure; hold on



%iterate through super cell
for istage = 1:length(all_smoothed_rates)
    
    all_field_locs{istage} = [];
    
    %find info content of each bin
    [~, pos_infos] = pos_info_shell(all_smoothed_rates{istage}, all_dwell_times{istage});
    all_field_locs{istage} = [all_field_locs{istage}; pos_infos];

    
    istage_1 = [1 3 5 7];
    subplot(4,2,istage_1(istage))
    imagesc(all_field_locs{istage})
    %axis([0.35 length(bin_means)+0.5 0.5 iclust+0.5])
    set(gca,'TickLength',[0, 0])
    caxis([0 10])
    
    for isect = 1:length(cum_sect_bins)
        hold on; plot((cum_sect_bins(isect)+0.5).*[1 1], ylim, 'r-')
    end
    
    istage_2 = [2 4 6 8];
    subplot(4,2,istage_2(istage))
    bar(nanmean(all_field_locs{istage}))
    set(gca,'TickLength',[0, 0])
    ylim([0 10])
    
    for isect = 1:length(cum_sect_bins)
        hold on; plot((cum_sect_bins(isect)+0.5).*[1 1], ylim, 'r-')
    end

end