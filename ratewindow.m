function [no_assumptions_t_score, dms_rwd, dms_rwd_p_values, left_back, left_forward, right_back, right_forward] = ratewindow(eptrials, cluster_cell, bins, windowbck, windowfwd, flag, file)
%plots average firing rates of cluster_cell 'cluster_cell' over a window of
%windowbck+windowfwd seconds surrounding entrance into 'section' section. 
%
%the function outputs a barchart if the bins are 1 (averaged across entire
%window), and a histogram if bins > 1. 
%
%eptrials is a matrix output by the function 'trials'
%
%The maze is divided into 6 sections by "folding" over the two halves along
%the stem such that flag can be:
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


accuracy = 1;
if accuracy == 2
    warning('accuracy set to error trials')
end

grn=[52 153 70]./255;
blu=[46 49 146]./255;
red = [196 11 11]./255;

enter_times = [];
exit_times = [];

figure_on = 0;


%Makes thin grey line of all X,Y points.

if figure_on == 1
    figure
    plot(eptrials(isfinite(eptrials(:, 2)) & isfinite(eptrials(:, 3)), 2), eptrials(isfinite(eptrials(:, 2)) & isfinite(eptrials(:, 3)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
    set(gca,'xdir','reverse')
    hold on 
end


%pre-emptive. will be overwritten if called.
dms_rwd = 'not called';
no_assumptions_t_score = 'not called';
dms_rwd_p_values = 'not called';


%nans(rates, trialtype)
windowrates = nan(max(eptrials(:,5))-1, 2, bins);

%determine firing rate and trialtype for each trial
for trl = 2:max(eptrials(:,5))

    %CHANGE this between 1 for correct and 2 for error trials.    
    if mode(eptrials(eptrials(:,5)==trl,8))==accuracy
    
        %determining 'flag' input
        if ismember(flag, [1 4])
    
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==flag,1));
        
        %determining 'flag' input
        elseif ismember(flag, [2 3])
    
            %find arrival, the timestamp of entrance into section (minimum timestamp in
            %section on trial)
            
            last_rwd_sect = max(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & ismember(eptrials(:,6), [7 8]),1));
            last_start_sect_b4_rwd = max(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==1 & eptrials(:,1) < last_rwd_sect,1));
            
            event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==flag & eptrials(:,1) > last_start_sect_b4_rwd,1));
            
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
                
                %stem entrance on this trial (max time point in start area)
                stement = max(eptrials(eptrials(:,5)==trl & eptrials(:,6)==1, 1));
            
                %if there is a lick detection
                if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0
                    
                    %find the timestamp of first lick detection
                    event = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,1)>stement,1));
                    
                %if there is NOT a lick detection, progress to next trial
                else
                    
                    continue
                       
                end
            
        end
        
        %%%%how many spikes occured in each bin in the window surrounding 
        %the entrance timestamp on trial trl
        for currentbin = 1:bins
       
        windowlow = event-windowbck; enter_times = [enter_times; windowlow];
        windowhigh = event+windowfwd; exit_times = [exit_times; windowhigh];
        window = (windowbck+windowfwd);
        lowerbound = (currentbin-1)*(window/bins);
        upperbound = currentbin*(window/bins);
                
        spikes = length(eptrials(eptrials(:,4)==cluster_cell & eptrials(:,5)==trl & eptrials(:,1)>(windowlow+lowerbound) & eptrials(:,1)<(windowlow+upperbound),4));
        rate = spikes/((windowbck+windowfwd)/bins);
        
        windowrates(trl, 1, currentbin) = rate;
        windowrates(trl, 2, currentbin) = mode(eptrials(eptrials(:,5)==trl, 7));  
        
                if figure_on==1
                    if currentbin==1

                        if mode(eptrials(eptrials(:,5)==trl, 7))==1
                        h1 = plot(eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', grn, 'LineWidth', 0.5, 'LineStyle', '-');
                        elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
                        h2 = plot(eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,1)>windowlow & eptrials(:,1)<windowhigh, 3), 'Color', blu, 'LineWidth', 0.5, 'LineStyle', '-');
                        hold on
                        end
                            
                        plot(eptrials(eptrials(:,1)>event-.5 & eptrials(:,1)<event+.5, 2), eptrials(eptrials(:,1)>event-.5 & eptrials(:,1)<event+.5, 3), 'Color', red, 'LineWidth', 0.5, 'LineStyle', '-');
                    end
                end
                
        end
    
    %NaNs for the incorrect trials. We will continue to ignore them below.
    else 
        continue
    end
end

if figure_on == 1
    legend([h1, h2],'Left Trials', 'Right Trials', 'location', 'northeastoutside')
    hold off 

    %sections; 
    rewards(eptrials, 0);
    axis off
end


%if bins is 1, then make a barplot (not a histogram)
if bins==0
    
    error('bins must be >=1');

