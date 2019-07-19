function accl_column = vid_acceleration(eptrials, velocity_col)
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

        vid_velo = velocity_col(eptrials(:,14)==1);
    
        velo1 = vid_velo(1:end-1);
        velo2 = vid_velo(2:end);

        accl = (velo2-velo1)./0.01; %0.01 is time. delta velo / time = accl
        accl = [accl(1); accl];
        
        %set rows
        accl_column = nan(size(eptrials,1),1);
        accl_column(eptrials(:,14)==1) = smooth(accl, 40);%try 40
        
end