function [all_mean_pos_info, all_pos_infos] = pos_info_shell(rates, dwell_times)
%shell function for computing positional information scores from
%linearized track rates and dwell times

% maze section bin boundaries
sect_bins_cumsum = [13    36    64   100   113   136   164   200];
%sect_bins_cumsum = [13    37    65   101   114   138   166   202];

omit_second_stem_idx = [1:sect_bins_cumsum(5) sect_bins_cumsum(6):sect_bins_cumsum(end)];

all_mean_pos_info = nan(size(rates,1),1);
%all_pos_infos = nan(size(rates,1), length(omit_second_stem_idx));
all_pos_infos = nan(size(rates{1},1), 2*size(rates{1},2));
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
    %comb_trials{ic} = comb_trials{ic}(:,omit_second_stem_idx);
    %comb_dwells{ic} = comb_dwells{ic}(:,omit_second_stem_idx);
    
    %compute pos info
    [mean_pos_info, pos_infos] = pos_info(comb_trials{ic}, comb_dwells{ic});
    all_pos_infos(ic,:) = pos_infos;
    all_mean_pos_info(ic) = mean_pos_info;
end

