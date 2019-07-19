function plotratetrial(eptrials, cell)
%plotratetrial(eptrials, cell) plots a line with error bars for each trial 
%type with firing rate on the y axis and maze section on the x axis.
%
%eptrials is a matrix output by the function 'trials'
%
%cell is the sorted cluster number
%
%The maze is divided into 6 sections by "folding" over the two halves along
%the stem such that
%  1 = start area 
%  2 = low stem 
%  3 = high stem
%  4 = choice area 
%  5 = choice arm (both)
%  6 = reward area (both)
%  7 = return arm (both)

smplrt=length(eptrials(isnan(eptrials(:,4)),1))/max(eptrials(:,1));

figure

%zeros(rates, trialtype, section)
trialrates = nan(max(eptrials(:,5))-1, 3, 7);

%at each section
for section = 1:7

    %determine firing rate and trialtype for each trial
    for trl = 2:max(eptrials(:,5))
    
    %Change this between 1 for correct and 2 for error trials.  
    if mode(eptrials(eptrials(:,5)==trl,8))==1
    
        %this if statement accounts for the "both"s in the section input
        if ismember(section, 1:4)
        
            %how many spikes(c) occured on the section(s) on trial(trl) 
            spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,6)==section,4));
    
            %how long was spent on section(s) on trial(trl)
            time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
            rate = spikes/time;
    
            trialrates(trl, 1, section) = rate;
            trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
            trialrates(trl, 3, section) = section;

        elseif section == 5 %approach
        
            %how many spikes(c) occured on the section(s) on trial(trl) 
            spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,6)>4 & eptrials(:,6)<7,4));
    
            %how long was spent on section(s) on trial(trl)
            time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)>4 & eptrials(:,6)<7 & isnan(eptrials(:,4)), 1))/smplrt;

            rate = spikes/time;
    
            trialrates(trl, 1, section) = rate;
            trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
            trialrates(trl, 3, section) = section;
            
        elseif section == 6 %reward
        
            %how many spikes(c) occured on the section(s) on trial(trl) 
            spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,6)>6 & eptrials(:,6)<9,4));
    
            %how long was spent on section(s) on trial(trl)
            time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)>6 & eptrials(:,6)<9 & isnan(eptrials(:,4)), 1))/smplrt;    
            
            rate = spikes/time;
    
            trialrates(trl, 1, section) = rate;
            trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
            trialrates(trl, 3, section) = section;

        elseif section == 7 %return
        
            %how many spikes(c) occured on the section(s) on trial(trl) 
            spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,6)>8,4));
    
            %how long was spent on section(s) on trial(trl)
            time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)>8 & isnan(eptrials(:,4)), 1))/smplrt;    
            
            rate = spikes/time;
    
            trialrates(trl, 1, section) = rate;
            trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
            trialrates(trl, 3, section) = section;
    
        end
            
    else %NaNs for the incorrect trials. We will continue to ignore them below.
        
        trialrates(trl, 1) = NaN;
        trialrates(trl, 2) = NaN;
        
    end
    end
end

leftmeans = zeros (1,7);
rightmeans = zeros (1,7);
leftstds = zeros (1,7);
rightstds = zeros (1,7);
leftlens = zeros (1,7);
rightlens = zeros (1,7);


for secti = 1:7

%calculating means
leftmeans(1,secti)=nanmean(trialrates(trialrates(:,2)==1, 1, secti));
rightmeans(1,secti)=nanmean(trialrates(trialrates(:,2)==2, 1, secti));
leftstds(1,secti)=nanstd(trialrates(trialrates(:,2)==1, 1, secti));
rightstds(1,secti)=nanstd(trialrates(trialrates(:,2)==2, 1, secti));
leftlens(1,secti)=sum(~isnan(trialrates(trialrates(:,2)==1, 1, secti)));
rightlens(1,secti)=sum(~isnan(trialrates(trialrates(:,2)==2, 1, secti)));

end

grn=[52 153 70]./255;
blu=[46 49 146]./255;

h1=errorbar(1:7, leftmeans, leftstds./sqrt(leftlens), 'Color', grn, 'linewidth', 2.0);
hold on
h2=errorbar(1:7, rightmeans, rightstds./sqrt(rightlens), 'Color', blu, 'linewidth', 2.0);
hold off

box 'off'

axis([0.5,7.5, 0, 100])
%daspect([1 10 1])
axis 'auto y'
set(gca, 'XTickLabel',{'Start', 'Low Stem', 'High Stem', 'Choice', 'Approach', 'Reward', 'Return'}, 'fontsize', 12, 'TickLength',[ 0 0 ])
ylabel('Firing Rate (Hz)', 'fontsize', 20)
xlabel('Maze Section', 'fontsize', 20)
title(['Cell ',num2str(cell)],'fontsize', 20)
legend([h1, h2],'Left Trials', 'Right Trials', 'location', 'northeastoutside');







