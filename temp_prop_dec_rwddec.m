function [sesh_means_out, rwd_dec_out, rwd_prop] = temp_prop_dec_rwddec(all_decode_vars)
%turning future_decode_script stuffs into proportion plots

proportion_of_nonstem_decode = [];
proportion_of_nonstem_visit = [];

[ij_pos(:,1), ij_pos(:,2)] = ind2sub([50 50],all_decode_vars{5}(:,4));

%xmin xmax ymin ymax
lra = [1 18; ...
       38 50];
rra = [33 50; ...
       38 50];
stem_area = [20 33;14 35];

left_reward_x = ij_pos(:,2) >= lra(1,1) & ij_pos(:,2) <= lra(1,2);
left_reward_y = ij_pos(:,1) >= lra(2,1) & ij_pos(:,1) <= lra(2,2);
left_reward_idx = left_reward_x + left_reward_y == 2;

right_reward_x = ij_pos(:,2) >= rra(1,1) & ij_pos(:,2) <= rra(1,2);
right_reward_y = ij_pos(:,1) >= rra(2,1) & ij_pos(:,1) <= rra(2,2);
right_reward_idx = right_reward_x + right_reward_y == 2;

stem_idx_x = ij_pos(:,2) >= stem_area(1,1) & ij_pos(:,2) <= stem_area(1,2);
stem_idx_y = ij_pos(:,1) >= stem_area(2,1) & ij_pos(:,1) <= stem_area(2,2);
stem_idx = stem_idx_x + stem_idx_y == 2;

sesh_means = [];
rwd_prop = [];

nineteen = [];
for i = 1:length(all_decode_vars{19})
 nineteen = [nineteen; all_decode_vars{19}{i}];
end
all_decode_vars{19} = nineteen;

count = 0;
for irat = unique(all_decode_vars{5}(:,1))' 
    for isesh = unique(all_decode_vars{5}(all_decode_vars{5}(:,1)==irat,3))' 
        
        count = count +1;
        
        %left trial samples
        lts_future = sum(all_decode_vars{5}(:,1)==irat & ...
                all_decode_vars{5}(:,3)==isesh & all_decode_vars{19} == 1 ...
                & left_reward_idx);
        lts_notfuture = sum(all_decode_vars{5}(:,1)==irat & ...
                all_decode_vars{5}(:,3)==isesh & all_decode_vars{19} == 1 ...
                & right_reward_idx);
            
        %right trial samples
        rts_future = sum(all_decode_vars{5}(:,1)==irat & ...
                all_decode_vars{5}(:,3)==isesh & all_decode_vars{19} == 2 ...
                & right_reward_idx);
        rts_notfuture = sum(all_decode_vars{5}(:,1)==irat & ...
                all_decode_vars{5}(:,3)==isesh & all_decode_vars{19} == 2 ...
                & left_reward_idx);
            
        %intermediate sums
        future_rwd = lts_future + rts_future;
        not_future_rwd = lts_notfuture + rts_notfuture;
        future_dec = [sesh_means; (future_rwd - not_future_rwd) / (future_rwd + not_future_rwd)];

        %output
        %
        prop_of_nonstem = [sesh_means; (future_rwd + not_future_rwd) / ...
            sum(all_decode_vars{5}(:,1)==irat &...
            all_decode_vars{5}(:,3)==isesh & ~stem_idx & ~isnan(ij_pos(:,1)))];
        
        sesh_means = future_dec;
        
        visited_area = ~isnan(all_decode_vars{3}(:,:,count));
        
        vis_area_rwd_L = sum(sum(visited_area(lra(1,1):lra(1,2), lra(2,1):lra(2,2))));
        vis_area_rwd_R = sum(sum(visited_area(rra(1,1):rra(1,2), rra(2,1):rra(2,2))));
        vis_area_rwd = vis_area_rwd_L + vis_area_rwd_R;
        
        vis_area_stem = sum(sum(visited_area(stem_area(1,1):stem_area(1,2), stem_area(2,1):stem_area(2,2))));
        
        nonstem_areas = sum(sum(visited_area)) - vis_area_stem;
        
        all_areas = sum(sum(visited_area));
        
        rwd_prop = [rwd_prop; vis_area_rwd/nonstem_areas];
        
        rwd_dec_out = prop_of_nonstem/rwd_prop;
        
        test_out = future_rwd + not_future_rwd;
        
        
        
    end
end

%[t p stats] = ttest(sesh_means)
%rwd_dec_out = rwd_dec_out(:,5);
sesh_means_out = sesh_means;