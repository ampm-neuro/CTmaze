function [start_depth, end_depth] = ttdepths(ttdepth_fractions, cell_row, tt_col, track_length)
% cell_row and tt_col index the cell matrix ttdepth_fractions saved in
% 'revisions_ttdepth_fractions.mat'
%
% track length is the measured length of the track. Units are arbitrary and
% output will keep the same units.


start_depth = track_length.*ttdepth_fractions{cell_row,tt_col}(1);
end_depth = track_length*ttdepth_fractions{cell_row,tt_col}(2);

