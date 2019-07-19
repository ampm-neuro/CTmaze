function [end_trial_response, end_trial_diff, delay_trial_diff] = delay_end_resp(eptrials, cell, bins, windowbck, windowfwd, stem_entrance)
%tests three delay related firing questions of a single cell between
%left and right trial types
%
% (1) Does the cell fire differently, on average, during the 30s prior to
%   true stem entrance on BOTH left and right trials?
%
%       This is output by L and R. Each gets a 1 if Yes, 0 if No.
%
% (2) Does the cell fire differently in the last second before stem
%  entrance than during the rest of the delay?
%
%       This is output by end_trial_diff. 1 if Yes. 0 if no.
%
% (3) Does the cell fire differently in the last second before stem
%  entrance on left vs right trials?
%
%       This is output by delay_trial_diff. 1 if Yes, 0 if No.
%

%preallocate outputs
L = nan;
R = nan;
end_trial_diff = nan;
delay_trial_diff = nan;

%nans(rates, trialtype)
windowrates = nan(max(eptrials(:,5))-1, 2, bins);

%determine firing rate and trialtype for each trial
for trl = 2:max(eptrials(:,5))

    %CHANGE this between 1 for correct and 2 for error trials.    
    if mode(eptrials(eptrials(:,5)==trl,8))==1
    
        %input
        event = stem_entrance;
        
        %other options:
            %event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==2,1));

            last_rwd_sect = max(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & ismember(eptrials(:,6), [7 8]),1));
            last_start_sect_b4_rwd = max(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==1 & eptrials(:,1) < last_rwd_sect,1));
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,1) > last_start_sect_b4_rwd,1));

        %%%%how many spikes occured in each bin in the window surrounding 
        %the entrance timestamp on trial trl
        for currentbin = 1:bins
       
        windowlow = event-windowbck;
        window = (windowbck+windowfwd);
        lowerbound = (currentbin-1)*(window/bins);
        upperbound = currentbin*(window/bins);
                
        spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound),4));
        rate = spikes/((windowbck+windowfwd)/bins);
        
        windowrates(trl, 1, currentbin) = rate;
        windowrates(trl, 2, currentbin) = mode(eptrials(eptrials(:,5)==trl, 7));  
        
        end
    
    %NaNs for the incorrect trials. We will continue to ignore them below.
    else 
        continue
    end
end
    

%shuffle: is firing rate during last second greater than if rates shuffled among seconds within trials?
        
%firing rates right and left trials
L_hz = squeeze(windowrates(windowrates(:,2,currentbin)==1, 1, :));
R_hz = squeeze(windowrates(windowrates(:,2,currentbin)==2, 1, :));

%firing rate during last second
L_test_rates = L_hz(:,bins);
L_test_mean = mean(L_hz(:,bins));
R_test_rates = R_hz(:,bins);
R_test_mean = mean(R_hz(:,bins));

%number of trials
L_num_trials = length(L_hz(:,1));
R_num_trials = length(R_hz(:,1));

%shuffle enough times to get 1000 elements
shuffles = ceil(1000/bins);

%list of all rates (1 per trial-second)
L_flat_hz = L_hz(:);
R_flat_hz = R_hz(:);

%preallocate?
L_shuf_dist = [];
R_shuf_dist = [];

%we can save time if L and R num_trials are equal
if L_num_trials == R_num_trials
    for shuf = 1:shuffles

        %preallocate shuffled rates
        L_shuf_hz = nan(L_num_trials, bins);
        R_shuf_hz = nan(R_num_trials, bins);
                
        %index each row with a new random arrangment of columns
        for row = 1:L_num_trials
            rndp = randperm(bins);
            L_shuf_hz(row, :) = L_hz(row, rndp);
            R_shuf_hz(row, :) = R_hz(row, rndp);
        end
        
        %add column means to shuffle_distribution
        L_shuf_dist = [L_shuf_dist; mean(L_shuf_hz)'];
        R_shuf_dist = [R_shuf_dist; mean(R_shuf_hz)'];
           
    end

%otherwise calculate them serially
else           
    for shuf = 1:shuffles

        %preallocate shuffled rates
        L_shuf_hz = nan(L_num_trials, bins);
        R_shuf_hz = nan(R_num_trials, bins);
                
        %index each row with a new random arrangment of columns
        for row = 1:L_num_trials
            L_shuf_hz(row, :) = L_hz(row, randperm(bins));
        end
        
        %index each row with a new random arrangment of columns
        for row = 1:R_num_trials
            R_shuf_hz(row, :) = R_hz(row, randperm(bins));
        end
        
        %add column means to shuffle_distribution
        L_shuf_dist = [L_shuf_dist; mean(L_shuf_hz)'];
        R_shuf_dist = [R_shuf_dist; mean(R_shuf_hz)'];
           
    end
end


%p_values
L_shuf_p = 1-(sum(L_shuf_dist<L_test_mean)/length(L_shuf_dist));
R_shuf_p = 1-(sum(R_shuf_dist<R_test_mean)/length(R_shuf_dist));

%OUTPUTS
%

%individual L and R outputs for significant shuffles
if L_shuf_p < 0.025 || L_shuf_p > 0.975
    L = 1;
else
    L = 0;
end
if R_shuf_p < 0.025 || R_shuf_p > 0.975
    R = 1;
else 
    R = 0;
end

%combined L R output
if sum([L R]) == 2
    end_trial_response = 1;
else
    end_trial_response = 0;
end
    
%ttest for trial type difference in last second firing rate
end_trial_diff = ttest2(L_test_rates, R_test_rates);

%check for rate difference between L and R delays (29s)
L_del_mean = mean(L_hz(:, 1:bins-1),2);
R_del_mean = mean(R_hz(:, 1:bins-1),2);
delay_trial_diff = ttest2(L_del_mean, R_del_mean);


end

