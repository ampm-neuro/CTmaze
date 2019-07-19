function [matrix, folded_section_area, unfolded_section_area, histmats, histmatt, overall_rate] = hist2_vd(eptrials, c, bins, min_visits)
% function histmat  = hist2(eptrials, c, bins)
%
% Extract 2D histogram data containing the firing rate for cell c at each
% of the bins defined by the x and y ranges in eptrials, and the bin
% spacing defined by bins.
%
% Essentially this builds two 2d histograms in parrallel, and then plots one
% divided by the other.
%
% This is a modified version of Dave Bulkin's hist2.m, and contains 
% portions that I do not fully understand. See below.

%include both corrects and errors [1 2]
Corr_Err_include = [1 2];


%lazy
folded_section_area = [];
unfolded_section_area = [];

%samplingrate
smplrt=length(eptrials(eptrials(:,14)==1,1))/max(eptrials(:,1));

%subset of trials
%eptrials = eptrials(eptrials(:,5)>20, :);

    %all spike events in two vectors
    xs = eptrials(eptrials(:,4)==c & ismember(eptrials(:,8), Corr_Err_include), 2);
    ys = eptrials(eptrials(:,4)==c & ismember(eptrials(:,8), Corr_Err_include), 3);

    %all time samples in two vectors 
    xt = eptrials(eptrials(:,14)==1 & ismember(eptrials(:,8), Corr_Err_include), 2);
    yt = eptrials(eptrials(:,14)==1 & ismember(eptrials(:,8), Corr_Err_include), 3);


%evenly spaced bins of x and y coordinate ranges (incl pos - not just event -
%data)
xedges = linspace(min(eptrials(:,2)), max(eptrials(:,2)), bins);
yedges = linspace(min(eptrials(:,3)), max(eptrials(:,3)), bins);


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
    pixles_and_trials = [ybint xbint eptrials(eptrials(:,14)==1 & ismember(eptrials(:,8), Corr_Err_include), 5)];

    %get indices of unique rows (each pixle visited on each trial)
    [~, uni_indi, ~] = unique(pixles_and_trials, 'rows');
    pixle_per_trial = pixles_and_trials(uni_indi, 1:2);

    %get repeated rows of pixles_and_trials(indices, 1:2) (pixles that were 
    %visited on multiple trials)
    [~,~,n] = unique(pixle_per_trial, 'rows'); %see help unique
    hist_counts = hist(n, .5:1:(max(n)-.5)); %how many trials each pixle was visited on
    multi_trial_pixles = pixle_per_trial(ismember(n, find(hist_counts>=min_visits)), :); %pixles visited on >1 trials

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

overall_rate = sum(histmats(:))/sum(histmatt(:));

%spikes
histmats(1,1)=0;
%time
histmatt(1,1)=0;

