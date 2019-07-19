function trlrwdrep(eptrials, cells, bins, windowbck, windowfwd, flag)

%Individually plots a line for each trial showing the changing 
%mahalanobis distance to the reward representation over the timewindow.
%
%One figure for the previous reward location, one figure for the future
%reward location.
%
%Solid lines for correct trials, dotted lines for error trials
%
%The reward representation is averaged from all first lick detections.
%While this does include error trials, error trials often do not have lick 
%detections.
%

%FLAG: The maze is divided into 6 sections by "folding" over the two halves along
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
%This function will struggle with time windows encompassing entrance into
%the start area, as this is accompanied by a change in trial number.
%

%Reward representation window
wdwbck=0;
wdwfwd=1;
                
%nans(trials, rate/trialtype/accuracy, cells)
rwdwindowrates = nan(max(eptrials(:,5))-1, 3, length(cells));

%nans(rates, rate/trialtype/accuracy, bins, cells)
windowrates = nan(max(eptrials(:,5))-1, 3, bins, length(cells));

%nans(bins, accuracy)
zdists = nan(bins,2);

%world's greatest colors
%left_green=[52 153 70]./255;
%right_blue=[46 49 146]./255;
future_orange = [255/255 140/255 0/255]; %DarkOrange
past_blue = [0/255 0/255 128/255]; %Navy
proximal_brown = [165 42 42]./255;
distal_blue = [30 144 255]./255;
error_red = [158 8 8]./255;
correct_gray = [120 120 120]./255;

%translating flag input into string for legend
if flag == 0
    flg = 'Lick Detection';
elseif flag == 1
    flg = 'Ent. Start Area';
elseif flag == 2  
    flg = 'Ent. Low Stem';
    elseif flag == 3  
    flg = 'Ent. High Stem';
elseif flag == 4
    flg = 'Ent. Choice Point';
elseif flag == 5
    flg = 'Ent. Approach Arm';
elseif flag == 6
    flg = 'Ent. Reward Area';
elseif flag == 7
    flg = 'Ent. Return Arm';
else
    error('Flag input must be 0, 1, 2, 3, 4, 5, 6, or 7.')
end

%Plots thin grey line of all X,Y points.
figure
plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
set(gca,'xdir','reverse')
hold on

%%BINS AROUND FLAG%%

