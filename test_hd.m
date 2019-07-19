function test_hd(eptrials, x_pos, y_pos, hds, speed)

%test_hd takes vectors of x positions, y positions, and head direction, and
%plays a video of the rat moving around the maze.
%
%eptrials is only used to make the maze boundaries, and can be deleted.
%
%quiver_arrow_size is only asthetic and can be deleted. its based on 3rd
%party code. google: adjust_quiver_arrowhead_size

%check inputs
if length(x_pos) ~= length(y_pos)
    error('position vectors must be of equal length')
elseif length(hds) ~= length(x_pos) || length(hds) ~= length(y_pos)
   	error('head_directions and position vectors must be of equal length')
end

%time vector
time = 1:length(x_pos);

figure;
sections(eptrials);

%iterate through sample time points
for pos = 1:speed:length(x_pos) %1:length(sample(:,1))

    %magic arrow ingredients (see help of quiver)
    angle = (hds(pos));
    s = x_pos(pos);
    t = y_pos(pos);
    u = sin(angle*(pi/180));
    v = cos(angle*(pi/180));
    line_length = 30;
    arrow_size = 10;
    
    %plot pos and hd
    h1 = quiver(s, t, u, v, line_length, 'k', 'linewidth', 3);
    quiver_arrow_size(h1, arrow_size)

    %time legend
    h2 = legend(['Time' 'Angle'], num2str(time(pos)), num2str(angle), 'location', 'northeastoutside');    
    %play image
    frame = getframe;
    im = frame2im(frame);
    delete(h1);
    delete(h2);
    
end


end