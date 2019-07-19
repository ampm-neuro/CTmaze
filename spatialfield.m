function [summary, folded_section_area, meta_mtx, field_sizes, rate_ratios, reliability_scores] = spatialfield(varargin)

%this function identifies the number of place fields, in which maze section
%their respective centers are located, and plots a 'sections' plot with the
%field outlined



switch nargin
    case 3
        eptrials = varargin{1};
        cluster = varargin{2};
        min_visits = varargin{3};
        
        
        field_sizes = [];
        rate_ratios = [];
        reliability_scores = [];
    
    case 6 
        eptrials = varargin{1};
        cluster = varargin{2};
        min_visits = varargin{3};
        field_sizes = varargin{4};
        rate_ratios = varargin{5};
        reliability_scores = varargin{6};
    %{
    case 6 
        eptrials = varargin{1};
        cluster = varargin{2};
        stem_runs = varargin{3};
        comx = varargin{4};
        comy = varargin{5};
        min_visits = varargin{6};
        
        field_sizes = [];
        rate_ratios = [];
        reliability_scores = [];
    %}    
    case 9 
        eptrials = varargin{1};
        cluster = varargin{2};
        stem_runs = varargin{3};
        comx = varargin{4};
        comy = varargin{5};
        min_visits = varargin{6};
        field_sizes = varargin{4};
        rate_ratios = varargin{5};
        reliability_scores = varargin{6};
    otherwise
        error(message('incorrect var input'))
end


newcell=1;

%stem only
%
if exist('stem_runs', 'var')
    stem_runs_idx = zeros(size(eptrials(:,1)));
        for t = 1:size(stem_runs,1)
            stem_runs_idx(eptrials(:,1)>stem_runs(t,1) & eptrials(:,1)<stem_runs(t,2)) = 1;
        end
    eptrials = eptrials(logical(stem_runs_idx), :);
end
%}

%PLOTTING OPTIONS
figure_on = 0;
%figure_on = 1;%fields on heatmaps
%figure_on = 2; %all fields

bins = 80;

xedges = linspace(min(eptrials(:,2)), max(eptrials(:,2)), bins);
yedges = linspace(min(eptrials(:,3)), max(eptrials(:,3)), bins);

comx=1000; comy=1000;
%establishes maze section boundaries [xlow xhigh ylow yhigh]
strt = [comx-50 comx+50  comy-200 comy-80]; %start area 1 1
stem1 = [comx-50 comx+50 comy-80 comy+12.5]; %low common stem 2 2
stem2 = [comx-50 comx+50 comy+12.5 comy+105]; %high common stem 3 3
chce = [comx-50 comx+50 comy+105 comy+205]; %choice area 4 4
chmL = [comx+50 comx+120 comy+85 comy+205]; %approach arm left 5 5
chmR = [comx-120 comx-50 comy+85 comy+205]; %approach arm right 6 5
rwdL = [comx+120 comx+225 comy+85 comy+205]; %reward area left 7 6
rwdR = [comx-230 comx-120 comy+85 comy+205]; %reward area right 8 6
rtnL = [comx+50 comx+225 comy-200 comy+85]; %return arm left 9 7
rtnR = [comx-230 comx-50 comy-200 comy+85]; %return arm right 10 7


min_time = .2;
[~, spk_ct, spc_occ] = ...
        trialbased_heatmap(eptrials, cluster, bins, min_visits, min_time, 0);
    
    %set non-visted pixles to nans for both spikes and occupancy
    spc_occ(spc_occ<min_time) = 0;
    spk_ct(spc_occ<min_time) = 0;
    spc_occ(spc_occ==0) = nan;
    spk_ct(spk_ct==0) = nan;

    %rate heatmap
    matrix = skagg_smooth(spk_ct, spc_occ);
    %matrix = smooth2a(matrix,1);
    
    %figure; imagesc(matrix)
    
    
    folded_section_area = [];

%visited pixles
visited_pixles = length(matrix(~isnan(matrix)));

%DEFINING A PLACE FIELD

%field firing rate
    %95percentile rate (to avoid normalizing to outliers)
    rate_vector = sort(matrix(~isnan(matrix)));
    %high_rate = rate_vector(floor(.985*length(rate_vector)));
    high_rate = rate_vector(floor(.995*length(rate_vector)));
    field_rate = .5*high_rate;

%minimum size relative to visited area (contiguous pixles)
min_size = size(matrix)./10;
min_size = ceil(min_size(1)*min_size(2));
%min_size = 35;

%maximum size relative to visited area
max_size = round(visited_pixles.*0.5);

%within:without firing rate
field_ratio = 2.0;

%reliability (proportion of passes on which the cell fired)
reliability_min = 0.50;



%IDENTIFY PLACE FIELDS

%pass matrix through minimum rate conditions
logic_ratematrix = matrix > field_rate;

%identify candidate fields (contiguous points)
%calls the function 'contiguous'
[logic_contiguitymatrix] = contiguous(double(logic_ratematrix));

%figure; imagesc(logic_contiguitymatrix)

