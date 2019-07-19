function [info_scores, mean_FRs] = rev_is_fn(rates, dwell_times)

% maze section bin boundaries
sect_bins_cumsum = [13    36    64   100   113   136   164   200];
omit_second_stem_idx = [1:sect_bins_cumsum(5) sect_bins_cumsum(6):sect_bins_cumsum(end)];

%for each cell
comb_trials = cell(1, size(rates,1));
comb_dwells = cell(1, size(rates,1));
info_scores = nan(size(rates,1),1);
mean_FRs = nan(size(rates,1),1);
for ic = 1:size(rates,1)

    %combine trials
    max_rows = max([size(rates{ic,1},1) size(rates{ic,2},1)]);
    comb_trials{ic} = nan(max_rows, size(rates{ic,1},2) + size(rates{ic,2},2));
    comb_trials{ic}(1:size(rates{ic,1},1),1:size(rates{ic,1},2)) = rates{ic,1};
    comb_trials{ic}(1:size(rates{ic,2},1),size(rates{ic,1},2)+1:end) = rates{ic,2};
    
    %combine dwell times
    comb_dwells{ic} = nan(max_rows, size(rates{ic,1},2) + size(rates{ic,2},2));
    comb_dwells{ic}(1:size(rates{ic,1},1),1:size(rates{ic,1},2)) = dwell_times{ic,1};
    comb_dwells{ic}(1:size(rates{ic,2},1),size(rates{ic,1},2)+1:end) = dwell_times{ic,2};
    
    %remove second stem visit
    comb_trials{ic} = comb_trials{ic}(:,omit_second_stem_idx);
    comb_dwells{ic} = comb_dwells{ic}(:,omit_second_stem_idx);
    
    %compute average FR in each bin
    bin_FRs = nanmean(comb_trials{ic});
    bin_FRs(bin_FRs<0) = 0;
    
    %compute mean dwell time for each bin
    dwell_times_hold = nanmean(comb_dwells{ic});

    %minimum bin threshold
    min_bin_proportion = .50;
    min_bins = ceil(length(bin_FRs)*min_bin_proportion);
        
    %check for min bins
    dwell_times_hold = dwell_times_hold(~isnan(bin_FRs));
    bin_FRs = bin_FRs(~isnan(bin_FRs));
    if length(bin_FRs) < min_bins
        continue
    end
    
    %load overall mean firing rate
    mean_FRs(ic) = mean(bin_FRs);
    
    %load infoscore  
    info_content = nan(length(bin_FRs),1);
    for i = 1:length(info_content)

        Pi = dwell_times_hold(i)/nansum(dwell_times_hold); %probability of occupancy of bin i
        Ri = bin_FRs(i); %mean firing rate for bin i
        rr = Ri/mean_FRs(ic); %relative rate
        info_content(i) = Pi*(rr)*log2(rr) ;%load info content for each bin
        
    end
    info_scores(ic) = nansum(nansum(info_content)); 
    
    
    
    
    
     
end


end