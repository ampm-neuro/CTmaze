function learning_curve_seshmeans(data_ot, data_cont, first, mid, crit)

ot = unique(data_ot(:,9))';


%preallocate
sesh_means_first = nan(size(first));
sesh_means_mid = nan(size(mid));
sesh_means_crit = nan(size(crit));
sesh_means_ot = nan(size(ot));

sesh_means_first_e = nan(size(first));
sesh_means_mid_e = nan(size(mid));
sesh_means_crit_e = nan(size(crit));
sesh_means_ot_e = nan(size(ot));


%fill with means
for i = first
    idx = find(first == i);
    sesh_means_first(idx) = mean(data_cont(data_cont(:,9)==i & data_cont(:,7)==1, 3));
    sesh_means_first_e(idx) = mean(data_cont(data_cont(:,9)==i & data_cont(:,7)==2, 3));
end
for i = mid
    idx = find(mid == i);
    sesh_means_mid(idx) = mean(data_cont(data_cont(:,9)==i & data_cont(:,7)==1, 3));
    sesh_means_mid_e(idx) = mean(data_cont(data_cont(:,9)==i & data_cont(:,7)==2, 3));
end
for i = crit
    idx = find(crit == i);
    sesh_means_crit(idx) = mean(data_cont(data_cont(:,9)==i & data_cont(:,7)==1, 3));
    sesh_means_crit_e(idx) = mean(data_cont(data_cont(:,9)==i & data_cont(:,7)==2, 3));
end
for i = unique(data_ot(:,9))'
    idx = find(ot == i);
    sesh_means_ot(idx) = mean(data_ot(data_ot(:,9)==i & data_ot(:,7)==1, 3));
    sesh_means_ot_e(idx) = mean(data_ot(data_ot(:,9)==i & data_ot(:,7)==2, 3));
end


sesh_means_first
sesh_means_mid
sesh_means_crit
sesh_means_ot

sesh_means_first_e
sesh_means_mid_e
sesh_means_crit_e
sesh_means_ot_e



plot_means = [mean(sesh_means_first) mean(sesh_means_mid) mean(sesh_means_crit) mean(sesh_means_ot)];
plot_ste = [std(sesh_means_first)/sqrt(length(first)) std(sesh_means_mid)/sqrt(length(mid)) std(sesh_means_crit)/sqrt(length(crit)) std(sesh_means_ot)/sqrt(length(ot))];

%plot_means_e = [nanmean(sesh_means_first_e) nanmean(sesh_means_mid_e) nanmean(sesh_means_crit_e) nanmean(sesh_means_ot_e)];
%plot_ste_e = [nanstd(sesh_means_first_e)/sqrt(sum(~isnan(sesh_means_first_e))) nanstd(sesh_means_mid_e)/sqrt(sum(~isnan(sesh_means_mid_e))) nanstd(sesh_means_crit_e)/sqrt(sum(~isnan(sesh_means_crit_e))) nanstd(sesh_means_ot_e)/sqrt(sum(~isnan(sesh_means_ot_e)))];


figure; hold on
%plot(1:4, plot_means, 'k')
%plot(1:4, plot_means_e, 'r')
errorbar(1:4, plot_means, plot_ste)
%errorbar(1:4, plot_means_e, plot_ste_e)


end