


load('revisions_mixed_model_prep.mat')

% build tables
tbl_class_acc = table(class_acc_dv, class_acc_stage, class_acc_subj,'VariableNames',{'dv','stage','subject'});
    tbl_class_acc = tbl_class_acc(~any(ismissing(tbl_class_acc),2),:);
tbl_zdiff = table(zdiff_dv, zdiff_stage, zdiff_subj,'VariableNames',{'dv','stage','subject'});
tbl_rwd_rep_cull = table(rwd_rep_dv_all(rwd_rep_cull_idx), ftr_sim_stage(rwd_rep_cull_idx), ftr_sim_subj(rwd_rep_cull_idx),'VariableNames',{'dv','stage','subject'});
tbl_future_sim = table(ftr_sim_dv, ftr_sim_stage, ftr_sim_subj,'VariableNames',{'dv','stage','subject'});
tbl_future_sim_discrete = table(ftr_sim_dv_discrete, ftr_sim_stage, ftr_sim_subj,'VariableNames',{'dv','stage','subject'});
tbl_rwd_rep_discrete = table(rwd_rep_dv_all_discrete(rwd_rep_cull_idx), ftr_sim_stage(rwd_rep_cull_idx), ftr_sim_subj(rwd_rep_cull_idx),'VariableNames',{'dv','stage','subject'});

% set predictors to categorical
tbl_class_acc.stage = categorical(tbl_class_acc.stage);
tbl_class_acc.subject = categorical(tbl_class_acc.subject);
tbl_zdiff.stage = categorical(tbl_zdiff.stage);
tbl_zdiff.subject = categorical(tbl_zdiff.subject);
tbl_rwd_rep_cull.stage = categorical(tbl_rwd_rep_cull.stage);
tbl_rwd_rep_cull.subject = categorical(tbl_rwd_rep_cull.subject);
tbl_future_sim.stage = categorical(tbl_future_sim.stage);
tbl_future_sim.subject = categorical(tbl_future_sim.subject);
tbl_future_sim_discrete.stage = categorical(tbl_future_sim_discrete.stage);
tbl_future_sim_discrete.subject = categorical(tbl_future_sim_discrete.subject);
tbl_rwd_rep_discrete.stage = categorical(tbl_rwd_rep_discrete.stage);
tbl_rwd_rep_discrete.subject = categorical(tbl_rwd_rep_discrete.subject);

% models without stage
%lme_class_acc_partial = fitlme(tbl_class_acc,'dv~1+(1|subject)');
%lme_zdiff_partial = fitlme(tbl_zdiff,'dv~1+(1|subject)');
%lme_rwd_rep_cull_partial = fitlme(tbl_rwd_rep_cull,'dv~1+(1|subject)');
%lme_future_sim_partial = fitlme(tbl_future_sim,'dv~1+(1|subject)');

% models with stage
lme_class_acc = fitlme(tbl_class_acc,'dv~stage+(1|subject)+(stage-1|subject)');
lme_zdiff = fitlme(tbl_zdiff,'dv~stage+(1|subject)+(stage-1|subject)');
lme_rwd_rep_cull = fitlme(tbl_rwd_rep_cull,'dv~stage+(1|subject)+(stage-1|subject)');
lme_future_sim = fitlme(tbl_future_sim,'dv~stage+(1|subject)+(stage-1|subject)');
lme_future_sim_discrete = fitlme(tbl_future_sim_discrete,'dv~stage+(1|subject)+(stage-1|subject)');
lme_rwd_rep_discrete = fitlme(tbl_rwd_rep_discrete,'dv~stage+(1|subject)+(stage-1|subject)');

% test importance of stage coefs
r = [0,1,0,0; 0,0,1,0; 0,0,0,1];
[p_space, F_space, DF1_space, DF2_space] = coefTest(lme_class_acc,r);


% test importance of stage coefs
r = [0,1,0,0; 0,0,1,0; 0,0,0,1];
[p_zdiff, F_zdiff, DF1_zdiff, DF2_zdiff] = coefTest(lme_zdiff, r);


% test importance of stage coefs
r = [0,1,0,0; 0,0,1,0; 0,0,0,1];
[p_rwdrep, F_rwdrep, DF1_rwdrep, DF2_rwdrep] = coefTest(lme_rwd_rep_cull, r);


% test importance of stage coefs
r = [0,1,0,0; 0,0,1,0; 0,0,0,1];
[p_future, F_future, DF1_future, DF2_future] = coefTest(lme_future_sim, r);


% test importance of stage coefs
r = [0,1,0,0; 0,0,1,0; 0,0,0,1];
[p_future_discrete, F_future_discrete, DF1_future_discrete, DF2_future_discrete] = coefTest(lme_future_sim_discrete, r);


% test importance of stage coefs
r = [0,1,0,0; 0,0,1,0; 0,0,0,1];
[p_rwd_rep_discrete, F_rwd_rep_discrete, DF1_rwd_rep_discrete, DF2_rwd_rep_discrete] = coefTest(lme_rwd_rep_discrete, r);


