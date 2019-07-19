 function errorbar_plot( cell_e , varargin)
%plots errorbar

%connections
if nargin == 2
    connect = varargin{1};
elseif nargin ==3
    connect = varargin{1};
    xaxis = varargin{2};
else
    connect = 0;
end

%preallocate
all_mtx = cell2mat(cell_e(:));
all_mtx_grps = [];

means = nan(length(cell_e),1);
stds = nan(length(cell_e),1);
sqrt_l = nan(length(cell_e),1);

hold on;

if connect == 1
    for connections = 1:length(cell_e{1})

        line_points = nan(length(cell_e));
        for ilp = 1:length(cell_e)
           line_points(ilp) = cell_e{ilp}(connections); 
        end

        if exist('xaxis', 'var')
            plot(xaxis, line_points, '-', 'color', [.7 .7 .7])
        else
            plot(1:length(line_points), line_points, '-', 'color', [.7 .7 .7])  
        end

    end
end


for imtx = 1: length(cell_e)
  
    if exist('xaxis', 'var')
        plot(xaxis(imtx), cell_e{imtx}, 'o', 'color', [.8 .8 .8])
    else
        mean_imtx = nanmean(cell_e{imtx});
        std_imtx = nanstd(cell_e{imtx});
        for idpt = 1:length(cell_e{imtx})
            
            if connect==0
                base_jitter_multiplier = length(cell_e{imtx})*0.0006 + 0.25;
                manual_jitter_multiplier = 1.5;
                base_jitter = (rand(1)-0.5)*base_jitter_multiplier*manual_jitter_multiplier;
                dist_from_mean = abs(cell_e{imtx}(idpt) - mean_imtx);
                std_from_mean = dist_from_mean/std_imtx;
                bulb_correction = std_from_mean/7.5 + (rand(1)-0.5)*0.4;
                xaxis_hold = imtx+base_jitter*(1-bulb_correction);
            else
                xaxis_hold = imtx;
            end
            
            plot(xaxis_hold, cell_e{imtx}(idpt), 'o', 'color', [.8 .8 .8])
        end
    end
    all_mtx_grps = [all_mtx_grps; repmat(imtx, size(cell_e{imtx}(:)))];
    means(imtx) = nanmean(cell_e{imtx});
    stds(imtx) = nanstd(cell_e{imtx});
    sqrt_l(imtx) = sqrt(length(~isnan(cell_e{imtx})));

    
end

std_es = stds./sqrt_l;


set(gca,'TickLength',[0, 0]); box off
xlim([.5 length(cell_e)+.5])
%xticks(1:4)

if exist('xaxis', 'var')
    errorbar(xaxis,means, std_es, 'g', 'linewidth', 1.5)
else
    errorbar(means, std_es, 'g', 'linewidth', 1.5)
end

    

if length(cell_e)==2
   if connect==1
       [~, pval, ~, stat_struct] = ttest(cell_e{1}, cell_e{2});
       title(['t(' num2str(stat_struct.df) ')=' num2str(round(abs(stat_struct.tstat).*1000)/1000) ', p=' num2str(round(pval.*1000)/1000)])
   else
       [~, pval, ~, stat_struct] = ttest2(cell_e{1}, cell_e{2});
       title(['t(' num2str(stat_struct.df) ')=' num2str(round(abs(stat_struct.tstat).*1000)/1000) ', p=' num2str(round(pval.*1000)/1000)])
   end
    
end


end

