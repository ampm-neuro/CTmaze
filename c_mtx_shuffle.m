function [all_error, diag_error] = c_mtx_shuffle(learning_first, learning_second, ot_first, ot_second, learning_cell_idx, ot_cell_idx, min_cells, shuffles)
%uses the function c_mtx to calculate, 'shuffles' number of times, the
%error (sum difference from mean) of the off-diagonals from each of the
%correlation matrices (of first and second halves of each session) from 
%learning (early and late) and ot (early and late)

%incl_learning_first, incl_learning_mid, incl_learning_last, incl_learning_ot

if shuffles == 1
    
    %calculate error
    [mean_error, ods_vect] = c_mtx_shuffle_nested(learning_first, learning_second, ot_first, ot_second, learning_cell_idx, ot_cell_idx, min_cells);
    
    %outputs
    all_error = mean_error;
    diag_error = ods_vect;
    
elseif shuffles > 1
    
    %shuffles must be an integer
    shuffles = round(shuffles);
    
    %preallocate error
    all_error = nan(shuffles, 1);
    diag_error = nan(4, shuffles);
    
    %combine first half rates and combine second half rates
    first = [learning_first ot_first];
    second = [learning_second ot_second];
        
    %rebuild combined rate matrices with included cells (incl. multiples of repeated
    %cells)
    %first = [first(:, incl_learning_first) first(:, incl_learning_mid) first(:, incl_learning_last) first(:, incl_learning_ot)];
    %second = [second(:, incl_learning_first) second(:, incl_learning_mid) second(:, incl_learning_last) second(:, incl_learning_ot)];
    
    for shuf = 1:shuffles
        
        shuf
        
        %SHUFFLE
        %preserves first-half second-half session split, but randomizes which cells
        %get assigned to 21, 22, 41, and 42 learning stages.
        
        %Does not shuffle indices. Shuffles actual cell matrices.

        %randomly select learning and ot groups of cells that are the same 
            %size as the original groups
            shuffle_idx = randperm(length(first)); %same length as 'second'
            shuf_learning_idx = shuffle_idx(1:length(learning_cell_idx));
            shuf_ot_idx = shuffle_idx(length(shuf_learning_idx)+1:end);

            %sort cell_vectors
            learning_first = first(:, shuf_learning_idx);
            learning_second = second(:, shuf_learning_idx);
            ot_first = first(:, shuf_ot_idx);
            ot_second = second(:, shuf_ot_idx);
        
        %calculate error
        [mean_error, ods_vect] = c_mtx_shuffle_nested(learning_first, learning_second, ot_first, ot_second, learning_cell_idx, ot_cell_idx, min_cells);
        
        %fill outputs
        all_error(shuf) = mean_error;
        diag_error(:,shuf) = ods_vect;
        
    end
    
else
    error('must have at least one shuffle')
end

end