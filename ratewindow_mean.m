function [windowrates] = ratewindow_mean(eptrials, cluster_cell, bins, windowbck, windowfwd, flag)
%plots average firing rates of cluster_cell 'cluster_cell' over a window of
%windowbck+windowfwd seconds surrounding entrance into 'section' section. 
%
%the function outputs a barchart if the bins are 1 (averaged across entire
%window), and a histogram if bins > 1. 
%
%eptrials is a matrix output by the function 'trials'
%
%The maze is divided into 6 sections by "folding" over the two halves along
%the stem such that flag can be:
%
%  0 = first lick detection on that trial
%  1 = start area 
%  2 = low stem 
%  3 = high stem
%  4 = choice area 
%  5 = approach arm (both)
%  6 = reward area (both)
%  7 = return arm (both)
%
%This code is easily modified to use error trials. See below.
%


accuracy = 1;
if accuracy == 2
    warning('accuracy set to error trials')
end

enter_times = [];
exit_times = [];

%nans(rates, trialtype)
windowrates = nan(max(eptrials(:,5))-1, 2, bins);

%determine firing rate and trialtype for each trial
for trl = 2:max(eptrials(:,5))

    %CHANGE this between 1 for correct and 2 for error trials.    
    if mode(eptrials(eptrials(:,5)==trl,8))==accuracy
    
        %determining 'flag' input
        if ismember(flag, [1 4])
    
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==flag,1));
        
        %determining 'flag' input
        elseif ismember(flag, [2 3])
    
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            
            last_rwd_sect = max(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & ismember(eptrials(:,6), [7 8]),1));
            last_start_sect_b4_rwd = max(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==1 & eptrials(:,1) < last_rwd_sect,1));
            
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==flag & eptrials(:,1) > last_start_sect_b4_rwd,1));
            
        %determining 'flag' input    
        elseif flag == 5
            
            %"unfold" maze to plot correct spatial section for each trial type 
            if mode(eptrials(eptrials(:,5)==trl, 7))==1
            
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==5,1));
        
            elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==6,1));
            
            end
            
        %determining 'section' input
        elseif flag == 6
        
            if mode(eptrials(eptrials(:,5)==trl, 7))==1
            
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==7,1));
        
            elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==8,1));
            
            end
            
        %determining 'section' input
        elseif flag == 7
            
            if mode(eptrials(eptrials(:,5)==trl, 7))==1
            
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==9,1));
        
            elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==10,1));
            
            end
            
        %if section input indicates reward receipt...
        elseif flag == 0
                
                %stem entrance on this trial (max time point in start area)
                stement = max(eptrials(eptrials(:,5)==trl & eptrials(:,6)==1, 1));
            
                %if there is a lick detection
                if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0
                    
                    %find the timestamp of first lick detection
                    event = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,1)>stement,1));
                    
                %if there is NOT a lick detection, progress to next trial
                else
                    
                    continue
                       
                end
            
        end
        
        %%%%how many spikes occured in each bin in the window surrounding 
        %the entrance timestamp on trial trl
        for currentbin = 1:bins
       
            windowlow = event-windowbck; enter_times = [enter_times; windowlow];
            windowhigh = event+windowfwd; exit_times = [exit_times; windowhigh];
            window = (windowbck+windowfwd);
            lowerbound = (currentbin-1)*(window/bins);
            upperbound = currentbin*(window/bins);

            spikes = length(eptrials(eptrials(:,4)==cluster_cell & eptrials(:,5)==trl & eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound),4));
            rate = spikes/((windowbck+windowfwd)/bins);

            windowrates(trl, 1, currentbin) = rate;
            windowrates(trl, 2, currentbin) = mode(eptrials(eptrials(:,5)==trl, 7));  
                
        end
    
    %NaNs for the incorrect trials. We will continue to ignore them below.
    else 
        continue
    end
end

end

