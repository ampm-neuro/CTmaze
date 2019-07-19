function wndwdistpre(eptrials, cells, bins, windowbck, windowfwd, flag)

%Individually plots the mean population distance between the current time bin 
%and the population representation of each reward location (+1s) over 
%the time window 'windowbck+windowfwd' surrounding event 'flag'
%
%The reward representation is averaged from all first lick detections.
%While this does include error trials, error trials often do not have lick 
%detections. This may bias the reward representation.
%
%Separately plots the mean cartesian distance to each of the reward locations
%during each time bin
%
%
%FLAG: The maze is divided into 7 sections by "folding" over the two halves along
%the stem such that flag can be the time of ENTRANCE INTO (when applicable):
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



%REWARD WINDOW TIMES HERE
wdwbck=0;
wdwfwd=1;

%PREALLOCATION
rwdwindowrates = nan(max(eptrials(:,5))-1, 2, length(cells)); %nans(rates, trialtype, cells)
windowrates = nan(max(eptrials(:,5))-1, 3, length(cells), bins); %nans(trials, rate/trialtype/accuracy, cells, bins)
poswindowmeans = nan(max(eptrials(:,5))-1, 3, bins); %nans(trial, x/y/trialtype, bins)

%world's greatest colors
left_grn=[52 153 70]./255;
right_blu=[46 49 146]./255;
proximal_black = [0 0 0];
distal_gray = [.5 .5 .5];



%translating flag input into string for legend
if flag == 0
    flg = 'Lick Detection';
elseif flag == 1
    flg = 'Start Area';
elseif flag == 2  
    flg = 'Low Stem';
elseif flag == 3  
    flg = 'High Stem';
elseif flag == 4
    flg = 'Choice Point';
elseif flag == 5
    flg = 'Approach Arm';
elseif flag == 6
    flg = 'Reward Area';
elseif flag == 7
    flg = 'Return Arm';
else
    error('Flag input must be 0, 1, 2, 3, 4, 5, 6, or 7.');
end


%Plots thin grey line of all X,Y points.
figure
plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
set(gca,'xdir','reverse')
hold on


%DETERMINING FIRING RATE OF EACH CELL IN EACH BIN AROUND FLAG EVENT

%for each trial
for trl = 2:max(eptrials(:,5)) %Can set sub sample of trials: "for trl = #:#"
    
    %FINDING REWARD EVENT TIME (if there is a lick detection) and correct
    if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0 && mode(eptrials(eptrials(:,5)==trl,8))==1
            
        %first lick AFTER choice-instant
        choice = max(eptrials(eptrials(:,5)==trl & eptrials(:,6)==1,1));
        
        if eptrials(eptrials(:,5)==trl, 7)==1
            %find the timestamp of first lick detection
            rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>choice & eptrials(:,10)==1 & eptrials(:,6)==7,1));
        elseif eptrials(eptrials(:,5)==trl, 7)==2
            %find the timestamp of first lick detection
            rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>choice & eptrials(:,10)==1 & eptrials(:,6)==8,1));
        end

    %FINDING REWARD REPRESENTATION how many spikes occured in the window surrounding reward
        for c = 1:length(cells)
          cell = cells(c);
            
            rwdspikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,1)>(rwdevent-wdwbck) & eptrials(:,1)<(rwdevent+wdwfwd),4));
            rate = rwdspikes/(wdwbck+wdwfwd);
          
            rwdwindowrates(trl, 1, c) = rate;
            rwdwindowrates(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));
       
        end
    else 
        %if there is no lick detection, there is no rwdevent
        rwdevent = [];
    end
    
    %FINDING ACTIVE (BIN) REPRESENTATION how many spikes occured in 
    %each bin in the window surrounding the event timestamp on trial trl
    for c = 1:length(cells)
      cell = cells(c);
            
        for currentbin = 1:bins
    
            %TRIAL ACCURACY: correct only (1) (Also must have a lick
            %detection)
            if mode(eptrials(eptrials(:,5)==trl,8))==1 && ~isempty(rwdevent)
    
                %FINDING FLAG EVENT TIME
                if ismember(flag, 1:7)
                    
                    %find arrival, the timestamp of entrance into section (minimum timestamp in
                    %section on trial)
                    event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,11)==flag, 1));
                    
                %if flag input indicates reward
                elseif flag == 0
                    
                    event = rwdevent; %from above
                
                end

                windowlow = event-windowbck;
                windowhigh = event+windowfwd;
                window = (windowbck+windowfwd);
                lowerbound = (currentbin-1)*(window/bins);
                upperbound = currentbin*(window/bins);
                
                spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound),4));
                rate = spikes/((windowbck+windowfwd)/bins);
        
                windowrates(trl, 1, c, currentbin) = rate;
                windowrates(trl, 2, c, currentbin) = mode(eptrials(eptrials(:,5)==trl, 7));
                windowrates(trl, 3, c, currentbin) = mode(eptrials(eptrials(:,5)==trl, 8));
        
                %FINDING POSITION MEANS
                poswindowmeans(trl, 1, currentbin) = mean(eptrials(eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound) & eptrials(:,5)==trl, 2));
                poswindowmeans(trl, 2, currentbin) = mean(eptrials(eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound) & eptrials(:,5)==trl, 3));
                poswindowmeans(trl, 3, currentbin) = mode(eptrials(eptrials(:,5)==trl, 7));
   
                    
                    %PLOTTING POS OVER TIMEWINDOW
                    if currentbin==1 && c==1
        
                        if mode(eptrials(eptrials(:,5)==trl, 7))==1
                            plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', left_grn, 'LineWidth', 0.5, 'LineStyle', '-')
                            hold on
                        elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                            plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', right_blu, 'LineWidth', 0.5, 'LineStyle', '-')
                            hold on
                        end
                    end
            else
                %for error trials, leave rates as NaN, but include trial type and
                %accuracy indexing information
                windowrates(trl, 2, c, currentbin) = mode(eptrials(eptrials(:,5)==trl, 7));
                windowrates(trl, 3, c, currentbin) = mode(eptrials(eptrials(:,5)==trl, 8));
            end
        end 
    end    
