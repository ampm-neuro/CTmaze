%function revisions_exp_vs_learn
% regression with two explanatory variables (# of sessions on maze & pct
% correct alternation) to predict Ipos and Reliability of individual cells.


%number of sessions (cols = accl, learn, ot)
%{
[~,sesh_cts_cell] = ALL_ct_sessions;

%pct_correct in each session (cell cols = learn, ot)
pct_correct = ALL_pct_correct;

%ipos for each cell in each session (cell cols = learn, ot)
[subj_cell_MIS, subj_cell_PosInfo] = ALL_MIS;

%learning stage
LS_cell = ALL_learning_stage_idx;

  %}  

%build matrix with 1 row per cell (cols = sesh ct, pct cor, mis, posinfo)
%
lin_model_input_mtx = [];
for isubj = 1:size(sesh_cts_cell,1)
    for ilearning_stage = 1:size(sesh_cts_cell,2)
        for isesh = 1:length(sesh_cts_cell{isubj,ilearning_stage})
            for iclust = 1:length(subj_cell_MIS{isubj,ilearning_stage}{isesh})
                 lin_model_input_mtx = [lin_model_input_mtx; ...
                     sesh_cts_cell{isubj, ilearning_stage}{isesh} pct_correct{isubj, ilearning_stage}{isesh}...
                     subj_cell_MIS{isubj,ilearning_stage}{isesh}(iclust) subj_cell_PosInfo{isubj,ilearning_stage}{isesh}(iclust)...
                     LS_cell{isubj, ilearning_stage}{isesh}];   
            end
        end
    end
end
%}

lin_model_input_mtx = lin_model_input_mtx(~isnan(sum(lin_model_input_mtx,2)),:);

%linear model with OT
%{
tbl_reliability_wOT = table(lin_model_input_mtx(:,1), lin_model_input_mtx(:,2), lin_model_input_mtx(:,3), 'VariableNames',{'NumberSessions','AlternationAccuracy','ReliabilityScore'}); 
lm_reliability_wOT = fitlm(tbl_reliability_wOT,'ReliabilityScore~NumberSessions+AlternationAccuracy','RobustOpts','on')
figure; plotResiduals(lm_reliability_wOT); title lm-reliability


tbl_posinfo_wOT = table(lin_model_input_mtx(:,1), lin_model_input_mtx(:,2), lin_model_input_mtx(:,4), 'VariableNames',{'NumberSessions','AlternationAccuracy','PosInfoScore'}); 
lm_posinfo_wOT = fitlm(tbl_posinfo_wOT,'PosInfoScore~NumberSessions+AlternationAccuracy','RobustOpts','on')
figure; plotResiduals(lm_posinfo_wOT); title lm-posinfo
%}

%linear model without OT
learn_idx = lin_model_input_mtx(:,5)==2;
tbl_reliability = table(lin_model_input_mtx(learn_idx,1), lin_model_input_mtx(learn_idx,2), lin_model_input_mtx(learn_idx,3), 'VariableNames',{'NumberSessions','AlternationAccuracy','ReliabilityScore'}); 
lm_reliability = fitlm(tbl_reliability,'ReliabilityScore~NumberSessions+AlternationAccuracy','RobustOpts','on')
figure; plotResiduals(lm_reliability); title lm-reliability

tbl_posinfo = table(lin_model_input_mtx(learn_idx,1), lin_model_input_mtx(learn_idx,2), lin_model_input_mtx(learn_idx,4), 'VariableNames',{'NumberSessions','AlternationAccuracy','PosInfoScore'}); 
lm_posinfo = fitlm(tbl_posinfo,'PosInfoScore~NumberSessions+AlternationAccuracy','RobustOpts','on')
figure; plotResiduals(lm_posinfo); title lm-posinfo


