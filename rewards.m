function [XYLR, first_rwd_times] = rewards(eptrials, varargin) 
%this plots the average first reward receipt location for right and left trials
%XYLR are the reward positions
%first_rwd_time

figure_on = 0;
if nargin > 1
    figure_on = varargin{1};
end

%all trials
all_trials = unique(eptrials(~isnan(eptrials(:,5)),5))'; 

firstLrwdsXY = NaN(max(eptrials(:,5)), 2);
firstRrwdsXY = NaN(max(eptrials(:,5)), 2);

first_rwd_times = NaN(max(eptrials(:,5)), 1);

for trl = all_trials
    
    
        if mode(eptrials(eptrials(:,5)==trl,7))==1
            
            if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,10))>0
        
                %for some reason one trial was ouputting two values. The
                %nanmean solved that problem.
                firstLrwdsXY(trl,1) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,1)), 2));
                firstLrwdsXY(trl,2) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,1)), 3));
                
                %time
                first_rwd_times(trl) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,1)), 1));
            
            end
        
        elseif mode(eptrials(eptrials(:,5)==trl,7))==2
            
            if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,10))>0
            
                firstRrwdsXY(trl,1) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,1)), 2));
                firstRrwdsXY(trl,2) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,1)), 3));
                
                %time
                first_rwd_times(trl) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,1)), 1));
    
            end
            
        end

end


%first_rwd_times = first_rwd_times(~isnan(first_rwd_times));


avgXYrwdL = [nanmean(firstLrwdsXY(:, 1)) nanmean(firstLrwdsXY(:, 2))];
avgXYrwdR = [nanmean(firstRrwdsXY(:, 1)) nanmean(firstRrwdsXY(:, 2))];

XYLR = [avgXYrwdL ; avgXYrwdR];

if figure_on == 1;

    hold on

            plot(nanmean(firstLrwdsXY(:, 1)), nanmean(firstLrwdsXY(:, 2)), '.', 'Color', [0 0 0], 'markersize', 30)
            plot(nanmean(firstRrwdsXY(:, 1)), nanmean(firstRrwdsXY(:, 2)), '.', 'Color', [0 0 0], 'markersize', 30)
            %set(gca,'xdir','reverse')
            set(gca, 'Ytick', 50:10:450, 'XTick', 150:15:600)

    hold off


    axis([750 1250 750 1250])
    set(gca, 'Xtick',(750:50:1250), 'Ytick',(750:50:1250), 'fontsize', 10)
    
end
    
    
    
    