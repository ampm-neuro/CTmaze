function velocity_column = vid_velocity(eptrials)
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
        
    dist_btwn_rwds_cm = 112.395;
    
    velocity_column = nan(size(eptrials,1),1);
    
    avgXYrwdL = [mean(eptrials(eptrials(:,8)==1 & eptrials(:,7)==1,2)) mean(eptrials(eptrials(:,8)==1 & eptrials(:,7)==1,3))];
    avgXYrwdR = [mean(eptrials(eptrials(:,8)==1 & eptrials(:,7)==2,2)) mean(eptrials(eptrials(:,8)==1 & eptrials(:,7)==2,3))];
    rwd_dist = pdist([avgXYrwdL; avgXYrwdR]);
    cm_per_matlab_unit = dist_btwn_rwds_cm/rwd_dist;
    cm_per_matlab_unit = .55;

        %calculate distances between every video sample
        eptrials_vid = eptrials(eptrials(:,14) == 1, 2:3);

        pos1 = [eptrials_vid(1:end-1,1)'; eptrials_vid(1:end-1,2)'];
        pos2 = [eptrials_vid(2:end,1)'; eptrials_vid(2:end,2)'];

        distances = zeros(length(eptrials_vid),1);
        for i = 1:length(eptrials_vid)-1
            distance = pdist([pos1(:,i) pos2(:,i)]');
            distances(i+1) = distance;%(1,2);
        end

        %calulate velocity (cm/s) from dists_overall (see above)
        velocity = (distances.*cm_per_matlab_unit)./0.01; %0.01 is time. dist/time = velocity
        %change to m/s
        velocity = velocity/100;

        %set rows
        velocity(1) = velocity(2);
        velocity_column(eptrials(:,14)==1) = smooth(velocity, 40);%try 40
        
    end