%delete fields smaller than minimum size or larger than maximum size
for field = 1:max(logic_contiguitymatrix(:))    
        
    %figure;
    %imagesc(logic_contiguitymatrix == field)
    
    if sum(sum(logic_contiguitymatrix == field)) < min_size
 
        logic_contiguitymatrix(logic_contiguitymatrix == field) = 0;

    elseif sum(sum((logic_contiguitymatrix == field))) > max_size
 
        logic_contiguitymatrix(logic_contiguitymatrix == field) = 0;

    end
end

remaining_fields = unique(logic_contiguitymatrix(logic_contiguitymatrix>0));

%delete fields with insufficient within:without firing rate
for f = 1:length(remaining_fields)
    field = remaining_fields(f);
    
    infield_rate = nanmean(matrix(logic_contiguitymatrix == field));
    
    %OPTIONS:
        %outfield rate excludes other candidate place fields (lenient):
            %outfield_rate = nanmean(matrix(~ismember(logic_contiguitymatrix, remaining_fields)));
        %outfield rate includes other candidate place fields (strict):
            outfield_rate = nanmean(matrix(logic_contiguitymatrix ~= field));
    
    %logic_contiguitymatrix ~= field));
    
    if infield_rate/outfield_rate < field_ratio
        
        logic_contiguitymatrix(logic_contiguitymatrix == field) = 0;
    end
end

remaining_fields = unique(logic_contiguitymatrix(logic_contiguitymatrix>0));

%delete fields with insufficient reliability
for f = 1:length(remaining_fields)
    field = remaining_fields(f);
    
    %time_binpos = [times binned_xpos binned_xpos event]
    [~, xbinz] = histc(eptrials(eptrials(:,14)==1 | eptrials(:,4)==cluster, 2), xedges);
    [~, ybinz] = histc(eptrials(eptrials(:,14)==1 | eptrials(:,4)==cluster, 3), yedges);
        xbinz(xbinz == 0) = 1;
        ybinz(ybinz == 0) = 1;
    time_binpos = [eptrials(eptrials(:,14)==1 | eptrials(:,4)==cluster, 1) xbinz ybinz eptrials(eptrials(:,14)==1 | eptrials(:,4)==cluster, 4)];
    
    %call function reliability
    [reliability_score] = reliability(eptrials, logic_contiguitymatrix, time_binpos, field, cluster);
    
    if reliability_score < reliability_min
        
        logic_contiguitymatrix(logic_contiguitymatrix == field) = 0;
        
    else
        
        reliability_scores = [reliability_scores; reliability_score];
        
    end
            
end

remaining_fields = unique(logic_contiguitymatrix(logic_contiguitymatrix>0));

%preallocate summary matrix (field number, folded section)
summary = zeros(length(remaining_fields), 2);


meta_mtx = ones(bins, bins, length(remaining_fields));

%renumber fields AND COUNT AND PLOT
for f = 1:length(remaining_fields)
    field = remaining_fields(f);
    
    
    field_sizes = [field_sizes; sum(sum((logic_contiguitymatrix == field)))];
    rate_ratios = [rate_ratios; nanmean(matrix(logic_contiguitymatrix == field))/nanmean(matrix(logic_contiguitymatrix ~= field))];
    
    
    
    %re-lable
    logic_contiguitymatrix(logic_contiguitymatrix == field) = f;
	
    %find contour coords using contour function
    h = contourc(double(logic_contiguitymatrix == f),1);
    h(:,1) = [];
    end_field = find(h(1,:)==.5, 1, 'first');
    h(:, end_field:end) = [];
    
        %meta matrix thing
        meta_mtx_temp = ones(bins);

        %contour
        for i = 1:length(h)
            meta_mtx_temp(round(h(2,i)), round(h(1,i)))=2;
        end
        
        %floodfill outside matrix (clever girl)
        meta_mtx_temp(flood_fill(meta_mtx_temp,1,bins))=2;
        
        %reverse and redo contour
        meta_mtx_temp(meta_mtx_temp==1) = 1;
        for i = 1:length(h)
            meta_mtx_temp(round(h(2,i)), round(h(1,i)))=1;
        end
        meta_mtx_temp(meta_mtx_temp==2) = 0;
        
        %figure; pcolor(meta_mtx_temp)
        
        %load
        meta_mtx(:,:,f) = meta_mtx_temp;
        
    if figure_on == 2
        %convert heatmap coords to video coords
        for pxl = 1:size(h,2)
            if h(1,pxl) - round(h(1,pxl)) == 0
                h(1,pxl) = xedges(h(1,pxl));
            else
                h(1,pxl) = mean([xedges(floor(h(1,pxl))) xedges(ceil(h(1,pxl)))]);
            end

            if h(2,pxl) - round(h(2,pxl)) == 0
                h(2,pxl) = yedges(h(2,pxl));
            else
                h(2,pxl) = mean([yedges(floor(h(2,pxl))) yedges(ceil(h(2,pxl)))]);
            end
        end
    end
    
    %locate firing rate peak
    rate_vect = sort(matrix(logic_contiguitymatrix == f));
    [row, col] = find(matrix == rate_vect(floor(.99*length(rate_vect))) & logic_contiguitymatrix == f);
        %OR CENTER OF MASS
        %[row, col] = find(logic_contiguitymatrix == f);
        %row = round(mean(row));
        %col = round(mean(col));

    
    %find field location
    [sum1, sum2] = field_location(xedges, yedges, col, row, f, strt, stem1, stem2, chce, chmL, chmR, rwdL, rwdR, rtnL, rtnR);
    summary(f, 1) = sum1; %place field or no
    summary(f, 2) = sum2; %folded section
    
    %if sum2==4
    
        %fields on heatmaps
        if figure_on == 1
            
            if newcell==1
                trialbased_heatmap(eptrials, cluster, bins, min_visits, min_time, 1)
                %hist2(eptrials, cluster, 80)
                newcell=0;
            end

            %plot contour
            smooth_wndw = 2;
            hold on; plot(smooth([h(1,:) h(1,1)] + repmat(.5, size([h(1,:) h(1,1)])),smooth_wndw), smooth([h(2,:), h(2,1)] + repmat(.5, size([h(2,:) h(2,1)])),smooth_wndw))

            %plot rate peak
            hold on; plot(col-.5, row+.5, '.', 'Color', [0 0 0], 'markersize', 25)
            