%for each trial
for trl = 2:max(eptrials(:,5))
%Can set sub sample of trials: "for trl = #:#"

    %FINDING REWARD EVENT TIME (if there is a lick detection)
    if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0 && mode(eptrials(eptrials(:,5)==trl,8))==1
                    
        if eptrials(eptrials(:,5)==trl, 7)==1
            %find the timestamp of first lick detection
            rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,1));
        elseif eptrials(eptrials(:,5)==trl, 7)==2
            %find the timestamp of first lick detection
            rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,1));
        end
        
        %FINDING REWARD REPRESENTATION how many spikes occured in the 1s window surrounding reward
        for c = 1:length(cells)
          cell = cells(c);
            
            rwdspikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,1)>(rwdevent-wdwbck) & eptrials(:,1)<(rwdevent+wdwfwd),4));
            rate = rwdspikes/(wdwbck+wdwfwd);
        
            rwdwindowrates(trl, 1, c) = rate;
            rwdwindowrates(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7)); %trial type
            rwdwindowrates(trl, 3, c) = mode(eptrials(eptrials(:,5)==trl, 8)); %accuracy
            
        end
    end

    %FINDING FLAG EVENT TIME
    if ismember(flag, 1:7)
                    
        %find arrival, the timestamp of entrance into section (minimum timestamp in
        %section on trial)
        event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==flag, 1));
                    
    %if flag input indicates reward
    elseif flag == 0
                
        event = rwdevent; %from above
                
    end
    
    
    %FINDING ACTIVE (BIN) REPRESENTATION how many spikes occured in 
    %each bin in the window surrounding the event timestamp on trial trl
    for c = 1:length(cells)
          cell = cells(c);
            
        for currentbin = 1:bins
       
        	windowlow = event-windowbck;
        	windowhigh = event+windowfwd;
        	window = (windowbck+windowfwd);
            lowerbound = (currentbin-1)*(window/bins);
            upperbound = currentbin*(window/bins);
                
            spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound),4));
            rate = spikes/((windowbck+windowfwd)/bins);
        
            windowrates(trl, 1, currentbin, c) = rate;
            windowrates(trl, 2, currentbin, c) = mode(eptrials(eptrials(:,5)==trl, 7)); %trial type
            windowrates(trl, 3, currentbin, c) = mode(eptrials(eptrials(:,5)==trl, 8)); %accuracy
            
            %PLOTTING POS OVER TIMEWINDOW
            if currentbin==1 && c==1
                
                %correct trials
                if mode(eptrials(eptrials(:,5)==trl, 8))==1
                    p1 = plot(eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', [.25 .25 .25], 'LineWidth', 0.5, 'LineStyle', '-');
                	hold on
                %error trials
                elseif mode(eptrials(eptrials(:,5)==trl, 8))==2
                	p2 = plot(eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', [178/255 34/255 34/255], 'LineWidth', 0.5, 'LineStyle', '-');
                	hold on
                end
            
            end
            
        end  
    end
end

sections(eptrials);
rewards(eptrials);
legend([p1, p2],'Correct', 'Error', 'location', 'northeastoutside');
hold off

%Population distances to each reward location from average of current bin.
LRR = squeeze(rwdwindowrates(rwdwindowrates(:,2)==1, 1, :)); %left reward representation
RRR = squeeze(rwdwindowrates(rwdwindowrates(:,2)==2, 1, :)); %right reward representation

%finding clusters that never fire during at least one of the reward windows
clusts = sum([sum(LRR)==0; sum(RRR)==0]);

%removing those clusters from reward representations. This is essential for
%distance measures.
LRR = LRR(:, clusts == 0);
RRR = RRR(:, clusts == 0);

%readout reporting withheld clusters
WITHHELD_CLUSTERS = cells(clusts > 0)

Lcov = nancov(LRR); %left reward covariance
Rcov = nancov(RRR); %right reward covariance

%windowrates

%bin representations. Produces vectors: (trials, bins, cells)
C_L_rates = squeeze(windowrates(windowrates(:,2)==1 & windowrates(:,3)==1, 1, :, :)); %correct left
C_R_rates = squeeze(windowrates(windowrates(:,2)==2 & windowrates(:,3)==1, 1, :, :)); %correct right
E_L_rates = reshape(windowrates(windowrates(:,2)==1 & windowrates(:,3)==2, 1, :, :), length(windowrates(windowrates(:,2)==1 & windowrates(:,3)==2, 1, 1, 1)), bins, length(cells)); %error left
E_R_rates = reshape(windowrates(windowrates(:,2)==2 & windowrates(:,3)==2, 1, :, :), length(windowrates(windowrates(:,2)==2 & windowrates(:,3)==2, 1, 1, 1)), bins, length(cells)); %error right


%preallocating distance vectors
C_L_dists_past = nan(length(C_L_rates(:,1,1)), length(C_L_rates(1,:,1)));
C_R_dists_past = nan(length(C_R_rates(:,1,1)), length(C_R_rates(1,:,1)));
C_L_dists_futr = nan(length(C_L_rates(:,1,1)), length(C_L_rates(1,:,1)));
C_R_dists_futr = nan(length(C_R_rates(:,1,1)), length(C_R_rates(1,:,1)));

if ~isempty(E_L_rates)
    E_L_dists_past = nan(length(E_L_rates(:,1,1)), length(E_L_rates(1,:,1)));
    E_L_dists_futr = nan(length(E_L_rates(:,1,1)), length(E_L_rates(1,:,1)));
end

if ~isempty(E_R_rates)
    E_R_dists_past = nan(length(E_R_rates(:,1,1)), length(E_R_rates(1,:,1)));
    E_R_dists_futr = nan(length(E_R_rates(:,1,1)), length(E_R_rates(1,:,1)));
end

%calculating distances and filling distance vectors
for trl=1:length(C_L_rates(:,1,1))
    for bin=1:length(C_L_rates(1,:,1))
        
        %distance to right (past) reward representation
        C_L_dists_past(trl,bin) = 1/sqrt(mahal(squeeze(C_L_rates(trl,bin,clusts==0))', RRR)/length(cells(clusts == 0)));
        
        %distance to left (correct future) reward representation
        C_L_dists_futr(trl,bin) = 1/sqrt(mahal(squeeze(C_L_rates(trl,bin,clusts==0))', LRR)/length(cells(clusts == 0)));

    end
end

for trl=1:length(C_R_rates(:,1,1)) 
    for bin=1:length(C_R_rates(1,:,1))
        
        %distance to left (past) reward representation
        C_R_dists_past(trl,bin) = 1/sqrt(mahal(squeeze(C_R_rates(trl,bin,clusts==0))', LRR)/length(cells(clusts == 0)));
        
        %distance to right (correct future) reward representation
        C_R_dists_futr(trl,bin) = 1/sqrt(mahal(squeeze(C_R_rates(trl,bin,clusts==0))', RRR)/length(cells(clusts == 0)));
        
    end
end


if ~isempty(E_L_rates)
for trl=1:length(E_L_rates(:,1,1))
    
    for bin=1:length(E_L_rates(1,:,1))
        
        %distance to left (past) reward representation
        E_L_dists_past(trl,bin) = 1/sqrt(mahal(squeeze(E_L_rates(trl,bin,clusts==0))', LRR)/length(cells(clusts == 0)));
        
        %distance to right (correct future) reward representation
        E_L_dists_futr(trl,bin) = 1/sqrt(mahal(squeeze(E_L_rates(trl,bin,clusts==0))', RRR)/length(cells(clusts == 0)));
        
    end
end
end

if ~isempty(E_R_rates)
for trl=1:length(E_R_rates(:,1,1))
    
    for bin=1:length(E_R_rates(1,:,1))
        
        %distance to right (past) reward representation
        E_R_dists_past(trl,bin) = 1/sqrt(mahal(squeeze(E_R_rates(trl,bin,clusts==0))', RRR)/length(cells(clusts == 0)));
        
        %distance to left (correct future) reward representation
        E_R_dists_futr(trl,bin) = 1/sqrt(mahal(squeeze(E_R_rates(trl,bin,clusts==0))', LRR)/length(cells(clusts == 0)));
        
    end
end
end

%combining like matrices 
C_dists_past = [C_L_dists_past;C_R_dists_past];
C_dists_futr = [C_L_dists_futr;C_R_dists_futr];

if isempty(E_L_rates) && ~isempty(E_R_rates)
    
    E_dists_past = E_R_dists_past;
    E_dists_futr = E_R_dists_futr;
    
elseif ~isempty(E_L_rates) && isempty(E_R_rates)
    
    E_dists_past = E_L_dists_past;
    E_dists_futr = E_L_dists_futr;
    
else
    
    E_dists_past = [E_L_dists_past;E_R_dists_past];
    E_dists_futr = [E_L_dists_futr;E_R_dists_futr];
    
end


%discrimination plot
C_zdists = (nanmean(C_dists_futr) - nanmean(C_dists_past))/sqrt(nanstd(C_dists_futr)/sum(isfinite(C_dists_futr)) + nanstd(C_dists_past)/sum(isfinite(C_dists_past)));
E_zdists = (nanmean(E_dists_futr) - nanmean(E_dists_past))/sqrt(nanstd(E_dists_futr)/sum(isfinite(E_dists_futr)) + nanstd(E_dists_past)/sum(isfinite(E_dists_past)));

pos_C_zdists = C_zdists.*(C_zdists>0);
neg_C_zdists = C_zdists.*(C_zdists<0);
pos_E_zdists = E_zdists.*(E_zdists>0);
neg_E_zdists = E_zdists.*(E_zdists<0);


%range for yaxis
zrng = 1.2*max([max(abs(C_zdists));max(abs(E_zdists))]);


%converting to a similarity metric where approaching infinite is perfectly 
%similar and approaching 0 is perfectly dissimilar.
%C_dists_past = ones(size(C_dists_past))./C_dists_past;
%C_dists_futr = ones(size(C_dists_futr))./C_dists_futr;
%E_dists_past = ones(size(E_dists_past))./E_dists_past;
%E_dists_futr = ones(size(E_dists_futr))./E_dists_futr;

%SORTING FOR VISUALIZATION
%C_dists_past = sort(C_dists_past,2);
%C_dists_futr = sort(C_dists_futr,2);
%E_dists_past = sort(E_dists_past,2);
%E_dists_futr = sort(E_dists_futr,2);

%preallocating maximum similarity vectors
max_C_dists_past = nan(length(C_dists_past(:,1)),1);
max_C_dists_futr = nan(length(C_dists_futr(:,1)),1);
max_E_dists_past = nan(length(E_dists_past(:,1)),1);
max_E_dists_futr = nan(length(E_dists_futr(:,1)),1);

%preallocating mean similarity vectors
mean_C_dists_past = nan(length(C_dists_past(:,1)),1);
mean_C_dists_futr = nan(length(C_dists_futr(:,1)),1);
mean_E_dists_past = nan(length(E_dists_past(:,1)),1);
mean_E_dists_futr = nan(length(E_dists_futr(:,1)),1);

%preallocating mean similarity vectors
min_C_dists_past = nan(length(C_dists_past(:,1)),1);
min_C_dists_futr = nan(length(C_dists_futr(:,1)),1);
min_E_dists_past = nan(length(E_dists_past(:,1)),1);
min_E_dists_futr = nan(length(E_dists_futr(:,1)),1);

%x-axis prep to make negatives times before event and positve times after
xaxistick = (0:(bins-1)) ./ (bins-1)*(windowbck+windowfwd);
correction = (-windowbck).*ones(1, bins);
xaxistick = xaxistick + correction;


figure
subplot(2,4,1);
hold on
for i = 1:length(C_dists_past(:,1))
    
    plot(xaxistick, C_dists_past(i,:), 'linewidth', .8, 'Color', past_blue);
    plot(xaxistick, C_dists_futr(i,:), 'linewidth', .8, 'Color', future_orange);
    max_C_dists_past(i) = nanmax(C_dists_past(i,:));
    max_C_dists_futr(i) = nanmax(C_dists_futr(i,:));
    mean_C_dists_past(i) = nanmean(C_dists_past(i,:));
    mean_C_dists_futr(i) = nanmean(C_dists_futr(i,:));
    min_C_dists_past(i) = nanmin(C_dists_past(i,:));
    min_C_dists_futr(i) = nanmin(C_dists_futr(i,:));
    
end

set(gca,'fontsize', 15)
ylabel('Similarity (1/MDistance)', 'fontsize', 15)
title('Correct Distances', 'fontsize', 20)


subplot(2,4,5)
hold on
for i = 1:length(E_dists_past(:,1))
    
    plot(xaxistick, E_dists_past(i,:), 'linewidth', 1, 'Color', past_blue);
    plot(xaxistick, E_dists_futr(i,:), 'linewidth', 1, 'Color', future_orange);
    max_E_dists_past(i) = nanmax(E_dists_past(i,:));
    max_E_dists_futr(i) = nanmax(E_dists_futr(i,:));
    mean_E_dists_past(i) = nanmean(E_dists_past(i,:));
    mean_E_dists_futr(i) = nanmean(E_dists_futr(i,:));
    min_E_dists_past(i) = nanmin(E_dists_past(i,:));
    min_E_dists_futr(i) = nanmin(E_dists_futr(i,:));
    
end
set(gca,'fontsize', 15)
ylabel('Similarity (1/MDistance)', 'fontsize', 15)
xlabel('Time (s)', 'fontsize', 20)
title('Error Distances', 'fontsize', 20)
yaxis = 1.1*max(max([max_C_dists_past;max_C_dists_futr;max_E_dists_past;max_E_dists_futr]));
plot([0 0],[0 yaxis],'r-', 'LineWidth',3)
axis([-windowbck, windowfwd, 0, yaxis])
hold off

subplot(2,4,1);
hold on
plot([0 0],[0 yaxis],'r-', 'LineWidth',3)
axis([-windowbck, windowfwd, 0, yaxis])
hold off

%plotting averages
subplot(2,4,2)
hold on
errorbar(xaxistick, nanmean(C_dists_futr), nanstd(C_dists_futr)./sqrt(sum(isfinite(C_dists_futr))),'-', 'linewidth', 2, 'Color', future_orange); % population distance to proximal reward
errorbar(xaxistick, nanmean(C_dists_past), nanstd(C_dists_past)./sqrt(sum(isfinite(C_dists_past))),'-', 'linewidth', 2, 'Color', past_blue); % population distance to distal reward
plot([0 0],[0 yaxis],'r-', 'LineWidth',3);
set(gca,'fontsize', 15)
ylabel('Similarity (1/MDistance)', 'fontsize', 15)
title('Mean Correct Distances', 'fontsize', 20)
axis([-windowbck, windowfwd, 0, yaxis])
hold off

subplot(2,4,6)
hold on
errorbar(xaxistick, nanmean(E_dists_futr), nanstd(E_dists_futr)./sqrt(sum(isfinite(E_dists_futr))),'-', 'linewidth', 2, 'Color', future_orange); % population distance to proximal reward
errorbar(xaxistick, nanmean(E_dists_past), nanstd(E_dists_past)./sqrt(sum(isfinite(E_dists_past))),'-', 'linewidth', 2, 'Color', past_blue); % population distance to distal reward
plot([0 0],[0 yaxis],'r-', 'LineWidth',3)
set(gca,'fontsize', 15)
ylabel('Similarity (1/MDistance)', 'fontsize', 15)
xlabel('Time (s)', 'fontsize', 20)
title('Mean Error Distances', 'fontsize', 20)
axis([-windowbck, windowfwd, 0, yaxis])
hold off


subplot(2,4,3)
hold on

h1 = bar(xaxistick, neg_C_zdists, 1, 'FaceColor', past_blue, 'EdgeColor', past_blue);
h2 = bar(xaxistick, pos_C_zdists, 1, 'FaceColor', future_orange, 'EdgeColor', future_orange);
h3 = plot([0 0],[-zrng zrng],'r-', 'LineWidth',3);

plot([min(xaxistick) max(xaxistick)],[0 0],'k-', 'LineWidth',1)
set(gca,'fontsize', 15)
ylabel('Specificity (Z-Score Difference)', 'fontsize', 15)
title('Correct Discrimination', 'fontsize', 20)
axis([-windowbck, windowfwd, -zrng, zrng])
legend([h1, h2, h3],'Last Visited Reward', 'Correct Future Reward', num2str(flg), 'location', 'northeastoutside');

hold off


subplot(2,4,7)
hold on

bar(xaxistick, pos_E_zdists, 1, 'FaceColor', future_orange, 'EdgeColor', future_orange)
bar(xaxistick, neg_E_zdists, 1, 'FaceColor', past_blue, 'EdgeColor', past_blue)

plot([min(xaxistick) max(xaxistick)],[0 0],'k-', 'LineWidth',1)
plot([0 0],[-zrng zrng],'r-', 'LineWidth',3)
set(gca,'fontsize', 15)
ylabel('Specificity (Z-Score Difference)', 'fontsize', 15)
xlabel('Time (s)', 'fontsize', 20)
title('Discrimination Error', 'fontsize', 20)
axis([-windowbck, windowfwd, -zrng, zrng])

hold off




%max barplot inputs AVERAGING ACROSS TRIAL TYPE
Cmean_past = nanmean(max_C_dists_past);
Cmean_futr = nanmean(max_C_dists_futr);
Emean_past = nanmean(max_E_dists_past);
Emean_futr = nanmean(max_E_dists_futr);

Cstd_past = nanstd(max_C_dists_past);
Cstd_futr = nanstd(max_C_dists_futr);
Estd_past = nanstd(max_E_dists_past);
Estd_futr = nanstd(max_E_dists_futr);

Clen=sum(~isnan(Cmean_past));
Elen=sum(~isnan(Emean_past));

means=[Cmean_past, Cmean_futr; Emean_past, Emean_futr];
stand=[Cstd_past, Cstd_futr; Estd_past, Estd_futr];
N=[Clen, Clen; Elen, Elen];
errr=stand./sqrt(N);

%mean barplot inputs AVERAGING ACROSS TRIAL TYPE
Cmean_past1 = nanmean(mean_C_dists_past);
Cmean_futr1 = nanmean(mean_C_dists_futr);
Emean_past1 = nanmean(mean_E_dists_past);
Emean_futr1 = nanmean(mean_E_dists_futr);

Cstd_past1 = nanstd(mean_C_dists_past);
Cstd_futr1 = nanstd(mean_C_dists_futr);
Estd_past1 = nanstd(mean_E_dists_past);
Estd_futr1 = nanstd(mean_E_dists_futr);

means1=[Cmean_past1, Cmean_futr1; Emean_past1, Emean_futr1];
stand1=[Cstd_past1, Cstd_futr1; Estd_past1, Estd_futr1];
errr1=stand1./sqrt(N);

%min barplot inputs AVERAGING ACROSS TRIAL TYPE
Cmean_past2 = nanmean(min_C_dists_past);
Cmean_futr2 = nanmean(min_C_dists_futr);
Emean_past2 = nanmean(min_E_dists_past);
Emean_futr2 = nanmean(min_E_dists_futr);

Cstd_past2 = nanstd(min_C_dists_past);
Cstd_futr2 = nanstd(min_C_dists_futr);
Estd_past2 = nanstd(min_E_dists_past);
Estd_futr2 = nanstd(min_E_dists_futr);

means2=[Cmean_past2, Cmean_futr2; Emean_past2, Emean_futr2];
stand2=[Cstd_past2, Cstd_futr2; Estd_past2, Estd_futr2];
errr2=stand2./sqrt(N);

%min barplot function
figure
bar0 = subplot(3,1,1);
barweb(means2, errr2, 1.00);

%plot details
b1=get(gca, 'Children');
set(b1(3), 'FaceColor', future_orange)
set(b1(4), 'FaceColor', past_blue)
set(gca,'FontSize',15)
set(gca,'LineWidth', 1)
set(gca,'XTickLabel',[])
title('Reward Representation and Memory Performance','fontsize', 20)
legend('Last Visited Reward', 'Correct Future Reward', 'location', 'northeast')
ylabel('Min. Similarity', 'fontsize', 15)



%max barplot function
bar1 = subplot(3,1,2);
hold on
barweb(means, errr, 1.00);

%plot details
b=get(gca, 'Children');
set(b(3), 'FaceColor', future_orange)
set(b(4), 'FaceColor', past_blue)
set(gca,'FontSize',15)
set(gca,'LineWidth', 1)
ylabel('Max. Similarity', 'fontsize', 15)
set(gca,'XTickLabel',[])
y=ylim;
yaxisbar = [0 y(2)];
ylim(yaxisbar)

%ax = get(bar0,'Parent');
set(bar0,'YLim', yaxisbar);



%mean barplot function
bar2 = subplot(3,1,3);
barweb(means1, errr1, 1.00);

%plot details
b1=get(gca, 'Children');
set(b1(3), 'FaceColor', future_orange)
set(b1(4), 'FaceColor', past_blue)
set(gca,'FontSize',15)
set(gca,'LineWidth', 1)
ylim(yaxisbar)
ylabel('Mean Similarity', 'fontsize', 15)
set(gca,'XTickLabel',{'Success', 'Error'}, 'fontsize', 15)