end   


%modifying trajectory plot and locating rewards (XYLR)
sections(eptrials);
XYLR = rewards(eptrials);


%REWARD REPRESENTATIONS
LRR = squeeze(rwdwindowrates(rwdwindowrates(:,2)==1, 1, :)); %left reward representation
RRR = squeeze(rwdwindowrates(rwdwindowrates(:,2)==2, 1, :)); %right reward representation

%removing clusters that do not fire during at least one of the reward
%windows. This is essential for the distance measures.
clusts = sum([nansum(LRR)==0; nansum(RRR)==0]);
LRR = LRR(:, clusts == 0);
RRR = RRR(:, clusts == 0);

%readout removed clusters
WITHHELD_CLUSTERS = cells(clusts > 0)

%reward representation covariances
Lcov = nancov(LRR); %left reward covariance
Rcov = nancov(RRR); %right reward covariance



%defining the PREVIOUS (p) trials for indexing purposes
pleft=windowrates(:,2)==1;
pleft(1)=[];
pleft=[pleft;0];

pright=windowrates(:,2)==2;
pright(1)=[];
pright=[pright;0];

pcorrect=windowrates(:,3)==1;
pcorrect(1)=[];
pcorrect=[pcorrect;0];

perror=windowrates(:,3)==2;
perror(1)=[];
perror=[perror;0];



%FIRING RATES on the PREVIOUS trials
C_L_rates = squeeze(windowrates(pleft & pcorrect, 1, :, :)); %RATES BEFORE L-SUCCESS (RIGHT RWD)
C_R_rates = squeeze(windowrates(pright & pcorrect, 1, :, :)); %RATES BEFORE R-SUCCESS (LEFT RWD)
E_L_rates = reshape(windowrates(pleft & perror, 1, :, :), length(windowrates(pleft & perror, 1, 1, 1)), length(cells), bins); %RATES BEFORE L-ERROR (LEFT RWD)
E_R_rates = reshape(windowrates(pright & perror, 1, :, :), length(windowrates(pright & perror, 1, 1, 1)), length(cells), bins); %RATES BEFORE L-ERROR (LEFT RWD)
%removing withheld clusters (see above section)
C_L_rates = C_L_rates(:, clusts == 0, :);
C_R_rates = C_R_rates(:, clusts == 0, :);
E_L_rates = E_L_rates(:, clusts == 0, :);
E_R_rates = E_R_rates(:, clusts == 0, :);
%removing cases where the previous trial was an error
C_L_rates = C_L_rates(isfinite(C_L_rates(:,1)), :, :);
C_R_rates = C_R_rates(isfinite(C_R_rates(:,1)), :, :);
E_L_rates = E_L_rates(isfinite(E_L_rates(:,1)), :, :);
E_R_rates = E_R_rates(isfinite(E_R_rates(:,1)), :, :);



