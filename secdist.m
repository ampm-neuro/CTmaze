function secdist(eptrials, cells)

%Distance measure
%
%builds two (left and right) M x N matrices, X1 and X2, of mean firing rates where M rows contain the trials and N columns
%contain clusters.

%video sampling rate for this session (used to determine time)
smplrt=length(eptrials(isnan(eptrials(:,4)),1))/max(eptrials(:,1));

%(rates, trialtype, cells)
trialrates1 = nan(max(eptrials(:,5))-1, 2, length(cells));
trialrates2 = nan(max(eptrials(:,5))-1, 2, length(cells));

%(sections, distancetypes, accuracy)
crctsecdists = nan(7, 3);
errrsecdists = nan(7, 3);

%performed seperately for correct and error trials because I suck.

%at each section
for section = 1:7

        %for each cell
        for c = 1:length(cells)
          cell = cells(c);

            %for each trial
            for trl = 2:max(eptrials(:,5))
            %Can set sub sample of trials: "for trl = #:#"  
            
                %correct (1)
                if mode(eptrials(eptrials(:,5)==trl,8))==1
    
                    %how many spikes occured on the section(s) on trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl)
                    time = length(eptrials(eptrials(:,5)==trl & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    trialrates1(trl, 1, c) = rate;
                    trialrates1(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));

                else
        
                    continue
        
                end
                
            end

        end

        X1 = squeeze(trialrates1(trialrates1(:, 2)==1, 1, :));
        X2 = squeeze(trialrates1(trialrates1(:, 2)==2, 1, :));
        
        %finding clusters that never fire during at least one of the reward windows
        clusts = sum([sum(X1)==0; sum(X2)==0]);

        %removing those clusters from reward representations. This is 
        %essential for distance measures.
        X1 = X1(:, clusts == 0);
        X2 = X2(:, clusts == 0);

        %readout withheld clusters
        WITHHELD_CLUSTERS = cells(clusts > 0)
    
        mu1=nanmean(X1);
        C1=nancov(X1);
        mu2=nanmean(X2);
        C2=nancov(X2);
        cov1=(C1+C2)/2;
        %S1= mean([std(X1); std(X2)]);
        %crctsecdists(section, 1) = %pdist([mu1;mu2], 'seuclidean', S1)
        crctsecdists(section, 2) = sqrt(((mu1-mu2)*(inv(cov1))*(mu1-mu2)')/length(cells(clusts == 0)));
        %crctsecdists(section, 3) = %bhatt(X1,X2);

end
 
%if there is at least one error for each trial type
if ~isempty(unique(eptrials(eptrials(:,5)==2 & eptrials(:,7)==1, 5))) && ~isempty(unique(eptrials(eptrials(:,5)==2 & eptrials(:,7)==2, 5)))
   errtst = 1;     
%at each section
for section = 1:7

        %for each cell
        for c = 1:length(cells)
          cell = cells(c);

            %for each trial
            for trl = 2:max(eptrials(:,5))
            %Can set sub sample of trials: "for trl = #:#"    

                %error (2)
                if mode(eptrials(eptrials(:,5)==trl,8))==2
    
                    %how many spikes occured on the section(s) on trial(trl) 
                    spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,11)==section,4));
    
                    %how long was spent on section(s) on trial(trl)
                    time = length(eptrials(eptrials(:,5)==trl & eptrials(:,11)==section & isnan(eptrials(:,4)), 1))/smplrt;
    
                    rate = spikes/time;
    
                    trialrates2(trl, 1, c) = rate;
                    trialrates2(trl, 2, c) = mode(eptrials(eptrials(:,5)==trl, 7));

                else
        
                    continue
        
                end
                
            end

        end

       
        X3 = squeeze(trialrates2(trialrates2(:, 2)==1, 1, :));
        X4 = squeeze(trialrates2(trialrates2(:, 2)==2, 1, :));
        
        %finding clusters that never fire during at least one of the reward windows
        clusts1 = sum([sum(X3)==0; sum(X4)==0]);

        %removing those clusters from reward representations. This is 
        %essential for distance measures.
        X3 = X3(:, clusts1 == 0);
        X4 = X4(:, clusts1 == 0);

        %readout withheld clusters
        WITHHELD_CLUSTERS = cells(clusts1 > 0)
        
        mu3=nanmean(X3);
        C3=nancov(X3);
        mu4=nanmean(X4);
        C4=nancov(X4);
        cov2=(C3+C4)/2;
        %S2= mean([std(X3); std(X4)]);
        %errrsecdists(section, 1) = pdist([mu3;mu4], 'seuclidean', S2);
        errrsecdists(section, 2) = sqrt(((mu3-mu4)*(inv(cov2))*(mu3-mu4)')/length(cells(clusts1 == 0))); %pdist([mu3;mu4],'mahalanobis', cov2)/length(cells(clusts == 0))
        %errrsecdists(section, 3) = bhatt(X3,X4);
end

else
    
    errtst = 0;

end

%trialrates

figure
hold on
%h1 = plot(1:7, crctsecdists(:, 1), '-', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
h2 = plot(1:7, .7977.*crctsecdists(:, 2), '-', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
%h3 = plot(1:7, crctsecdists(:, 3), '-', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);

if errtst == 0
title('Population Distances','fontsize', 20)
%legend([h1 h2 h3], 'Correct Seuclidean', 'Correct Mahalanobis', 'Correct Bhattacharyya', 'location', 'northeastoutside');
set(gca, 'XTickLabel',{'Start','Low Stem', 'High Stem', 'Choice', 'Approach', 'Reward', 'Return'},'XTick', 1:7, 'fontsize', 12)
ylabel('Standardized Rate Difference', 'fontsize', 20)
xlabel('Maze Section', 'fontsize', 20)
end

if errtst == 1
%h4 = plot(1:7, errrsecdists(:, 1), '--', 'linewidth', 2, 'Color',[178/255 34/255 34/255]);
h5 = plot(1:7, errrsecdists(:, 2), '--', 'linewidth', 2, 'Color',[34/255 139/255 34/255]);
%h6 = plot(1:7, errrsecdists(:, 3), '--', 'linewidth', 2, 'Color',[0/255 0/255 128/255]);

title('Population Distances','fontsize', 20)
legend([h1 h2 h3 h4 h5 h6], 'Correct Seuclidean', 'Correct Mahalanobis', 'Correct Bhattacharyya', 'Error Seuclidean', 'Error Mahalanobis', 'Error Bhattacharyya','location', 'northeastoutside');
set(gca, 'XTickLabel',{'Start','Low Stem', 'High Stem', 'Choice', 'Approach', 'Reward', 'Return'}, 'fontsize', 12)
ylabel('Standardized Rate Difference', 'fontsize', 20)
xlabel('Maze Section', 'fontsize', 20)
end
%axis([0.75, 6.25, 0, 8])
axis([0.75, 7.25, 0, 1.05*max([max(crctsecdists(:)) max(errrsecdists(:))])])


