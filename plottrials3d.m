function plottrials3d(varargin)

%this individually plots each of the trials obtained from the function 
%"trials". However, it does not plot the first or last "trials," as these
% are the probe trial and the time before the rat is removed from the maze,
% repsectively.

%also plots sections, lick detections (flag 1), are entrance to the stem
%(flag 0)

%turn on spike plots if you are prepared for 40 x (#spikes) plots.

%check inputs
switch nargin
    case 0
        error(message('need more inputs'))
    case 1
        eptrials = varargin{1};
    case 2
        eptrials = varargin{1};
        
        if rem(varargin{2}, round(varargin{2})) > 0
            cell = varargin{2};
        else
            trials = varargin{2};
        end
        
    case 3
        eptrials = varargin{1};
        
        if rem(varargin{1}, round(varargin{1})) > 0
            cell = varargin{2};
            trials = vargarin{3};
        else
            trials = varargin{2};
            cell = varargin{3};
        end
        
    otherwise
        error(message('too many inputs'))
end

%what trials to plot
if exist('trials', 'var')
    range = trials + ones(size(trials));
else
    range = 1:1:(max(eptrials(:,5)));
end



for trl = range;

    figure
        
    hold on
    
        local_eptrials = eptrials(eptrials(:,5)==trl, :);
        trl_min_time = min(local_eptrials(:,1));
        number_timestamps_trl = length(local_eptrials(:,1));
        time_correction_vector = ones(number_timestamps_trl,1)*trl_min_time;
        local_eptrials(:,1) = (local_eptrials(:,1) - time_correction_vector).*10;
    
    %plot positions
        
        plot3(local_eptrials(local_eptrials(:,5)==trl, 2), local_eptrials(local_eptrials(:,5)==trl, 3), local_eptrials(local_eptrials(:,5)==trl,1), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
    
        if exist('cell', 'var')
        plot3(local_eptrials(local_eptrials(:,4)==cell, 2), local_eptrials(local_eptrials(:,4)==cell, 3), local_eptrials(local_eptrials(:,4)==cell,1), '.', 'Color', [1 0 0], 'markersize', 8)
        end
        plot3(local_eptrials(local_eptrials(:,10)==1, 2), local_eptrials(local_eptrials(:,10)==1, 3), local_eptrials(local_eptrials(:,10)==1,1), '.', 'Color', [0 0 0], 'markersize', 12)
        set(gca, 'Ytick', 50:10:450, 'XTick', 150:15:600)

    
    hold off
    
    sections;
    
    hold on
    
    %plot start and stop icons    
    plot3(local_eptrials(find(local_eptrials(:,1)==min(local_eptrials(:,1)),1), 2), local_eptrials(find(local_eptrials(:,1)==min(local_eptrials(:,1)),1), 3), min(local_eptrials(:,1)), 'g*', 'markersize', 20)
    plot3(local_eptrials(find(local_eptrials(:,1)==max(local_eptrials(:,1)),1), 2), local_eptrials(find(local_eptrials(:,1)==max(local_eptrials(:,1)),1), 3), max(local_eptrials(:,1)), 'r*', 'markersize', 20)
    
    %entrance to stem
        %last time point in high stem area
        last_stem = max(local_eptrials(local_eptrials(:,6)==3, 1));
    stem_ent = max(local_eptrials(local_eptrials(:,6)==1 & local_eptrials(:,1)<last_stem, 1));
    
    %exit from stem
        %first true reward visit
        rwd_vis = min(local_eptrials(ismember(local_eptrials(:,6), [7 8]) & local_eptrials(:,1)>stem_ent,1));
    stem_ext = min(local_eptrials(local_eptrials(:,6)==4 & local_eptrials(:,1)<rwd_vis & local_eptrials(:,1)>stem_ent,1));
   
    plot3(local_eptrials(local_eptrials(:,1)>stem_ent & local_eptrials(:,1)<stem_ext, 2), local_eptrials(local_eptrials(:,1)>stem_ent & local_eptrials(:,1)<stem_ext, 3), local_eptrials(local_eptrials(:,1)>stem_ent & local_eptrials(:,1)<stem_ext, 1), 'Color', 'c', 'LineWidth', 3)
    
        %left or right trial type (for plots)
        if mode(local_eptrials(:, 7))==1
            type = 'Left';
        elseif mode(local_eptrials(:, 7))==2
            type = 'Right';
        else
            type = 'Unknown_L/R';
        end
    
        %correct or error trial type (for plots)
        if mode(local_eptrials(:, 8))==1
            accuracy = 'Correct';
        elseif mode(local_eptrials(:, 8))==2
            accuracy = 'Error';
        else
            accuracy = 'UnknownAccuracy';
        end
        
        
    %lables
    title(['Trial ',num2str(trl-1), ' ',num2str(type), ' ',num2str(accuracy)],'fontsize', 16)
    
    %first lick detection
    
    %...the first trial will never be the one..and this works with the next
    %line
    for i = 2:length(local_eptrials)
 
        %only 2 and 3 will add to 5.
        if local_eptrials(i, 11) + local_eptrials(i-1, 11)==5
            
            %moment rat enters choice section from stem section.
            tmstmp=local_eptrials(i,1);
            
            licktime = min(local_eptrials(local_eptrials(:,10)==1 & local_eptrials(:,1)>tmstmp, 1));
       
            %crappy way of excluding trials w/o a lick detection
            if licktime > 0
            
                plot3(local_eptrials(local_eptrials(:,1)==licktime, 2), local_eptrials(local_eptrials(:,1)==licktime, 3), local_eptrials(local_eptrials(:,1)==licktime, 1), '.', 'Color', [0 0 1], 'markersize', 20)
            
            end
        end
    end
      
    
    %reverse z (time) plot so that time increase as rat moves away from
    %viewer default angle
    set(gca,'zdir','reverse')
    
    
end