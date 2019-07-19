function [shuf_out, shuf_out_2] = mahaldist_err_shuf(rate_matrices, shuffs)
%rate matrices is output by mahaldist_err, and is input as a cell matrix of
%individual matrices
%outputs means for each rate matrix, the absolute error of all rate
%matrices, and the classification success of all.

%IDs (could be input)
ID_idx = [ones(size(rate_matrices{1},1)/2,1); repmat(2, size(rate_matrices{1},1)/2,1)];

%number of matrices
n_matx = length(rate_matrices);

%combine rate matrices
o_matrix = [];
rm_cell_counts = nan(length(rate_matrices), 2);
count_hold = 0;
for rm = 1:length(rate_matrices)
   rm_cell_counts(rm, :) = [count_hold+1 count_hold+size(rate_matrices{rm}, 2)];
   o_matrix = [o_matrix rate_matrices{rm}];
   count_hold = count_hold+size(rate_matrices{rm}, 2);
end

%shuffle
shuf_out = nan(shuffs, 1+n_matx);
shuf_out_2 = nan(shuffs, n_matx);
for shuf = 1:shuffs

    %shuffle cells between rate_matrices
    rand_idx = randperm(size(o_matrix,2));
    for rm = 1:n_matx
        
        %build shuffled rate_matrix
        rm_shuf = o_matrix(:,rand_idx(rm_cell_counts(rm, 1):rm_cell_counts(rm, 2)));
    
        dist_specificity_shuf = nan(size(rm_shuf,1),1);
        for i = 1:size(rm_shuf,1)

            current_shuf = rm_shuf(i,:);
            
            comp_idx_shuf = 1:size(rm_shuf,1); comp_idx_shuf = comp_idx_shuf~=i;
            id_idx_opposite_shuf = (ID_idx~=ID_idx(i))'; id_idx_same_shuf = (ID_idx==ID_idx(i))';
           
            opposite_center_shuf = mean(rm_shuf(comp_idx_shuf & id_idx_opposite_shuf, :));
            same_center_shuf = mean(rm_shuf(comp_idx_shuf & id_idx_same_shuf, :));


            dist_opposite_shuf = dist(current_shuf, opposite_center_shuf')/sqrt(size(rm_shuf,2));
            dist_same_shuf = dist(current_shuf, same_center_shuf')/sqrt(size(rm_shuf,2));
            dist_specificity_shuf(i) = (dist_opposite_shuf-dist_same_shuf)/(dist_opposite_shuf+dist_same_shuf);


        end
    
        shuf_out(shuf, rm) = mean(dist_specificity_shuf);
        shuf_out_2(shuf, rm) = sum(dist_specificity_shuf>0)/sum(~isnan(dist_specificity_shuf));
    
    end
    
    %absolute error
    
    %shuf_out(shuf, 1+n_matx) = sum(abs(shuf_out(shuf, 1:n_matx) - repmat(mean(shuf_out(shuf, 1:n_matx)), size(shuf_out(shuf, 1:n_matx)))));
    %shuf_out_2(shuf, 1+n_matx) = sum(abs(shuf_out_2(shuf, 1:n_matx) - repmat(mean(shuf_out_2(shuf, 1:n_matx)), size(shuf_out_2(shuf, 1:n_matx)))));
    
    
    %mean squared error
    shuf_out(shuf, 1+n_matx) = sum((shuf_out(shuf, 1:n_matx) - repmat(mean(shuf_out(shuf, 1:n_matx)), size(shuf_out(shuf, 1:n_matx)))).^2)/length(shuf_out(shuf, 1:n_matx));
    shuf_out_2(shuf, 1+n_matx) = sum((shuf_out_2(shuf, 1:n_matx) - repmat(mean(shuf_out_2(shuf, 1:n_matx)), size(shuf_out_2(shuf, 1:n_matx)))).^2)/length(shuf_out_2(shuf, 1:n_matx));
    
end
    
    
end
