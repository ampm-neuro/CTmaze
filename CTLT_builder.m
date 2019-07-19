function [CTLTot] = CTLT_builder(comb_dec_stem_trl_ot)%comb_dec_stem_trl_cont, CTLTcont 

%builds CTLT matrices containing many looks at the decoded probability
%sums.
%
%col 1 = decode to future choice arm
%col 2 = decode to not_future choice arm
%col 3 = decode to future reward location
%col 4 = decode to not_future reward location
%col 5 = decode to future return arm
%col 6 = decode to not_future return arm
%
%col 7 = future choice - not_future choice
%col 8 = future reward - not_future reward
%col 9 = future return - not_future return
%
%col 10 = trial number within session
%col 11 = trial type: 1 for go left 2 for go right 
%col 12 = accuracy: 1 for correct 2 for error 
%col 13 = stem run time
%col 14 = session number
%
%col 15 = trajectory to future traj (col 1 + col 3)
%col 16 = trajectory to not_future traj (col 2 + col 4)
%col 17 = future trajectory - not_future trajectory

col_total = 17;

%preallocate
%CTLTcont = nan([size(comb_dec_stem_trl_cont,1) col_total]);
CTLTot = nan([size(comb_dec_stem_trl_ot,1) col_total]);

  
%cols 1 3 and 5 (future)
    %cont
    %CTLTcont(comb_dec_stem_trl_cont(:,11)==1, [1 3 5]) = comb_dec_stem_trl_cont(comb_dec_stem_trl_cont(:,11)==1, [4 6 8]);
    %CTLTcont(comb_dec_stem_trl_cont(:,11)==2, [1 3 5]) = comb_dec_stem_trl_cont(comb_dec_stem_trl_cont(:,11)==2, [5 7 9]);
    %ot
    CTLTot(comb_dec_stem_trl_ot(:,11)==1, [1 3 5]) = comb_dec_stem_trl_ot(comb_dec_stem_trl_ot(:,11)==1, [4 6 8]);
    CTLTot(comb_dec_stem_trl_ot(:,11)==2, [1 3 5]) = comb_dec_stem_trl_ot(comb_dec_stem_trl_ot(:,11)==2, [5 7 9]);


%cols 2 4 and 6 (not future)
    %cont
    %CTLTcont(comb_dec_stem_trl_cont(:,11)==1, [2 4 6]) = comb_dec_stem_trl_cont(comb_dec_stem_trl_cont(:,11)==1, [5 7 9]);
    %CTLTcont(comb_dec_stem_trl_cont(:,11)==2, [2 4 6]) = comb_dec_stem_trl_cont(comb_dec_stem_trl_cont(:,11)==2, [4 6 8]);
    %ot
    CTLTot(comb_dec_stem_trl_ot(:,11)==1, [2 4 6]) = comb_dec_stem_trl_ot(comb_dec_stem_trl_ot(:,11)==1, [5 7 9]);
    CTLTot(comb_dec_stem_trl_ot(:,11)==2, [2 4 6]) = comb_dec_stem_trl_ot(comb_dec_stem_trl_ot(:,11)==2, [4 6 8]);

    
%col 7 8 9
%CTLTcont(:,7:9) = CTLTcont(:,[1 3 5]) - CTLTcont(:,[2 4 6]);
CTLTot(:,7:9) = CTLTot(:,[1 3 5]) - CTLTot(:,[2 4 6]);

%col 10 11 12 13 14
%CTLTcont(:,10:14) = comb_dec_stem_trl_cont(:,10:14);
CTLTot(:,10:14) = comb_dec_stem_trl_ot(:,10:14);

%col 15 16
    %cont
    %CTLTcont(:,15) = CTLTcont(:,1) + CTLTcont(:,3);
    %CTLTcont(:,16) = CTLTcont(:,2) + CTLTcont(:,4);
    %ot
    CTLTot(:,15) = CTLTot(:,1) + CTLTot(:,3);
    CTLTot(:,16) = CTLTot(:,2) + CTLTot(:,4);
    
%col 17
%CTLTcont(:,17) = CTLTcont(:,15) - CTLTcont(:,16);
CTLTot(:,17) = CTLTot(:,15) - CTLTot(:,16);







end