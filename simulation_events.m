function [sim_evt_ct, p_traj] = simulation_events(posterior_cells, vect2mat_idx)
%identify trials with high decoding to both/either future trajectories

ptraj_stage = [];
p=[];
p_traj = [];
sim_evt_ct = [];

for i = 1:length(posterior_cells)

    posterior_all_cell = posterior_cells{i};
    
    for sesh = 1:length(posterior_all_cell)

        hold = posterior_all_cell{sesh};
        
        hold = nansum(hold(:, vect2mat_idx==4), 2);

        p_traj = [p_traj; hold];

        ptraj_stage = [ptraj_stage; hold];
        
        sim_evt_ct = [sim_evt_ct; sum(hold>.2)/length(hold>.2)];
        
        p = [p; mean(p_traj)];

    end

    figure; hist(ptraj_stage, 10)
    ptraj_stage = [];
    
mean(p_traj)
std(p_traj)

end

figure; hist(p_traj, 10)
figure; hist(sim_evt_ct)
end