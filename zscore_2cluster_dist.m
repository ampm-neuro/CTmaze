function zc_dist = zscore_2cluster_dist(cluster_a, cluster_b)
% finds the zscored euclidean distance between two clusters, a and b
%
% computes this as the mean distance from each dot in 'a' to the mean of 'b' 
% and visa versa, and then divides that distance by the mean distance from 
% each dot in 'a' to the mean of 'a' (and same for b).
%
% euclid distances are normalized by the sqrt of the number of dimensions
%
% this is analogous to dividing the difference by the standard diviation.
%
% ampm 2017

%cluster means (centers)
mean_a = mean(cluster_a);
mean_b = mean(cluster_b);

%dimensionality normalization
dn = sqrt(size(cluster_a,2));

%find between distances
between_dists_a = dist(cluster_a, mean_b')./dn;
between_dists_b = dist(cluster_b, mean_a')./dn;
between_dist = mean([between_dists_a; between_dists_b]);

%find within distances
within_dists_a = dist(cluster_a, mean_a')./dn;
within_dists_b = dist(cluster_b, mean_b')./dn;
within_dist = mean([within_dists_a; within_dists_b]);

%zscore dist
zc_dist = between_dist/within_dist;

end