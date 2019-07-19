function [comb_dec_stem_trl, CTLT] = ALL_p2(p_decodes, varargin)
% ALL_p2 takes the output from ALL_p1 (p_decodes aka
% unfolded_section_decodes), which is the time-point by time-point decoded 
% probabilities of the rat being located in each maze sector, and calculates 
% the trial by trial decoded probabilities (comb_dec_stem_trl). 
%
% comb_dec_stem_trl:
% includes indexing columns for trial number within the session, trial type
% (L/R), trial accuracy (C/E), how long the stem run took, and the session
% number. 
%
% cor_traj_like_trl:
% ALL_p2 also outputs the partially-redundant trial by trial computation
% cor_traj_like_trl (correct-trajectory-like trial), which is the
% probability that the rat was located in the left approach and rwd area (:,1)
% and the probability that it was located in the right approach area and 
% rwd area (:,2). The third column (:,3) contains the (:,1) - (:,2) for 
% go-left trials and (:,2) - (:,1) for go-right trials. The fourth column
% (:,4) contains how much larger the correct trajectory decode is than the 
% incorrect trajectory decode. That is (1 - ((:,1)/(:,2))) for rwd-left
% trials, and (1 - ((:,2)/(:,1))) for rwd-right trials.


%would you like to shuffle?
switch nargin
    case 1
        shuffle = 0;
    case 2
        shuffle = varargin{1};
    otherwise
        error('wrong number of inputs')
end

%preallocate
comb_dec_stem_trl = [];

for sesh = 1: size(p_decodes,1)

    %finish decoder
    [dec_stem_trl] = decodesection_shuffle_p2_CorErr(p_decodes{sesh}, shuffle);
    %add session number
    comb_dec_stem_trl = [comb_dec_stem_trl; [dec_stem_trl repmat(sesh, size(dec_stem_trl(:,1)))]];
  
end



%MAKE cor_traj_like_trl
%{
% columns:
%
% 1 p(L trajectory)
% 2 p(R trajectory)
% 3 p(trialtype trajectory) - p(~trialtype trajectory)
% 4 1 - p(trialtype trajectory)/p(~trialtype trajectory)
% 5 trial number within session
% 6 left or right trial type
% 7 correct or incurrect accuracy
% 8 stem run time
% 9 session number
%
%
%preallocate
cor_traj_like_trl = nan(size(comb_dec_stem_trl, 1), 9);

%p(L traj)
cor_traj_like_trl(:,1) = comb_dec_stem_trl(:,4) + comb_dec_stem_trl(:,6);

%p(R traj)
cor_traj_like_trl(:,2) = comb_dec_stem_trl(:,5) + comb_dec_stem_trl(:,7);

%p(trialtype trajectory) - p(~trialtype trajectory)
cor_traj_like_trl(comb_dec_stem_trl(:,11)==1, 3) = cor_traj_like_trl(comb_dec_stem_trl(:,11)==1,1) - cor_traj_like_trl(comb_dec_stem_trl(:,11)==1,2);
cor_traj_like_trl(comb_dec_stem_trl(:,11)==2, 3) = cor_traj_like_trl(comb_dec_stem_trl(:,11)==2,2) - cor_traj_like_trl(comb_dec_stem_trl(:,11)==2,1);

%proportionally greater
cor_traj_like_trl(comb_dec_stem_trl(:,11)==1, 4) = cor_traj_like_trl(comb_dec_stem_trl(:,11)==1,1)./cor_traj_like_trl(comb_dec_stem_trl(:,11)==1,2);
cor_traj_like_trl(comb_dec_stem_trl(:,11)==2, 4) = cor_traj_like_trl(comb_dec_stem_trl(:,11)==2,2)./cor_traj_like_trl(comb_dec_stem_trl(:,11)==2,1);

%trial number, type, accuracy, runtime, session number
cor_traj_like_trl(:,5:9) = comb_dec_stem_trl(:,10:14);
%}


%MAKE CTLT
CTLT = CTLT_builder(comb_dec_stem_trl);


end