%get rates
%ALL_keytimes has important modification options, such as min number of
%trials, including or not stem runs, etc.
%{
[stem_rates_21, rwd_rates_21, ID_idx_21] = ALL_keytimes_LR(2.1);
[stem_rates_22, rwd_rates_22, ID_idx_22] = ALL_keytimes_LR(2.2);
[stem_rates_23, rwd_rates_23, ID_idx_23] = ALL_keytimes_LR(2.3);
[stem_rates_4, rwd_rates_4, ID_idx_4] = ALL_keytimes_LR(4);
%}

%
%pct_corr_pctbounds = [0.8400 0.8800; 0.881 0.92; 0.921 0.96; 0.961 1.0000];
[stem_rates_21, rwd_rates_21, ID_idx_21] = ALL_keytimes_LR_err(4, 1);
[stem_rates_22, rwd_rates_22, ID_idx_22] = ALL_keytimes_LR_err(4, 2);
[stem_rates_23, rwd_rates_23, ID_idx_23] = ALL_keytimes_LR_err(4, 3);
[stem_rates_4, rwd_rates_4, ID_idx_4] = ALL_keytimes_LR_err(4, 4);
%}

%zscore everything (remove nan columns)
%{
z_smr_21 = zscore_mtx(stem_rates_21); z_smr_21 = z_smr_21(:, ~isnan(z_smr_21(1,:)));
z_smr_22 = zscore_mtx(stem_rates_22); z_smr_22 = z_smr_22(:, ~isnan(z_smr_22(1,:)));
z_smr_23 = zscore_mtx(stem_rates_23); z_smr_23 = z_smr_23(:, ~isnan(z_smr_23(1,:)));
z_smr_4 = zscore_mtx(stem_rates_4); z_smr_4 = z_smr_4(:, ~isnan(z_smr_4(1,:)));
z_rmr_21 = zscore_mtx(rwd_rates_21); z_rmr_21 = z_rmr_21(:, ~isnan(z_rmr_21(1,:)));
z_rmr_22 = zscore_mtx(rwd_rates_22); z_rmr_22 = z_rmr_22(:, ~isnan(z_rmr_22(1,:)));
z_rmr_23 = zscore_mtx(rwd_rates_23); z_rmr_23 = z_rmr_23(:, ~isnan(z_rmr_23(1,:)));
z_rmr_4 = zscore_mtx(rwd_rates_4); z_rmr_4 = z_rmr_4(:, ~isnan(z_rmr_4(1,:)));
%} 
z_smr_21 = zscore_mtx(stem_rates_21); 
z_smr_22 = zscore_mtx(stem_rates_22); 
z_smr_23 = zscore_mtx(stem_rates_23); 
z_smr_4 = zscore_mtx(stem_rates_4); 
z_rmr_21 = zscore_mtx(rwd_rates_21); 
z_rmr_22 = zscore_mtx(rwd_rates_22); 
z_rmr_23 = zscore_mtx(rwd_rates_23); 
z_rmr_4 = zscore_mtx(rwd_rates_4);

nnanidx21 = ~isnan(z_smr_21(1,:)) & ~isnan(z_rmr_21(1,:));
nnanidx22 = ~isnan(z_smr_22(1,:)) & ~isnan(z_rmr_22(1,:));
nnanidx23 = ~isnan(z_smr_23(1,:)) & ~isnan(z_rmr_23(1,:));
nnanidx4 = ~isnan(z_smr_4(1,:)) & ~isnan(z_rmr_4(1,:));



z_smr_21 = z_smr_21(:, nnanidx21);
z_smr_22 = z_smr_22(:, nnanidx22);
z_smr_23 = z_smr_23(:, nnanidx23);
z_smr_4 = z_smr_4(:, nnanidx4);
z_rmr_21 = z_rmr_21(:, nnanidx21);
z_rmr_22 = z_rmr_22(:, nnanidx22);
z_rmr_23 = z_rmr_23(:, nnanidx23);
 z_rmr_4 = z_rmr_4(:, nnanidx4);
 
