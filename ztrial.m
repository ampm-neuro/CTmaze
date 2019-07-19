function [aysm_scores, zscore_sections] = ztrial(eptrials, cells)
%ztrial(eptrials, cell) plots a single line indicating the firing rate
%difference (zscore) between trial types for the single cell "cell," with
%difference on the y axis and maze section on the x axis.
%
%eptrials is a matrix output by the function 'trials'
%
%cells is the sorted cluster numbers
%
%The maze is divided into 6 sections by "folding" over the two halves along
%the stem such that
%  0 = first lick detection on that trial
%  1 = start area 
%  2 = low stem 
%  3 = high stem
%  4 = choice area 
%  5 = choice arm (both)
%  6 = reward area (both)
%  7 = return arm (both)  
%
%
%COLORS AND LEGEND ARE CURRENTLY HARD CODED FOR UP TO 11 CELLS

%colors
a{1} = [0/255 0/255 0/255]; %Black 
a{2} = [169/255 169/255 169/255]; %DarkGray
a{3} = [178/255 34/255 34/255]; %FireBrick
a{4} = [34/255 139/255 34/255]; %ForestGreen
a{5} = [75/255 0/255 130/255]; %Indigo
a{6} = [255/255 140/255 0/255]; %DarkOrange
a{7} = [0/255 0/255 128/255]; %Navy
a{8} = [218/255 165/255 32/255]; %Goldenrod
a{9} = [0/255 139/255 139/255]; %DarkCyan
a{10} = [47/255 79/255 79/255]; %DarkSlateGray
a{11} = [139/255 69/255 19/255]; %SaddleBrown
a{12} = [188/255 143/255 143/255]; %RosyBrown
a{13} = [0/255 191/255 255/255]; %DeepSkyBlue
a{14} = [85/255 107/255 47/255]; %DarkOliveGreen
a{15} = [218/255 112/255 214/255]; %Orchid
a{16} = [139/255 0/255 139/255]; %DarkMagenta
a{17} = [210/255 180/255 140/255]; %Tan
a{18} = [178/255 34/255 34/255]; %SkyBlue
a{19} = [135/255 206/255 235/255]; %SkyBlue
a{20} = [178/255 34/255 34/255]; %red

h = zeros(length(cells), 1);
%zdists = nan(1,7,length(cells));
zdists = nan(length(cells),7);

smplrt=length(eptrials(isnan(eptrials(:,4)),1))/max(eptrials(:,1));

%figure

%preallocate
summary = nan(length(cells),2);


for c = 1:length(cells)
        
    %zeros(rates, trialtype, section)
    trialrates = nan(max(eptrials(:,5))-1, 3, 7);

    %at each section
    for section = 1:7

        %determine firing rate and trialtype for each trial
        for trl = 2:max(eptrials(:,5))
            %2:20 
    
            %Change this between 1 for correct and 2 for error trials.    
            if mode(eptrials(eptrials(:,5)==trl,8))==1
    
                %this if statement accounts for the "both"s in the section input
                if ismember(section, 1:4)
        
                    %how many spikes(c) occured on the section(s) on trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cells(c) & eptrials(:,5)==trl & eptrials(:,6)==section,4));
    
                    %how long was spent on section(s) on trial(trl)
                    time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)==section & isnan(eptrials(:,4)), 1))/smplrt;

    
                    rate = spikes/time;
    
                    trialrates(trl, 1, section) = rate;
                    trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
                    trialrates(trl, 3, section) = section;

                elseif section == 5
        
                    %how many spikes(c) occured on the section(s) on trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cells(c) & eptrials(:,5)==trl & eptrials(:,6)>4 & eptrials(:,6)<7,4));
    
                    %how long was spent on section(s) on trial(trl)
                    time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)>4 & eptrials(:,6)<7 & isnan(eptrials(:,4)), 1))/smplrt;

            
                    rate = spikes/time;
    
                    trialrates(trl, 1, section) = rate;
                    trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
                    trialrates(trl, 3, section) = section;
            
                elseif section == 6
        
                    %how many spikes(c) occured on the section(s) on trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cells(c) & eptrials(:,5)==trl & eptrials(:,6)>6 & eptrials(:,6)<9,4));
    
                    %how long was spent on section(s) on trial(trl)
                    time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)>6 & eptrials(:,6)<9 & isnan(eptrials(:,4)), 1))/smplrt;    
            
                    rate = spikes/time;
    
                    trialrates(trl, 1, section) = rate;
                    trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
                    trialrates(trl, 3, section) = section;

                elseif section == 7
        
                    %how many spikes(c) occured on the section(s) on trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cells(c) & eptrials(:,5)==trl & eptrials(:,6)>8,4));
    
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

