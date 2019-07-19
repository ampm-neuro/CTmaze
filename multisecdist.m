function multisecdist(eptrials, cells)

%Population distance measure plot trials before, during, and after current trial.
%Solid lines correspond to correct (current) trials, and dotted lines
%correspond to error (current) trials
%
%Thus a dotted line in the first subplot shows the average population
%distances between left and right trials at each section on trials occuring
%just before an error trial. This trial may or may not have been an error
%itself.
%
%This plot is designed to look for relationships between the typicality of
%the representation occuring on the trial preceding an error or correct
%trial. It does this by asking how similar the average of the preceding trials 
%that happen to be "left" are compared to the average of the preceding trials 
%that happen to be "right." This assumes that typicality will be evidenced by
%a greater difference between left and right trial types, likely by a decrease 
%in variability. This is obviouslyan indirect measure.
%
%
%Currently includes 3 types of distances for comparison.

%video sampling rate for this session (used to determine time)
smplrt=length(eptrials(isnan(eptrials(:,4)),1))/max(eptrials(:,1));

%correct trials (rates, trialtype, cells)
crcttrialrates0 = nan(max(eptrials(:,5))-1, 2, length(cells));
crcttrialrates1 = nan(max(eptrials(:,5))-1, 2, length(cells));
crcttrialrates2 = nan(max(eptrials(:,5))-1, 2, length(cells));

%error trials (rates, trialtype, cells)
errrtrialrates0 = nan(max(eptrials(:,5))-1, 2, length(cells));
errrtrialrates1 = nan(max(eptrials(:,5))-1, 2, length(cells));
errrtrialrates2 = nan(max(eptrials(:,5))-1, 2, length(cells));

%(sections, distancetypes, accuracy)
crctsecdists0 = nan(6, 3);
crctsecdists1 = nan(6, 3);
crctsecdists2 = nan(6, 3);

errrsecdists0 = nan(6, 3);
errrsecdists1 = nan(6, 3);
errrsecdists2 = nan(6, 3);

%performed seperately for correct and error trials because I suck.

