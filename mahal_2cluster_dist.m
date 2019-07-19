function m_dist = mahal_2cluster_dist(cluster_a, cluster_b)
% finds the mahalanobis distance between two clusters, a and b
%
% computes this as the mean distance from each dot in 'a' to the mean of 'b' 
% and visa versa
%
% distances are normalized by the sqrt of the number of dimensions
%
% this is analogous to dividing the difference by the standard diviation.
%
% ampm 2017

%cluster means (centers)
%mean_a = mean(cluster_a);
%mean_b = mean(cluster_b);

%dimensionality normalization
dn = sqrt(size(cluster_a,2));

%find between distances
between_dists_a = sqrt(mahal(cluster_a, cluster_b))./dn;
between_dists_b = sqrt(mahal(cluster_b, cluster_a))./dn;
m_dist = mean([between_dists_a; between_dists_b]);

end