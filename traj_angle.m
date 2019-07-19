function [trajectory_angle] = traj_angle(X, Y, window_size)

% traj_angle iterates through window_size adjacent points and calculates the
% angle (in degrees) between the first and last point in the window with 
% respect to the positive y axis. This angle is assigned to the point in the 
% middle of the window.
%
% traj_angle also screens trajectory_angle for unlikely angle changes and
% it assumes that large angle changes are more likely when the animal is
% moving rapidly and/or accellerating (read: starting from a stop), and less 
% likely when the animal is moving slowly and/or stopping.
%
% There are a number of non-trivial variables which can be altered in the
% body of the code if you are feeling particular. They include smoothing
% window sizes and such. Of note are:
%
%   accl_wdw affects the definition of starting and stopping. Larger values 
%       of accl_wdw will require the rat to be stopped for longer before its 
%       behavior is described as a stop/start.
%
%   cut_power and cut_const affect the nonlinear definition of (un)likely
%       angular change. They are detailed at length below in the body.
%
%
% INPUTS:
%
%   X and Y are column vectors of X and Y positions. They should be at 
%   equally-spaced time points. They need to be the same length.
%
%   window_size acts a bit like a smoother on the instantaneous angle.
%   The angle is calculated between two positions (x1,y1) and (x2,y2).
%   window_size determines how far apart these two positions are in the
%   vectors X and Y. A windowsize of 1 is impossible. A window size of 2
%   would calculate the angle at every pair of contiguous points. In my 
%   data, a window size of 100 would calculate the angle between two points 
%   1s apart. Try: 10
%
%
% OUTPUTS:
%
%   trajectory_angle is a vector of clockwise angles with respect to the
%   positive y axis. It is the same length as X and Y.
%



%CALCULATE EMPIRICAL TRAJECTORY ANGLE AND DISTANCE TRAVELLED
%

%preallocate
trajectory_angle = nan(1, length(X));
cumdist = nan(1, length(X));

%deal with items at the begining of the session, which cannot accomodate the window size
trajectory_angle(1:floor((window_size+1)/2)) = cwangle(X(1), Y(1), X(window_size), Y(window_size));
cumdist(1:floor((window_size+1)/2)) = sum(sqrt(diff(X(1:window_size)).^2 + diff(Y(1:window_size)).^2));

%deal with items at the very end of the session, which cannot accomodate the window size
trajectory_angle((length(trajectory_angle)-floor((window_size)/2)):end) = cwangle(X(length(X) - window_size), Y(length(Y) - window_size), X(end), Y(end));
cumdist((length(cumdist)-floor((window_size)/2)):end) = sum(sqrt(diff(X((length(X) - window_size):end)).^2 + diff(Y((length(Y) - window_size):end)).^2));

%set begining item angle as last_clear_motion (unlikley to be used)
last_clear_motion = trajectory_angle(1);

%deal with bulk of items in the session
for current_item = (floor((window_size+1)/2)+1):(length(trajectory_angle)-(floor((window_size+1)/2)+1))

    %position coordinates
    x1 = X(current_item - floor((window_size+1)/2));
    y1 = Y(current_item - floor((window_size+1)/2));
    x2 = X(current_item + floor((window_size+1)/2));
    y2 = Y(current_item + floor((window_size+1)/2));
    
    %ranges
    low = current_item - floor((window_size+1)/2);
    high = current_item + floor((window_size+1)/2);
    xwdw = X(low:high);
    ywdw = Y(low:high);
    
    %cumulative_difference_vectors
    cumdist(current_item) = sum(sqrt(diff(xwdw).^2 + diff(ywdw).^2));

    %Avoiding nan's
    if sum(abs(diff(xwdw))) < 0.1 && sum(abs(diff(ywdw))) < 0.1 %ignore samples where position does not change
        trajectory_angle(current_item) = last_clear_motion; %if no movement, set angle as last angle observation
    else
        trajectory_angle(current_item) = cwangle(x1, y1, x2, y2);
        last_clear_motion = trajectory_angle(current_item); %define last clear motion as current angle observation
    end
    
end

%normalized cumulative differences. 1 for lots of movement, 0 for little
%movement. Will be used later in a mathy way to eliminate unlikely
%angular changes.
cumdist_norm = cumdist./max(cumdist);



