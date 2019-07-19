function plot3d(eptrials, cell)

%3d
c=cell;
figure

%trajectory
plot3(eptrials(:,1)./1000000, eptrials(:,2), eptrials(:,3), 'Color', [0.5 0.5 0.5] , 'LineWidth', 0.5, 'LineStyle', '-')

%cell
hold on
plot3(eptrials(eptrials(:,4)==c,1)./1000000, eptrials(eptrials(:,4)==c,2), eptrials(eptrials(:,4)==c,3), '.', 'Color', [1 0 0], 'markersize', 10)