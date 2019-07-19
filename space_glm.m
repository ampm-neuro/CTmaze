function [pvals_all, Fstats_all, varnames] = space_glm(stage, bins)
% Iterate through sessions. Assign all time points to spatial bins on
% a linearized maze, compute mean velocity, angular velocity, HD, and FR at
% each bin one each trial. Perform a GLM to identify influence of spatial 
% bin and each egocentric variable on FR for each cell.
%
% try 50, 100, 170 bins

%output
pvals_all = [];
Fstats_all = [];

% get all files
filepath = 'C:\Users\ampm1\Desktop\oldmatlab\neurodata';
session_paths = get_file_paths(filepath);
session_paths = session_paths(contains(session_paths, '\1'));

% constrain by stage
if stage==4
    session_type = 'overtraining';
    session_paths = session_paths(contains(session_paths, session_type));
elseif floor(stage)==2
    session_type = 'continuous';
    session_paths = session_paths(contains(session_paths, session_type));
    
    all_subjs_lo = length(filepath) + 2;
    all_subjs_hi = all_subjs_lo + 3;
    all_subjs = []; 
    count =0;
    for ifile=1:size(session_paths,1)
        count = count+1;
        all_subjs{count} = session_paths{ifile}(all_subjs_lo:all_subjs_hi);
    end

    all_sessions = cell(1); 
    count = 0;
    for ifile=1:size(session_paths,1)
        count = count+1;
        all_session_lo = strfind(session_paths{ifile}, session_type) + length(session_type) + 1;
        all_session_hi = strfind(session_paths{ifile}, '.') - 1;
        all_sessions{count} = session_paths{ifile}(all_session_lo:all_session_hi);
    end

    % constrained sessions
    session_paths_hold = [];
    for unq_subj = unique(all_subjs)
        subj_sesh_paths = session_paths(contains(session_paths, unq_subj));
        sesh_idx = first_mid_last(size(subj_sesh_paths,1),stage,0);
        if ~isnan(sesh_idx)
            subj_sesh_paths = subj_sesh_paths(sesh_idx);
            session_paths_hold = [session_paths_hold; subj_sesh_paths];
        end
        
    end
    session_paths = session_paths_hold; 
end

%print
session_paths = session_paths

% iterate through sessions
for isesh = 1%:length(session_paths)
    disp(session_paths{isesh})
   
    % load session 
    load(session_paths{isesh}, 'eptrials', 'clusters')
   
   % clusters
   clusts = clusters(clusters(:,2)>=3,1);

   % linearized position (spatial bin) column
   lin_pos_col = linearize_pos(eptrials, bins); 

   % velocity column
   velocity_col = vid_velocity(eptrials);

   % accleration column
   accl_column = vid_acceleration(eptrials, velocity_col);

   % angular velocity column
   angvel_column = vid_angvelocity(eptrials);

   % all trials
   unq_trials = unique(eptrials(:,5));
   num_trials = length(unq_trials);

   % preallocate trial vectors
   mVels = nan(num_trials, bins);
   mAccls = nan(num_trials, bins);
   mAngVels = nan(num_trials, bins);
   mHDs = nan(num_trials, bins);
   mFRs = nan(num_trials, bins, length(clusts));
   
   % iterate through trials
   for itrl = 1:num_trials
       current_trial = unq_trials(itrl);
       trl_idx = eptrials(:,5)==current_trial;
       
       % iterate through bins
       for ibin = 1:bins
           bin_idx = lin_pos_col==ibin;
       
           % mean velocity in each spatial bin (by trial)
           mVels(itrl, ibin) = nanmean(velocity_col(trl_idx & bin_idx));
           
           % mean acceleration in each spatial bin (by trial)
           mAccls(itrl, ibin) = nanmean(accl_column(trl_idx & bin_idx));

           % mean angular velocity in each spatial bin (by trial) 
           mAngVels(itrl, ibin) = ...
               rad2deg(circ_mean(deg2rad(angvel_column(trl_idx & bin_idx & ~isnan(angvel_column)))));

           % mean HD in each spatial bin (by trial)
           HD_hold = rad2deg(circ_mean(deg2rad(eptrials(trl_idx & bin_idx & ~isnan(eptrials(:,15)),15))));
           HD_hold(HD_hold<0) = HD_hold(HD_hold<0) + 360;
           mHDs(itrl, ibin) = nanmean(eptrials(trl_idx & bin_idx,15));

           % iterate through clusters
           for iclust = 1:length(clusts)
               
               % spikes in bin
               sib = sum(eptrials(trl_idx & bin_idx,4)==clusts(iclust));
               
               % time in bin
               tib = sum(eptrials(trl_idx & bin_idx,14)==1)*0.01;
               
               % mean FR in each spatial bin (by trial)
               mFRs(itrl, ibin, iclust) = sib/tib;
               
           end
       end   
   end
   
   % GLM input
   bins_input = repmat(1:bins, num_trials, 1); bins_input = bins_input(:);
   mVels = mVels(:);
   mAccls = mAccls(:);
   mAngVels = abs(mAngVels(:)); %ABSOLUTE VALUE
   mHDs = mHDs(:);
   
   % remove nan rows (spatial bins not visited on opposite trials)
   nnan_index = ~isnan(bins_input) & ~isnan(mVels) & ~isnan(mAccls) & ~isnan(mAngVels) & ~isnan(mHDs);
   
   bins_input = bins_input(nnan_index);
   mVels = mVels(nnan_index);
   mAccls = mAccls(nnan_index);
   mAngVels = mAngVels(nnan_index); %ABSOLUTE VALUE
   mHDs = mHDs(nnan_index);
   
   % bin HD into 6 60deg bins
   [~,~,mHDs] = histcounts(mHDs,linspace(0-realmin,360+realmin,7));
   
   for iclust = 1:length(clusts)
   
       % Firing rate input
       mFRs_clust = mFRs(:,:,iclust);
       mFRs_clust = mFRs_clust(:);
       mFRs_clust = mFRs_clust(nnan_index);


       %fit_line(bins_input,mFRs_clust)
       
       % regression table
       tbl = table(mFRs_clust, mVels, mAccls, mAngVels, mHDs, bins_input,...
           'VariableNames',{'FiringRates','Velocity','Acceleration','AngularVelocity','HeadDirection','SpatialLocation'});
        tbl = tbl(~any(ismissing(tbl),2),:);
        
       % define categorical variables (will produce 1 new variable per cetegory)
       tbl.HeadDirection = categorical(tbl.HeadDirection);
       tbl.SpatialLocation = categorical(tbl.SpatialLocation);       

       % regress
       linreg_wo_space = fitlm(tbl,'FiringRates ~ 1 + Velocity + Acceleration + AngularVelocity + HeadDirection')
       linreg_w_space = fitlm(tbl,'FiringRates ~ 1 + Velocity + Acceleration + AngularVelocity + HeadDirection + SpatialLocation')
       
       % compare models using F statistic
        numerator = (linreg_wo_space.SSE-linreg_w_space.SSE)/(linreg_w_space.NumCoefficients-linreg_wo_space.NumCoefficients);
        denominator = linreg_w_space.SSE/linreg_w_space.DFE;
        F = numerator/denominator;
        p = 1-fcdf(F,linreg_w_space.NumCoefficients-linreg_wo_space.NumCoefficients, linreg_w_space.DFE);
        
        [F p]
        
       % load output
       pvals_all = [pvals_all; p];
       Fstats_all = [Fstats_all; F];
               
   end  
end

%output
varnames = linreg_w_space.VariableNames;
