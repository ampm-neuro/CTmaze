function hist2trials(eptrials, c, bins, b, d, mask, size_fix, varargin)
% function hist2trials(eptrials, c, bins)
%
% Extract 2D histogram data containing the firing rate for cell c at each
% of the bins defined by the x and y ranges in eptrials, and the bin
% spacing defined by bins. b and d are output by hist2. 
%
% Essentially this builds two 2d histograms in parrallel, and then plots one
% divided by the other. Twice.
%
% This is a modified version of Dave Bulkin's hist2.m, and contains 
% portions that I do not fully understand. See below.



if nargin > 7
    times = varargin{1};
end


%establishes matrix for max and min values that will define the range of
%the colorbar
clrrng = zeros(2);

%A cell array that receives the two completed matrices.
plotmtx = {0 0};

%samplingrate
smplrt=length(eptrials(eptrials(:,14)==1,1))/max(eptrials(:,1));

%{
if exist('times', 'var')
%contstrain eptrials to time ranges
times(:,2) = times(:,1)+2;
times(:,1) = times(:,1)-30;

eptrials_times = nan(size(





end
%}

for trl = 1:(max(eptrials(:,7))) %trl is TRIAL TYPE not trial number   

%all spike events in two vectors LAST TWO INDEXING TERMS CAN RESTRICT TRIAL
%RANGE
xs = eptrials(eptrials(:,7)==trl & eptrials(:,4)==c & eptrials(:,8)==1 & eptrials(:,5)>1 & eptrials(:,5)<=max(eptrials(:,5))*1, 2);
ys = eptrials(eptrials(:,7)==trl & eptrials(:,4)==c & eptrials(:,8)==1 & eptrials(:,5)>1 & eptrials(:,5)<=max(eptrials(:,5))*1, 3);

%all time samples in two vectors LAST TWO INDEXING TERMS CAN RESTRICT TRIAL
%RANGE
xt = eptrials(eptrials(:,7)==trl & eptrials(:,14)==1 & eptrials(:,8)==1 & eptrials(:,5)>1 & eptrials(:,5)<=((max(eptrials(:,5)))*1), 2);
yt = eptrials(eptrials(:,7)==trl & eptrials(:,14)==1 & eptrials(:,8)==1 & eptrials(:,5)>1 & eptrials(:,5)<=((max(eptrials(:,5)))*1), 3);

%evenly spaced bins of x and y coordinate ranges (incl pos - not just event -
%data)
xedges = linspace(min(eptrials(eptrials(:,8)==1,2)), max(eptrials(eptrials(:,8)==1,2)), bins);
yedges = linspace(min(eptrials(eptrials(:,8)==1,3)), max(eptrials(eptrials(:,8)==1,3)), bins);


%filling xbin and ybin with firing rates. Last row is always 0, so we
%remove it. xn and yn are necessary. Don't ask me why.

%spikes
[xns, xbins] = histc(xs,xedges);
[yns, ybins] = histc(ys,yedges);
%time
[xnt, xbint] = histc(xt,xedges);
[ynt, ybint] = histc(yt,yedges);


%THIS SECTION REMOVES PIXLES THAT WERE ONLY VISITED ON ONE TRIAL. IT IS NOT
%APPROPRIATE FOR NON-TRIAL BASED DATA (CAN BE COMMENTED OUT).

    %matrix y-cords x-cords and trial number
    pixles_and_trials = [ybint xbint eptrials(eptrials(:,14)==1 & eptrials(:,7)==trl & eptrials(:,8)==1 & eptrials(:,5)>1 & eptrials(:,5)<=max(eptrials(:,5))*1, 5)]; 

    %get indices of unique rows (each pixle visited on each trial)
    [~, uni_indi, ~] = unique(pixles_and_trials, 'rows');
    pixle_per_trial = pixles_and_trials(uni_indi, 1:2);

    %get repeated rows of pixles_and_trials(indices, 1:2) (pixles that were 
    %visited on multiple trials)
    [~,~,n] = unique(pixle_per_trial, 'rows'); %see help unique
    hist_counts = hist(n, .5:1:(max(n)-.5)); %how many trials each pixle was visited on
    multi_trial_pixles = pixle_per_trial(ismember(n, find(hist_counts>1)), :); %pixles visited on >1 trials

    %index pixles_and_trials for pixles visited on multiple trials
    multivisit_pixle_index_space = logical(ismember([ybint xbint], multi_trial_pixles, 'rows'));
    multivisit_pixle_index_event = logical(ismember([ybins xbins], multi_trial_pixles, 'rows'));

    %re-define set of visited x and y matrix coords to only include
    %pixles visited on multiple trials
    xbint = xbint(multivisit_pixle_index_space);
    ybint = ybint(multivisit_pixle_index_space);
    xbins = xbins(multivisit_pixle_index_event);
    ybins = ybins(multivisit_pixle_index_event);


%xbin, ybin zero for out of range values (see the help of histc) force this 
%event to the first bins

%spikes
xbins(find(xbins == 0)) = 1;
ybins(find(ybins == 0)) = 1;
xbint(find(xbint == 0)) = 1;
ybint(find(ybint == 0)) = 1;
%time
xnbins = length(xedges);
ynbins = length(yedges);
xnbint = length(xedges);
ynbint = length(yedges);


%wtf is going on here? ASK DAVE.

%spikes
if xnbins >= ynbins
    xys = ybins*(xnbins) + xbins;
    indexshifts = xnbins;
else
    xys = xbins*(ynbins) + ybins;
    indexshifts = ynbins;
end
%time
if xnbint >= ynbint
    xyt = ybint*(xnbint) + xbint;
    indexshiftt = xnbint;
else
    xyt = xbint*(ynbint) + ybint;
    indexshiftt = ynbint;
end


%spikes
xyunis = unique(xys);
hstress = histc(xys,xyunis);
%time
xyunit = unique(xyt);
hstrest = histc(xyt,xyunit);

%establish the histmat matrix
%spikes
histmats = zeros(xnbins, ynbins);
%time
histmatt = zeros(xnbint, ynbint);

%spikes
histmats(xyunis-indexshifts) = hstress;
histmats = histmats';
%time
histmatt(xyunit-indexshiftt) = hstrest;
histmatt = histmatt'./smplrt;

%spikes
histmats(1,1)=0;
%time
histmatt(1,1)=0;

%enters firing rate matrix of current trial type trl into cell array
%plotmtx
matrix = (histmats./histmatt);
plotmtx{trl} = smooth2a(matrix, 2, 2);
%plotmtx{trl} = smooth2a(plotmtx{trl}, 2, 2);




%enters mins and maxs into color range matrix clrrng
a = plotmtx{trl}(~isnan(plotmtx{trl}));
clrrng(1,trl) = min(a(:));
clrrng(2,trl) = max(a(:));
b = min(clrrng(1,:));
d = max(clrrng(2,:));
    
end


%plot

%caxis controls colorbar
figure;pcolor(xedges,yedges,plotmtx{1}); colorbar; axis square tight;
set(gca,'xdir','reverse')
caxis([20 80])
caxis([b d])
shading flat
title('Left Trials','fontsize', 16) 
colormap jet
figure;pcolor(xedges,yedges,plotmtx{2}); colorbar; axis square tight;
set(gca,'xdir','reverse')
caxis([20 80])
caxis([b d])
shading flat
title('Right Trials','fontsize', 16) 
colormap jet

