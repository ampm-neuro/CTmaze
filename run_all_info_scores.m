%
[out_first_smooth] = ALL_infoscores(2.1, all_vel_first); first_mean = nanmean(out_first_smooth)
[out_mid_smooth] = ALL_infoscores(2.2, all_vel_mid); mid_mean = nanmean(out_mid_smooth)
[out_crit_smooth] = ALL_infoscores(2.3, all_vel_crit); crit_mean = nanmean(out_crit_smooth)
[out_ot_smooth] = ALL_infoscores(4, all_vel_ot); ot_mean = nanmean(out_ot_smooth)


figure; hold on; 
bar([nanmean(out_first_smooth) nanmean(out_mid_smooth) nanmean(out_crit_smooth) nanmean(out_ot_smooth)]); 
errorbar([nanmean(out_first_smooth) nanmean(out_mid_smooth) nanmean(out_crit_smooth) nanmean(out_ot_smooth)],...
    [nanstd(out_first_smooth)/sqrt(length(out_first_smooth)) nanstd(out_mid_smooth)/sqrt(length(out_mid_smooth))...
    nanstd(out_crit_smooth)/sqrt(length(out_crit_smooth)) nanstd(out_ot_smooth)/sqrt(length(out_ot_smooth))], 'k.')
figure; histogram(out_ot_smooth, 0:0.05:3, 'Normalization', 'Probability')
%}


%{
[out_first_smooth_thirds] = ALL_infoscores(2.1, all_vel_first_thirds);
[out_mid_smooth_thirds] = ALL_infoscores(2.2, all_vel_mid_thirds);
[out_crit_smooth_thirds] = ALL_infoscores(2.3, all_vel_crit_thirds);
[out_ot_smooth_thirds] = ALL_infoscores(4, all_vel_ot_thirds);


figure; hold on; 
bar([nanmean(out_first_smooth_thirds) nanmean(out_mid_smooth_thirds) nanmean(out_crit_smooth_thirds) nanmean(out_ot_smooth_thirds)]); 
errorbar([nanmean(out_first_smooth_thirds) nanmean(out_mid_smooth_thirds) nanmean(out_crit_smooth_thirds) nanmean(out_ot_smooth_thirds)],...
    [nanstd(out_first_smooth_thirds)/sqrt(length(out_first_smooth_thirds)) nanstd(out_mid_smooth_thirds)/sqrt(length(out_mid_smooth_thirds))...
    nanstd(out_crit_smooth_thirds)/sqrt(length(out_crit_smooth_thirds)) nanstd(out_ot_smooth_thirds)/sqrt(length(out_ot_smooth_thirds))], 'k.')
figure; histogram(out_ot_smooth, 0:0.05:3, 'Normalization', 'Probability')
%}

