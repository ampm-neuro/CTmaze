function [mtx_out, peaks_out, sorted_peaks_out] = sort_rows_by_peak(mtx)
%good for sorting rate matrices with rows as cells and columns as space or
%time


peaks = nan(size(mtx,1),1);
for irow = 1:size(mtx,1)
    mtx(irow,:) = nanfastsmooth(mtx(irow,:), 3, 1, .75);
    if ~isempty(find(mtx(irow,:) == max(mtx(irow,:)), 1,'last'))
        peaks(irow) = find(mtx(irow,:) == max(mtx(irow,:)), 1,'last');
    else
       peaks(irow) = nan;
    end
end

[~,sort_idx] = sort(peaks);

mtx_out = mtx(sort_idx,:);
peaks_out = peaks;
sorted_peaks_out = peaks(sort_idx);

end