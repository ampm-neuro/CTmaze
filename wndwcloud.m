function wndwcloud(eptrials, cells, windowbck, windowfwd, flag)
%plots the firing rates of n cells in n dimensions for every trial,
%colored by trial type, within a time window surrounding a flagged event.
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
%  5 = approach arm (both)
%  6 = reward area (both)
%  7 = return arm (both)
%
%This code is easily modified to use error trials. See below.
%

grn=[52 153 70]./255;
blu=[46 49 146]./255;

bins=1;

%Makes thin grey line of all X,Y points.
figure
plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
set(gca,'xdir','reverse')
hold on

%nans(rates, trialtype, bins, cells)
windowrates = nan(max(eptrials(:,5))-1, 2, bins, length(cells));

for c = 1:length(cells)
    cell = cells(c);

    %determine firing rate and trialtype for each trial
    for trl = 2:max(eptrials(:,5))

        %CHANGE this between 1 for correct and 2 for error trials.    
        if mode(eptrials(eptrials(:,5)==trl,8))==1
    
            %determining 'flag' input
            if ismember(flag, 1:4)
    
                %find arrival, the timestamp of entrance into section (minimum timestamp in
                %section on trial)
                event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==flag,1));
        
            %determining 'flag' input    
            elseif flag == 5
            
                %"unfold" maze to plot correct spatial section for each trial type 
                if mode(eptrials(eptrials(:,5)==trl, 7))==1
            
                %find arrival, the timestamp of entrance into section (minimum timestamp in
                %section on trial)
                event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==5,1));
        
                elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                
                %find arrival, the timestamp of entrance into section (minimum timestamp in
                %section on trial)
                event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==6,1));
            
                end
            
            %determining 'section' input
            elseif flag == 6
        
                if mode(eptrials(eptrials(:,5)==trl, 7))==1
            
                %find arrival, the timestamp of entrance into section (minimum timestamp in
                %section on trial)
                event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==7,1));
        
                elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                
                %find arrival, the timestamp of entrance into section (minimum timestamp in
                %section on trial)
                event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==8,1));
            
                end
            
            %determining 'section' input
            elseif flag == 7
            
                if mode(eptrials(eptrials(:,5)==trl, 7))==1
            
                %find arrival, the timestamp of entrance into section (minimum timestamp in
                %section on trial)
                event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==9,1));
        
                elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                
                %find arrival, the timestamp of entrance into section (minimum timestamp in
                %section on trial)
                event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==10,1));
            
                end
            
            %if section input indicates reward receipt...
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
        
    


        
        %%%%how many spikes occured in each bin in the window surrounding 
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
    
        %NaNs for the incorrect trials. We will continue to ignore them below.
        else 
            
            continue
    
        end
    end
    
end

%sections(eptrials);
rewards(eptrials);
hold off

%left trial type firing rates
X1 = mean(squeeze(windowrates(windowrates(:, 2)==1, 1, :)));
%right trial type firing rates
X2 = mean(squeeze(windowrates(windowrates(:, 2)==2, 1, :)));


%if there are 2 cells to plot
if length(cells) == 2
    
    figure
    hold on
    
    for trl = 2:(max(eptrials(:,5))-1)
    
        
        if isfinite(windowrates(trl,1,1,1)) && isfinite(windowrates(trl,1,1,2)) && windowrates(trl,2,1,1)==1
        
            h1 = plot(windowrates(trl,1,1,1), windowrates(trl,1,1,2), '.', 'Color', grn, 'markersize', 25);
    
        end
        
        if isfinite(windowrates(trl,1,1,1)) && isfinite(windowrates(trl,1,1,2)) && windowrates(trl,2,1,1)==2
        
            h2 = plot(windowrates(trl,1,1,1), windowrates(trl,1,1,2), '.', 'Color', blu, 'markersize', 25);
        
        end
    
    end

    plot(X1(1), X1(2), '.', 'Color', grn, 'markersize', 50)
    plot(X2(1), X2(2), '.', 'Color', blu, 'markersize', 50)
    h3 = plot([X1(1) X2(1)], [X1(2) X2(2)],'r-','linewidth', 2.5);

    %lables
    title(['Windowback= ',num2str(windowbck), 'Windowforward=  ',num2str(windowfwd), 'Flag= ',num2str(flag)],'fontsize', 16)
    xlabel (['Cell ',num2str(cells(1)), ' (Hz)'], 'fontsize', 20)
    ylabel (['Cell ',num2str(cells(2)), ' (Hz)'], 'fontsize', 20)
    %legend([h1, h2, h3],'Left Trials', 'Right Trials', 'Euclidean Distance', 'location', 'northeastoutside')
    legend([h1, h2],'Left Trials', 'Right Trials', 'location', 'northeastoutside')

end

