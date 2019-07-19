function evtposplot(event, pos, c)

%evtposplot is a function that plots the rat's trajectory and the spatial 
% location of spikes from single units. Each unit is plotted on its own
% figure.
%
%Input evtpos is a Nx4 matrix output by MrgNlx. Specifically:
%   evtpos(:,1) is a common timestamp in the form of 1:1:N
%   evtpos(:,2) is the rat's X coordinate position data
%   evtpos(:,3) is the rat's Y coordinate position data
%   evtpos(:,4) is the spike event. Unique numbers correspond to unique cells
%
%It does not extrapolate for (but instead excludes) NaN/0 position data

%merges event and pos matrices
evtpos = sortrows([event;pos], 1);


figure
hold on

plot(evtpos(:, 2), evtpos(:, 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
plot(evtpos(evtpos(:,4)==c, 2), evtpos(evtpos(:,4)==c, 3), '.', 'Color', [1 0 0], 'markersize', 5)
set(gca,'xdir','reverse')
set(gca, 'Ytick', 50:10:450, 'XTick', 150:15:600)

hold off
