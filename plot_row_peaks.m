function [vect] = plot_row_peaks(mtx)

hold on

vect = nan(size(mtx,1),1);

for i = 1:size(mtx,1)
    if ~isempty(find(mtx(i,:)==max(mtx(i,:)),1,'first'))
        vect(i) = find(mtx(i,:)==max(mtx(i,:)),1,'first');
    else
        vect(i) = nan;
    end
end

plot(vect, (1:size(mtx,1))./size(mtx,1), '-', 'linewidth', 2)