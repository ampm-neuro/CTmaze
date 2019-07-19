%load('revisions_alternate_spacedecode_shuf')
% also see: temp_decode_script

figure; hold on


%
% preallocate
obs_class = cell(1,4); % observed classification accuracies

% iterate through each session computing proportion accurate decodes
%

%minimum of ten cell pop size
load('pop_size_cell_counts')

% early
%obs_class{1} = 1./all_decode_vars_21{4}(:,5);
obs_class{1} = 1./all_decode_vars_21{4}(cell_counts{1}>=10,5);

%{
for isesh = unique(all_decode_vars_21{5}(:,5))'
    sesh_idx = all_decode_vars_21{5}(:,5)==isesh;
    dist_btwn_obs_and_true_pos = iter_lin_dist([50,50], all_decode_vars_21{5}(sesh_idx,4), all_decode_vars_21{20}(sesh_idx));
    dist_btwn_obs_and_true_pos = dist_btwn_obs_and_true_pos(~isnan(dist_btwn_obs_and_true_pos));
    obs_class{1} = [obs_class{1}; sum(dist_btwn_obs_and_true_pos<7)/length(dist_btwn_obs_and_true_pos)]; 
end
%}

% middle
%obs_class{2} = 1./all_decode_vars_22{4}(:,5);
obs_class{2} = 1./all_decode_vars_22{4}(cell_counts{2}>=10,5);
%{
for isesh = unique(all_decode_vars_22{5}(:,5))'
    sesh_idx = all_decode_vars_22{5}(:,5)==isesh;
    dist_btwn_obs_and_true_pos = iter_lin_dist([50,50], all_decode_vars_22{5}(sesh_idx,4), all_decode_vars_22{20}(sesh_idx));
    dist_btwn_obs_and_true_pos = dist_btwn_obs_and_true_pos(~isnan(dist_btwn_obs_and_true_pos));
    obs_class{2} = [obs_class{2}; sum(dist_btwn_obs_and_true_pos<7)/length(dist_btwn_obs_and_true_pos)]; 
end
%}

% late
%obs_class{3} = 1./all_decode_vars_23{4}(:,5);
obs_class{3} = 1./all_decode_vars_23{4}(cell_counts{3}>=10,5);
%{
for isesh = unique(all_decode_vars_23{5}(:,5))'
    sesh_idx = all_decode_vars_23{5}(:,5)==isesh;
    dist_btwn_obs_and_true_pos = iter_lin_dist([50,50], all_decode_vars_23{5}(sesh_idx,4), all_decode_vars_23{20}(sesh_idx));
    dist_btwn_obs_and_true_pos = dist_btwn_obs_and_true_pos(~isnan(dist_btwn_obs_and_true_pos));
    obs_class{3} = [obs_class{3}; sum(dist_btwn_obs_and_true_pos<7)/length(dist_btwn_obs_and_true_pos)];
end
%}