%plot
matrix = histmats./histmatt;
%{
%replace inf values
if sum(isinf(matrix(:)))>0
%matrix(isinf(matrix))=NaN;%replace inf values with NaN

    %set inf pixles to nanmean of surrounding pixles
    [inf_y, inf_x] = ind2sub(size(matrix), find(matrix==inf));

        %remove corners (if they exist)
        inf_corners = [1 1; size(matrix, 1) 1; 1 size(matrix, 2); size(matrix)];
        inf_y = inf_y(~ismember([inf_y inf_x], inf_corners, 'rows'));
        inf_x = inf_x(~ismember([inf_y inf_x], inf_corners, 'rows'));
    
    for inf_value = 1:length(inf_y)
        
        %gather surrounding pixle firing rates
        if inf_y(inf_value) == 1
         	surround = [matrix(inf_y(inf_value)+1, inf_x(inf_value)) matrix(inf_y(inf_value), inf_x(inf_value)+1) matrix(inf_y(inf_value), inf_x(inf_value)-1) matrix(inf_y(inf_value)+1, inf_x(inf_value)+1) matrix(inf_y(inf_value)+1, inf_x(inf_value)-1)];
        elseif inf_y(inf_value) == size(matrix,1)
         	surround = [matrix(inf_y(inf_value)-1, inf_x(inf_value)) matrix(inf_y(inf_value), inf_x(inf_value)+1) matrix(inf_y(inf_value), inf_x(inf_value)-1) matrix(inf_y(inf_value)-1, inf_x(inf_value)-1) matrix(inf_y(inf_value)-1, inf_x(inf_value)+1)];
        elseif inf_x(inf_value) == 1
         	surround = [matrix(inf_y(inf_value)+1, inf_x(inf_value)) matrix(inf_y(inf_value)-1, inf_x(inf_value)) matrix(inf_y(inf_value), inf_x(inf_value)+1) matrix(inf_y(inf_value)+1, inf_x(inf_value)+1) matrix(inf_y(inf_value)-1, inf_x(inf_value)+1)];
        elseif inf_x(inf_value) == size(matrix,2)
          	surround = [matrix(inf_y(inf_value)+1, inf_x(inf_value)) matrix(inf_y(inf_value)-1, inf_x(inf_value)) matrix(inf_y(inf_value), inf_x(inf_value)-1) matrix(inf_y(inf_value)-1, inf_x(inf_value)-1) matrix(inf_y(inf_value)+1, inf_x(inf_value)-1)];
        else
            surround = [matrix(inf_y(inf_value)+1, inf_x(inf_value)) matrix(inf_y(inf_value)-1, inf_x(inf_value)) matrix(inf_y(inf_value), inf_x(inf_value)+1) matrix(inf_y(inf_value), inf_x(inf_value)-1) matrix(inf_y(inf_value)+1, inf_x(inf_value)+1) matrix(inf_y(inf_value)-1, inf_x(inf_value)-1) matrix(inf_y(inf_value)+1, inf_x(inf_value)-1) matrix(inf_y(inf_value)-1, inf_x(inf_value)+1)];
        end
        
        if ~isempty(surround)
        
            %set new value
            matrix(inf_y(inf_value), inf_x(inf_value)) = nanmean(surround(~isinf(surround)));
        
        else
        
            matrix(inf_y(inf_value), inf_x(inf_value)) = NaN;
            
        end
        
    end
    
   %on the very unlikely case that we actually removed corners - replace
   %with mean overall rate
   matrix(isinf(matrix))=mean(matrix(~isinf(matrix)));%replace remaining inf values with mean firing rate
   
end

%matrix with NaNs in place of NaNs and 1's in place of numbers. This
%prevents (actually, deletes) the bloat occuring during convolution.
size_fix = matrix; 
size_fix(~isnan(size_fix))=1;


mask = [1 3 1; 3 4 3; 1 3 1]./20;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');matrix = matrix.*size_fix;
%matrix = conv2nan(matrix, mask, 'same');matrix = matrix.*size_fix;

%establishes maze section boundaries [xlow xhigh ylow yhigh]
sections = nan(10,4);
%sections(1,:) = [bin_comx-50/5 bin_comx+50/5  bin_comy-200/5 bin_comy-80/5]; %start area 1 1
%sections(2,:) = [bin_comx-50/5 bin_comx+50/5 bin_comy-80/5 bin_comy+12.5/5]; %low common stem 2 2
%sections(3,:) = [bin_comx-50/5 bin_comx+50/5 bin_comy+12.5/5 bin_comy+105/5]; %high common stem 3 3
%sections(4,:) = [bin_comx-50/5 bin_comx+50/5 bin_comy+105/5 bin_comy+205/5]; %choice area 4 4
%sections(5,:) = [bin_comx+50/5 bin_comx+120/5 bin_comy+85/5 bin_comy+205/5]; %approach arm left 5 5
%sections(6,:) = [bin_comx-120/5 bin_comx-50/5 bin_comy+85/5 bin_comy+205/5]; %approach arm right 6 5
%sections(7,:) = [bin_comx+120/5 bin_comx+225/5 bin_comy+85/5 bin_comy+205/5]; %reward area left 7 6
%sections(8,:) = [bin_comx-230/5 bin_comx-120/5 bin_comy+85/5 bin_comy+205/5]; %reward area right 8 6
%sections(9,:) = [bin_comx+50/5 bin_comx+225/5 bin_comy-200/5 bin_comy+85/5]; %return arm left 9 7
%sections(10,:) = [bin_comx-230/5 bin_comx-50/5 bin_comy-200/5 bin_comy+85/5]; %return arm right 10 
sections(1,:) = [bins*0.3750 bins*0.6250  1 bins*.3000]; %start area 1 1
sections(2,:) = [bins*0.3750 bins*0.6250 bins*.3000 bins*0.5375]; %low common stem 2 2
sections(3,:) = [bins*0.3750 bins*0.6250 bins*0.5375 bins*0.7625]; %high common stem 3 3
sections(4,:) = [bins*0.3750 bins*0.6250 bins*0.7625 bins]; %choice area 4 4
sections(5,:) = [bins*0.2000 bins*0.3750 bins*0.7125 bins]; %approach arm left 5 5
sections(6,:) = [bins*0.6250 bins*0.8000 bins*0.7125 bins]; %approach arm right 6 5
sections(7,:) = [1 bins*0.2000 bins*0.7125 bins]; %reward area left 7 6
sections(8,:) = [bins*0.8000 bins bins*0.7125 bins]; %reward area right 8 6
sections(9,:) = [1 bins*0.3750 1 bins*0.7125]; %return arm left 9 7
sections(10,:) = [bins*0.6250 bins 1 bins*0.7125]; %return arm right 10 7


%replace out of bounds
sections(sections<1) = 1;
sections(sections>80) = 80;
sections=round(sections);

%preallocate

%how much time spent in each section
%unfolded_section_time = zeros(10,1);
%folded_section_time = zeros(7,1);

%how many unique bins visited in each section
%unfolded_section_area = zeros(10,1);
folded_section_area = zeros(7,1);
unfolded_section_area = zeros(10,1);

%iterate through histmatt

%start positions
%x=1;y=1;

histmatt_visit = double(histmatt>0)';

folded_section_area(1) = sum(sum(histmatt_visit(sections(1,1):sections(1,2), sections(1,3):sections(1,4))));
folded_section_area(2) = sum(sum(histmatt_visit(sections(2,1):sections(2,2), sections(2,3):sections(2,4))));
folded_section_area(3) = sum(sum(histmatt_visit(sections(3,1):sections(3,2), sections(3,3):sections(3,4))));
folded_section_area(4) = sum(sum(histmatt_visit(sections(4,1):sections(4,2), sections(4,3):sections(4,4))));
folded_section_area(5) = sum(sum(histmatt_visit(sections(5,1):sections(5,2), sections(5,3):sections(5,4)))) + sum(sum(histmatt_visit(sections(6,1):sections(6,2), sections(6,3):sections(6,4))));
folded_section_area(6) = sum(sum(histmatt_visit(sections(7,1):sections(7,2), sections(7,3):sections(7,4)))) + sum(sum(histmatt_visit(sections(8,1):sections(8,2), sections(8,3):sections(8,4))));
folded_section_area(7) = sum(sum(histmatt_visit(sections(9,1):sections(9,2), sections(9,3):sections(9,4)))) + sum(sum(histmatt_visit(sections(10,1):sections(10,2), sections(10,3):sections(10,4))));

unfolded_section_area(1) = sum(sum(histmatt_visit(sections(1,1):sections(1,2), sections(1,3):sections(1,4))));
unfolded_section_area(2) = sum(sum(histmatt_visit(sections(2,1):sections(2,2), sections(2,3):sections(2,4))));
unfolded_section_area(3) = sum(sum(histmatt_visit(sections(3,1):sections(3,2), sections(3,3):sections(3,4))));
unfolded_section_area(4) = sum(sum(histmatt_visit(sections(4,1):sections(4,2), sections(4,3):sections(4,4))));
unfolded_section_area(5) = sum(sum(histmatt_visit(sections(5,1):sections(5,2), sections(5,3):sections(5,4))));
unfolded_section_area(6) = sum(sum(histmatt_visit(sections(6,1):sections(6,2), sections(6,3):sections(6,4))));
unfolded_section_area(7) = sum(sum(histmatt_visit(sections(7,1):sections(7,2), sections(7,3):sections(7,4))));
unfolded_section_area(8) = sum(sum(histmatt_visit(sections(8,1):sections(8,2), sections(8,3):sections(8,4))));
unfolded_section_area(9) = sum(sum(histmatt_visit(sections(9,1):sections(9,2), sections(9,3):sections(9,4))));
unfolded_section_area(10) = sum(sum(histmatt_visit(sections(10,1):sections(10,2), sections(10,3):sections(10,4))));
%}