%IDENTIFY STOPS AND STARTS
%

%acceleration window_size
%this affects the amount of time information that goes into determining 
%whether the rat is "starting" or "stopping." 100 (1s) works well.
accl_wdw = 100;

%preallocate
accel_descrip = nan(1, length(X));

%deal with the begining and end of the session, which cannot accomodate the window size
accel_descrip(1:accl_wdw) = 0;
accel_descrip((length(accel_descrip)-(accl_wdw-1)):end) = 0;

%identify stops and starts
for current_item = (accl_wdw+1):((length(accel_descrip)-accl_wdw))
    
    %ranges
    back = (current_item - accl_wdw):(current_item - 1);
    fwd = (current_item + 1) : (current_item + accl_wdw);
   
    %if insufficient movement, move to next loop item
    if sum(sqrt(diff(X(back)).^2 + diff(Y(back)).^2)) < 3 && sum(sqrt(diff(X(fwd)).^2 + diff(Y(fwd)).^2)) < 3
        %holding speed
        accel_descrip(current_item) = 0;
        continue
    end
        
    %if coming to a stop
    %(moved ten times as far in the last half time window than the next half time window) 
    if sum(sqrt(diff(X(back)).^2 + diff(Y(back)).^2)) > 10*sum(sqrt(diff(X(fwd)).^2 + diff(Y(fwd)).^2))
        accel_descrip(current_item) = -1;

    %if speeding up
    %(moved ten times as far in the next half time window than the last half time window)
    elseif 10*sum(sqrt(diff(X(back)).^2 + diff(Y(back)).^2)) < sum(sqrt(diff(X(fwd)).^2 + diff(Y(fwd)).^2))
        accel_descrip(current_item) = 1;

    %if holding speed
    %none of the above
    else
        accel_descrip(current_item) = 0;
    end
 
end



%IGNORE LOW PROBABILITY ANGLE CHANGES
%
%This loop checks at every time point if the change in angle at that time
%point is below an arbitrary boundary, determined by accelleration. If it 
%is above the boundary, it treats the change at that time point as 
%untrustworthy and substitutes in the last trusted angle.
%
%The cuttoff is non-linear, and is much lower at slow speeds, 
%meaning that angle changes at low speeds are more likely to be ignored. 
%The cuttoff is controlled by two variables: cut_power and cut_const
%
%Higher values of cut_power increase the nonlinearity of the penalty, 
%essentially penalizing low speeds to an exponentially greater degree. 
%Try: 3 
%
%Higher values of cut_const are required to operate under increased penalty.
%These values lower the penalty on all speeds in a linear fashion. 
%Try: 20,000
%
%To see the cutoff at every time point, plot:
%figure; plot(cumdist_norm.^cut_power.*cut_const); ylim([0 360]); hold on; plot([0 length(cumdist_norm)],[180 180],'r-', 'LineWidth',3)
%
%The red line indicates 180 degrees, the functional ceiling for restricting
%angle shift. Values above 180 (and there should be many) are functionally
%equivillant to 180.

cut_power = 3;
cut_const = 20000;

%set first angle as last_clear_movement (unlikely to be used)
last_clear_movement = trajectory_angle(1);

for item = 2:length(trajectory_angle)
    
    %if stopping, more penalty
    if accel_descrip(item) == -1
    
        if circ_distance(trajectory_angle(item-1), trajectory_angle(item), [0 360]) < cut_const*(0.5) * cumdist_norm(item)^(cut_power+1)

            last_clear_movement = trajectory_angle(item);
        else
            trajectory_angle(item) = last_clear_movement;
        end
        
    %if starting, less penalty
    elseif accel_descrip(item) == 1
        
        if circ_distance(trajectory_angle(item-1), trajectory_angle(item), [0 360]) < cut_const*(1.5) * cumdist_norm(item)^(cut_power-1)

            last_clear_movement = trajectory_angle(item);
        else
            trajectory_angle(item) = last_clear_movement;
        end
    
    %if holding speed, unchanged penalty
    elseif accel_descrip(item) == 0
        
        if circ_distance(trajectory_angle(item-1), trajectory_angle(item), [0 360]) < cut_const * cumdist_norm(item)^(cut_power)

            last_clear_movement = trajectory_angle(item);
        else
            trajectory_angle(item) = last_clear_movement;
        end
        
    end
end


end
