function [stage_outs, shuffs_out] = prop_pages_plot(prop_pages)
%prop_pages is a cell containing prop pages from each learning stage in
%order


figure; hold on

stage_outs = cell(length(prop_pages),1);
stage_mean = nan(length(prop_pages),1);

for stage = 1:length(prop_pages)

    session_means = nan(size(prop_pages{stage},3), 1);
    %
    for sesh = 1:size(prop_pages{stage},3)
        
       session_means(sesh) = nanmean(nanmean(prop_pages{stage}(:,:,sesh)));
        
       %plot(stage, session_means(sesh), 'ko') 
                
    end
    %}
    stage_outs{stage} = session_means;
    
    plot(stage, mean(session_means), 'k.', 'Markersize', 30)
    errorbar(stage, mean(session_means), std(session_means)/sqrt(length(session_means)), 'Linewidth', 2, 'Color', 'k')
    
    stage_mean(stage) = mean(stage_outs{stage});
end

plot(1:length(stage_mean), stage_mean, 'k-')
box off; set(gca,'TickLength',[0, 0]);
hold off

shuffs_out_origin = shuffle_grps_props(0, stage_outs);
shuffs_out = shuffle_grps_props(10000, stage_outs);


figure;
hist(shuffs_out,30);
hold on
plot([shuffs_out_origin shuffs_out_origin], [0 1500], 'r-')
box off; set(gca,'TickLength',[0, 0]);axis square
shuf_pval = sum(shuffs_out>=shuffs_out_origin)/length(shuffs_out)
end