%            ylabel(num2str(info_score(eptrials, 80, 4, cluster)))

        end
        
        %all fields, no heatmaps
        if figure_on == 2
            
            %if rand(1) < 35/63;
            
                %plot contour
                smooth_wndw = 2;
                hold on; plot(smooth([h(1,:) h(1,1)],smooth_wndw), smooth([h(2,:), h(2,1)],smooth_wndw))

                %plot rate peak
                hold on; plot(xedges(col), yedges(row), '.', 'Color', [0 0 0], 'markersize', 25)
            
            %end
        end

    %end
    
end

    
function [sum1, sum2] = field_location(xedges, yedges, col, row, field, strt, stem1, stem2, chce, chmL, chmR, rwdL, rwdR, rtnL, rtnR)
  
    %unfolded section    
    switch logical(true)
        case xedges(col)>=strt(1,1) & xedges(col)<=strt(1,2) & yedges(row)>=strt(1,3) & yedges(row)<=strt(1,4), unfolded_section = 1;
        %case xedges(col)>stem(1,1) & xedges(col)<stem(1,2) & yedges(row)>stem(1,3) & yedges(row)<stem(1,4), unfolded_section = 2;
        case xedges(col)>=stem1(1,1) & xedges(col)<=stem1(1,2) & yedges(row)>=stem1(1,3) & yedges(row)<stem1(1,4), unfolded_section = 2;
        case xedges(col)>=stem2(1,1) & xedges(col)<=stem2(1,2) & yedges(row)>=stem2(1,3) & yedges(row)<stem2(1,4), unfolded_section = 3;
        case xedges(col)>=chce(1,1) & xedges(col)<=chce(1,2) & yedges(row)>=chce(1,3) & yedges(row)<=chce(1,4), unfolded_section = 4;
        case xedges(col)>chmL(1,1) & xedges(col)<chmL(1,2) & yedges(row)>chmL(1,3) & yedges(row)<chmL(1,4), unfolded_section = 5;
        case xedges(col)>chmR(1,1) & xedges(col)<chmR(1,2) & yedges(row)>chmR(1,3) & yedges(row)<chmR(1,4), unfolded_section = 6;
        case xedges(col)>=rwdL(1,1) & xedges(col)<=rwdL(1,2) & yedges(row)>=rwdL(1,3) & yedges(row)<=rwdL(1,4), unfolded_section = 7;
        case xedges(col)>=rwdR(1,1) & xedges(col)<=rwdR(1,2) & yedges(row)>=rwdR(1,3) & yedges(row)<=rwdR(1,4), unfolded_section = 8;
        case xedges(col)>rtnL(1,1) & xedges(col)<rtnL(1,2) & yedges(row)>rtnL(1,3) & yedges(row)<rtnL(1,4), unfolded_section = 9;
        case xedges(col)>rtnR(1,1) & xedges(col)<rtnR(1,2) & yedges(row)>rtnR(1,3) & yedges(row)<rtnR(1,4), unfolded_section = 10;
    end

    %FOLDED MAZE SECTION
    
    if ~exist('unfolded_section', 'var')
        
        sum1 = field;
        sum2 = nan;
        
    else

        if unfolded_section==1
            folded_section=1;
        elseif unfolded_section==2
            folded_section=2;
        elseif unfolded_section==3
            folded_section=3;
        elseif unfolded_section==4
            folded_section=4;
        elseif unfolded_section==5 || unfolded_section==6
            folded_section=5;
        elseif unfolded_section==7 || unfolded_section==8
            folded_section=6;
        elseif unfolded_section==9 || unfolded_section==10
            folded_section=7;
        end
    
        sum1 = field;
        sum2 = folded_section;
        
    end
    
    
end
    
end
