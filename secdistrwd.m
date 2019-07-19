function secdistrwd(eptrials, cells)

%Plots a line showing distance between each section representation.
%
%builds two (left and right) M x N matrices, X1 and X2, of mean firing rates where M rows contain the trials and N columns
%contain clusters.
%
%
%Only includes portion of trial between last entrance into start area and first lick
%detection (+ wndwfwd). This resembles a standard t-maze trial. The early time cuttoff may not be
%suitable for delay trials - consider using first entry to start area for
%those (a la secdist). 

%world's greatest colors
left_green=[52 153 70]./255;
right_blue=[46 49 146]./255;
%proximal_black = [0 0 0];
%distal_gray = [.5 .5 .5];
%error_red = [158 8 8]./255;
%correct_gray = [120 120 120]./255;

%video sampling rate for this session (used to determine time)
smplrt=length(eptrials(eptrials(:,14)==1,1))/max(eptrials(:,1));

%(rates, trialtype, cells)
trialrates = nan(max(eptrials(:,5))-1, 2, length(cells));

%(sections, distancetypes, accuracy)
crctsecdists = nan(6, 3);

%Makes thin grey line of all X,Y points.
figure
plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
set(gca,'xdir','reverse')
hold on


%at each section
for section = 1:6

        %for each cell
        for c = 1:length(cells)
          cell = cells(c);

            %for each trial
            for trl = 2:max(eptrials(:,5))
            %Can set sub sample of trials: "for trl = #:#"  
            
                %correct (1) and a lick detection
                if mode(eptrials(eptrials(:,5)==trl,8))==1 && sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0
                    
                    %included time (in seconds) after lick detection.
                    %(Should be between 0 and ~7s)
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
                                %if the rat doesn't visit folded_sect 7
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
                            
                            %timewindow for plotting
                            trlsecwindow = eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd);
                            
                            plot(eptrials(eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)<(rwdevent+wdwfwd), 2), eptrials(eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)<(rwdevent+wdwfwd), 3), 'Color', left_green, 'LineWidth', 0.5, 'LineStyle', '-')
                            %plot(eptrials(trlsecwindow, 2), eptrials(trlsecwindow, 3), 'Color', left_green, 'LineWidth', 0.5, 'LineStyle', '-')
                            hold on
                                
                        elseif eptrials(eptrials(:,5)==trl, 7)==2
                            
                            %find the timestamp of first lick detection
                            rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>stement & eptrials(:,10)==1 & eptrials(:,6)==8,1));
                            
                            %find the timestamp of the last crossover 
                            %between folded-section 7 and section 1
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

                            plot(eptrials(eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd), 2), eptrials(eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd), 3), 'Color', right_blue, 'LineWidth', 0.5, 'LineStyle', '-')
                            hold on
                                    
                        end 
                        
                        %how many spikes occured on the section(s) on trial(trl) 
                        spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,6)==sect & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd), 4));

                        %how long was spent on section(s) on trial(trl)
                        time = length(eptrials(eptrials(:,5)==trl & eptrials(:,6)==sect & isnan(eptrials(:,4)) & eptrials(:,1)>trlstart & eptrials(:,1)<(rwdevent+wdwfwd), 1))/smplrt;
                            
                        rate = spikes/time;
    
                        trialrates(trl, 1, c) = rate;
                        trialrates(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));

                else
        
                    continue
       
                end               
            end
        end

        
        %trialrates
        X1 = squeeze(trialrates(trialrates(:, 2)==1, 1, :));
        X2 = squeeze(trialrates(trialrates(:, 2)==2, 1, :));
        
        %finding clusters that never fire during at least one of the reward windows
        clusts = sum([sum(X1)==0; sum(X2)==0]);

        %removing those clusters from reward representations. This is 
        %essential for distance measures.
        X1 = X1(:, clusts == 0);
        X2 = X2(:, clusts == 0);

        %readout withheld clusters
        WITHHELD_CLUSTERS = cells(clusts > 0)
    
        %cells
        %cells(clusts == 0)
        %length(cells(clusts == 0))
        %length(clusts)
        
        mu1=nanmean(X1);
        C1=nancov(X1);
        mu2=nanmean(X2);
        C2=nancov(X2);
        cov1=(C1+C2)/2;
        %S1= nanmean([std(X1); std(X2)]);
        crctsecdists(section, 1) = NaN; %pdist([mu1;mu2], 'seuclidean', S1);
        crctsecdists(section, 2) = sqrt(((mu1-mu2)*(inv(cov1))*(mu1-mu2)')/length(cells(clusts == 0)));
        crctsecdists(section, 3) = NaN; %bhatt(X1,X2);

end

sections(eptrials);
figure
hold on
%h1 = plot(1:6, crctsecdists(:, 1), '-', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
h2 = plot(1:6, crctsecdists(:, 2), '-', 'linewidth', 2, 'Color',[0 0 0]);
%h3 = plot(1:6, crctsecdists(:, 3), '-', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);

title('Population Distances','fontsize', 20)
%legend([h1 h2 h3], 'Seuclidean', 'Mahalanobis', 'Bhattacharyya', 'location', 'northeastoutside');
legend(h2, 'Mahalanobis', 'location', 'northeastoutside');
set(gca, 'XTickLabel',{'Start','Low Stem', 'High Stem', 'Choice', 'Approach', 'Reward'},'XTick', 1:6, 'fontsize', 12)
ylabel('Mahalanobis Distance', 'fontsize', 20)
xlabel('Maze Section', 'fontsize', 20)

%axis([0.75, 5.25, 0, 8])
axis([0.75, 6.25, 0, 1.05*max(crctsecdists(:,2))])


