function [all_class, all_posterior] = future_dec_linearized(rate_mtx_r, rate_mtx_l, sect_bins, tao)
%takes rate vectors at each position on R and L laps around the maze.
%Performs bayesian decoding on each spatial bin on the stem on each lap.
%Outcomes are averages with a lap and then between laps.

%isolate all test samples
comb_mtx_test = [rate_mtx_r; rate_mtx_l];
stem_mtx = comb_mtx_test(:, sect_bins(1):sect_bins(2), :);
stem_mtx = permute(stem_mtx, [2, 3, 1]);

%prepare training samples
rate_mtx_train_R = permute(rate_mtx_r, [2,3,1]); 
rate_mtx_train_L = permute(rate_mtx_l, [2,3,1]); 

%group IDs
group_train_R = 1:100;
group_train_L = 101:200;  

%stem spatial bins get same group ID on both L and R trials
group_train_L((sect_bins(1):sect_bins(2))+100) = sect_bins(1):sect_bins(2); 

%iterate through trials
all_class = nan((size(rate_mtx_r,1)+size(rate_mtx_l,1)),4);
all_posterior = [];
for itrial = 1:(size(rate_mtx_r,1)+size(rate_mtx_l,1))

    %stem samples from this trial
    sample_set = stem_mtx(:,:, itrial);
    
    %remove entire trial from training set
    if itrial <= size(rate_mtx_train_R,3)
        training_set = cat(3, rate_mtx_train_R(:,:,setdiff(1:size(rate_mtx_trial_R,1), itrial)), rate_mtx_train_L);
        group_ID = [repmat(group_train_R, length(setdiff(1:size(rate_mtx_trial_R,1), itrial)),1); repmat(group_train_L, size(rate_mtx_train_L,3),1)];
    else
        training_set = cat(3, rate_mtx_train_R, rate_mtx_train_L(:,:,setdiff(1:size(rate_mtx_trial_R,1), itrial-size(rate_mtx_train_R,3))));
        group_ID = [repmat(group_train_R, size(rate_mtx_train_R,3),1); repmat(group_train_L, length(setdiff(1:size(rate_mtx_trial_L,1), itrial-size(rate_mtx_train_R,3))),1)];
    end
    
    %decode all samples from this trial
    [class, posterior] = bayesian_decode(sample_set, reshape_pages(training_set), group_ID, tao);
   
    %load
    all_class(itrial, :) = class;
    all_posterior = cat(3, all_posterior, nanmean(posterior, 3));
    
end