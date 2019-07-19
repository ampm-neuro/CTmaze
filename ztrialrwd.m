function ztrialrwd(eptrials, cells)
%ztrial(eptrials, cell) plots a single line indicating the firing rate
%difference (zscore) between trial types for the single cell "cell," with
%difference on the y axis and maze section on the x axis.
%
%eptrials is a matrix output by the function 'trials'
%
%cells is the sorted cluster numbers
%
%Only includes portion of trial between last entrance into start area and first lick
%detection (+ wndwfwd). This resembles a standard t-maze trial. The early time cuttoff may not be
%suitable for delay trials - consider using first entry to start area for
%those (a la secdist).
%
%
%The maze is divided into 6 sections by "folding" over the two halves along
%  0 = first lick detection on that trial
%  1 = start area 
%  2 = low stem 
%  3 = high stem
%  4 = choice area 
%  5 = choice arm (both)
%  6 = reward area (both)
%  7 = return arm (both)  
%
%COLORS AND LEGEND ARE CURRENTLY HARD CODED FOR UP TO 20 CELLS
%
%

%zeros(rates, trialtype, section)
trialrates = nan(max(eptrials(:,5))-1, 3, 5);

%video sampling rate for this session (used to determine time)
smplrt=length(eptrials(isnan(eptrials(:,4)),1))/max(eptrials(:,1));

%nan(1???, sections, cells)
zdists = nan(1,6,length(cells));

%plot colors
left_green=[52 153 70]./255;
right_blue=[46 49 146]./255;
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

%legend input
h = zeros(length(cells), 1);

%Makes thin grey line of all X,Y points.
figure
plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
set(gca,'xdir','reverse')
sections(eptrials);
rewards(eptrials);
hold on


for c = 1:length(cells)
    cell = cells(c);

    %at each section
    for section = 1:6

        %determine firing rate and trialtype for each trial
        for trl = 2:max(eptrials(:,5))
    
            %correct (1) and a lick detection
            if mode(eptrials(eptrials(:,5)==trl,8))==1 && sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0
    
                %included time (in seconds) after lick detection.
                %(Should be between 0 and 7s)
                wdwfwd=5;
                    
                %stem entrance
                stement = max(eptrials(eptrials(:,5)==trl & eptrials(:,6)==1, 1));
 
                if eptrials(eptrials(:,5)==trl, 7)==1
                            
                    %find the timestamp of first lick detection
                  	rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>stement & eptrials(:,10)==1 & eptrials(:,6)==7,1));
                            
                  	%find the timestamp of the last crossover 
                    %between folded-section 5 and section 1
                    trlstart = max(eptrials(eptrials(:,5)==trl & eptrials(:,11)==7 & eptrials(:,1)<rwdevent, 1));
                            
                    if isempty(trlstart)
                        %if the rat doesn't visit folded_sect 6
                        %before entering stem, then trlstart isjust
                        %first instant in sect 1.
                        trlstart = min(eptrials(eptrials(:,5)==trl & eptrials(:,11)==1, 1)); 
                    end
                             
                    %translate to unfolded section
                    if section == 1
                        sect = 1;
                    elseif section == 2
                        sect = 2;
                    elseif section == 3
                        sect = 3;
                    elseif section == 4
                        sect = 4;
                    elseif section == 5
                        sect = 5;
                    elseif section == 6
                        sect = 7;
                    end
                
                    if c == 1
                    
                    %timewindow for plotting
                    trlsecwindow = eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd);
                            
                    plot(eptrials(trlsecwindow, 2), eptrials(trlsecwindow, 3), 'Color', left_green, 'LineWidth', 0.5, 'LineStyle', '-')
                    hold on
                       
                    end
                    
                elseif eptrials(eptrials(:,5)==trl, 7)==2
                            
                    %find the timestamp of first lick detection
                    rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>stement & eptrials(:,10)==1 & eptrials(:,6)==8,1));
                            
                    %find the timestamp of the last crossover 
                    %between folded-section 5 and section 1
                    trlstart = max(eptrials(eptrials(:,5)==trl & eptrials(:,11)==7 & eptrials(:,1)<rwdevent, 1));
                            
                    if isempty(trlstart)
                       	%if the rat doesn't visit folded_sect 6
                     	%before entering stem, then trlstart isjust
                      	%first instant in sect 1.
                      	trlstart = min(eptrials(eptrials(:,5)==trl & eptrials(:,11)==1, 1));       
                    end
                            
                    %translate to unfolded section
                    if section == 1
                      	sect = 1;
                    elseif section == 2
                        sect = 2;
                    elseif section == 3
                        sect = 3;
                    elseif section == 4
                        sect = 4;
                    elseif section == 5
                        sect = 6;
                    elseif section == 6
                        sect = 8;
                    end
                      
                    if c == 1
                        
                    %timewindow for plotting
                    trlsecwindow = eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd);
                           
                    plot(eptrials(trlsecwindow, 2), eptrials(trlsecwindow, 3), 'Color', right_blue, 'LineWidth', 0.5, 'LineStyle', '-')
                    hold on
                    
                    end
                                    
                end 
                        
               	%how many spikes occured on the section(s) on trial(trl) 
                spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,6)==sect & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd), 4));

                %how long was spent on section(s) on trial(trl)
                time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd), 1))/smplrt;
                            
                rate = spikes/time;
    
                trialrates(trl, 1, section) = rate;
                trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
                trialrates(trl, 3, section) = section;

      
            else
                
                continue
        
            end
        end
    end
 
        
    leftmeans = nan(1,5);
    rightmeans = nan(1,5);
    leftstds = nan(1,5);
    rightstds = nan(1,5);
    leftlens = nan(1,5);
    rightlens = nan(1,5);


    for secti = 1:6

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

    for secti = 1:6
    zdists(1,secti,c)= abs(leftmeans(1,secti) - rightmeans(1,secti))/sqrt(leftstds(1,secti)/leftlens(1,secti) + rightstds(1,secti)/rightlens(1,secti));
    end

    %plotting each cell on the same figure   
    if c == 1
        figure 
    end
    h(c) = plot(1:6, zdists(:, :, c), '-', 'linewidth', 2, 'Color', a{c});
    hold on

end

axis([0.5,6.5, 0, 1.05*max(zdists(:))])
set(gca, 'XTickLabel',{'Start','Low Stem', 'High Stem', 'Choice', 'Approach', 'Reward'},'XTick', 1:6, 'fontsize', 12)
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
        
        

    
