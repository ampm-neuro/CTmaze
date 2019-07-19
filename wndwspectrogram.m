function wndwspectrogram(eptrials, windowbck, windowfwd, flag)

%Plots the average spectrogram during the time window (-'windowback':'windowfwd')
%surrounding flag 'flag'. Produces 3 subplots: (1) both trial types combined 
%(2) Left trials only (3) right trials only.
%
%Also plots rats trajectory
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

%THIS IS CURRENTLY INEFFICIENT BECAUSE I DONT KNOW HOW TO PREALLOCATE THE
%MATRICES FOR THE P OUTPUTS FROM SPECTOGRAM.M. Once I figure that out, the
%nested cell arrays should be replaced with a preallocated 3D matrix.


%world's greatest colors
grn=[52 153 70]./255;
blu=[46 49 146]./255;


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
plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
set(gca,'xdir','reverse')
hold on

%Correct and Error trial counts
correct_left = length(unique(eptrials(eptrials(:,8)==1 & eptrials(:,7)==1, 5)));
correct_right = length(unique(eptrials(eptrials(:,8)==1 & eptrials(:,7)==2, 5)));
%errors_left = length(unique(eptrials(eptrials(:,8)==2 & eptrials(:,7)==1, 5)));
%errors_right = length(unique(eptrials(eptrials(:,8)==2 & eptrials(:,7)==2, 5)));


%establishing cells to hold the power spectral density matrices
samples_L = cell(correct_left,1);
samples_R = cell(correct_right,1);

%For loop indexes
L=1;
R=1;

%for each trial
for trl = 2:max(eptrials(:,5))

%TRIAL ACCURACY: correct (1) OR error (2)
if mode(eptrials(eptrials(:,5)==trl,8))==1


    %FINDING FLAG EVENT TIME
    if ismember(flag, 1:7)
                    
        %find arrival, the timestamp of entrance into section (minimum timestamp in
        %section on trial)
      	event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,11)==flag, 1));
         
    %if flag input indicates reward
    elseif flag == 0

        %FINDING REWARD EVENT TIME (if there is a lick detection)
        if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1,10))>0
            
            %first lick AFTER choice-instant
            choice = max(eptrials(eptrials(:,5)==trl & eptrials(:,6)==1,1));
        
            if eptrials(eptrials(:,5)==trl, 7)==1
                %find the timestamp of first lick detection
                event = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>choice & eptrials(:,10)==1 & eptrials(:,6)==7,1));
            elseif eptrials(eptrials(:,5)==trl, 7)==2
                %find the timestamp of first lick detection
                event = min(eptrials(eptrials(:,5)==trl & eptrials(:,1)>choice & eptrials(:,10)==1 & eptrials(:,6)==8,1));
            end
            
        else
            
            %if flag is a lick detection, but there is no lick detection...
            continue
            
        end          
    end
    
    %Window around event
    windowlow = event-windowbck;
    windowhigh = event+windowfwd;
    
    %Finding CSC samples
    [~,F,~,P] = spectrogram(eptrials(isfinite(eptrials(:,13)) & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh,13),fix(length(eptrials(isfinite(eptrials(:,13)) & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh,13))/15),[],1:.01:30,2000, 'yaxis');

    if mode(eptrials(eptrials(:,5)==trl, 7))==1
        
        samples_L{L} = P;
        L=L+1;
        
        %also plot x/y's
        p1 = plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 3), 'Color', grn, 'LineWidth', 0.5, 'LineStyle', '-');
        
    elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
        
        samples_R{R} = P;
        R=R+1;
        
        %also plot x/y's
        p2 = plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 3), 'Color', blu, 'LineWidth', 0.5, 'LineStyle', '-');
        
    end
    
end
end    
    

sections(eptrials);
rewards(eptrials);
legend([p1, p2],'Left', 'Right', 'location', 'northeastoutside');
hold off


%eliminating empty cells
for i = 1:(max(eptrials(:,5))-1)
    try
        if isempty(samples_L{i})
            samples_L(i:end) = [];
        end  
        if isempty(samples_R{i})
            samples_R(i:end) = [];
        end
    end
