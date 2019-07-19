
function posplot(eptrials, clust)
%posplot is a function that plots the rats location (in gray) from the X and Y
%vectors within the pos matrix. 
%


figure
hold on

plot(eptrials(:, 2), eptrials(:, 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')

plot(eptrials(:, 2), eptrials(:, 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')

plot(eptrials(eptrials(:,4)==clust, 2), eptrials(eptrials(:,4)==clust, 3), '.', 'Color', [1 0 0], 'markersize', 12)

%plot(eptrials(:, 2), eptrials(:, 3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')
%axis([130 632 9 455])