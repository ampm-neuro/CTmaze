figure; hold on


a = corm_2stem_means_learn_folded_nostart_complete'; 
color_hold = 0.8.*[1 1 1];
plot(nanmean(a), 'color', color_hold)
plot(nanmean(a)+nanstd(a), 'color', color_hold)
plot(nanmean(a)-nanstd(a), 'color', color_hold)
plot(nanmean(a)+nanstd(a)./sqrt(sum(~isnan(a))), 'color', color_hold)
plot(nanmean(a)-nanstd(a)./sqrt(sum(~isnan(a))), 'color', color_hold)

a = corm_2stem_means_ot_folded_nostart_complete'; 
color_hold = 0.3.*[1 1 1];
plot(nanmean(a), 'color', color_hold)
plot(nanmean(a)+nanstd(a), 'color', color_hold)
plot(nanmean(a)-nanstd(a), 'color', color_hold)
plot(nanmean(a)+nanstd(a)./sqrt(sum(~isnan(a))), 'color', color_hold)
plot(nanmean(a)-nanstd(a)./sqrt(sum(~isnan(a))), 'color', color_hold)


set(gca,'TickLength',[0, 0]); box off; xlim([.5 89.5]); plot(xlim, [1 1].*0, 'k--');

ylim auto;

hold on; plot((cum_sect_bins_folded(2:end)-floor(cum_sect_bins_folded(1))).*[1; 1], ylim, 'k-')

xticks([])
ylabel('Firing Rate (z)')