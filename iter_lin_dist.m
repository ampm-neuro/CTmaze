function dists = iter_lin_dist(mtx_size, v1, v2)
%calculates the euclidean distance (in matrix space) between the pixles 
%identified in the linear index vectors v1 and v2.
%
% mtx_size is the size (dimensions) of the matrix indexed in v1 and v2
% e.g., [2,2]
%
% v1 and v2 must be the same length and orientation


if length(v1) ~= length(v2)
    size_v1 = size(v1)
    size_v2 = size(v2)
    error('v1 and v2 must be the same length and orientation')
end

dists = nan(length(v1),1);
for i = 1:length(v1)
    
    [x_v1, y_v1] = ind2sub(mtx_size, v1(i));
    [x_v2, y_v2] = ind2sub(mtx_size, v2(i));
    
    dists(i) = pdist([x_v1 y_v1; x_v2 y_v2]);
    
end

end