%SPATIAL LOCATIONS on the PREVIOUS trials
C_L_locs_X = squeeze(poswindowmeans(pleft & pcorrect, 1, :, :)); %RATES BEFORE L-SUCCESS (RIGHT RWD)
C_R_locs_X = squeeze(poswindowmeans(pright & pcorrect, 1, :, :)); %RATES BEFORE R-SUCCESS (LEFT RWD)
E_L_locs_X = squeeze(poswindowmeans(pleft & perror, 1, :, :)); %RATES BEFORE L-ERROR (LEFT RWD)
E_R_locs_X = squeeze(poswindowmeans(pright & perror, 1, :, :)); %RATES BEFORE R-ERROR (RIGHT RWD)
C_L_locs_Y = squeeze(poswindowmeans(pleft & pcorrect, 2, :, :)); %RATES BEFORE L-SUCCESS (RIGHT RWD)
C_R_locs_Y = squeeze(poswindowmeans(pright & pcorrect, 2, :, :)); %RATES BEFORE R-SUCCESS (LEFT RWD)
E_L_locs_Y = squeeze(poswindowmeans(pleft & perror, 2, :, :)); %RATES BEFORE L-ERROR (LEFT RWD)
E_R_locs_Y = squeeze(poswindowmeans(pright & perror, 2, :, :)); %RATES BEFORE R-ERROR (RIGHT RWD)

%removing cases where the previous trial was an error AND merging X and Y matrices
C_L_locs(:,:,1) = C_L_locs_X(isfinite(C_L_rates(:,1)), :);
C_L_locs(:,:,2) = C_L_locs_Y(isfinite(C_L_rates(:,1)), :);
C_R_locs(:,:,1) = C_R_locs_X(isfinite(C_R_rates(:,1)), :);
C_R_locs(:,:,2) = C_R_locs_Y(isfinite(C_R_rates(:,1)), :);
E_L_locs(:,:,1) = E_L_locs_X(isfinite(E_L_rates(:,1)), :);
E_L_locs(:,:,2) = E_L_locs_Y(isfinite(E_L_rates(:,1)), :);
E_R_locs(:,:,1) = E_R_locs_X(isfinite(E_R_rates(:,1)), :);
E_R_locs(:,:,2) = E_R_locs_Y(isfinite(E_R_rates(:,1)), :);

%preallocating distance vectors (trial, bin)
C_L_pdists_same = nan(length(C_L_rates(:,1)), bins);
C_R_pdists_same = nan(length(C_R_rates(:,1)), bins);
E_L_pdists_same = nan(length(E_L_rates(:,1)), bins);
E_R_pdists_same = nan(length(E_R_rates(:,1)), bins);
C_L_pdists_opp = nan(length(C_L_rates(:,1)), bins);
C_R_pdists_opp = nan(length(C_R_rates(:,1)), bins);
E_L_pdists_opp = nan(length(E_L_rates(:,1)), bins);
E_R_pdists_opp = nan(length(E_R_rates(:,1)), bins);

C_L_cdists_same = nan(length(C_L_locs(:,1)), bins);
C_R_cdists_same = nan(length(C_R_locs(:,1)), bins);
E_L_cdists_same = nan(length(E_L_locs(:,1)), bins);
E_R_cdists_same = nan(length(E_R_locs(:,1)), bins);
C_L_cdists_opp = nan(length(C_L_locs(:,1)), bins);
C_R_cdists_opp = nan(length(C_R_locs(:,1)), bins);
E_L_cdists_opp = nan(length(E_L_locs(:,1)), bins);
E_R_cdists_opp = nan(length(E_R_locs(:,1)), bins);