elseif bins==1

    %calculating means
    leftmean=nanmean(windowrates(windowrates(:,2)==1, 1));
    rightmean=nanmean(windowrates(windowrates(:,2)==2, 1));
    leftstd=nanstd(windowrates(windowrates(:,2)==1, 1));
    rightstd=nanstd(windowrates(windowrates(:,2)==2, 1));
    leftlen=sum(~isnan(windowrates(windowrates(:,2)==1, 1)));
    rightlen=sum(~isnan(windowrates(windowrates(:,2)==2, 1)));

    
    %{
    means=[leftmean, rightmean];
    %stand=[leftstd, rightstd];
    N=[leftlen, rightlen];
    serror=[leftstd./sqrt(N(1)), rightstd./sqrt(N(2))];
    %}
    
    if leftlen < 10 || rightlen < 10
        disp('too few trials. cluster_cells are forfeit.')
        num_cluster_cells = size(clusters,1)
                
        t_score = nans(num_cluster_cells, 1);
        dms_rwd = zeros(num_cluster_cells, 1);
        dms_rwd_p_values = ones(num_cluster_cells, 1);
        
        return
    end
    

    means=[leftmean(1:10), rightmean(1:10)];
    N = [10 10];
    stds = [leftstd(1:10) rightstd(1:10)];
    serror=[leftstd(1:10)./sqrt(N(1)), rightstd(1:10)./sqrt(N(2))];
    
    
    %EQUAL SAMPLE SIZE & VAR 
    equality_assummed_t_score = (means(1) - means(2))/(sqrt(.5*(stds(1)^2 + stds(2)^2))*sqrt(2/sum(N)));
    equal_assump_df = sum(N)-2;
    %NO ASSUMPTIONS 
    no_assumptions_t_score = abs((means(1) - means(2))/sqrt(stds(1)^2/N(1) + stds(2)^2/N(2)));
    no_assump_df = ((stds(1)^2/N1() + stds(2)^2/N(2))^2)/(((std(1)^2/N(1))^2)/(N(1)-1) + ((std(2)^2/N(2))^2)/(N(2)-1));

    %avoiding errors that can occur if cluster_cell does not fire at all.
    if leftmean == 0 && rightmean == 0 
        equality_assummed_t_score = 0;
        no_assumptions_t_score = 0;
        warning ('no events during time window')
    end
    
    if ismember(figure_on, [1 2])
        figure

        %plotting with barweb, a function downloaded from the internet that adds
        %errorbars to barplots
        barweb(means, serror, .80);

        b=get(gca, 'Children');
        set(b(3), 'FaceColor', blu)
        set(b(4), 'FaceColor', grn)
        set(gca,'FontSize',15)
        set(gca,'LineWidth', 1)

        %lables
        ylabel('Mean Firing Rate (Hz)', 'fontsize', 20)
        %set(gca, 'YLim',[0 25],'YTick', [0:5:25])
        set(gca, 'Xtick', 0.850:0.30:1.150,'XTickLabel',{'Left', 'Right'}, 'fontsize', 20)

        title(['cluster_cell ',num2str(cluster_cell)],'fontsize', 16) 
    end