end

figure
hold on

%center x-axis
T = -windowbck:1:windowfwd;

%Merging (0) or not (1)

%LEFT TRIALS

    %preallocating to help with summing
    sum_samples_L = zeros(size(samples_L{1}));
    sum_samples_R = zeros(size(samples_R{1}));
    
    %sum left samples; try/catch is to remove matrices of unique
    %dimensions. I do not know why they (rarely) exist.
    
    omit_L = 0;
    
    for i = 1:length(samples_L)
        try
            sum_samples_L = sum_samples_L + samples_L{i};
        catch
            omit_L = omit_L + 1;
        end
    end

    omit_L
    
    %divide for mean of left samples
    mean_samples_L = sum_samples_L./(length(samples_L) - omit_L);
    
    %plot left sample means
    subplot(3,1,2)
    imagesc( T, F, log(mean_samples_L) ); %plot the log spectrum
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
    %shading interp
    hold on
    hc = colorbar;
    ylabel(hc, 'Spectral Power (log units)','fontsize', 20)
    plot([0 0],[0 30],'k-', 'LineWidth',4); %vertical line at the event point
    set(gca,'fontsize', 20)
    %xlabel('Time (s)', 'fontsize', 20)
    ylabel('Frequency (Hz)', 'fontsize', 20)
    title('Left Trials LFP Spectrogram','fontsize', 20)
         %(-',num2str(windowbck), 's : ',num2str(windowfwd), 's)  Flag= ',num2str(flg)']
    
%RIGHT TRIALS        
         
    %sum right samples; try/catch is to remove matrices of unique
    %dimensions. I do not know why they (rarely) exist.
    
    omit_R = 0;
    
    for i = 1:length(samples_R)
        
        try
            sum_samples_R = sum_samples_R + samples_R{i};  
        catch
            omit_R = omit_R + 1;
        end
    end
    
    omit_R
    
    %divide for mean of right samples
    mean_samples_R = sum_samples_R./(length(samples_R) - omit_R);
        
    %plot right sample means
    subplot(3,1,3)
    imagesc( T, F, log(mean_samples_R) ); %plot the log spectrum
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
    %shading interp
    hold on
    hc = colorbar;
    ylabel(hc, 'Spectral Power (log units)','fontsize', 20)
    plot([0 0],[0 30],'k-', 'LineWidth',4); %vertical line at the event point
    set(gca,'fontsize', 20)
    xlabel('Time (s)', 'fontsize', 20)
    ylabel('Frequency (Hz)', 'fontsize', 20)
    title('Right Trials LFP Spectrogram','fontsize', 20)
        %(-',num2str(windowbck), 's : ',num2str(windowfwd), 's)  Flag= ',num2str(flg)']
    
%COMBINED
    
    %merge samples from each trial type
    samples = [samples_L; samples_R];
    
    %sum samples by trial
    sum_samples = zeros(size(samples{1}));
    
    omit_C = 0;
    
    for i = 1:length(samples)
        try
            sum_samples = sum_samples + samples{i};
        catch
            omit_C = omit_C + 1;
        end
    end
    
    omit_C
    
    %divide for the mean
    mean_samples = sum_samples./length(samples);

    %plot sample means
    subplot(3,1,1)
    imagesc( T, F, log(mean_samples) ); %plot the log spectrum
    set(gca,'YDir', 'normal'); % flip the Y Axis so lower frequencies are at the bottom
    %shading interp
    hold on
    hc = colorbar;
    ylabel(hc, 'Spectral Power (log units)','fontsize', 20)
    plot([0 0],[0 30],'k-', 'LineWidth',4); %vertical line at the event point
    set(gca,'fontsize', 20)
    %xlabel('Time (s)', 'fontsize', 20)
    ylabel('Frequency (Hz)', 'fontsize', 20)
    title(['LFP Spectrogram (-',num2str(windowbck), 's : ',num2str(windowfwd), 's)  Flag = ',flg],'fontsize', 20)
    
end