%classify

%rwddisttest
rdt1 = mean(z_rmr_21(ID_idx_21==1,:));
rdt2 = mean(z_rmr_21(ID_idx_21==2,:));

[s_p_correct_21, s_assignments_21, s_distances_21] = md_classify(z_smr_21, ID_idx_21, mean(z_rmr_21(ID_idx_21==1,:)), mean(z_rmr_21(ID_idx_21==2,:)));
[s_p_correct_22, s_assignments_22, s_distances_22] = md_classify(z_smr_22, ID_idx_22, mean(z_rmr_22(ID_idx_22==1,:)), mean(z_rmr_22(ID_idx_22==2,:)));
[s_p_correct_23, s_assignments_23, s_distances_23] = md_classify(z_smr_23, ID_idx_23, mean(z_rmr_23(ID_idx_23==1,:)), mean(z_rmr_23(ID_idx_23==2,:)));
[s_p_correct_4, s_assignments_4, s_distances_4] = md_classify(z_smr_4, ID_idx_4, mean(z_rmr_4(ID_idx_4==1,:)), mean(z_rmr_4(ID_idx_4==2,:)));
[r_p_correct_21, r_assignments_21, r_distances_21] = md_classify(z_rmr_21, ID_idx_21,mean(z_rmr_21(ID_idx_21==1,:)), mean(z_rmr_21(ID_idx_21==2,:)));
[r_p_correct_22, r_assignments_22, r_distances_22] = md_classify(z_rmr_22, ID_idx_22, mean(z_rmr_22(ID_idx_22==1,:)), mean(z_rmr_22(ID_idx_22==2,:)));
[r_p_correct_23, r_assignments_23, r_distances_23] = md_classify(z_rmr_23, ID_idx_23, mean(z_rmr_23(ID_idx_23==1,:)), mean(z_rmr_23(ID_idx_23==2,:)));
[r_p_correct_4, r_assignments_4, r_distances_4] = md_classify(z_rmr_4, ID_idx_4, mean(z_rmr_4(ID_idx_4==1,:)), mean(z_rmr_4(ID_idx_4==2,:)));

%trial-type specificity

%preallocate
s_tts_21 = nan(size(ID_idx_21));
s_tts_22 = nan(size(ID_idx_22));
s_tts_23 = nan(size(ID_idx_23));
s_tts_4 = nan(size(ID_idx_4));
r_tts_21 = nan(size(ID_idx_21));
r_tts_22 = nan(size(ID_idx_22));
r_tts_23 = nan(size(ID_idx_23));
r_tts_4 = nan(size(ID_idx_4));



%change lefts and right tt to correct and incorrect tt
%
s_distances_21(ID_idx_21==2, [1 2]) = s_distances_21(ID_idx_21==2, [2 1]);
s_distances_22(ID_idx_22==2, [1 2]) = s_distances_22(ID_idx_22==2, [2 1]);
s_distances_23(ID_idx_23==2, [1 2]) = s_distances_23(ID_idx_23==2, [2 1]);
s_distances_4(ID_idx_4==2, [1 2]) = s_distances_4(ID_idx_4==2, [2 1]);
r_distances_21(ID_idx_21==2, [1 2]) = r_distances_21(ID_idx_21==2, [2 1]);
r_distances_22(ID_idx_22==2, [1 2]) = r_distances_22(ID_idx_22==2, [2 1]);
r_distances_23(ID_idx_23==2, [1 2]) = r_distances_23(ID_idx_23==2, [2 1]);
r_distances_4(ID_idx_4==2, [1 2]) = r_distances_4(ID_idx_4==2, [2 1]);
%}

