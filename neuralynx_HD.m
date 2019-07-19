function head_direction = neuralynx_HD(Targets, TimestampsVT, Angles, ep_vid_time, rotang)
%
% neuralynx_HD takes neuralynx head direction output variable Angles, and
% streamlines it with eptrials by removing dropped signals,
% interpolating additional timepoints, correcting for maze roation, and 
% smoothing.
%
% a full description of the input variables can be found in the sister 
% function, remedial_hd
%



%REMOVE DROPPED SIGNALS
%

%pull out ys (the one thing I understand) from Targets
%ys = ferret_ys(Targets);

%dropped signals contain zeros in one or both vectors
%dropped_signals = ys(1,:)==0 | ys(2,:)==0 | Angles == 0;

%remove dropped signals
%time_vt = TimestampsVT(~dropped_signals)';
%nrlx_hd = Angles(~dropped_signals);

time_vt= TimestampsVT';
nrlx_hd = Angles;

%INTERPOLATE HEAD DIRECTION
%

%converts video timestamp units into seconds
starttime = zeros(length(time_vt), 1);
starttime(:,1) = time_vt(1);
time_vt = time_vt - starttime;
time_vt = time_vt./1000000;

%interpolate for head direction
head_direction = circ_interp1(nrlx_hd, [0 360], ep_vid_time', time_vt);



%FLIP L-R
%

%flip LR so that 90deg becomes 270, but 180 stays 180
%
%I don't know why this needs to be done, but it probably has to do with the
%camera reversing things at some point
%head_direction = ones(size(head_direction)).*360 - head_direction;


%CORRECT FOR MAZE ROTATION
%
%rotang comes from another function in trials_III (rotate_pts), and is in
%clockwise degrees

%apply correction
head_direction = head_direction - ones(1,length(head_direction))*rotang;

%fix items that ended up outside of range after correction
if sum(head_direction < 0) > 0 
    head_direction(head_direction < 0) = ones(1,length(head_direction(head_direction < 0)))*360 + head_direction(head_direction < 0);
end
if sum(head_direction > 360) > 0
    head_direction(head_direction > 360) = head_direction(head_direction > 360) - ones(1,length(head_direction(head_direction > 360)))*360;
end



%FINAL OUTPUT
%

%circular smooth
head_direction = circ_smooth(head_direction, [0 360], 40);




end