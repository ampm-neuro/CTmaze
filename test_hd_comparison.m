function test_hd_comparison(eptrials, x_pos, y_pos, hds_h1, hds_h2, speed)

%check inputs
if length(x_pos) ~= length(y_pos)
    error('position vectors must be of equal length')
%elseif length(hds) ~= length(x_pos) || length(hds) ~= length(y_pos)
%   	error('head_directions and position vectors must be of equal length')
end

%time vector
time = 1:length(x_pos);

figure;
sections(eptrials);

%iterate through sample time points
for pos = 1:speed:length(x_pos) %1:length(sample(:,1))

    %magic arrow ingredients (see help of quiver)
    angle_h1 = (hds_h1(pos));
    angle_h2 = (hds_h2(pos));
    s = x_pos(pos);
    t = y_pos(pos);
    u_h1 = sin(angle_h1*(pi/180));
    v_h1 = cos(angle_h1*(pi/180));
    u_h2 = sin(angle_h2*(pi/180));
    v_h2 = cos(angle_h2*(pi/180));
    line_length = 30;
    arrow_size = 10;
    
    %plot pos and hd
    h1 = quiver(s, t, u_h1, v_h1, line_length, 'b', 'linewidth', 3);
    quiver_arrow_size(h1, arrow_size)
    h2 = quiver(s, t, u_h2, v_h2, line_length, 'r', 'linewidth', 3);
    quiver_arrow_size(h2, arrow_size)
    

    %time legend
    legend([h1, h2], 'nrlx', 'ampm', 'location', 'northeastoutside');
    
    %play image
    frame = getframe;
    im = frame2im(frame);
    delete(h1);
    delete(h2);

end


end