%at each section
for section = 1:7

        %for each cell
        for c = 1:length(cells)
          cell = cells(c);

            %for each trial
            for trl = 2:(max(eptrials(:,5))-2)
            %Can set sub sample of trials: "for trl = #:#" 

                %correct (1)
                if mode(eptrials(eptrials(:,5)==trl,8))==1
    
                    %how many spikes occured on the section(s) on PREVIOUS trial(trl-1) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl-1 & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl-1)
                    time = length(eptrials(eptrials(:,5)==trl-1 & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    crcttrialrates0(trl, 1, c) = rate;
                    crcttrialrates0(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl-1, 7));
                    
                    %how many spikes occured on the section(s) on CURRENT trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl)
                    time = length(eptrials(eptrials(:,5)==trl & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    crcttrialrates1(trl, 1, c) = rate;
                    crcttrialrates1(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));
                    
                    %how many spikes occured on the section(s) on NEXT trial(trl+1) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl+1 & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl+1)
                    time = length(eptrials(eptrials(:,5)==trl+1 & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    crcttrialrates2(trl, 1, c) = rate;
                    crcttrialrates2(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl+1, 7));

                else
        
                    continue
        
                end
                
            end

        end


        %previous trial distances
        X10 = squeeze(crcttrialrates0(crcttrialrates0(:, 2)==1, 1, :));
        X20 = squeeze(crcttrialrates0(crcttrialrates0(:, 2)==2, 1, :));
        
        %finding clusters that never fire during at least one of the reward windows
        clusts0 = sum([sum(X10)==0; sum(X20)==0]);
        
        %removing those clusters from reward representations. This is 
        %essential for distance measures.
        X10 = X10(:, clusts0 == 0);
        X20 = X20(:, clusts0 == 0);
        
        %readout withheld clusters
        WITHHELD_CLUSTERS_pre_cor = cells(clusts0 > 0);
        
        mu10=mean(X10);
        C10=cov(X10);
        mu20=mean(X20);
        C20=cov(X20);
        cov10=(C10+C20)/2;
        %S10= mean([std(X10); std(X20)]);
        crctsecdists0(section, 1) = NaN; %pdist([mu10;mu20], 'seuclidean', S10);
        crctsecdists0(section, 2) = sqrt(((mu10-mu20)*(inv(cov10))*(mu10-mu20)')/length(cells(clusts0 == 0))); %pdist([mu10;mu20],'mahalanobis', cov10);
        crctsecdists0(section, 3) = NaN; %bhatt(X10,X20);
        
        
        %current trial (CORRECT trial) distances
        X11 = squeeze(crcttrialrates1(crcttrialrates1(:, 2)==1, 1, :));
        X21 = squeeze(crcttrialrates1(crcttrialrates1(:, 2)==2, 1, :));
        
        %finding clusters that never fire during at least one of the reward windows
        clusts1 = sum([sum(X11)==0; sum(X21)==0]);
        
        %removing those clusters from reward representations. This is 
        %essential for distance measures.
        X11 = X11(:, clusts1 == 0);
        X21 = X21(:, clusts1 == 0);
        
        %readout withheld clusters
        WITHHELD_CLUSTERS_cur_cor = cells(clusts1 > 0);

        mu11=mean(X11);
        C11=cov(X11);
        mu21=mean(X21);
        C21=cov(X21);
        cov11=(C11+C21)/2;
        %S11= mean([std(X11); std(X21)]);
        crctsecdists1(section, 1) = NaN; %pdist([mu11;mu21], 'seuclidean', S11);
        crctsecdists1(section, 2) = sqrt(((mu11-mu21)*(inv(cov11))*(mu11-mu21)')/length(cells(clusts1 == 0))); %pdist([mu11;mu21],'mahalanobis', cov11);
        crctsecdists1(section, 3) = NaN; % bhatt(X11,X21);
        
        
        
        %next trial distances
        X12 = squeeze(crcttrialrates2(crcttrialrates2(:, 2)==1, 1, :));
        X22 = squeeze(crcttrialrates2(crcttrialrates2(:, 2)==2, 1, :));
        
        %finding clusters that never fire during at least one of the reward windows
        clusts2 = sum([sum(X12)==0; sum(X22)==0]);
        
        %removing those clusters from reward representations. This is 
        %essential for distance measures.
        X12 = X12(:, clusts2 == 0);
        X22 = X22(:, clusts2 == 0);
        
        %readout withheld clusters
        WITHHELD_CLUSTERS_nxt_cor = cells(clusts2 > 0);

        mu12=mean(X12);
        C12=cov(X12);
        mu22=mean(X22);
        C22=cov(X22);
        cov12=(C12+C22)/2;
        %S12= mean([std(X12); std(X22)]);
        crctsecdists2(section, 1) = NaN; %pdist([mu12;mu22], 'seuclidean', S12);
        crctsecdists2(section, 2) = sqrt(((mu12-mu22)*(inv(cov12))*(mu12-mu22)')/length(cells(clusts2 == 0))); %pdist([mu12;mu22],'mahalanobis', cov12);
        crctsecdists2(section, 3) = NaN; %bhatt(X12,X22);

end
    
Number_Correct_Left_Trials = length(crcttrialrates1(crcttrialrates1(:, 2)==1, 1, 1))
Number_Correct_Right_Trials = length(crcttrialrates1(crcttrialrates1(:, 2)==2, 1, 1))
    
%at each section
for section = 1:7

        %for each cell
        for c = 1:length(cells)
          cell = cells(c);

            %for each trial
            for trl = 2:(max(eptrials(:,5))-1)
            %Can set sub sample of trials: "for trl = #:#"    

                %error (2)
                if mode(eptrials(eptrials(:,5)==trl,8))==2
    
                    %how many spikes occured on the section(s) on PREVIOUS trial(trl-1) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl-1 & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl-1)
                    time = length(eptrials(eptrials(:,5)==trl-1 & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    errrtrialrates0(trl, 1, c) = rate;
                    errrtrialrates0(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl-1, 7));
                    
                    %how many spikes occured on the section(s) on CURRENT trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl)
                    time = length(eptrials(eptrials(:,5)==trl & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    errrtrialrates1(trl, 1, c) = rate;
                    errrtrialrates1(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));
                    
                    %how many spikes occured on the section(s) on NEXT trial(trl+1) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl+1 & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl+1)
                    time = length(eptrials(eptrials(:,5)==trl+1 & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    errrtrialrates2(trl, 1, c) = rate;
                    errrtrialrates2(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl+1, 7));


                else
        
                    continue
        
                end
                
            end

        end
        
        %If there are at least two left errors and two right errors
        if length(errrtrialrates1(errrtrialrates1(:, 2)==1, 1, 1)) >1 && length(errrtrialrates1(errrtrialrates1(:, 2)==2, 1, 1)) >1

            %previous trial distances
            X30 = squeeze(errrtrialrates0(errrtrialrates0(:, 2)==1, 1, :));
            X40 = squeeze(errrtrialrates0(errrtrialrates0(:, 2)==2, 1, :));

            
            %finding clusters that never fire during at least one of the reward windows
            clusts3 = sum([sum(X30)==0; sum(X40)==0]);
        
            %removing those clusters from reward representations. This is 
            %essential for distance measures.
            X30 = X30(:, clusts3 == 0);
            X40 = X40(:, clusts3 == 0);
        
            %readout withheld clusters
            WITHHELD_CLUSTERS_pre_err = cells(clusts3 > 0);

            mu30=mean(X30);
            C30=cov(X30);
            mu40=mean(X40);
            C40=cov(X40);
            cov30=(C30+C40)/2;
            %S30= mean([std(X30); std(X40)]);
            errrsecdists0(section, 1) = NaN; %pdist([mu30;mu40], 'seuclidean', S30);
            errrsecdists0(section, 2) = sqrt(((mu30-mu40)*(inv(cov30))*(mu30-mu40)')/length(cells(clusts3 == 0))); %pdist([mu30;mu40],'mahalanobis', cov30);
            errrsecdists0(section, 3) = Nan; %bhatt(X30,X40);
        
            
            %current trial (ERROR trial) distances
            X31 = squeeze(errrtrialrates1(errrtrialrates1(:, 2)==1, 1, :));
            X41 = squeeze(errrtrialrates1(errrtrialrates1(:, 2)==2, 1, :));
            
            %finding clusters that never fire during at least one of the reward windows
            clusts4 = sum([sum(X31)==0; sum(X41)==0]);
        
            %removing those clusters from reward representations. This is 
            %essential for distance measures.
            X31 = X31(:, clusts4 == 0);
            X41 = X41(:, clusts4 == 0);
        
            %readout withheld clusters
            WITHHELD_CLUSTERS_cur_err = cells(clusts4 > 0);
            
            mu31=mean(X31);
            C31=cov(X31);
            mu41=mean(X41);
            C41=cov(X41);
            cov31=(C31+C41)/2;
            %S31= mean([std(X31); std(X41)]);
            errrsecdists1(section, 1) = NaN; %pdist([mu31;mu41], 'seuclidean', S31);
            errrsecdists1(section, 2) = sqrt(((mu31-mu41)*(inv(cov31))*(mu31-mu41)')/length(cells(clusts4 == 0))); %pdist([mu31;mu41],'mahalanobis', cov31);
            errrsecdists1(section, 3) = NaN; %bhatt(X31,X41);
        
            
            %next trial distances
            X32 = squeeze(errrtrialrates2(errrtrialrates2(:, 2)==1, 1, :));
            X42 = squeeze(errrtrialrates2(errrtrialrates2(:, 2)==2, 1, :));
            
            %finding clusters that never fire during at least one of the reward windows
            clusts5 = sum([sum(X32)==0; sum(X42)==0]);
        
            %removing those clusters from reward representations. This is 
            %essential for distance measures.
            X32 = X32(:, clusts5 == 0);
            X42 = X42(:, clusts5 == 0);
        
            %readout withheld clusters
            WITHHELD_CLUSTERS_nxt_err = cells(clusts5 > 0);
            
            mu32=mean(X32);
            C32=cov(X32);
            mu42=mean(X42);
            C42=cov(X42);
            cov32=(C32+C42)/2;
            %S32= mean([std(X32); std(X42)]);
            errrsecdists2(section, 1) = NaN; %pdist([mu32;mu42], 'seuclidean', S32);
            errrsecdists2(section, 2) = sqrt(((mu32-mu42)*(inv(cov32))*(mu32-mu42)')/length(cells(clusts5 == 0))); %pdist([mu32;mu42],'mahalanobis', cov32);
            errrsecdists2(section, 3) = NaN; %bhatt(X32,X42);
        
        end
end

Number_Error_Left_Trials = length(errrtrialrates1(errrtrialrates1(:, 2)==1, 1, 1))
Number_Error_Right_Trials = length(errrtrialrates1(errrtrialrates1(:, 2)==2, 1, 1))

if length(errrtrialrates1(errrtrialrates1(:, 2)==1, 1, :)) >1 && length(errrtrialrates1(errrtrialrates1(:, 2)==2, 1, 1)) >1
    warning('Fewer than two error trials of each type. Error trials are not plotted.')
end

figure
%title('Population Distances','fontsize', 20)

s0 = subplot(3,1,1);
hold on
%h1 = plot(1:6, crctsecdists0(1:6, 1), '-', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
h2 = plot(1:6, crctsecdists0(1:6, 2), '-', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
%h3 = plot(1:6, crctsecdists0(1:6, 3), '-', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);
    if length(errrtrialrates1(errrtrialrates1(1:6, 2)==1, 1, :)) >1 && length(errrtrialrates1(errrtrialrates1(:, 2)==2, 1, 1)) >1
    %h4 = plot(1:6, errrsecdists0(1:6, 1), '--', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
    h5 = plot(1:6, errrsecdists0(1:6, 2), '--', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
    %h6 = plot(1:6, errrsecdists0(1:6, 3), '--', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);
    end
t0=title('Trial-1','fontsize', 11);
axis([0.5, 6.5, 0, 1.05*max([max(crctsecdists0(:));max(errrsecdists0(:));max(crctsecdists1(:));max(errrsecdists1(:));max(crctsecdists2(:));max(errrsecdists2(:))])])
set(s0, 'XTickLabel',{''})

s1 = subplot(3,1,2);
hold on
%plot(1:6, crctsecdists1(1:6, 1), '-', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
plot(1:6, crctsecdists1(1:6, 2), '-', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
%plot(1:6, crctsecdists1(1:6, 3), '-', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);
    if length(errrtrialrates1(errrtrialrates1(1:6, 2)==1, 1, :)) >1 && length(errrtrialrates1(errrtrialrates1(:, 2)==2, 1, 1)) >1
    %plot(1:6, errrsecdists1(1:6, 1), '--', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
    plot(1:6, errrsecdists1(1:6, 2), '--', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
    %plot(1:6, errrsecdists1(1:6, 3), '--', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);
    end
t1=title('Trial','fontsize', 11);
axis([0.5, 6.5, 0, 1.05*max([max(crctsecdists0(:));max(errrsecdists0(:));max(crctsecdists1(:));max(errrsecdists1(:));max(crctsecdists2(:));max(errrsecdists2(:))])])
set(s1, 'XTickLabel',{''})

s2 = subplot(3,1,3);
hold on
%plot(1:6, crctsecdists2(1:6, 1), '-', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
plot(1:6, crctsecdists2(1:6, 2), '-', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
%plot(1:6, crctsecdists2(1:6, 3), '-', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);
    if length(errrtrialrates1(errrtrialrates1(1:6, 2)==1, 1, :)) >1 && length(errrtrialrates1(errrtrialrates1(:, 2)==2, 1, 1)) >1
    %plot(1:6, errrsecdists2(1:6, 1), '--', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
    plot(1:6, errrsecdists2(1:6, 2), '--', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
    %plot(1:6, errrsecdists2(1:6, 3), '--', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);
    end
t2=title('Trial+1','fontsize', 11);
axis([0.5, 6.5, 0, 1.05*max([max(crctsecdists0(:));max(errrsecdists0(:));max(crctsecdists1(:));max(errrsecdists1(:));max(crctsecdists2(:));max(errrsecdists2(:))])])
set(s2, 'XTickLabel',{'Start','Low Stem', 'High Stem', 'Choice', 'Approach', 'Reward'}, 'fontsize', 12)
xlabel('Maze Section', 'fontsize', 20)

%mtit('Population Distances','fontsize',20);
%legend([h1 h2 h3 h4 h5 h6], 'Correct Seuclidean', 'Correct Mahalanobis', 'Correct Bhattacharyya', 'Error Seuclidean', 'Error Mahalanobis', 'Error Bhattacharyya','location', 'northeastoutside');
%ylabel('Standardized Rate Difference', 'fontsize', 20)

