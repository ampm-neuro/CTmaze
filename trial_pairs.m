function [trl_idx, trl_lists] = trial_pairs(eptrials)
%sorts into odd-even PAIRS of correct trials.

%unique trials
unq_trl = unique(eptrials(:,5);

%concat type & accuracy
hold = nan(size(unq_trl,1), 2);
for i = 1:size(unq_trl,1)
    trl = unq_trl(i);
    hold(i,1:2) = mode(eptrials(eptrials(:,5)==trl, [7 8]));
end
unq_trl = [unq_trl hold];









end