% ot
%obs_class{4} = 1./all_decode_vars_4{4}(:,5);
obs_class{4} = 1./all_decode_vars_4{4}(cell_counts{4}>=10 & logical([1 1 1 1 1 1 1 1 1 1 1 0 1 1 1])',5);
%{
for isesh = unique(all_decode_vars_4{5}(:,5))'
    sesh_idx = all_decode_vars_4{5}(:,5)==isesh;
    dist_btwn_obs_and_true_pos = iter_lin_dist([50,50], all_decode_vars_4{5}(sesh_idx,4), all_decode_vars_4{20}(sesh_idx));
    dist_btwn_obs_and_true_pos = dist_btwn_obs_and_true_pos(~isnan(dist_btwn_obs_and_true_pos));
    obs_class{4} = [obs_class{4}; sum(dist_btwn_obs_and_true_pos<7)/length(dist_btwn_obs_and_true_pos)]; 
end
%}

%means and ses
obs_means = [mean(obs_class{1}) mean(obs_class{2}) mean(obs_class{3}) mean(obs_class{4})];
obs_std = [std(obs_class{1}) std(obs_class{2}) std(obs_class{3}) std(obs_class{4})];
obs_ses = obs_std./sqrt([length(obs_class{1}) length(obs_class{2}) length(obs_class{3}) length(obs_class{4})]);



%plot obs
for istg = 1:4
   plot(istg, obs_class{istg},'o', 'color', 0.7.*[1 1 1]) 
end
errorbar(obs_means, obs_ses, 'k-', 'linewidth', 2)

xlim([.5 4.5])
set(gca,'TickLength',[0, 0]); box off;



%compute all shuffle accuracy proportions
%
shufs_21 = all_decode_vars_21{6};
shufs_22 = all_decode_vars_22{6};
shufs_23 = all_decode_vars_23{6};
shufs_4 = all_decode_vars_4{6};

% min 20 cells cell_counts{4}>=10
shufs_21 = shufs_21(cell_counts{1}>=10,:);
shufs_22 = shufs_22(cell_counts{2}>=10,:);
shufs_23 = shufs_23(cell_counts{3}>=10,:);
shufs_4 = shufs_4(cell_counts{4}>=10 & logical([1 1 1 1 1 1 1 1 1 1 1 0 1 1 1])',:);

% means of each shuffled session
all_shuf_props_21_mean = mean(shufs_21,1);
all_shuf_props_22_mean = mean(shufs_23,1);
all_shuf_props_23_mean = mean(shufs_23,1);
all_shuf_props_4_mean = mean(shufs_4,1);

% sort
all_shuf_props_21_mean = sort(all_shuf_props_21_mean);
all_shuf_props_22_mean = sort(all_shuf_props_22_mean);
all_shuf_props_23_mean = sort(all_shuf_props_23_mean);
all_shuf_props_4_mean = sort(all_shuf_props_4_mean);

%drop 5 percent
all_shuf_props_21_mean = all_shuf_props_21_mean(25:975);
all_shuf_props_22_mean = all_shuf_props_22_mean(25:975);
all_shuf_props_23_mean = all_shuf_props_23_mean(25:975);
all_shuf_props_4_mean = all_shuf_props_4_mean(25:975);


%{
num_shufs = size(all_decode_vars_4{9},2);

% early
all_shuf_props_21 = nan(length(unique(all_decode_vars_21{5}(:,5))), num_shufs); % sesh, shuf
for ishuf = 1:num_shufs
    for isesh = unique(all_decode_vars_21{5}(:,5))'
        sesh_idx = all_decode_vars_21{5}(:,5)==isesh;
        dist_btwn_shuf_and_true_pos = iter_lin_dist([50,50], all_decode_vars_21{9}(sesh_idx,ishuf), all_decode_vars_21{20}(sesh_idx));
        dist_btwn_shuf_and_true_pos = dist_btwn_shuf_and_true_pos(~isnan(dist_btwn_shuf_and_true_pos));
        all_shuf_props_21(isesh,ishuf) = sum(dist_btwn_shuf_and_true_pos<7)/length(dist_btwn_shuf_and_true_pos); 
    end
end

% middle
all_shuf_props_22 = nan(length(unique(all_decode_vars_22{5}(:,5))), num_shufs); % sesh, shuf
for ishuf = 1:num_shufs
    for isesh = unique(all_decode_vars_22{5}(:,5))'
        sesh_idx = all_decode_vars_22{5}(:,5)==isesh;
        dist_btwn_shuf_and_true_pos = iter_lin_dist([50,50], all_decode_vars_22{9}(sesh_idx,ishuf), all_decode_vars_22{20}(sesh_idx));
        dist_btwn_shuf_and_true_pos = dist_btwn_shuf_and_true_pos(~isnan(dist_btwn_shuf_and_true_pos));
        all_shuf_props_22(isesh,ishuf) = sum(dist_btwn_shuf_and_true_pos<7)/length(dist_btwn_shuf_and_true_pos); 
    end
end

% late
all_shuf_props_23 = nan(length(unique(all_decode_vars_23{5}(:,5))), num_shufs); % sesh, shuf
for ishuf = 1:num_shufs
    for isesh = unique(all_decode_vars_23{5}(:,5))'
        sesh_idx = all_decode_vars_23{5}(:,5)==isesh;
        dist_btwn_shuf_and_true_pos = iter_lin_dist([50,50], all_decode_vars_23{9}(sesh_idx,ishuf), all_decode_vars_23{20}(sesh_idx));
        dist_btwn_shuf_and_true_pos = dist_btwn_shuf_and_true_pos(~isnan(dist_btwn_shuf_and_true_pos));
        all_shuf_props_23(isesh,ishuf) = sum(dist_btwn_shuf_and_true_pos<7)/length(dist_btwn_shuf_and_true_pos); 
    end
end

% ot
all_shuf_props_4 = nan(length(unique(all_decode_vars_4{5}(:,5))), num_shufs); % sesh, shuf
for ishuf = 1:num_shufs
    for isesh = unique(all_decode_vars_4{5}(:,5))'
        sesh_idx = all_decode_vars_4{5}(:,5)==isesh;
        dist_btwn_shuf_and_true_pos = iter_lin_dist([50,50], all_decode_vars_4{9}(sesh_idx,ishuf), all_decode_vars_4{20}(sesh_idx));
        dist_btwn_shuf_and_true_pos = dist_btwn_shuf_and_true_pos(~isnan(dist_btwn_shuf_and_true_pos));
        all_shuf_props_4(isesh,ishuf) = sum(dist_btwn_shuf_and_true_pos<7)/length(dist_btwn_shuf_and_true_pos); 
    end
end
%}



% compute means and extremes of shuffled distribution
shuf_means = [mean(all_shuf_props_21_mean) mean(all_shuf_props_22_mean) mean(all_shuf_props_23_mean) mean(all_shuf_props_4_mean)];
shuf_mins = [min(all_shuf_props_21_mean) min(all_shuf_props_22_mean) min(all_shuf_props_23_mean) min(all_shuf_props_4_mean)];
shuf_maxs = [max(all_shuf_props_21_mean) max(all_shuf_props_22_mean) max(all_shuf_props_23_mean) max(all_shuf_props_4_mean)];

%xpos = [0.5:1:4.5];
xpos = [0.8 1.2 1.8 2.2 2.8 3.2 3.8 4.2];
yidx = [1 1 2 2 3 3 4 4];
plot(xpos, shuf_means(yidx), 'k--')
plot(xpos, shuf_mins(yidx), 'k-')
plot(xpos, shuf_maxs(yidx), 'k-')

%compute pval shuffle anova
obs_mse = shuffle_grps_props(0, obs_class);
shuf_mses = shuffle_grps_props(1000, obs_class);

title(['shuf pval = ' num2str(sum(shuf_mses>=obs_mse)/length(shuf_mses))])



%linear effects mixed model
class_acc_dv = cell2mat(obs_class');
class_acc_stage = [ones(length(obs_class{1}),1); ones(length(obs_class{2}),1).*2; ones(length(obs_class{3}),1).*3; ones(length(obs_class{4}),1).*4];
class_acc_subj = [all_decode_vars_21{4}(:,1); all_decode_vars_22{4}(:,1); all_decode_vars_23{4}(:,1); all_decode_vars_4{4}(:,1)]; 




