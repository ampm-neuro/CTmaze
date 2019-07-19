function cellfiringrates = firingratebatch(eptrials, clusters)

%Returns the session-average firing rates for each cell in clusters.
%Rates are rounded to two decimal places

%Session time (in seconds) total
time = max(eptrials(:,1));

%preallocate matrix
cellfiringrates = nan(length(clusters), 2);

for c = 1:length(clusters)
    
    cellfiringrates(c,1) = clusters(c);
    cellfiringrates(c,2) = str2num(sprintf('%.2f',length(eptrials(eptrials(:,4)==clusters(c),4))/time));
    
end
cellfiringrates = cellfiringrates(:,2);