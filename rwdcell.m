function [summary, rates_out, fs_and_ts] = rwdcell(eptrials, clusters, win_siz, cor_err, stem_runs, file)

%a function that performs a two way anova to ID reward cells.

%only typical stem run trials
good_trials = unique(eptrials(:,5));
good_trials = good_trials(stem_runs(:,3)<1.25);
good_trials = good_trials(good_trials>1); %delete probe trial

fs_and_ts = [];

first_last = 1; %1 is first, 2 is last ten trials

%preallocate
rates = nan(length(good_trials), 4, length(clusters));
summary = nan(length(clusters),1);

%check if there are at least 10 correct left and 10 correct right
%trials.
left_corrects = unique(eptrials(eptrials(:,8)==1 & eptrials(:,7)==1, 5));
right_corrects = unique(eptrials(eptrials(:,8)==1 & eptrials(:,7)==2, 5));

if length(left_corrects)<10 || length(right_corrects)<10
    rates_out = nan(20,3);
    return
end

%calculate rates
for trial = 1:length(good_trials)
    good_trial = good_trials(trial);
    
    %trial index
    trl_idx = eptrials(:,5)==good_trial;
    
    %find lick (first reward flag)
    first_flag = min(eptrials(trl_idx & eptrials(:,10)==1, 1));
    if ~isempty(first_flag)
        
        %for each cell
        for clust = 1:length(clusters);
            cell = clusters(clust);
            
            %indices
            cell_idx = eptrials(:,4)==cell;
            win_bfr = eptrials(:,1) >= first_flag - win_siz/2 & eptrials(:,1) < first_flag;
            win_aft = eptrials(:,1) >= first_flag & eptrials(:,1) <= first_flag + win_siz/2;
            
            %rates
            before_rate = length(eptrials(trl_idx & cell_idx & win_bfr, 1))/(win_siz/2);
            after_rate = length(eptrials(trl_idx & cell_idx & win_aft, 1))/(win_siz/2);
            
            %trial type
            trl_typ = mode(eptrials(trl_idx,7));
            
            %accuracy
            trl_acc = mode(eptrials(trl_idx,8));
            
            %fill rates
            rates(trial, 1:4, clust) = [before_rate after_rate trl_typ trl_acc];
            
        end
     
    %if no flag, leave nans
    else
        continue        
    end
end


%corrects or errors only only
left_rates = rates(rates(:,4)==cor_err & rates(:,3)==1, 1:2, :);
right_rates = rates(rates(:,4)==cor_err & rates(:,3)==2, 1:2, :);

%first 10 only
try

    if first_last == 1
        left_rates = left_rates(1:10, :,:);
        right_rates = right_rates(1:10, :,:);
    elseif first_last == 2
        left_rates = left_rates(end-9:end, :,:);
        right_rates = right_rates(end-9:end, :,:);
    end

catch
    rates_out = nan(20,3);
    return
end


%perform stats for each cell
for clust = 1:length(clusters);
    %cell = clusters(clust); 
    
    L_rates_bef = left_rates(:,1,clust);
    L_rates_aft = left_rates(:,2,clust);
    R_rates_bef = right_rates(:,1,clust);
    R_rates_aft = right_rates(:,2,clust);
    
    
    %{
    lmeans = mean([L_rates_bef L_rates_aft])
    rmeans = mean([R_rates_bef R_rates_aft])
    %}
    
    
    anov_inpt = [[L_rates_bef;L_rates_aft] [R_rates_bef;R_rates_aft]];
    [tvals_posthoc, tp]  = ttest2(L_rates_aft, R_rates_aft);

    p_vals = anova2(anov_inpt, 10, 'off');   
    %p_trl_type = p_vals(1);
    %p_before_after = p_vals(2);
    p_interact = p_vals(3);
    
    %on_off reward cell    
    %summary(clust) = any([p_before_after p_interact] < .05);
    
    %trial type specific reward cell
    summary(clust) = p_interact < .05 & tvals_posthoc == 1;
    
    fs_and_ts = [fs_and_ts; [p_interact tp]];
    
    %anything reward-like
    %summary(clust) = any([p_trl_type p_before_after p_interact] < .05);
    
    %reddish main only
    %summary(clust) = p_trl_type < .05;

    if summary(clust) == 1
        %ratewindow(eptrials, clusters(clust), 40, 3, 1, 0, file);
        ratewindow(eptrials, clusters(clust), 40, 3, 1, 0);
    end
    
end

rates_out = [[L_rates_bef L_rates_aft ones(size(L_rates_bef))]; [R_rates_bef R_rates_aft repmat(2, size(R_rates_bef))]];

end