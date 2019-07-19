function [outcomes, rwd_rep] = ftr_traj_temp(p_sections, pp_cell)
%outputs a plot of each session's future/past preference

%load('ftr_traj_200_stemruns_aug23_withcellcts.mat')

figure; hold on
outcomes = cell(length(p_sections),1);
for i = 1:length(p_sections)

    %trajectories
    future_traj = squeeze(sum(p_sections{i}([4 6], 1, :) + p_sections{i}([5 7], 2, :)))./2;
    past_traj = squeeze(sum(p_sections{i}([5 7], 1, :) + p_sections{i}([4 6], 2, :)))./2;

    
    %approaches
    %future_traj = squeeze(sum(p_sections{i}([4 4], 1, :) + p_sections{i}([5 5], 2, :)))./4;
    %past_traj = squeeze(sum(p_sections{i}([5 5], 1, :) + p_sections{i}([4 4], 2, :)))./4;
    
    %rewards
    %future_traj = squeeze(sum(p_sections{i}([6 6], 1, :) + p_sections{i}([7 7], 2, :)))./4;
    %past_traj = squeeze(sum(p_sections{i}([7 7], 1, :) + p_sections{i}([6 6], 2, :)))./4;
    
    %stem
    %future_traj = squeeze(sum(p_sections{i}([2 3], 1, :) + p_sections{i}([2 3], 2, :)))./4;
    %past_traj = squeeze(sum(p_sections{i}([2 3], 1, :) + p_sections{i}([2 3], 2, :)))./4;
    
    %rtrns = squeeze(sum(p_sections{i}([2 2], 1, :) + p_sections{i}([2 2], 2, :)))./4;
    %rtrns = ones(size(rtrns)) - rtrns;
    
    %future_traj = squeeze(sum(p_sections{i}([8 8], 1, :) + p_sections{i}([9 9], 2, :)))./4;
    %past_traj = squeeze(sum(p_sections{i}([9 9], 1, :) + p_sections{i}([8 8], 2, :)))./4;


    preferred = nan(size(future_traj));
    for sesh = 1:length(future_traj)
        
        preferred(sesh) = (future_traj(sesh) - past_traj(sesh))/(future_traj(sesh) + past_traj(sesh));
        
    end
    
    %
    trajz = sum([future_traj past_traj],2);
    %trajz = sort([future_traj past_traj],2);%old
    %trajz = trajz(:,size(trajz,2));%old
    
    %uncomment for total reward rep
    %
     stemz = squeeze(sum(p_sections{i}(2, :, :),2))./2;
     preferred = trajz./(1-stemz);
     out = temp_III(pp_cell{i}, 50)' ;
     preferred = preferred./out;
    
    %}
    
    
    
  %{  
    if i ==3
        
        preferred(6) = [];
    elseif i == 4
        preferred(12) = [];
    end
    %}
    
    outcomes{i} = preferred;

    
    %bar(i, mean(preferred))
    
    
    plot(i, nanmean(preferred), 'k.','markersize',30)
    
    errorbar(i, nanmean(preferred), nanstd(preferred)./sqrt(sum(~isnan(preferred))), 'k','LineWidth',2);
    plot(repmat(i, size(preferred)), preferred, 'ko', 'markersize', 6)
    
    
    %[t_outcome, t_pval] = ttest(preferred)
    
    %preferred
    %mean_preferred = mean(preferred);
end

 %hold on; plot([.5 4.5], [1 1], 'k--')
 %ylim([0 3])

 plot(1:4, [nanmean(outcomes{1}) nanmean(outcomes{2}) nanmean(outcomes{3}) nanmean(outcomes{4})], 'k','LineWidth',2)

%
plot([.5 i+.5], [0 0], 'k--')
 %ylim([-.27 .27])
 ylim auto
 box off; set(gca,'TickLength',[0, 0]);
 hold off

 shuffs_stageshuf = shuffle_grps_props(10000, outcomes);
 shuffs_stageshuf_origin = shuffle_grps_props(0, outcomes);
 shuf_pval = sum(shuffs_stageshuf>=shuffs_stageshuf_origin)/10000
    
    figure; hist(shuffs_stageshuf,30)
    hold on; plot([shuffs_stageshuf_origin shuffs_stageshuf_origin], [0 1500], 'r-')
    
    
   % [r p] = fit_line(vel_pos(:,1), preferred) 
    %title('velocity')
    %[r p] = fit_line(vel_pos(:,2), preferred)
    %title('lat pos')
 %
for i = 1:length(p_sections)
    % accuracy{i} = accuracy{i}';
    %[r, p] = fit_line(outcomes{i}, accuracy{i})
 end

 
 %}
 %[r, p] = fit_line(cell2mat(outcomes), cell2mat(accuracy))
 %}
end