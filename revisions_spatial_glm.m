bins = 50;
[pvals_early, Fstats_early, varnames_early] = space_glm(2.1,bins);
[pvals_mid, Fstats_mid, varnames_mid] = space_glm(2.2,bins);
[pvals_late, Fstats_late, varnames_late] = space_glm(2.3,bins);
[pvals_ot, Fstats_ot, varnames_ot] = space_glm(4.0,bins);

%figures
figure; bar([sum(pvals_early<0.05)/length(pvals_early) sum(pvals_mid<0.05)/length(pvals_mid) sum(pvals_late<0.05)/length(pvals_late) sum(pvals_ot<0.05)/length(pvals_ot)])
figure; errorbar_plot([{Fstats_early} {Fstats_mid} {Fstats_late} {Fstats_ot}])

% pval the change in f stats
shuf_out_f_obs = shuffle_grps_props(0, [{Fstats_early} {Fstats_mid} {Fstats_late} {Fstats_ot}]);
shuf_out_f = shuffle_grps_props(10000, [{Fstats_early} {Fstats_mid} {Fstats_late} {Fstats_ot}]);
shuf_pval = sum(shuf_out_f>=shuf_out_f_obs)/length(shuf_out_f)