leftmeans = nan(1,7);
rightmeans = nan(1,7);
leftstds = nan(1,7);
rightstds = nan(1,7);
leftlens = nan(1,7);
rightlens = nan(1,7);


    for secti = 1:7

    %calculating means
    leftmeans(1,secti)=nanmean(trialrates(trialrates(:,2)==1, 1, secti));
    rightmeans(1,secti)=nanmean(trialrates(trialrates(:,2)==2, 1, secti));
    %calculating standard deviations
    leftstds(1,secti)=nanstd(trialrates(trialrates(:,2)==1, 1, secti));
    rightstds(1,secti)=nanstd(trialrates(trialrates(:,2)==2, 1, secti));
    %calculating lengths
    leftlens(1,secti)=sum(isfinite(trialrates(trialrates(:,2)==1, 1, secti)));
    rightlens(1,secti)=sum(isfinite(trialrates(trialrates(:,2)==2, 1, secti)));

    end

    for secti = 1:7
    zdists(c,secti)= abs(leftmeans(1,secti) - rightmeans(1,secti))/sqrt(leftstds(1,secti)/leftlens(1,secti) + rightstds(1,secti)/rightlens(1,secti));
    end

%h(c) = plot(1:7, zdists(:, :, c), '-', 'linewidth', 2, 'Color', a{c});
%hold on

summary(c, 1) = cells(c);
summary(c, 2) = sum(zdists(c, :));


end

%summary

aysm_scores = summary(:,2);
zscore_sections = zdists;

%{
axis([0.5,7.5, 0, 1.05*max(zdists(:))])
set(gca, 'XTickLabel',{'Start','Low Stem', 'High Stem', 'Choice', 'Approach', 'Reward', 'Return'}, 'fontsize', 12)
ylabel('Rate Difference (z-score)', 'fontsize', 20)
xlabel('Maze Section', 'fontsize', 20)

%godforsaken title/legend
if length(cells) == 1
    
    title(['Cell ',num2str(cells)],'fontsize', 20)

elseif length(h) == 2
    
    legend([h(1) h(2)], num2str(cells(1)), num2str(cells(2)), 'location', 'northeastoutside');
    
elseif length(h) == 3
        
    legend([h(1) h(2) h(3)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), 'location', 'northeastoutside');
        
elseif length(h) == 4
        
    legend([h(1) h(2) h(3) h(4)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), 'location', 'northeastoutside');
        
elseif length(h) == 5
        
    legend([h(1) h(2) h(3) h(4) h(5)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), 'location', 'northeastoutside');
 
elseif length(h) == 6
       
    legend([h(1) h(2) h(3) h(4) h(5) h(6)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), 'location', 'northeastoutside');
        
elseif length(h) == 7
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), 'location', 'northeastoutside');

elseif length(h) == 8
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), 'location', 'northeastoutside');        
        
elseif length(h) == 9
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), 'location', 'northeastoutside');
    
elseif length(h) == 10
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), 'location', 'northeastoutside');    
   
elseif length(h) == 11
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), 'location', 'northeastoutside');    
    
elseif length(h) == 12
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11) h(12)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), num2str(cells(12)), 'location', 'northeastoutside');    
    
elseif length(h) == 13
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11) h(12) h(13)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), num2str(cells(12)), num2str(cells(13)), 'location', 'northeastoutside');        

elseif length(h) == 14
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11) h(12) h(13) h(14)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), num2str(cells(12)), num2str(cells(13)), num2str(cells(14)), 'location', 'northeastoutside');        

elseif length(h) == 15
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11) h(12) h(13) h(14) h(15)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), num2str(cells(12)), num2str(cells(13)), num2str(cells(14)), num2str(cells(15)), 'location', 'northeastoutside');        

elseif length(h) == 16
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11) h(12) h(13) h(14) h(15) h(16)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), num2str(cells(12)), num2str(cells(13)), num2str(cells(14)), num2str(cells(15)), num2str(cells(16)), 'location', 'northeastoutside');        

elseif length(h) == 17
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11) h(12) h(13) h(14) h(15) h(16) h(17)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), num2str(cells(12)), num2str(cells(13)), num2str(cells(14)), num2str(cells(15)), num2str(cells(16)), num2str(cells(17)), 'location', 'northeastoutside');        

elseif length(h) == 18
        
    legend([h(1) h(2) h(3) h(4) h(5) h(6) h(7) h(8) h(9) h(10) h(11) h(12) h(13) h(14) h(15) h(16) h(17) h(18)], num2str(cells(1)), num2str(cells(2)), num2str(cells(3)), num2str(cells(4)), num2str(cells(5)), num2str(cells(6)), num2str(cells(7)), num2str(cells(8)), num2str(cells(9)), num2str(cells(10)), num2str(cells(11)), num2str(cells(12)), num2str(cells(13)), num2str(cells(14)), num2str(cells(15)), num2str(cells(16)), num2str(cells(17)), num2str(cells(18)), 'location', 'northeastoutside');        

end
%}
        
        

    
