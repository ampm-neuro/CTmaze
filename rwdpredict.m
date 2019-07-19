function [Cmean_same, Emean_same, Cmean_opp, Emean_opp, Cmean, Emean, specific_z_dist] = rwdpredict(eptrials, cells)

%Plots the mean population distances between the reward representation on 
%the previous trial and the mean population representation for that reward 
%location. Plots both error and correct (current) trials. 
%
%The reward representation is averaged from all first lick detections on correct trials.
%

%REWARD WINDOW TIMES HERE
wdwbck=0;
wdwfwd=1;

%input check
%must have committed this many errors
if length(unique(eptrials(eptrials(:,8)==2,5))) < 1
    display('INSUFFICIENT ERRORS')
end




%nans(trials, rate/trialtype/accuracy, cells)
rwdwindowrates = nan(max(eptrials(:,5))-1, 3, length(cells));

%world's greatest colors
%left_green=[52 153 70]./255;
%right_blue=[46 49 146]./255;
proximal_brown = [180/255 180/255 180/255]; %DarkGray
distal_blue = [0/255 0/255 0/255]; %Black
error_red = [180/255 180/255 180/255]; %DarkGray
correct_gray = [0/255 0/255 0/255]; %Black


%for each trial
for trl = 2:max(eptrials(:,5))
%for trl = 21:50

    %find firing rate within window around lick detection
    for c = 1:length(cells)
      cell = cells(c);
             
        %if there is a lick detection and correct
        if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0 && mode(eptrials(eptrials(:,5)==trl,8))==1
            
            %if left trial type
            if mode(eptrials(eptrials(:,5)==trl, 7))==1
                %find the timestamp of first lick detection occuring in the
                %left reward area
                rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7, 1));
            %if right trial type
            elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                %find the timestamp of first lick detection occuring in the
                %right reward area
                rwdevent = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8, 1));
            end
            
            
            rwdspikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,1)>(rwdevent-wdwbck) & eptrials(:,1)<(rwdevent+wdwfwd),4));
            rate = rwdspikes/(wdwbck+wdwfwd);
        
            rwdwindowrates(trl, 1, c) = rate;
            rwdwindowrates(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));
            rwdwindowrates(trl, 3, c) = mode(eptrials(eptrials(:,5)==trl, 8));
            
        else        
            
        %DEALING WITH TRIALS THAT DO NOT HAVE A LICK DETECTION        
        %rwdwindowrates(trl, 1, c) these are left as NAN
        rwdwindowrates(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));
        rwdwindowrates(trl, 3, c) = mode(eptrials(eptrials(:,5)==trl, 8));
        
        end
    end         
end

%session reward representations
LRR = squeeze(rwdwindowrates(rwdwindowrates(:,2)==1, 1, :)); %left reward representations
RRR = squeeze(rwdwindowrates(rwdwindowrates(:,2)==2, 1, :)); %right reward representations

%finding clusters that do not fire at least once in both rwd locations
clusts = sum([nansum(LRR)==0; nansum(RRR)==0]);

%removing those clusters from reward representations. This is essential for
%distance measures.
LRR = LRR(:, clusts == 0);
LRR = LRR(~any(isnan(LRR),2),:);
RRR = RRR(:, clusts == 0);
RRR = RRR(~any(isnan(RRR),2),:);

%readout withheld clusters
WITHHELD_CLUSTERS = cells(clusts > 0)

%covariance
Lcov = nancov(LRR); %left reward covariance
Rcov = nancov(RRR); %right reward covariance
COV = (Lcov+Rcov)/2;