elseif bins>1
    
    %plot histogram of firing rates in each bin, and a vertical line
    %indicatng the event
    leftbinmeans = nan(bins,2);
    rightbinmeans = nan(bins,2);
    
    %getting means
    %some jijitsu to translate bin numbers back into negative seconds
    %before event and positive seconds after the event
    
    correction = windowbck + (windowbck+windowfwd)/(2*bins);
    
    for currentbin = 1:bins
        
        leftbinmeans(currentbin,1) = nanmean(windowrates(windowrates(:,2,currentbin)==1, 1, currentbin));
        leftbinmeans(currentbin,2) = ((windowbck+windowfwd)/bins)*currentbin - correction;
        rightbinmeans(currentbin,1) = nanmean(windowrates(windowrates(:,2,currentbin)==2, 1, currentbin));
        rightbinmeans(currentbin,2) = ((windowbck+windowfwd)/bins)*currentbin - correction;

    end
    
    figure
    if ismember(figure_on, [1 2])
        %getting max firing rates to set y-axis
        maxrate = zeros(2,1);
        maxrate(1,1) = max(leftbinmeans(:,1));
        maxrate(2,1) = max(rightbinmeans(:,1));
    
        %left figure
        subplot(2,1,1)
        bar(leftbinmeans(:,2), leftbinmeans(:,1), 1, 'k')
        
        %lables
        title([file, ' ', num2str(cluster_cell)],'fontsize', 10)
        axis([-windowbck, windowfwd, 0, 1.2*max(maxrate)])
        ylabel('Left FR (Hz)', 'fontsize', 20)
        %xlabel('Time (Sec)', 'fontsize', 20)

        if windowbck + windowfwd < 10

            set(gca, 'Xtick',(-windowbck:1:windowfwd),'fontsize', 20, 'TickLength',[ 0 0 ])

        elseif windowbck+ windowfwd < 30

            set(gca, 'Xtick',(-windowbck:2:windowfwd),'fontsize', 20, 'TickLength',[ 0 0 ])

        else

            set(gca, 'Xtick',(-windowbck:5:windowfwd),'fontsize', 20, 'TickLength',[ 0 0 ])

        end

        %adding a red vertical line at the event point
        hold on
        plot([0 0],[0 (max(maxrate))+0.2*(max(maxrate))],'r-', 'LineWidth',3)

        %right figure
        subplot(2,1,2)
        bar(rightbinmeans(:,2), rightbinmeans(:,1), 1, 'k')

        %lables
        %title('Right Trials','fontsize', 20)
        %axis([-1 .5, 0,1.2*(max(maxrate))])
        axis([-windowbck, windowfwd, 0, 1.2*max(maxrate)])
        ylabel('Right FRs (Hz)', 'fontsize', 20)
        
        %set(gca, 'YLim',[0 30],'YTick', [0:10:30])
        xlabel('Time (Sec)', 'fontsize', 20)

        if windowbck + windowfwd < 10

            set(gca, 'Xtick',(-windowbck:1:windowfwd),'fontsize', 20, 'TickLength',[ 0 0 ])

        elseif windowbck+ windowfwd < 30

            set(gca, 'Xtick',(-windowbck:2:windowfwd),'fontsize', 20, 'TickLength',[ 0 0 ])

        else

            set(gca, 'Xtick',(-windowbck:5:windowfwd),'fontsize', 20, 'TickLength',[ 0 0 ])

        end

        %adding a red vertical line at the event point
        hold on
        plot([0 0],[0 1.2*(max(maxrate))],'r-', 'LineWidth',3)
    end
    
    
    %Wilcoxon Rank Sum (if equal window sizes and even number of bins)
    if windowbck == windowfwd && mod(bins,2)==0
    
        left_back = leftbinmeans(1:(length(leftbinmeans)/2),1);
        left_forward = leftbinmeans(((length(leftbinmeans)/2)+1):length(leftbinmeans),1);
        [left_p] = ranksum(left_back,left_forward);
    
        right_back = rightbinmeans(1:(length(rightbinmeans)/2),1);
        right_forward = rightbinmeans(((length(rightbinmeans)/2)+1):length(rightbinmeans),1);
        [right_p] = ranksum(right_back,right_forward);
    
        dms_rwd = [left_p; right_p];
        
        %statistical criterion
        dms_rwd = double(dms_rwd<.05);
        %one 0 or 1 evaluating whether at least one rwd loc met the
        %criteria
        dms_rwd = double(sum(dms_rwd)>0);
        
        %potentially for figure selection
        dms_rwd_p_values = min([left_p right_p],[],2);
        
    else
        %for bin rate outputs
        if windowbck == 0
            left_back = [];
            right_back = [];
            left_forward = leftbinmeans(:,1);
            right_forward = rightbinmeans(:,1);
            
        elseif windowfwd == 0
            left_forward = [];
            right_forward = [];
            left_back = leftbinmeans(:,1);
            right_back = rightbinmeans(:,1);
            
        else
            bck_fwd_propor = windowbck/(windowbck+windowfwd);
            
            left_back = leftbinmeans(1:floor(size(leftbinmeans,1)*bck_fwd_propor),1);
            right_back = rightbinmeans(1:floor(size(leftbinmeans,1)*bck_fwd_propor),1);
            left_forward = leftbinmeans(floor(size(leftbinmeans,1)*bck_fwd_propor)+1:end,1);
            right_forward = rightbinmeans(floor(size(leftbinmeans,1)*bck_fwd_propor)+1:end,1);
        
        end
    
    end
end

enter_times = unique(enter_times);
exit_times = unique(exit_times);

spike_times = cell(length(enter_times),1);
trial_types_LR = nan(length(enter_times),1);
for i = 1:length(enter_times)
    spike_times{i} = eptrials(eptrials(:,4)==cluster_cell & eptrials(:,1)>enter_times(i) & eptrials(:,1)<exit_times(i),1)';
    spike_times{i} = spike_times{i} - repmat(enter_times(i)+windowbck, size(spike_times{i}));
    trial_types_LR(i) = mode(eptrials(eptrials(:,1)>enter_times(i) & eptrials(:,1)<exit_times(i), 7));
end

%plotting details
LineFormat = struct();
LineFormat.Color = [0 0 0];
LineFormat.LineWidth = 0.35;
LineFormat.LineStyle = '-';

if figure_on == 1
figure
plotSpikeRaster(spike_times(trial_types_LR==1),'PlotType','vertline', 'LineFormat', LineFormat);
%title(strcat(num2str(cluster_id), ' .', section_id_L), 'fontsize', 20)
ylabel('Left Trials', 'fontsize', 20)
xlabel('Time (seconds)', 'fontsize', 20)

figure
plotSpikeRaster(spike_times(trial_types_LR==2),'PlotType','vertline', 'LineFormat', LineFormat);
%title(strcat(num2str(cluster_id), ' .', section_id_R), 'fontsize', 20)
ylabel('Right Trials', 'fontsize', 20)
xlabel('Time (seconds)', 'fontsize', 20)
end

end

