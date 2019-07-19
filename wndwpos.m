function [left_means, right_means, vel_hold, h1, h2, mean_posLR, mean_velLR, mean_hdLR] = wndwpos(eptrials, windowbck, windowfwd, flag, varargin)

%Plots the rats trajectory during the defined window. Green for left
%trials, blue for right trials.
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


if nargin > 4
    h1 = varargin{1};
    h2 = varargin{2};
end

%world's greatest colors
grn=[52 153 70]./255;
blu=[46 49 146]./255;
%grn=[196 11 11]./255;
%blu=[196 11 11]./255;

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
%h1 = figure;
%hold on
%plot(eptrials(isfinite(eptrials(:, 2)), 2), eptrials(isfinite(eptrials(:, 2)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');

if ~exist('h1', 'var')
    h1 = figure;
    hold on
end

if ~exist('h2', 'var')
    h2 = figure;
    hold on
end
%calculate velocity
velocity_column = vid_velocity(eptrials);

left_means = [];
right_means = [];
vel_hold = [];
mean_posL=[];
mean_velL=[]; 
mean_hdL=[];
mean_posR=[];
mean_velR=[]; 
mean_hdR=[];

    l_count = 0;
    r_count = 0;

%for each trial
for trl = 2:max(eptrials(:,5))


    
%TRIAL ACCURACY: correct (1) OR error (2)
if mode(eptrials(eptrials(:,5)==trl,8))==1


    %FINDING FLAG EVENT TIME
    if ismember(flag, 1:7)
                    
        %find arrival, the timestamp of entrance into section (minimum timestamp in
        %section on trial)
      	event = min(eptrials(isnan(eptrials(:,4)) & eptrials(:,5)==trl & eptrials(:,6)==flag,1));
         
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
    
    %Plotting Trajectories
    if mode(eptrials(eptrials(:,5)==trl, 7))==1
        
        figure(h1)
        hold on
        if l_count > 15; continue; end
        p1 = plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 3), 'Color', grn, 'LineWidth', 0.5, 'LineStyle', '-');
        l_count = l_count+1;
        if mode(eptrials(eptrials(:,5)==trl,8))==1
            left_means = [left_means; mean(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 2))];
        end
        
        figure(h2)
        hold on
        times = eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 1) - repmat(event, size(velocity_column(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1)));
        vels = velocity_column(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1);
        %plot(times, vels, 'Color', grn);
        vel_hold = [vel_hold; [times vels ones(size(times))]];
        
        %sorry
            xpos = nanmean(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 2));
            ypos = nanmean(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 3));
        mean_posL=[mean_posL; [xpos ypos]];
        mean_velL=[mean_velL; nanmean(vels)]; 
        mean_hdL=[mean_hdL; nanmean(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 15))]; %shouldnt be close to 360/0
        
        
        
        
    elseif mode(eptrials(eptrials(:,5)==trl, 7))==2

        figure(h1)
        hold on
        if r_count > 15; continue; end
        p2 = plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh, 3), 'Color', blu, 'LineWidth', 0.5, 'LineStyle', '-');
        r_count = r_count+1;
        if mode(eptrials(eptrials(:,5)==trl,8))==1
            right_means = [left_means; mean(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 2))];
        end
        
        figure(h2)
        times = eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 1) - repmat(event, size(velocity_column(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1)));
        vels = velocity_column(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1);
        %plot(times, vels, 'Color', blu);
        vel_hold = [vel_hold; [times vels repmat(2,size(times))]];
        
        
        %sorry
            xpos = nanmean(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 2));
            ypos = nanmean(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 3));
        mean_posR=[mean_posR; [xpos ypos]];
        mean_velR=[mean_velR; nanmean(vels)]; 
            hds = eptrials(eptrials(:,5)==trl & eptrials(:,1)>=windowlow & eptrials(:,1)<windowhigh & eptrials(:,14)==1, 15);
            mean_hds = rad2deg(circ_mean(deg2rad(hds))); if mean_hds<0; mean_hds=mean_hds+360; end
        mean_hdR=[mean_hdR; mean_hds]; %shouldnt be close to 360/0
        
        
        
    end
    
end
end    
    
%figure(h1)
%sections;
%rewards(eptrials, 1);
%legend([p1, p2],'Left', 'Right', 'location', 'northeastoutside');
%hold off
%title(['(-',num2str(windowbck), 's : ',num2str(windowfwd), 's)  Flag = ',flg],'fontsize', 20)

%figure(h2)
%plot([0 0], [0 1.5], 'k-')
%title('velocity over time window')
%xlabel ('time (s)')
%ylabel ('velocity (m/s)')
%hold off
delete_idxL = true(size(mean_posL,1),1);
delete_idxR = true(size(mean_posR,1),1);

for i = 1:2
    delete_idxL(mean_posL(:,i)>(nanmean(mean_posL(:,i))+nanstd(mean_posL(:,i))*3)) = 0;
    delete_idxR(mean_posR(:,i)>(nanmean(mean_posR(:,i))+nanstd(mean_posR(:,i))*3)) = 0;
    delete_idxL(mean_posL(:,i)<(nanmean(mean_posL(:,i))-nanstd(mean_posL(:,i))*3)) = 0;
    delete_idxR(mean_posR(:,i)<(nanmean(mean_posR(:,i))-nanstd(mean_posR(:,i))*3)) = 0;
end

delete_idxL(mean_velL>(nanmean(mean_velL)+nanstd(mean_velL)*3)) = 0;
delete_idxR(mean_velR>(nanmean(mean_velR)+nanstd(mean_velR)*3)) = 0;
delete_idxL(mean_velL<(nanmean(mean_velL)-nanstd(mean_velL)*3)) = 0;
delete_idxR(mean_velR<(nanmean(mean_velR)-nanstd(mean_velR)*3)) = 0;

delete_idxL(mean_hdL>(nanmean(mean_hdL)+nanstd(mean_hdL)*3)) = 0;
delete_idxR(mean_hdR>(nanmean(mean_hdR)+nanstd(mean_hdR)*3)) = 0;
delete_idxL(mean_hdL<(nanmean(mean_hdL)-nanstd(mean_hdL)*3)) = 0;
delete_idxR(mean_hdR<(nanmean(mean_hdR)-nanstd(mean_hdR)*3)) = 0;

mean_posLR=[nanmean(mean_posL(delete_idxL,:)) nanmean(mean_posR(delete_idxR,:))];
mean_velLR=[nanmean(mean_velL(delete_idxL,:)) nanmean(mean_velR(delete_idxR,:))]; 
mean_hdLR=[nanmean(mean_hdL(delete_idxL,:)) nanmean(mean_hdR(delete_idxR,:))];

end