RWD_REP_dist_PooledM = sqrt(((nanmean(LRR)-nanmean(RRR))*(inv(COV))*(nanmean(LRR)-nanmean(RRR))')/length(cells(clusts == 0)));
RWD_REP_dist_trlXtrlM = (mean(sqrt(mahal(LRR,RRR)/length(cells(clusts == 0)))) + mean(sqrt(mahal(RRR,LRR)/length(cells(clusts == 0)))))/2;
%RWD_REP_meansM = (sqrt(mahal(nanmean(LRR),RRR)/length(cells(clusts == 0))) + sqrt(mahal(nanmean(RRR),LRR)/length(cells(clusts == 0))))/2;
%RWD_REP_dist_Bhatt = (bhatt(LRR, RRR) + bhatt(RRR, LRR))/2;


%defining the PREVIOUS (p) trials for type and accuracy indexing
pleft=rwdwindowrates(:,2)==1;
pleft(1)=[];
pleft=[pleft;0];

pright=rwdwindowrates(:,2)==2;
pright(1)=[];
pright=[pright;0];

pcorrect=rwdwindowrates(:,3)==1;
pcorrect(1)=[];
pcorrect=[pcorrect;0];

perror=rwdwindowrates(:,3)==2;
perror(1)=[];
perror=[perror;0];

%single-trial reward representations on the PREVIOUS trials
C_L_rates = squeeze(rwdwindowrates(pleft & pcorrect, 1, :)); %RATES BEFORE L-SUCCESS (RIGHT RWD)
C_R_rates = squeeze(rwdwindowrates(pright & pcorrect, 1, :)); %RATES BEFORE R-SUCCESS (LEFT RWD)
E_L_rates = reshape(rwdwindowrates(pleft & perror, 1, :, :), length(rwdwindowrates(pleft & perror, 1, 1, 1)), length(cells)); %RATES BEFORE L-ERROR (LEFT RWD)
E_R_rates = reshape(rwdwindowrates(pright & perror, 1, :, :), length(rwdwindowrates(pright & perror, 1, 1, 1)), length(cells)); %RATES BEFORE R-ERROR (RIGHT RWD)

C_L_rates = C_L_rates(isfinite(C_L_rates(:,1)), clusts == 0);
C_R_rates = C_R_rates(isfinite(C_R_rates(:,1)), clusts == 0);
E_L_rates = E_L_rates(isfinite(E_L_rates(:,1)), clusts == 0);
E_R_rates = E_R_rates(isfinite(E_R_rates(:,1)), clusts == 0);

%preallocating distance vectors
C_L_dists_same = nan(length(C_L_rates(:,1)), 1);
C_R_dists_same = nan(length(C_R_rates(:,1)), 1);
E_L_dists_same = nan(length(E_L_rates(:,1)), 1);
E_R_dists_same = nan(length(E_R_rates(:,1)), 1);
C_L_dists_opp = nan(length(C_L_rates(:,1)), 1);
C_R_dists_opp = nan(length(C_R_rates(:,1)), 1);
E_L_dists_opp = nan(length(E_L_rates(:,1)), 1);
E_R_dists_opp = nan(length(E_R_rates(:,1)), 1);


%calculating distances and filling distance vectors
for i=1:length(C_L_rates(:,1))
    %C_L_dists_same(i) = 1/sqrt(mahal(C_L_rates(i,:), RRR)/length(cells(clusts == 0))); %distance to session right (visited) reward representation
    C_L_dists_same(i) = dist(C_L_rates(i,:), mean(RRR)')/sqrt(length(cells(clusts == 0)));
    
    %C_L_dists_opp(i) = 1/sqrt(mahal(C_L_rates(i,:), LRR)/length(cells(clusts == 0))); %distance to session left (opposite) reward representation
    C_L_dists_opp(i) = dist(C_L_rates(i,:), mean(LRR)')/sqrt(length(cells(clusts == 0)));
end

for i=1:length(C_R_rates(:,1))
    %C_R_dists_same(i) = 1/sqrt(mahal(C_R_rates(i,:), LRR)/length(cells(clusts == 0))); %distance to session right (visited) reward representation
    C_R_dists_same(i) = dist(C_R_rates(i,:), mean(LRR)')/sqrt(length(cells(clusts == 0)));
    
    %C_R_dists_opp(i) = 1/sqrt(mahal(C_R_rates(i,:), RRR)/length(cells(clusts == 0))); %distance to session left (opposite) reward representation
    C_R_dists_opp(i) = dist(C_R_rates(i,:), mean(RRR)')/sqrt(length(cells(clusts == 0)));
end

if ~isempty(E_L_rates)
    for i=1:length(E_L_rates(:,1))
        %E_L_dists_same(i) = 1/sqrt(mahal(E_L_rates(i,:), LRR)/length(cells(clusts == 0))); %distance to session left (visited) reward representation
        E_L_dists_same(i) = dist(E_L_rates(i,:), mean(LRR)')/sqrt(length(cells(clusts == 0)));
        
        %E_L_dists_opp(i) = 1/sqrt(mahal(E_L_rates(i,:), RRR)/length(cells(clusts == 0))); %distance to session right (opposite) reward representation
        E_L_dists_opp(i) = dist(E_L_rates(i,:), mean(RRR)')/sqrt(length(cells(clusts == 0)));
    end
end

if ~isempty(E_R_rates)
    for i=1:length(E_R_rates(:,1))
        
        %E_R_dists_same(i) = 1/sqrt(mahal(E_R_rates(i,:), RRR)/length(cells(clusts == 0))); %distance to session right (visited) reward representation
        E_R_dists_same(i) = 1/dist(E_R_rates(i,:), mean(RRR)')/length(cells(clusts == 0));
        
        %E_R_dists_opp(i) = 1/sqrt(mahal(E_R_rates(i,:), LRR)/length(cells(clusts == 0))); %distance to session left (opposite) reward representation
        E_R_dists_opp(i) = 1/dist(E_R_rates(i,:), mean(LRR)')/length(cells(clusts == 0));
        
        
    end
end


%This deals with weighting issues. The mean for correct trial types needs
%to be weighted by the number of correct trials of each type. For proper
%comparison purposes, the mean of the correct trials should also be
%weighted to the number of corresponding error trials. In an extreme example, if there are
%only errors to the right (following visits to the right), then we should
%only plot corrects to the left (which also follow visits to the right).

    %weights
    EL = sum(isfinite(E_L_dists_same))/sum([sum(isfinite(E_L_dists_same)) sum(isfinite(E_R_dists_same))]);
    ER = sum(isfinite(E_R_dists_same))/sum([sum(isfinite(E_L_dists_same)) sum(isfinite(E_R_dists_same))]);
 
    %VISITED AND NONVISITED PLOT
    %barplot inputs AVERAGING ACROSS TRIAL TYPE. 
    %Correct trials are weighted to the proportion of errors of each trial type 
    Cmean_same = ER*nanmean(C_L_dists_same) + EL*nanmean(C_R_dists_same);
    Emean_same = nanmean([E_L_dists_same;E_R_dists_same]);
    Cmean_opp = ER*nanmean(C_L_dists_opp) + EL*nanmean(C_R_dists_opp);
    Emean_opp = nanmean([E_L_dists_opp;E_R_dists_opp]);
    %%%I MAY NEED A MORE SOPHISTICATED WEIGHTRD SD OF SOME SORT
    Cstd_same = ER*nanstd(C_L_dists_same) + EL*nanstd(C_R_dists_same);
    Estd_same = nanstd([E_L_dists_same;E_R_dists_same]);
    Cstd_opp = ER*nanstd(C_L_dists_opp) + EL*nanstd(C_R_dists_opp);
    Estd_opp = nanstd([E_L_dists_opp;E_R_dists_opp]);
    Clen=sum(~isnan([C_L_dists_same;C_R_dists_same]));
    Elen=sum(~isnan([E_L_dists_same;E_R_dists_same]));

    %Combining visited and nonvisited distance information (ENCODING SPECIFICITY)
    C_L_dists = C_L_dists_same - C_L_dists_opp;
    C_R_dists = C_R_dists_same - C_R_dists_opp;
    E_L_dists = E_L_dists_same - E_L_dists_opp;
    E_R_dists = E_R_dists_same - E_R_dists_opp;
    
    %dividing may help with proportionality?
    %C_L_dists = C_L_dists_same./C_L_dists_opp;
    %C_R_dists = C_R_dists_same./C_R_dists_opp;
    %E_L_dists = E_L_dists_same./E_L_dists_opp;
    %E_R_dists = E_R_dists_same./E_R_dists_opp;

    %barplot inputs AVERAGING ACROSS TRIAL TYPE. Correct trials are
    %weighted to the proportion of errors of each trial type
    Cmean = (ER*nanmean(C_L_dists)+ EL*nanmean(C_R_dists));
    Emean = nanmean([E_L_dists;E_R_dists]);
    %%%I MAY NEED A MORE SOPHISTICATED WEIGHTED SD OF SOME SORT
    Cstd = (ER*nanstd(C_L_dists) + EL*nanstd(C_R_dists));
    Estd = nanstd([E_L_dists;E_R_dists]);

%end

means=[Cmean_same, Cmean_opp; Emean_same, Emean_opp];
stand=[Cstd_same, Cstd_opp; Estd_same, Estd_opp];
N=[Clen, Clen; Elen, Elen];
error=stand./sqrt(N);

Btwn_Proximal_T_value = (Cmean_same - Emean_same) / sqrt((Cstd_same^2)/Clen + (Estd_same^2)/Elen);
Btwn_Distal_T_value = (Cmean_opp - Emean_opp) / sqrt((Cstd_opp^2)/Clen + (Estd_opp^2)/Elen);

%visited and nonvisited barplot function
%{
figure

%plot details
b=get(gca, 'Children');
set(b(3), 'FaceColor', proximal_brown)
set(b(4), 'FaceColor', distal_blue)
set(gca,'FontSize',15)
set(gca,'LineWidth', 1)

ylabel('1/M-Dist', 'fontsize', 20)
title(['Distance and Future Memory Performance RWD(-',num2str(wdwbck), 's:',num2str(wdwfwd), 's)'],'fontsize', 16)
%title(['PCA (-',num2str(wdwbck), 's : ',num2str(wdwfwd), 's)  Flag= ',num2str(wdwfwd)],'fontsize', 16)
set(gca,'XTickLabel',{'Before Success', 'Before Error'}, 'fontsize', 20)
legend('Proximal Reward', 'Distal Reward', 'location', 'northeastoutside')
%}

%INPUT FOR SPECIFICITY PLOT
means1=[Cmean, Emean];
%means1=ones(2)./means
stand=[Cstd, Estd];
%stand1=ones(2)./stand
N=[Clen, Elen];
error1=stand./sqrt(N);


Specificity_T_value = (Cmean - Emean) / sqrt((Cstd^2)/Clen + (Estd^2)/Elen);

specific_z_dist = (Cmean - Emean)/gdivide(Cstd+Estd, 2)

%visited minus nonvisited barplot function
%figure
%barweb(means1, error1, 1.00);

%plot details
%{
b=get(gca, 'Children');
set(b(3), 'FaceColor', error_red)
set(b(4), 'FaceColor', correct_gray)
set(gca,'FontSize',15)
set(gca,'LineWidth', 1)
ylim([0 1.4])

ylabel('(1/M-Dist to Visited RWD) - (1/M-Dist to NonVisited RWD)', 'fontsize', 15)
title(['Encoding Specificity and Future Memory Performance RWD(-',num2str(wdwbck), 's:',num2str(wdwfwd), 's)'],'fontsize', 16)
set(gca,'XTickLabel',{''}, 'fontsize', 20)
legend('Before Success', 'Before Error', 'location', 'northeastoutside')
%}







            
            
            