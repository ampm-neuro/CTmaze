function wndwvar(eptrials, cells, bins, windowbck, windowfwd, flag)

%Plots the VARIANCE (not firing rate) of the population during each bin of 
%a binned time window for each L and R trial types (solid lines).
%
%Additionally plots population distance between L and R trials in each bin
%for reference (dotted lines).
%
%eptrials is a matrix output by the function 'trials'
%
%cells is a column vector (length 2 or 3) of identities of sorted clusters
%
%The maze is divided into 6 sections by "folding" over the two halves along
%the stem such that flag can be ENTRANCE INTO:
%
%  0 = first lick detection on that trial
%  1 = start area 
%  2 = low stem 
%  3 = high stem
%  4 = choice area 
%  5 = choice arm (both)
%  6 = reward area (both)
%  7 = return arm (both)  
%
%By default this looks at both correct and error trials, but includes a
%line that allows for specification for either. See below.
%

grn=[52 153 70]./255;
blu=[46 49 146]./255;


%Makes thin grey line of all X,Y points.
figure
plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
set(gca,'xdir','reverse')
hold on

%nans(rates, trialtype, bins, cells)
windowrates = nan(max(eptrials(:,5))-1, 2, bins, length(cells));

%nans(bins, trialtype)
windowvars = nan(bins, 2);

%(bins, distancetypes)
bindists = nan(bins, 2, 3);

%for each trial
for trl = 2:max(eptrials(:,5))
%Can set sub sample of trials: "for trl = #:#"

    %for each cell
    for c = 1:length(cells)
    cell = cells(c);

        %correct (1) OR error (2) ***THIS CAN BE ADJUSTED TO SPECIFY
        %ONE TYPE***
        if mode(eptrials(eptrials(:,5)==trl,8))==1
    
                    %determining 'flag' input
                    if ismember(flag, 1:7)
                    
                        %find arrival, the timestamp of entrance into section (minimum timestamp in
                        %section on trial)
                        event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,11)==flag, 1));
                    
                    %if flag input indicates reward receipt...
                    elseif flag == 0
                
                        %if there is a lick detection
                        if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0
                    
                            if eptrials(eptrials(:,5)==trl, 7)==1
                            %find the timestamp of first lick detection
                            event = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,1));
                    
                            elseif eptrials(eptrials(:,5)==trl, 7)==2
                            %find the timestamp of first lick detection
                            event = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,1));
                    
                            end
                    
                        %if there is NOT a lick detection, progress to next trial
                        else
                    
                            continue
                       
                        end
            
                    end
                    
                    %how many spikes occured in each bin in the window surrounding 
                    %the entrance timestamp on trial trl
                    for currentbin = 1:bins
       
                    windowlow = event-windowbck;
                    windowhigh = event+windowfwd;
                    window = (windowbck+windowfwd);
                    lowerbound = (currentbin-1)*(window/bins);
                    upperbound = currentbin*(window/bins);
                
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound),4));
                    rate = spikes/((windowbck+windowfwd)/bins);
        
                    windowrates(trl, 1, currentbin, c) = rate;
                    windowrates(trl, 2, currentbin, c) = mode(eptrials(eptrials(:,5)==trl, 7));
     
                        if currentbin==1 && c==1
        
                            if mode(eptrials(eptrials(:,5)==trl, 7))==1
                                plot(eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', grn, 'LineWidth', 0.5, 'LineStyle', '-')
                                hold on
                        elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                                plot(eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', blu, 'LineWidth', 0.5, 'LineStyle', '-')
                                hold on
                            end
                        end
                    end
        else 
            
            continue
    
        end
    end
end

%nans(trials, cells, bins)
ratesL = nan(length(windowrates(windowrates(:,2)==1, 1, 1, 1)), length(cells), bins);
ratesR = nan(length(windowrates(windowrates(:,2)==2, 1, 1, 1)), length(cells), bins);

for c = 1:length(cells)
    
    for currentbin = 1:bins
        
        ratesL(:, c, currentbin) = windowrates(windowrates(:,2)==1, 1, currentbin, c);
        ratesR(:, c, currentbin) = windowrates(windowrates(:,2)==2, 1, currentbin, c);
    
    end
    
end

WITHHELD_CLUSTERS = nan(1, bins);

for currentbin = 1:bins
    
    X1 = ratesL(:, :, currentbin);
    X2 = ratesR(:, :, currentbin);
    
    %finding clusters that never fire during at least one of the reward windows
    clusts = sum([sum(X1)==0; sum(X2)==0]);

    %removing those clusters from reward representations. This is 
    %essential for distance measures.
    X1 = X1(:, clusts == 0);
    X2 = X2(:, clusts == 0);

    %readout withheld clusters
   	WITHHELD_CLUSTERS(currentbin) = length(cells(clusts > 0));
    
    mu1=nanmean(X1);
    C1=nancov(X1);
    mu2=nanmean(X2);
    C2=nancov(X2);
    cov1=(C1+C2)/2;
    %S1= mean([std(X1); std(X2)]);
    
    %left
    windowvars(currentbin, 1) = mean(nanstd(ratesL(:, :, currentbin)));
    %right
    windowvars(currentbin, 2) = mean(nanstd(ratesR(:, :, currentbin)));
    
    %distances
    bindists(currentbin, 1) = NaN; %pdist([mu1;mu2], 'seuclidean', S1);
    bindists(currentbin, 2) = sqrt(((mu1-mu2)*(inv(cov1))*(mu1-mu2)')/length(cells(clusts == 0))); %pdist([mu1;mu2],'mahalanobis', cov1);
    bindists(currentbin, 3) = NaN; %bhatt(X1,X2);
        
end

WITHHELD_CLUSTERS

hold off

sections(eptrials);rewards(eptrials)

xaxistick = (0:length(windowvars(:,1))-1) ./ (length(windowvars(:,1))-1)*(windowbck+windowfwd);
correction = (-windowbck).*ones(1, length(windowvars(:,1)));
xaxistick = xaxistick + correction;

%windowvars = windowvars xaxistick.*timestamp?

figure
h1 = plot(xaxistick, windowvars(:, 1), 'Color', grn, 'linewidth', 2.0);
hold on
h2 = plot(xaxistick, windowvars(:, 2), 'Color', blu, 'linewidth', 2.0);
%h3 = plot(xaxistick, bindists(:, 1), '--', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
h4 = plot(xaxistick, bindists(:, 2), '--', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
%h5 = plot(xaxistick, bindists(:, 3), '--', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);

%adding a red vertical line at the event point
    hold on
    plot([0 0],[0 1.2*(max(windowvars(:)))],'r-', 'LineWidth',3)

axis([-windowbck, windowfwd, 0, 1.2*max(windowvars(:))])
set(gca, 'Xtick',(-windowbck:(windowbck+windowfwd)/8:windowfwd),'fontsize', 20)
%axis 'auto y'
%ylabel('Mean Standard Deviation (Hz)', 'fontsize', 20)
%set(gca, 'YLim',[0 30],'YTick', [0:10:30])
xlabel('Time (Sec)', 'fontsize', 20)
title(['(-',num2str(windowbck), 's : ',num2str(windowfwd), 's)  Flag= ',num2str(flag)],'fontsize', 16)
legend([h1, h2, h4],'SD Left Trials', 'SD Right Trials', 'M-Dist', 'location', 'northeastoutside');













