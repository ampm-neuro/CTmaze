function hist2batch(eptrials, cells, bins, varargin)
% Heatmaps for all cells


if nargin > 3
    times = varargin{1};
end

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
    matrix = smooth2a(matrix,2,2);
    matrix = smooth2a(matrix,2,2);
    
    %remove convolve bloat
    matrix = matrix.*size_fix;
    
    clrrng = max(matrix(:));
    
    if exist('times', 'var')
        hist2trials(eptrials(eptrials(:,8)==1,:), cells(c), bins, 1.1, clrrng/1.1, times)
    else
        hist2trials(eptrials(eptrials(:,8)==1,:), cells(c), bins, 1.1, clrrng/1.1)
    end
    %plot
    %{
    figure; 
    pcolor(xedges,yedges,matrix); 
    colorbar; 
    axis square tight;
    set(gca,'xdir','reverse')
    shading flat
    caxis([0 max(matrix(:))*.7])
    title(['Cell ',num2str(cells(c))],'fontsize', 16)
    colormap jet
    %}
    
    %save figures
    %saveas(gcf,fullfile('/Users/ampm/Desktop/temp',[num2str(cells(c)),'.fig']),'fig')
    %saveas(gcf,fullfile('/Users/ampm/Desktop/temp',[num2str(cells(c)),'.jpg']),'jpg')
    
end

end