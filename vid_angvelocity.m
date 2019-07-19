function velocity_column = vid_angvelocity(eptrials)
    %vid_velocity adds a column with the estimated instantaneous
    %velocity at every video sample time-point (row). Other rows are nan.
    %
    % INPUTS
    %   eptrials = the overall output; a matrix of all relevant information
    %   cm_per_matlab_unit = conversion between xy coordniate space and real-life distance
    %
    % OUTPUT
    %   eptrials = the overall output; a matrix of all relevant information
    %    

    velocity_column = nan(size(eptrials,1),1);

        %calculate angular distances between every video sample
        eptrials_vid = eptrials(eptrials(:,14) == 1, 15);

        ang1 = eptrials_vid(1:end-1);
        ang2 = eptrials_vid(2:end);

        [circ_dist, cw] = circ_distance(ang1,ang2, [0 360]);
        circ_dist = circ_dist.*cw;

        %angular velocity (deg/s)
        velocity = circ_dist./0.01; %0.01 is time. dist/time = velocity

        %set rows
        velocity_column(eptrials(:,14)==1) = [velocity(1);smooth(velocity, 40)];%try 40
        
end