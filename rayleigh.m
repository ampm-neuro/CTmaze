% RAYLEIGH                    Rayleigh statistic for spherical uniformity 
% 
%     [pval,R] = rayleigh(U)
%
%     Most powerful invariant test against von Mises alternative.
%     Not consistent against alternatives with zero resultant length
%     (Mardia & Jupp, pg 209).
%
%     INPUTS
%     U - [n x p] matrix, n samples with dimensionality p
%         the data should already be projected to the unit hypersphere
%
%     OUTPUTS
%     pval - p-value
%     R - statistic
%
%     REFERENCE
%     Mardia, KV, Jupp, PE (2000). Directional Statistics. John Wiley
%
%     SEE ALSO
%     UniSphereTest, spatialSign

%     $ Copyright (C) 2014 Brian Lau http://www.subcortex.net/ $
%     The full license and most recent version of the code can be found at:
%     https://github.com/brian-lau/highdim
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.



function [pval,R] = rayleigh(U)
%U is a vector length 360 or some multiple. Each item in the vector is a
%firing rate indicating the mean firing rate observed when the rat was
%facing that HD.

%find bin size assuming that the test is on 360 data
bin_size = 360/length(U);

%convert bins to radians
bins = deg2rad(1:bin_size:360);

%...and then to vectors
vects_x = cos(bins);
vects_y = sin(bins);

%fill matrix with a number of vects for each angle equal to the firing rate
vects = nan(sum(floor(U(:))),2);
iv_ct = 1;
for iv = 1: length(U)
    vects(iv_ct:iv_ct+floor(U(iv))-1, :) = repmat([vects_x(iv) vects_y(iv)], floor(U(iv)), 1);
    iv_ct = iv_ct+floor(U(iv));
end

%resultant vector
r_vect = abs(mean(vects));

%resultant vector length
R = pdist([0 0; r_vect]);



%p value
pval = exp(sqrt(1+4*size(vects,1)+4*(size(vects,1)^2-R^2))-(1+2*size(vects,1)));
