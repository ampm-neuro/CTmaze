function [MSE_vect, included_cells] = shuffle_corms_across_learning(v1_2, v2_2, v1_4, v2_4, learn_sort, ot_sort, shuffles)
%randomizes neurons across learning days and computes off-diag error for each
%corm (21, 22, 23, 43). Does this 'shuffles' number of times. If shuffles =
% 0, it computes true values.

%prep
%

learning_hd_cells_definite = [192 194];
%learning_hd_cells_possible = [90 126 139 141 154 220 243 335];
learning_hd_cells_possible = [90 139 335]; % 126 141 154 220 243
learning_hd_cells = [learning_hd_cells_definite learning_hd_cells_possible];
learning_hd_cells = [];

ot_hd_cells_definite = [10 15 60 74 148 212 306];
ot_hd_cells_possible = [45 119 221 225 287 294 308 314]; % 145
ot_hd_cells = [ot_hd_cells_definite ot_hd_cells_possible];
ot_hd_cells = [];

v1_2 = v1_2(:,learn_sort);
    v2_2 = v2_2(:,learn_sort);
v1_4 = v1_4(:,ot_sort);
    v2_4 = v2_4(:,ot_sort);

v1_2(:, [learning_hd_cells]) = [];
    v2_2(:, [learning_hd_cells]) = [];
v1_4(:, [ot_hd_cells]) = [];
    v2_4(:, [ot_hd_cells ]) = [];



%}
num_learn_cells = size(v1_2,2);
num_ot_cells = size(v1_4,2);
combined_1 = [v1_2 v1_4];
combined_2 = [v2_2 v2_4];
min_cells = 50;

%included cells
included_cells = cell(4,1);

if shuffles == 0
    
    %input name change
    learning_first = v1_2;
    learning_second = v2_2;
    ot_first = v1_4;
    ot_second = v2_4;
    
    %calculate matrices
    figure; hold on
    [correlation_matrix_21, ~,~,~,included_cells_21] = c_mtx_presort(learning_first, learning_second, min_cells, 1);%learning early
        subplot(1,4,1); corm_offdiag(correlation_matrix_21);
    [correlation_matrix_22, ~,~,~, included_cells_22] = c_mtx_presort(learning_first, learning_second, min_cells, 2);%learning mid
        subplot(1,4,2); corm_offdiag(correlation_matrix_22);
    [correlation_matrix_23, ~,~,~, included_cells_23] = c_mtx_presort(learning_first, learning_second, min_cells, 3);%learning late
        subplot(1,4,3); corm_offdiag(correlation_matrix_23);
    [correlation_matrix_4, ~,~,~, included_cells_4] = c_mtx_presort(ot_first, ot_second, min_cells, 2);%ot late
        subplot(1,4,4); corm_offdiag(correlation_matrix_4);
     
    %calculate off-diagonal distances
    ods_21 = off_diagonal_sum(correlation_matrix_21);%learning early
    ods_22 = off_diagonal_sum(correlation_matrix_22);%learning late
    ods_23 = off_diagonal_sum(correlation_matrix_23);%ot early
    ods_4 = off_diagonal_sum(correlation_matrix_4);%ot late
    
    %mean squared error
    ods_vect = [ods_21; ods_22; ods_23; ods_4]
    MSE_vect = mean((ods_vect - repmat(mean(ods_vect), size(ods_vect))).^2);
    %MSE_vect = mean(abs((ods_vect - repmat(mean(ods_vect), size(ods_vect)))));
    
    %included cells
    included_cells{1} = included_cells_21;
    included_cells{2} = included_cells_22;
    included_cells{3} = included_cells_23;
    included_cells{4} = included_cells_4;
    
    
elseif shuffles > 0
    
    for ishuf = 1:shuffles
    
        %shuffle cells
        shuf_idx = randperm(num_learn_cells + num_ot_cells);
        
        shuf_combined_1 = combined_1(:,shuf_idx);
        shuf_combined_2 = combined_2(:,shuf_idx);
        learning_first = shuf_combined_1(:,1:num_learn_cells);
        learning_second = shuf_combined_2(:,1:num_learn_cells);
        ot_first = shuf_combined_1(:,num_learn_cells+1 : end);
        ot_second = shuf_combined_2(:,num_learn_cells+1 : end);
        
        %figure; subplot(1,2,1); imagesc(combined_1)
        %subplot(1,2,2); imagesc(shuf_combined_1)
        ot_sort_comb = ot_sort + max(learn_sort);
        ot_sort_comb = [learn_sort ot_sort];

        %calculate matrices
        correlation_matrix_21 = c_mtx_presort(learning_first, learning_second, min_cells, 1);%learning early
        correlation_matrix_22 = c_mtx_presort(learning_first, learning_second, min_cells, 2);%learning mid
        correlation_matrix_23 = c_mtx_presort(learning_first, learning_second, min_cells, 3);%learning late
        correlation_matrix_4 = c_mtx_presort(ot_first, ot_second, min_cells, 2);%ot late
        %correlation_matrix_4 = c_mtx_presort(shuf_combined_1, shuf_combined_2, min_cells, 2);%ot late

        %calculate off-diagonal distances
        ods_21 = off_diagonal_sum(correlation_matrix_21);%learning early
        ods_22 = off_diagonal_sum(correlation_matrix_22);%learning late
        ods_23 = off_diagonal_sum(correlation_matrix_23);%ot early
        ods_4 = off_diagonal_sum(correlation_matrix_4);%ot late

        %mean squared error
        ods_vect = [ods_21; ods_22; ods_23; ods_4]
        mean((ods_vect - repmat(mean(ods_vect), size(ods_vect))).^2)
        MSE_vect(ishuf) = mean((ods_vect - repmat(mean(ods_vect), size(ods_vect))).^2);
        %MSE_vect(ishuf) = mean(abs((ods_vect - repmat(mean(ods_vect), size(ods_vect)))));
    
    end
    
end

end


function ods = off_diagonal_sum(mtx)
    
    %find maximum correlation in each row
    diag_peak = nan(size(mtx,1), 2);
    for bin = 1:size(mtx,1)
        diag_peak(bin, 1:2) = [bin find(mtx(bin,:) == nanmax(mtx(bin,:)),1)];
    end
    
    %sum distance off diagonal
    error = abs(diag_peak(:,2) - diag_peak(:,1)); 
    error(error>max(diag_peak(:,1))/2) = repmat(max(diag_peak(:,1)), size(error(error>max(diag_peak(:,1))/2))) - error(error>max(diag_peak(:,1))/2); %correct for circularity
    ods = sum(error);
end