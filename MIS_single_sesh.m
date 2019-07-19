function [MIS_scores, PosInfo_scores] = MIS_single_sesh(eptrials, clusters, stem_runs)
%computes info scores measures (MIS and PosInfo) for a single session

%preallocate
MIS_scores = nan(size(clusters,1),1);
PosInfo_scores = nan(size(clusters,1),1);

for ic = 1:size(clusters,1)

    %paths' rates and dwell times
    [~, ~, times_in_all_bins, ~, ~, smoothed_rates_out, trltype_idx]...
                            = correllate_trialtypepaths(eptrials, stem_runs, 100, clusters(ic));

    times_in_all_bins = times_in_all_bins';

    smoothed_rates = [smoothed_rates_out{1} smoothed_rates_out{2}];
    dwell_times = [{times_in_all_bins(trltype_idx==1,:)}  {times_in_all_bins(trltype_idx==2,:)}];

    %compute scores and load
    MIS_scores(ic) = rev_mis_fn(smoothed_rates);
    PosInfo_scores(ic) = pos_info_shell(smoothed_rates, dwell_times);

end
