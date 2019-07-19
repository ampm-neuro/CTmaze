function [head_direction] = remedial_HD(Targets, TimestampsVT, ep_vid_time, ep_vid_X, ep_vid_Y, rotang)
%
% This code takes the nueralynx output variable Targets and estimates the
% rat's head direction in each video frame. Targets contains the Y-coordinate of
% each of two lights on top of the rat's head. It cannot distinguish between
% the two lights, so the only reliable measure is the difference between
% them (along the Y dimension). This difference can be used to narrow down the
% possible head directions to just 4 directions (one in each quadrant). 
% Trajectory information is then used to choose the correct one.
%
% There are a number of non-trivial variables which can be altered in the
% body of the code if you are feeling particular. They include smoothing
% window sizes and such. However, it works as is.
%
% INPUTS:
%
% Targets is output by the neuralynx extraction code Nlx2MatVT_v3, and
% contains location information about lights detected by the overhead
% camera. It's coded in an obscure way. This code treats the Targets input
% as two row vectors containing the y position of the two lights on top of
% the rat's head.
%
% TimestampsVT is output by the neuralynx extraction code Nlx2MatVT_v3, and
% contains the timestamps corresponding to the Targets data. Early on,
% remedial_hd translates these timestamps into units of seconds counting up
% from zero.
%
% ep_vid_time is a list of time points from the same session as Targets and 
% TimestampsVT. These are the time points at which I am calculting 
% head_direction. It should be at regular intervals starting at zero 
% (e.g., 0:.01:N). I upsample my time points, so ep_vid_time is much longer 
% than TimestampsVT. Try: ep_vid_time = eptrials(eptrials(:,14)==1, 1)
%
% ep_vid_X and ep_vd_Y are the x and y positions of the rat at the time
% points ep_vid_time. These vectors must be the same length as ep_vid_time.
% Try:
%  ep_vid_X = eptrials(eptrials(:,14)==1, 2)
%  ep_vid_Y = eptrials(eptrials(:,14)==1, 3)
%
% rotang is output by the function rotation_angle and should be available
% within trials_III. If it is not available, use 0 or simply delete it from
% the inputs and the body of the code. It is not essential.
%
% 
% OUTPUTS:
%
% head_direction contains the estimated head_direction angle at every time
% points in ep_vid_time. It is in clockwise degrees from the positive y
% axis.
%

%dropped signals contain zeros in one or both Targets row vectors
dropped_signals = Targets(1,:)==0 | Targets(2,:)==0;



%IDENTIFY CANDIDATE HEAD DIRECTIONS
%

%absolute differences between the y coordinates of the two lights
difference_vector = abs((Targets(1,~dropped_signals) - Targets(2,~dropped_signals)));

%add outlying distances to dropped_signals (these are distances > the maximum possible, i.e.
%noise).
dropped_signals(~dropped_signals) = difference_vector >= 800000;

%difference_vector sans outliers
difference_vector = abs((Targets(1,~dropped_signals) - Targets(2,~dropped_signals)));

%converts video timestamp units into seconds
time_vt = TimestampsVT(~dropped_signals)';
starttime = zeros(length(time_vt), 1);
starttime(:,1) = time_vt(1);
time_vt = time_vt - starttime;
time_vt = time_vt./1000000;

%interp, smooth, normalize. also find inverse
difference_vector = circ_interp1(difference_vector, [min(difference_vector) max(difference_vector)], ep_vid_time', time_vt);
difference_vector_smooth = smooth(difference_vector(~isnan(difference_vector)), 20)'; %this should not be circ_smoothed
difference_vector(~isnan(difference_vector)) = difference_vector_smooth;%avoids nans at end
difference_vector = difference_vector./max(difference_vector); 
inverse_diff_vect = ones(1,length(difference_vector)) - difference_vector; %inverse is important in the next step

%each item in the difference_vector corresponds to one of 4 possible head
%directions (except for the max and min, which each correspond to 2). When
%the y coordinates are very different (far apart), the lights are vertical
%and the rat is facing more left or right and less up or down. When the y 
%coordinates are very similar, the lights are level and the rat is facing
%more up or down and less left or right.
candidate_hds(1, :) = difference_vector.*90; %quadrant I (0 to 90 degrees)
candidate_hds(2, :) = (inverse_diff_vect.*90) + (ones(1, length(inverse_diff_vect)).*90); %quadrant II (90 to 180 degrees)
candidate_hds(3, :) = (difference_vector.*90) + (ones(1, length(difference_vector)).*180); %quadrant III (180 to 270 degrees)
candidate_hds(4, :) = (inverse_diff_vect.*90) + (ones(1, length(inverse_diff_vect)).*270); %quadrant IV (270 to 360 degrees)
   


%CORRECT FOR MAZE ROTATION
%
%because Targets contains unprocessed data, it must be rotated to match x,y 
%coordinates used below. rotang comes from another function in trials_III 
%(rotate_pts), and is in clockwise degrees

%apply correction
candidate_hds = candidate_hds + ones(size(candidate_hds))*rotang;

%circular correct items that ended up outside of range after rotation
if sum(candidate_hds(:) < 0) > 0 
    candidate_hds = candidate_hds + double(candidate_hds < 0)*360;
end
if sum(candidate_hds(:) > 360) > 0
    candidate_hds = candidate_hds - double(candidate_hds > 360)*360;
end


    
%IDENTIFY TRAJECTORY ANGLE
%

%calculate the rat's angle of trajectory at every point
X = smooth(ep_vid_X, 100);
Y = smooth(ep_vid_Y, 100);

window_size = 10;
[trajectory_angle] = traj_angle(X, Y, window_size);

%smooth trajectory angle
trajectory_angle = circ_smooth(trajectory_angle, [0 360], 30);



%USE TRAJECTORY ANGLE TO SELECT AMONG CANDIDATE HEAD DIRECTIONS
%
%preallocate
head_direction = nan(1,size(candidate_hds, 2));

%identify the best candidate_hd 
for sample = 1:size(candidate_hds, 2)
    
    %circular distance from the trajectory angle to each candidate HDs
    distances = [circ_distance(trajectory_angle(sample), candidate_hds(1, sample), [0 360]);
                 circ_distance(trajectory_angle(sample), candidate_hds(2, sample), [0 360]);
                 circ_distance(trajectory_angle(sample), candidate_hds(3, sample), [0 360]);
                 circ_distance(trajectory_angle(sample), candidate_hds(4, sample), [0 360])];
             
   	%head direction is the closest candidate hd (pass on NaNs)
    if ~isempty(candidate_hds(find(distances == min(distances), 1), sample))
        head_direction(sample) = candidate_hds(find(distances == min(distances), 1), sample);
    else
        head_direction(sample) = NaN;
    end
   
end


%FINAL OUTPUT
%
%circular smooth head direction
head_direction(~isnan(head_direction)) = circ_smooth(head_direction(~isnan(head_direction)), [0 360], 20);
    
end


