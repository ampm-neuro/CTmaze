function shuffle_out = futr_traj_shuf(posterior_all, sessions, shuffs)
%posterior_all is a cell array of posterior_alls output by decodehist.
%Sessions is the file path string to each session file.

%preallocate
shuffle_out = nan(shuffs, length(sessions));

%bins
bins = sqrt(length(posterior_all{1}(1,:)));

for sesh = 1:length(posterior_all)
    
    stem_runs = [];
    load(sessions{sesh});
    
    trials = unique(eptrials(eptrials(:,8)>0, 5));
    trials = trials(stem_runs(2:end,3)<1.25);
    
    left_trials = intersect(trials, unique(eptrials(eptrials(:,7)==1 & eptrials(:,8)==1, 5)));
    right_trials = intersect(trials, unique(eptrials(eptrials(:,7)==2 & eptrials(:,8)==1, 5)));
    
    LR_trials = [left_trials;right_trials];

    for shuffle = 1:shuffs
        
        
        LR_trials = LR_trials(randperm(length(LR_trials)));
        left_trials = LR_trials(1:length(left_trials));
        right_trials = LR_trials((length(left_trials)+1):end);
        
        left_probs = reshape(nanmean(posterior_all{sesh}(ismember(trials,left_trials),:)), 50, 50);
        right_probs = reshape(nanmean(posterior_all{sesh}(ismember(trials,right_trials),:)), 50, 50);
        
        warning('off','all')

        p_sections = nan(10,2);
        p_sections(1,:) = [nansum(nansum(left_probs(1:bins*.3000, bins*0.3750:bins*0.62500))) nansum(nansum(right_probs(1:bins*.3000, bins*0.3750:bins*0.62500)))]./sum(sum(~isnan(right_probs(1:bins*.3000, bins*0.3750:bins*0.62500)))); %start area 1 1
        p_sections(2,:) = [nansum(nansum(left_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250)))]./sum(sum(~isnan(right_probs(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250)))); %low common stem 2 2
        p_sections(3,:) = [nansum(nansum(left_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250)))]./sum(sum(~isnan(right_probs(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250)))); %high common stem 3 3
        p_sections(4,:) = [nansum(nansum(left_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250))) nansum(nansum(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250)))]./sum(sum(~isnan(right_probs(bins*0.7625:bins, bins*0.3750:bins*0.6250)))); %choice area 4 4
        p_sections(5,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.2000:bins*0.3750)))); %approach arm left 5 5
        p_sections(6,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.6250:bins*0.8000)))); %approach arm right 6 5
        p_sections(7,:) = [nansum(nansum(left_probs(bins*0.7125:bins, 1:bins*0.2000))) nansum(nansum(right_probs(bins*0.7125:bins, 1:bins*0.2000)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, 1:bins*0.2000)))); %reward area left 7 6
        p_sections(8,:) = [nansum(nansum(left_probs(bins*0.7125:bins, bins*0.8000:bins))) nansum(nansum(right_probs(bins*0.7125:bins, bins*0.8000:bins)))]./sum(sum(~isnan(right_probs(bins*0.7125:bins, bins*0.8000:bins)))); %reward area right 8 6
        p_sections(9,:) = [nansum(nansum(left_probs(1:bins*0.7125, 1:bins*0.3750))) nansum(nansum(right_probs(1:bins*0.7125, 1:bins*0.3750)))]./sum(sum(~isnan(right_probs(1:bins*0.7125, 1:bins*0.3750)))); %return arm left 9 7
        p_sections(10,:) = [nansum(nansum(left_probs(1:bins*0.7125, bins*0.6250:bins))) nansum(nansum(right_probs(1:bins*0.7125, bins*0.6250:bins)))]./sum(sum(~isnan(right_probs(1:bins*0.7125, bins*0.6250:bins)))); %return arm right 10 7

        warning('on','all')
        
        p_sections_norm = [p_sections(:,1)./sum(p_sections(:,1)) p_sections(:,2)./sum(p_sections(:,2))]; %normalize by section area
        p_sections_norm = [p_sections_norm(1,:); sum(p_sections_norm(2:3,:)); p_sections_norm(4:end,:)]; %normalize by sections

        future_traj = sum(p_sections_norm([4 6], 1) + p_sections_norm([5 7], 2))./2;
        past_traj = sum(p_sections_norm([5 7], 1) + p_sections_norm([4 6], 2))./2;
        
        shuffle_out(shuffle, sesh) = (future_traj - past_traj)/(future_traj + past_traj);
        
    end
end

shuffle_out = mean(shuffle_out, 2);

end