%if there are 3 cells to plot
if length(cells) == 3    
    
    figure
    hold on
    
    for trl = 2:(max(eptrials(:,5))-1)
    
        if isfinite(windowrates(trl,1,1,1)) && isfinite(windowrates(trl,1,1,2)) && isfinite(windowrates(trl,1,1,3)) && windowrates(trl,2,1,1)==1
        
            h1 = plot3(windowrates(trl,1,1,1), windowrates(trl,1,1,2), windowrates(trl,1,1,3), '.', 'Color', grn, 'markersize', 15);
    
        end
        
        if isfinite(windowrates(trl,1,1,1)) && isfinite(windowrates(trl,1,1,2)) && isfinite(windowrates(trl,1,1,3)) && windowrates(trl,2,1,1)==2
        
            h2 = plot3(windowrates(trl,1,1,1), windowrates(trl,1,1,2), windowrates(trl,1,1,3), '.', 'Color', blu, 'markersize', 15);
        
        end
    
    end

    %plotting large dots at average (center) of each cloud, and a red line
    %connecting the two points to highlight the euclidian distance between them
    h3=plot3([X1(1) X2(1)], [X1(2) X2(2)], [X1(3) X2(3)],'r-','linewidth', 2.5);
    plot3(X1(1), X1(2), X1(3), '.', 'Color', grn, 'markersize', 30)
    plot3(X2(1), X2(2), X2(3), '.', 'Color', blu, 'markersize', 30)

    %lables
    title(['(-',num2str(windowbck), 's : ',num2str(windowfwd), 's)  Flag= ',num2str(flag)],'fontsize', 16)
    xlabel (['Cell ',num2str(cells(1)), ' (Hz)'], 'fontsize', 20)
    ylabel (['Cell ',num2str(cells(2)), ' (Hz)'], 'fontsize', 20)
    zlabel (['Cell ',num2str(cells(3)), ' (Hz)'], 'fontsize', 20)
    legend([h1, h2, h3],'Left Trials', 'Right Trials', 'Euclidean Distance', 'location', 'northeastoutside')

end

%if there are >3 cells to plot (PRINCIPAL COMPONENT ANALYSIS)
if length(cells) > 3

    figure
    hold on
    
    %way to index directly for left and right trials AFTER PCA (within 'scores')
    all = windowrates(:, 2)==1 | windowrates(:, 2)==2;
    left = windowrates(:, 2)==1;
    right = windowrates(:, 2)==2;
    a = [all left right];
    a = a(any(a,2),:); %removing empty rows
    
    %Principal component anylsis
    [coeff, scores, latent] = princomp(squeeze(windowrates(windowrates(:, 2)==1 | windowrates(:, 2)==2, 1, :)));
    Cumulative_PC_Variances = cumsum(latent)./sum(latent)
    
    %plotting along 3 "best" axes using biplot???
    %biplot(coeff(:,1:3), 'Scores', scores(a(:,2),1:3), 'Color', grn, 'markersize', 15)
    %biplot(coeff(:,1:3), 'Scores', scores(a(:,3),1:3), 'Color', blu, 'markersize', 15)
    %biplot(coeff(:,1:3), 'Scores', mean(scores(a(:,2),1:3)), 'Color', grn, 'markersize', 30)
    %biplot(coeff(:,1:3), 'Scores', mean(scores(a(:,3),1:3)), 'Color', blu, 'markersize', 30)
    %hold off
    
    %Normalizing to largest value in vector
    scores(:,1) = scores(:,1)./max(abs(scores(:,1)));
    scores(:,2) = scores(:,2)./max(abs(scores(:,2)));
    scores(:,3) = scores(:,3)./max(abs(scores(:,3)));
    
    %figure
    %hold on
    %plotting along 3 "best" axes using plot3
    h1 = plot3(scores(a(:,2),1), scores(a(:,2),2), scores(a(:,2),3), '.', 'Color', grn, 'markersize', 25);
    h2 = plot3(scores(a(:,3),1), scores(a(:,3),2), scores(a(:,3),3), '.', 'Color', blu, 'markersize', 25);
    
    %plotting large dots at average (center) of each cloud, and a red line
    %connecting the two points to highlight the euclidian distance between them
    h3=plot3([mean(scores(a(:,2),1)) mean(scores(a(:,3),1))], [mean(scores(a(:,2),2)) mean(scores(a(:,3),2))], [mean(scores(a(:,2),3)) mean(scores(a(:,3),3))],'r-','linewidth', 2.5);
    plot3(mean(scores(a(:,2),1)), mean(scores(a(:,2),2)), mean(scores(a(:,2),3)), '.', 'Color', grn, 'markersize', 50)
    plot3(mean(scores(a(:,3),1)), mean(scores(a(:,3),2)), mean(scores(a(:,3),3)), '.', 'Color', blu, 'markersize', 50)
    
    %lables
    title(['PCA (-',num2str(windowbck), 's : ',num2str(windowfwd), 's)  Flag= ',num2str(flag)],'fontsize', 16)
    xlabel ('Component 1', 'fontsize', 20)
    ylabel ('Component 2', 'fontsize', 20)
    zlabel ('Component 3', 'fontsize', 20)
    legend([h1, h2, h3],'Left Trials', 'Right Trials', 'Euclidean Distance', 'location', 'northeastoutside')
    axis([-1.15 1.15 -1.15 1.15 -1.15 1.15])
    
end

hold off

%windowrates(rates, trialtype, 1, cells)
left = windowrates(:, 2)==1;
right = windowrates(:, 2)==2;
X1 = windowrates(left, 1, :);
X2 = windowrates(right, 1, :);
%var(X1)
%var(X2)
        
%finding clusters that never fire during at least one of the reward windows
clusts = sum([var(X1)==0; var(X2)==0]);

%removing those clusters from reward representations. This is 
%essential for distance measures.
LRR = X1(:, clusts == 0);
LRR = LRR(~any(isnan(LRR),2),:);
RRR = X2(:, clusts == 0);
RRR = RRR(~any(isnan(RRR),2),:);


%readout withheld clusters
WITHHELD_CLUSTERS = cells(clusts > 0)

mu1=nanmean(LRR);
Lcov=nancov(LRR);
mu2=nanmean(RRR);
Rcov=nancov(RRR);



COV=(Lcov+Rcov)/2;

M_distance = sqrt(((mu1-mu2)*(inv(COV))*(mu1-mu2)')/length(cells(clusts == 0)))






