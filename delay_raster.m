function [left_trials right_trials] = delay_raster(eptrials, stem_runs, clusters, c)
%plots rasters of the left and right trials delay periods +3s


delay_runs = [stem_runs(:,1)-repmat(30, size(stem_runs(:,1))) stem_runs(:,1)+repmat(3, size(stem_runs(:,1)))];
delay_runs = delay_runs(2:end, :);

left_trial_count=0;
right_trial_count=0;

for trl = 2:51
    
    
    if mode(eptrials(eptrials(:,5)==trl, 7))==1
        
        left_trial_count = left_trial_count+1;
        
        hold = eptrials(eptrials(:,4)==clusters(c,1) & eptrials(:,1)>delay_runs(trl-1,1) & eptrials(:,1)<delay_runs(trl-1,2),1)';
        hold = hold - repmat(max(hold), size(hold));
        
        
        left_trials(left_trial_count) = {hold};
        
        
        
    else
    
        right_trial_count = right_trial_count+1;
        
        hold = eptrials(eptrials(:,4)==clusters(c,1) & eptrials(:,1)>delay_runs(trl-1,1) & eptrials(:,1)<delay_runs(trl-1,2),1)';
        hold = hold - repmat(max(hold), size(hold));
        
        right_trials(right_trial_count) = {hold};

    end
    
end


LineFormat = struct();
LineFormat.Color = [0 0 0];
LineFormat.LineWidth = 0.35;
LineFormat.LineStyle = '-';

figure; plotSpikeRaster(left_trials,'PlotType','vertline', 'LineFormat', LineFormat); title right
figure; plotSpikeRaster(right_trials,'PlotType','vertline', 'LineFormat', LineFormat); title left


end