%calculate trial type specificity
s_tts_21 = diff(s_distances_21, [], 2) ./ sum(s_distances_21, 2);
s_tts_22 = diff(s_distances_22, [], 2) ./ sum(s_distances_22, 2);
s_tts_23 = diff(s_distances_23, [], 2) ./ sum(s_distances_23, 2);
s_tts_4 = diff(s_distances_4, [], 2) ./ sum(s_distances_4, 2);
r_tts_21 = diff(r_distances_21, [], 2) ./ sum(r_distances_21, 2);
r_tts_22 = diff(r_distances_22, [], 2) ./ sum(r_distances_22, 2);
r_tts_23 = diff(r_distances_23, [], 2) ./ sum(r_distances_23, 2);
r_tts_4 = diff(r_distances_4, [], 2) ./ sum(r_distances_4, 2);

%prep error bar plot
s_cell{1} = s_tts_21;
s_cell{2} = s_tts_22;
s_cell{3} = s_tts_23;
s_cell{4} = s_tts_4;
r_cell{1} = r_tts_21;
r_cell{2} = r_tts_22;
r_cell{3} = r_tts_23;
r_cell{4} = r_tts_4;

%plot tts
errorbar_plot(s_cell); title('stem trial-type specificity');
hold on; plot([0 5] , [0 0], 'k--'); ylim([-.1 inf])
errorbar_plot(r_cell); title('reward trial-type specificity');
hold on; plot([0 5] , [0 0], 'k--'); ylim([-.1 inf])

%dot figure prep
mkrsize = 25;
colors = ([...
0.15 0.15 0.15;
0.3 0.3 0.3;
0.7 0.7 0.7;
0.85 0.85 0.85;
]);

%dot plots
figure; axis([.7 1.5 .7 1.5]); title stem; hold on; axis square
plot(s_distances_21(:,1), s_distances_21(:,2), '.', 'markersize', mkrsize, 'color', colors(1, :))
plot(s_distances_22(:,1), s_distances_22(:,2), '.', 'markersize', mkrsize, 'color', colors(2, :))
plot(s_distances_23(:,1), s_distances_23(:,2), '.', 'markersize', mkrsize, 'color', colors(3, :))
plot(s_distances_4(:,1), s_distances_4(:,2), '.', 'markersize', mkrsize, 'color', colors(4, :))
plot(mean(s_distances_21(:,1)), mean(s_distances_21(:,2)), '.', 'markersize', mkrsize*3, 'color', colors(1, :))
plot(mean(s_distances_22(:,1)), mean(s_distances_22(:,2)), '.', 'markersize', mkrsize*3, 'color', colors(2, :))
plot(mean(s_distances_23(:,1)), mean(s_distances_23(:,2)), '.', 'markersize', mkrsize*3, 'color', colors(3, :))
plot(mean(s_distances_4(:,1)), mean(s_distances_4(:,2)), '.', 'markersize', mkrsize*3, 'color', colors(4, :))
plot([-1 2], [-1 2], 'k--')

figure; axis([.5 1.8 .5 1.8]); title reward; hold on; axis square 
plot(r_distances_21(:,1), r_distances_21(:,2), '.', 'markersize', mkrsize, 'color', colors(1, :))
plot(r_distances_22(:,1), r_distances_22(:,2), '.', 'markersize', mkrsize, 'color', colors(2, :))
plot(r_distances_23(:,1), r_distances_23(:,2), '.', 'markersize', mkrsize, 'color', colors(3, :))
plot(r_distances_4(:,1), r_distances_4(:,2), '.', 'markersize', mkrsize, 'color', colors(4, :))
plot(mean(r_distances_21(:, 1)), mean(r_distances_21(:, 2)), '.', 'markersize', mkrsize*3, 'color', colors(1, :))
plot(mean(r_distances_22(:, 1)), mean(r_distances_22(:, 2)), '.', 'markersize', mkrsize*3, 'color', colors(2, :))
plot(mean(r_distances_23(:, 1)), mean(r_distances_23(:, 2)), '.', 'markersize', mkrsize*3, 'color', colors(3, :))
plot(mean(r_distances_4(:, 1)), mean(r_distances_4(:, 2)), '.', 'markersize', mkrsize*3, 'color', colors(4, :))
plot([-1 2], [-1 2], 'k--')
    






