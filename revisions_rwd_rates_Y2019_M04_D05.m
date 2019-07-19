
% plot rates
[rr_out, rr_out_L, rr_out_R, subj_cell] = rwd_rates;
rr_out_3 = rr_out{3}(rr_out{3}~=max(rr_out{3}));
figure; errorbar_plot([rr_out(1:2) rr_out_3 rr_out(4)])
%hold on; errorbar_plot([rr_out_R(1:2) rr_out_3 rr_out_R(4)])

%means
%{
%prepare inputs
all_rates = cell2mat(rr_out');
all_stage = [ones(size(rr_out{1})); 2.*ones(size(rr_out{2})); 3.*ones(size(rr_out{3})); 4.*ones(size(rr_out{4}))];
all_subj = cell2mat(subj_cell');

%mixed model table
tbl = table(all_rates, all_stage, all_subj,'VariableNames',{'dv','stage','subject'});

% set predictors to categorical
tbl.stage = categorical(tbl.stage);
tbl.subject = categorical(tbl.subject);

%model
lme = fitlme(tbl,'dv~stage+(1|subject)+(stage-1|subject)');

% test stage coefs
r = [0,1,0,0; 0,0,1,0; 0,0,0,1];
[p, F, DF1, DF2] = coefTest(lme,r);
%}


%LR
%prepare inputs
all_rates = cell2mat([rr_out_L'; rr_out_R']);
all_location = [zeros(size(cell2mat(rr_out_L'))); ones(size(cell2mat(rr_out_R')))];
all_stage = [ones(size(rr_out{1})); 2.*ones(size(rr_out{2})); 3.*ones(size(rr_out{3})); 4.*ones(size(rr_out{4}))];
    all_stage = [all_stage;all_stage];
all_subj = cell2mat(subj_cell');
    all_subj = [all_subj;all_subj];

%mixed model table
tbl = table(all_rates, all_location, all_stage, all_subj,'VariableNames',{'dv','location', 'stage','subject'});

% set predictors to categorical
tbl.location = categorical(tbl.location);
tbl.stage = categorical(tbl.stage);
tbl.subject = categorical(tbl.subject);

%model
lme = fitlme(tbl,'dv~stage+location+(1|subject)+(stage-1|subject)+(location-1|subject)');

% test stage coefs
r = [0,0,1,0,0; 0,0,0,1,0; 0,0,0,0,1];
[p, F, DF1, DF2] = coefTest(lme,r);









