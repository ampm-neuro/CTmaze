function [correlation_matrix, first_half, second_half, first_sorting_vector, second_sorting_vector] = c_mtx_firsthalf_secondhalf(sessions, min_cells, first_last_seshs)
%make a correlation matrix correlating first and second halves of a group of sessions

    [~, first_half, ~, ~, ~, ~, first_sorting_vector] = ALL_ballistic_times(100, 3, sessions, 1, 0, 1);
    [~, second_half, ~, ~, ~, ~, second_sorting_vector] = ALL_ballistic_times(100, 3, sessions, 1, 0, 2);
    correlation_matrix = c_mtx(first_half, second_half, min_cells, first_last_seshs);
    %correlation_matrix = [];
end
