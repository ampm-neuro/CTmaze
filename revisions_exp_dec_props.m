load('ftr_traj_200_stemruns_aug23.mat')


%ftr_past_foldfig(posterior_all_cell_23, sessions_cell_23)

post_cell = posterior_all_cell_23;

% flip left trials
all_posts = [];
for iseh = 1:length(post_cell) 
    
    %get LR designations
    load(session)
    
    for itrl = 1:size(post_cell{})
        trial_hold = post_cell{iseh}(itrl,:);
    end
    all_posts = [all_posts; post_cell{iseh}]; 
end
figure; bar3(reshape(nanmean(all_posts)./nansum(nansum(nanmean(all_posts))), 50,50))