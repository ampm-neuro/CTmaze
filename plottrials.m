function plottrials(varargin)

%function plottrials(eptrials, cell, trials)
%
%this individually plots each of the trials obtained from the function 
%"trials". However, it does not plot the first or last "trials," as these
% are the probe trial and the time before the rat is removed from the maze,
% repsectively.

%also plots sections, lick detections (flag 1), are entrance to the stem
%(flag 0)

%turn on spike plots if you are prepared for 40 x (#spikes) plots.

%identifies sorted spikes
%c = unique(eptrials(eptrials(:,4)>0,4));

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
    
    %for spk = 1:length(c);

        plot(eptrials(eptrials(:,5)==trl, 2), eptrials(eptrials(:,5)==trl, 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
        if exist('cell', 'var')
            plot(eptrials(eptrials(:,5)==trl & eptrials(:,4)==cell, 2), eptrials(eptrials(:,5)==trl & eptrials(:,4)==cell, 3), '.', 'Color', [1 0 0], 'markersize', 8)
        end
        plot(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1, 2), eptrials(eptrials(:,5)==trl & eptrials(:,10)==1, 3), '.', 'Color', [0 0 0], 'markersize', 12)
        %set(gca,'xdir','reverse')
        set(gca, 'Ytick', 50:10:450, 'XTick', 150:15:600)

    %end

    hold off
    
    sections;
    
    hold on
    
    %entrance to stem
    stemtime = min(eptrials(eptrials(:,5)==trl & eptrials(:,6)==2, 1));
    
    plot(eptrials(eptrials(:,1)==stemtime, 2), eptrials(eptrials(:,1)==stemtime, 3), '.', 'Color', [0 0 1], 'markersize', 20)
    
        %left or right trial type (for plots)
        if mode(eptrials(eptrials(:,5)==trl, 7))==1
            type = 'Left';
        elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
            type = 'Right';
        else
            type = 'Unknown_L/R';
        end
    
        %correct or error trial type (for plots)
        if mode(eptrials(eptrials(:,5)==trl, 8))==1
            accuracy = 'Correct';
        elseif mode(eptrials(eptrials(:,5)==trl, 8))==2
            accuracy = 'Error';
        else
            accuracy = 'UnknownAccuracy';
        end
        
        
    %lables
    title(['Trial ',num2str(trl-1), ' ',num2str(type), ' ',num2str(accuracy)],'fontsize', 16)
    
    %first lick detection
    
    %pulling out trial-related eptrials to help indexing. May be able to
    %index directly?
    trialeptrials = eptrials(eptrials(:,5)==trl, :);
    
    %...the first trial will never be the one..and this works with the next
    %line
    for i = 2:length(trialeptrials)
 
        %only 2 and 3 will add to 5.
        if trialeptrials(i, 11) + trialeptrials(i-1, 11)==5
            
            %moment rat enters choice section from stem section.
            tmstmp=trialeptrials(i,1);
            
            licktime = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,1)>tmstmp, 1));
       
            %crappy way of excluding trials w/o a lick detection
            if licktime > 0
            
                plot(eptrials(eptrials(:,1)==licktime, 2), eptrials(eptrials(:,1)==licktime, 3), '.', 'Color', [0 0 1], 'markersize', 20)
            
            end
        end
    end
        
end