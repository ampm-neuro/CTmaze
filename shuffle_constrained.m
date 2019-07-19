
super_rm = [];
for i = 1:10
    i
    [~, ~, figeight_corr_matx] = ALL_ballistic_times(25, 3, 4);
    super_rm = cat(3, super_rm, figeight_corr_matx);
end