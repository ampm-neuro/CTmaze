function posplotcolor(eptrials)

%plots session trajectory with lines colored by trial type (left and right)
%obtained from the function "trials". However, it does not plot the first 
%"trial," as this is the probe trial.

%also plots sections, lick detections (flag 1), are entrance to the stem
%(flag 0)

grn=[52 153 70]./255;
blu=[46 49 146]./255;


figure
hold on
%set(gca,'xdir','reverse')
set(gca, 'Ytick', 50:10:450, 'XTick', 150:15:600)

for trl = 2:(max(eptrials(:,5)));

    if mode(eptrials(eptrials(:,5)==trl, 7))==1 

        h1=plot(eptrials(eptrials(:,5)==trl, 2), eptrials(eptrials(:,5)==trl, 3), 'Color', grn, 'LineWidth', 0.5, 'LineStyle', '-');
        hold on
        
        
    elseif mode(eptrials(eptrials(:,5)==trl, 7))==2
        
        h2=plot(eptrials(eptrials(:,5)==trl, 2), eptrials(eptrials(:,5)==trl, 3), 'Color', blu, 'LineWidth', 0.5, 'LineStyle', '-');
        hold on
    
    end
end

sections(eptrials); rewards(eptrials);
legend([h1 h2], 'Left Trials', 'Right Trials', 'Location', 'Northeastoutside')
axis('off')