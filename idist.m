function id_out = idist(XXX)
%calculates isolation distance, a measure of how far sorted spikes are from
%noise (and other spikes)
%
%Isolation distance is the radius of the smallest ellipsoid form the
%cluster center that contains all of the cluster spikes and an equal number
%of noise spikes. Larger distances indicate greater segregation.

%mahalanobis distance between spikes and the center of the cluster
mahal_dist = mahal(Y,X);


%find number of cluster spikes

%use 8 spikesort features (Peak x4 tts, Valley x4 tts) to localize every
%spike event into 8d space

%find center of cluster

%find distance from every non_cluster spike to the center of the cluster

%sort those distances

%find the nth smallest distance, where n is the number of cluster spikes.