%calculating distances and filling distance vectors
for currentbin = 1:bins

    for i=1:length(C_L_rates(:,1))
     
        C_L_pdists_same(i, currentbin) = 1/sqrt(mahal(C_L_rates(i, :, currentbin), RRR)/length(cells(clusts == 0))); %distance to session right (visited) reward representation
        C_L_pdists_opp(i, currentbin) = 1/sqrt(mahal(C_L_rates(i, :, currentbin), LRR)/length(cells(clusts == 0))); %distance to session left (distal) reward representation
        
        C_L_cdists_same(i, currentbin) = 1/dist(XYLR(2,:), [C_L_locs(i, currentbin, 1) C_L_locs(i, currentbin, 2)]'); %distance to session right (visited) reward location
        C_L_cdists_opp(i, currentbin) = 1/dist(XYLR(1,:), [C_L_locs(i, currentbin, 1) C_L_locs(i, currentbin, 2)]'); %distance to session left (distal) reward location
    
    end

    for i=1:length(C_R_rates(:,1))
     
        C_R_pdists_same(i, currentbin) = 1/sqrt(mahal(C_R_rates(i, :, currentbin), LRR)/length(cells(clusts == 0))); %distance to session right (visited) reward representation
        C_R_pdists_opp(i, currentbin) = 1/sqrt(mahal(C_R_rates(i, :, currentbin), RRR)/length(cells(clusts == 0))); %distance to session left (distal) reward representation
        
        C_R_cdists_same(i, currentbin) = 1/dist(XYLR(1,:), [C_R_locs(i, currentbin, 1) C_R_locs(i, currentbin, 2)]'); %distance to session right (visited) reward location
        C_R_cdists_opp(i, currentbin) = 1/dist(XYLR(2,:), [C_R_locs(i, currentbin, 1) C_R_locs(i, currentbin, 2)]'); %distance to session left (distal) reward location
    
    end
    
    for i=1:length(E_L_rates(:,1))
     
        E_L_pdists_same(i, currentbin) = 1/sqrt(mahal(E_L_rates(i, :, currentbin), LRR)/length(cells(clusts == 0))); %distance to session right (visited) reward representation
        E_L_pdists_opp(i, currentbin) = 1/sqrt(mahal(E_L_rates(i, :, currentbin), RRR)/length(cells(clusts == 0))); %distance to session left (distal) reward representation
        E_L_cdists_same(i, currentbin) = 1/dist(XYLR(1,:), [E_L_locs(i, currentbin, 1) E_L_locs(i, currentbin, 2)]'); %distance to session right (visited) reward location
        E_L_cdists_opp(i, currentbin) = 1/dist(XYLR(2,:), [E_L_locs(i, currentbin, 1) E_L_locs(i, currentbin, 2)]'); %distance to session left (distal) reward location
    
    end
    
    for i=1:length(E_R_rates(:,1))
     
        E_R_pdists_same(i, currentbin) = 1/sqrt(mahal(E_R_rates(i, :, currentbin), RRR)/length(cells(clusts == 0))); %distance to session right (visited) reward representation
        E_R_pdists_opp(i, currentbin) = 1/sqrt(mahal(E_R_rates(i, :, currentbin), LRR)/length(cells(clusts == 0))); %distance to session left (distal) reward representation
        E_R_cdists_same(i, currentbin) = 1/dist(XYLR(2,:), [E_R_locs(i, currentbin, 1) E_R_locs(i, currentbin, 2)]'); %distance to session right (visited) reward location
        E_R_cdists_opp(i, currentbin) = 1/dist(XYLR(1,:), [E_R_locs(i, currentbin, 1) E_R_locs(i, currentbin, 2)]'); %distance to session left (distal) reward location
    
    end   
end



%weights
EL = sum(isfinite(E_L_pdists_same(:,1)))/sum([sum(isfinite(E_L_pdists_same(:,1))) sum(isfinite(E_R_pdists_same(:,1)))]);
ER = sum(isfinite(E_R_pdists_same(:,1)))/sum([sum(isfinite(E_L_pdists_same(:,1))) sum(isfinite(E_R_pdists_same(:,1)))]);        



%AVERAGING ACROSS TRIAL TYPE. Correct trials are weighted to the proportion of errors of each trial type

%Population
C_popmean_same = ER.*nanmean(C_L_pdists_same) + EL.*nanmean(C_R_pdists_same);
E_popmean_same = nanmean([E_L_pdists_same;E_R_pdists_same]);
C_popmean_opp = ER.*nanmean(C_L_pdists_opp) + EL.*nanmean(C_R_pdists_opp);
E_popmean_opp = nanmean([E_L_pdists_opp;E_R_pdists_opp]);
C_popstd_same = ER.*nanstd(C_L_pdists_same) + EL.*nanstd(C_R_pdists_same);
E_popstd_same = nanstd([E_L_pdists_same;E_R_pdists_same]);
C_popstd_opp = ER*nanstd(C_L_pdists_opp) + EL*nanstd(C_R_pdists_opp);
E_popstd_opp = nanstd([E_L_pdists_opp;E_R_pdists_opp]);

%Cartesian
C_crtmean_same = ER.*nanmean(C_L_cdists_same) + EL.*nanmean(C_R_cdists_same);
E_crtmean_same = nanmean([E_L_cdists_same;E_R_cdists_same]);
C_crtmean_opp = ER.*nanmean(C_L_cdists_opp) + EL.*nanmean(C_R_cdists_opp);
E_crtmean_opp = nanmean([E_L_cdists_opp;E_R_cdists_opp]);
C_crtstd_same = ER.*nanstd(C_L_cdists_same) + EL.*nanstd(C_R_cdists_same);
E_crtstd_same = nanstd([E_L_cdists_same;E_R_cdists_same]);
C_crtstd_opp = ER*nanstd(C_L_cdists_opp) + EL*nanstd(C_R_cdists_opp);
E_crtstd_opp = nanstd([E_L_cdists_opp;E_R_cdists_opp]);

%Lengths
Clen = sum(isfinite([C_L_pdists_opp(:,1);C_R_pdists_opp(:,1)]));
Elen = sum(isfinite([E_L_pdists_opp(:,1);E_R_pdists_opp(:,1)]));



%PLOTTING DISTANCES OVER TIME BINS

%x-axis prep to make negatives times before event and positve times after
xaxistick = (0:(bins-1)) ./ (bins-1)*(windowbck+windowfwd);
correction = (-windowbck).*ones(1, bins);
xaxistick = xaxistick + correction;


%POPULATION distances at each bin
figure
hold on

h1 = errorbar(xaxistick, C_popmean_same, C_popstd_same./sqrt(Clen),'k-', 'linewidth', 2); % BEFORE SUCCESS population distance to proximal reward
h2 = errorbar(xaxistick, C_popmean_opp, C_popstd_opp./sqrt(Clen),'-', 'linewidth', 2, 'Color',distal_gray); % BEFORE SUCCESS population distance to distal reward
h3 = errorbar(xaxistick, E_popmean_same, E_popstd_same./sqrt(Elen),'k--', 'linewidth', 2); % BEFORE ERROR population distance to proximal reward
h4 = errorbar(xaxistick, E_popmean_opp, E_popstd_opp./sqrt(Elen),'--', 'linewidth', 2, 'Color',distal_gray); % BEFORE ERROR population distance to distal reward
h5 = plot([0 0],[0 1.2*(nanmax([nanmax(C_popmean_same);nanmax(E_popmean_same)]))],'r-', 'LineWidth',3); %adding a red vertical line at the flag event instant
hold off

axis([-windowbck, windowfwd, 0, 1.2*(nanmax([nanmax(C_popmean_same);nanmax(E_popmean_same)]))])
set(gca,'fontsize', 20)
xlabel('Time (Sec)', 'fontsize', 20)
ylabel('Inverse Distance (1/Std-Hz)', 'fontsize', 20)
title('Proximity to Reward Representations')
legend([h1, h2, h3, h4, h5], 'Success-Proximal', 'Success-Distal', 'Error-Proximal', 'Error-Distal', num2str(flg), 'location', 'northeastoutside');


%CARTESIAN distances
figure
hold on
h6 = errorbar(xaxistick, C_crtmean_same, C_crtstd_same./sqrt(Clen),'k-', 'linewidth', 2); % BEFORE SUCCESS population distance to proximal reward
h7 = errorbar(xaxistick, C_crtmean_opp, C_crtstd_opp./sqrt(Clen),'-', 'linewidth', 2, 'Color',distal_gray); % BEFORE SUCCESS population distance to distal reward
h8 = errorbar(xaxistick, E_crtmean_same, E_crtstd_same./sqrt(Elen),'k--', 'linewidth', 2); % BEFORE ERROR population distance to proximal reward
h9 = errorbar(xaxistick, E_crtmean_opp, E_crtstd_opp./sqrt(Elen),'--', 'linewidth', 2, 'Color',distal_gray); % BEFORE ERROR population distance to distal reward
h10 = plot([0 0],[0 1.2*(nanmax([nanmax(C_crtmean_same);nanmax(E_crtmean_same)]))],'r-', 'LineWidth',3); %adding a red vertical line at the event point
hold off

axis([-windowbck, windowfwd, 0, 1.2*(nanmax([nanmax(C_crtmean_same);nanmax(E_crtmean_same)]))])
set(gca,'fontsize', 20)
xlabel('Time (Sec)', 'fontsize', 20)
ylabel('Inverse Distance (1/cm)', 'fontsize', 20)
title('Proximity to Reward Locations')
legend([h6, h7, h8, h9, h10], 'Success-Proximal', 'Success-Distal', 'Error-Proximal', 'Error-Distal', num2str(flg), 'location', 'northeastoutside');






            
            
            