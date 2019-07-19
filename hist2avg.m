function hist2avg(eptrials, cells, bins)

% Extract 2D histogram data containing the normalized firing rate for each 
% cell c at each of the bins defined by the x and y ranges in eptrials, and 
% the bin spacing defined by bins. Average all normalized histograms, and
% output heatmap of average histogram.

%samplingrate
smplrt=length(eptrials(eptrials(:,14)==1,1))/max(eptrials(:,1));

%subset of trials
%eptrials = eptrials(eptrials(:,5)>20, :);


%FIRST DEAL WITH TIME (COMMON TO ALL CELLS). For comments, see hist2

%all time samples in two vectors
xt = eptrials(eptrials(:,14)==1, 2);
yt = eptrials(eptrials(:,14)==1, 3);

%evenly spaced bins of x and y coordinate ranges (incl pos - not just event -
%data)
xedges = linspace(min(eptrials(:,2)), max(eptrials(:,2)), bins);
yedges = linspace(min(eptrials(:,3)), max(eptrials(:,3)), bins);

[xnt, xbint] = histc(xt,xedges);
[ynt, ybint] = histc(yt,yedges);

xnbins = length(xedges);
ynbins = length(yedges);
xnbint = length(xedges);
ynbint = length(yedges);

if xnbint >= ynbint
    xyt = ybint*(xnbint) + xbint;
    indexshiftt = xnbint;
else
    xyt = xbint*(ynbint) + ybint;
    indexshiftt = ynbint;
end

xyunit = unique(xyt);
hstrest = histc(xyt,xyunit);

histmatt = zeros(xnbint, ynbint);

histmatt(xyunit-indexshiftt) = hstrest;
histmatt = histmatt'./smplrt;

%PREALLOCATE HERE
hold_matrices = nan(length(histmatt(:,1)), length(histmatt(1,:)), length(cells));


%LOOP THROUGH CELLS TO DEAL WITH SPIKES

for c = 1:length(cells)
    
    %all spike events in two vectors
    xs = eptrials(eptrials(:,4)==cells(c), 2);
    ys = eptrials(eptrials(:,4)==cells(c), 3);
    %filling xbin and ybin with firing rates. Last row is always 0, so we
    %remove it.

    %spikes
    [xns, xbins] = histc(xs,xedges);
    [yns, ybins] = histc(ys,yedges);
    


    %xbin, ybin zero for out of range values (see the help of histc) force this 
    %event to the first bins

    xbins(find(xbins == 0)) = 1;
    ybins(find(ybins == 0)) = 1;
    xbint(find(xbint == 0)) = 1;
    ybint(find(ybint == 0)) = 1;
    
    if xnbins >= ynbins
        xys = ybins*(xnbins) + xbins;
        indexshifts = xnbins;
    else
        xys = xbins*(ynbins) + ybins;
        indexshifts = ynbins;
    end

    xyunis = unique(xys);
    hstress = histc(xys,xyunis);
    
    histmats = zeros(xnbins, ynbins);

    histmats(xyunis-indexshifts) = hstress;
    histmats = histmats';
    

    %spikes
    histmats(1,1)=0;
    %time
    histmatt(1,1)=0;

    matrix = histmats./histmatt;

    if sum(isinf(matrix(:)))>0
        %disp('Warning: firing rate bins containing infinite values were set as NaN')
        matrix(isinf(matrix))=NaN;
    end

    size_fix = matrix;
    size_fix(~isnan(size_fix))=1;
    
    %convolve
    mask = [1 3 1; 3 4 3; 1 3 1]./20;
    
    matrix = conv2nan(matrix, mask, 'same');
    matrix = conv2nan(matrix, mask, 'same');
    matrix = conv2nan(matrix, mask, 'same');
    matrix = conv2nan(matrix, mask, 'same');
    
    %remove convolve bloat
    matrix = matrix.*size_fix;
    
    %normalize
    matrix = matrix./nansum(matrix(:));
    
    %hold matrix
    hold_matrices(:,:,c) = matrix;
    
end

    %average all held matrices
    avg_matrix = sum(hold_matrices, 3)./nansum(hold_matrices(:));
    
    %plot
    figure; 
    pcolor(xedges,yedges,avg_matrix); 
    colorbar; 
    axis square tight;
    set(gca,'xdir','reverse')
    shading flat
    %caxis([0 .0011])
    colormap jet

end