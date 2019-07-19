function spc_occ = space_occupancy(eptrials, bins)

%evenly spaced bins of x and y coordinate ranges
xedges = linspace(min(eptrials(:,2)), max(eptrials(:,2)), bins);
yedges = linspace(min(eptrials(:,3)), max(eptrials(:,3)), bins);

%all time samples in two vectors 
xt = eptrials(eptrials(:,14)==1, 2);
yt = eptrials(eptrials(:,14)==1, 3);

%filling xbin and ybin with occupancy time
[~, xbint] = histc(xt,xedges);
[~, ybint] = histc(yt,yedges);

%xbin, ybin zero for out of range values (see the help of histc) force this 
%event to the first bins

xbint(xbint == 0) = 1;
ybint(ybint == 0) = 1;

xnbint = length(xedges);
ynbint = length(yedges);


%time
if xnbint >= ynbint
    xyt = ybint*(xnbint) + xbint;
    indexshiftt = xnbint;
else
    xyt = xbint*(ynbint) + ybint;
    indexshiftt = ynbint;
end


%time
xyunit = unique(xyt);
hstrest = histc(xyt,xyunit);

%establish the histmat matrix
%time
histmatt = zeros(xnbint, ynbint);
histmatt(xyunit-indexshiftt) = hstrest;
histmatt = histmatt';

spc_occ = histmatt(:);

min_time = .25; %seconds
histmatt(histmatt<(min_time/.01)) = nan;

%figure; pcolor(histmatt)


end