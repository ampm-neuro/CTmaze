function [dec_stem_trl] = decodesection_shuffle_p2_CorErr(unfolded_section_pdecode, shuffle) 
%This is part 2 of the shuffle compliment to decodesection_shuffle_p1
%
%This takes the timesample by timesample decoded probability of the rat
%being in each of the 10 maze sections plus indices (unfolded_section_pdecode)
%and outputs the (averaged) trial by trial decoded probability of the rat
%being in each of the 9 maze sections (stem is combined). The trial by 
%trial average only includes time samples from proper stem runs. It also 
%excludes the first (probe) trial. The output also includes indices: trial 
%number (:,10), trial type (L/R) (:,11), accuracy (C/E) (:,12), how long 
%the proper run took in seconds (:,13).
%
%Importantly, this also takes as input a 0 (no shuffle) or 1 (shuffle)
%value for input variable shuffle. To shuffle the data, each the L/R trial
%type is shuffled randomly for each whole trial (not individual time
%sample). Correct trials are shuffled amongst themselves and error trials
%are shuffled seperately amongst themselves to ensure that the same number
%of Ls and Rs among the correct trials and among the error trials.


%remove first (probe) trial from data set
unfolded_section_pdecode(:, 11) = unfolded_section_pdecode(:, 11) - ones(size(unfolded_section_pdecode(:, 11)));
unfolded_section_pdecode(unfolded_section_pdecode(:,11)==0,:) = [];

%ensure that decoder proportions add to 1
for row = 1:size(unfolded_section_pdecode, 1)
    unfolded_section_pdecode(row, 1:10) = unfolded_section_pdecode(row, 1:10)./sum(unfolded_section_pdecode(row, 1:10));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SHUFFLE TRIAL TYPE (INDEPENDENTLY FOR CORRECT AND ERROR TRIALS)%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%index out trials and types
trials = unfolded_section_pdecode(:,11);
types = unfolded_section_pdecode(:,13);
accuracy = unfolded_section_pdecode(:,14);

%black magic to make trials_n_types = [unique(trials) types]
[trials idx] = unique(trials);
types = types(idx);
accuracy = accuracy(idx);
trials_n_types = [trials types];
trials_n_types_cor = trials_n_types(accuracy==1, :);
trials_n_types_err = trials_n_types(accuracy==2, :);

%shuffle trials (1=Y 0=N)
if shuffle == 1
    %shuffle
    trials_n_types_shuf_cor = [trials_n_types_cor(:,1) randsample(trials_n_types_cor(:,2), length(trials_n_types_cor(:,2)))];
    trials_n_types_shuf_err = [trials_n_types_err(:,1) randsample(trials_n_types_err(:,2), length(trials_n_types_err(:,2)))];
elseif shuffle == 0 
    %don't shuffle
    trials_n_types_shuf_cor = trials_n_types_cor;
    trials_n_types_shuf_err = trials_n_types_err;
end

%recombine error and correct trials
trials_n_types_shuf = sortrows([trials_n_types_shuf_cor; trials_n_types_shuf_err]);

%update unfolded_section_pdecode (there is probably a 1-line method)
unfolded_section_pdecode(ismember(unfolded_section_pdecode(:,11),trials_n_types_shuf(trials_n_types_shuf(:,2)==1,1)),13) = 1;
unfolded_section_pdecode(ismember(unfolded_section_pdecode(:,11),trials_n_types_shuf(trials_n_types_shuf(:,2)==2,1)),13) = 2;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%~~~averaging the decoding occuring on the true stem run individually for each trial
num_trials = length(unique(unfolded_section_pdecode(:, 11)));
dec_stem_trl = nan(num_trials, 10);%preallocate
for trial = 1:num_trials
    dec_stem_trl(trial, :) = mean(unfolded_section_pdecode(unfolded_section_pdecode(:,11)==trial & unfolded_section_pdecode(:,16)==1, 1:10));
end

%combine stem
dec_stem_trl(:, 2) = dec_stem_trl(:, 2) + dec_stem_trl(:, 3);
dec_stem_trl(:, 3) = [];

%add indices
dec_stem_trl(:, 10) = trials_n_types_shuf(:,1);
dec_stem_trl(:, 11) = trials_n_types_shuf(:,2);

dec_stem_trl(:, 12) = accuracy;
    %each run time
    [~, i] = unique(unfolded_section_pdecode(:,11), 'first'); %idx for first of each trial
dec_stem_trl(:, 13) = unfolded_section_pdecode(i,15); %use idx to get one (first) of each run time
%}

end

