function [mis_scores, binbybin_vars, trialbytrial_vars] = rev_mis_fn(rates)

% maze section bin boundaries
sect_bins_cumsum = [13    36    64   100   113   136   164   200];
omit_second_stem_idx = [1:sect_bins_cumsum(5) sect_bins_cumsum(6):sect_bins_cumsum(end)];

%for each cell
comb_trials = cell(1, size(rates,1));
mis_scores = nan(size(rates,1),1);
binbybin_vars = nan(size(rates,1),1);
trialbytrial_vars = nan(size(rates,1),1);
for ic = 1:size(rates,1)

    %combine trials
    max_rows = max([size(rates{ic,1},1) size(rates{ic,2},1)]);
    comb_trials{ic} = nan(max_rows, size(rates{ic,1},2) + size(rates{ic,2},2));
    comb_trials{ic}(1:size(rates{ic,1},1),1:size(rates{ic,1},2)) = rates{ic,1};
    comb_trials{ic}(1:size(rates{ic,2},1),size(rates{ic,1},2)+1:end) = rates{ic,2};
    
    %remove second stem visit
    comb_trials{ic} = comb_trials{ic}(:,omit_second_stem_idx);
    
    %calculate bin-by-bin variance on each trial (good variance)
    %
    
        %min number of bin rates for a given trial
        min_bin_pct = .50;
        min_bins = ceil(size(comb_trials{ic},2)*min_bin_pct);

        %preallocate
        binbybin_var = nan(size(comb_trials{ic},1), 1);
        
        %iterate through trials
        for it = 1:length(binbybin_var)

            %min bin check
            if sum(~isnan(comb_trials{ic}(it,:)))<min_bins
                continue
            end

            %load
            binbybin_var(it) = nanvar(comb_trials{ic}(it,:));
        end

    %calculate trial-by-trial variance at each bin (bad variance)
    %
    
        %min number of trial rates for a given bin
        min_trials = 15;
        
        %preallocate
        trialbytrial_var = nan(size(comb_trials{ic},2), 1);
        
        for ib = 1:length(trialbytrial_var)

            %min trial check
            if sum(~isnan(comb_trials{ic}(:,ib)))<min_trials
                continue
            end

            %load
            trialbytrial_var(ib) = nanvar(comb_trials{ic}(:,ib));
        end 
    
                
    %load mis
    %
    
    %min number of good and bar var estimates (reversed from above)
    if sum(~isnan(binbybin_var))<min_trials
        continue
    elseif sum(~isnan(trialbytrial_var))<min_bins
        continue
    end
    
    binbybin_vars(ic) = nanmean(binbybin_var);
    trialbytrial_vars(ic) = nanmean(trialbytrial_var);
    
    mis_scores(ic) = (binbybin_vars(ic) - trialbytrial_vars(ic))/(binbybin_vars(ic) + trialbytrial_vars(ic));
       
end


end