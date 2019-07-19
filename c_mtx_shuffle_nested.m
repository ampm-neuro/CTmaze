function [mean_error, ods_vect] = c_mtx_shuffle_nested(learning_first, learning_second, ot_first, ot_second, learn_sort, ot_sort, min_cells)
%uses the function c_mtx to calculate, 'shuffles' number of times, the
%error (sum difference from mean) of the off-diagonals from each of the
%correlation matrices (of first and second halves of each session) from 
%learning (early and late) and ot (early and late)

%calculate matrices
correlation_matrix_21 = c_mtx(learning_first, learning_second, learn_sort, min_cells, 1);%learning early
correlation_matrix_22 = c_mtx(learning_first, learning_second, learn_sort, min_cells, 2);%learning mid
correlation_matrix_23 = c_mtx(learning_first, learning_second, learn_sort, min_cells, 3);%learning late
correlation_matrix_4 = c_mtx(ot_first, ot_second, ot_sort, min_cells, 3);%ot late

%mirror
%{
correlation_matrix_21 = mirror_matrix(correlation_matrix_21);
correlation_matrix_22 = mirror_matrix(correlation_matrix_22);
correlation_matrix_23 = mirror_matrix(correlation_matrix_23);
correlation_matrix_4 = mirror_matrix(correlation_matrix_4);
%}

%calculate off-diagonal distances
ods_21 = off_diagonal_sum(correlation_matrix_21);%learning early
ods_22 = off_diagonal_sum(correlation_matrix_22);%learning late
ods_23 = off_diagonal_sum(correlation_matrix_23);%ot early
ods_4 = off_diagonal_sum(correlation_matrix_4);%ot late

%mean error
ods_vect = [ods_21; ods_22; ods_23; ods_4];
%mean_error = sum(abs(ods_vect - repmat(mean(ods_vect), size(ods_vect))));
mean_error = mean((ods_vect - repmat(mean(ods_vect), size(ods_vect))).^2);

%FUNCTIONS
%function for calculating off diagonal
    function ods = off_diagonal_sum(mtx)
    
        %find maximum correlation in each row
        diag_peak = nan(size(mtx,1), 2);
        for bin = 1:size(mtx,1)
            diag_peak(bin, 1:2) = [bin find(mtx(bin,:) == nanmax(mtx(bin,:)),1)];
        end

        %{
        figure
        imagesc(mtx)
        colormap jet
        hold on
        plot(diag_peak(:,2), diag_peak(:,1), 'k', 'LineWidth', 5)
        %}

        %sum distance off diagonal
        error = abs(diag_peak(:,2) - diag_peak(:,1)); 
        error(error>max(diag_peak(:,1))/2) = repmat(max(diag_peak(:,1)), size(error(error>max(diag_peak(:,1))/2))) - error(error>max(diag_peak(:,1))/2); %correct for circularity
        ods = sum(error);
    end
        
%mirror
    function mmtx = mirror_matrix(mtx)
        
        mmtx = (mtx+mtx')./2;
    end
end