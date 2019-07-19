function cod = corm_offdiag(mtx)
%plots matrix with black line tracing highest points in each row (starting
%from left to right). outputs the total off-diaganol error

%find maximum correlation in each row
diag_peak = nan(size(mtx,1), 2);
for bin = 1:size(mtx,1)
    diag_peak(bin, 1:2) = [bin find(mtx(bin,:) == nanmax(mtx(bin,:)),1)];
end

%sum distance off diagonal
error = abs(diag_peak(:,2) - diag_peak(:,1)); 
error(error>max(diag_peak(:,1))/2) = repmat(max(diag_peak(:,1)), size(error(error>max(diag_peak(:,1))/2))) - error(error>max(diag_peak(:,1))/2); %correct for circularity
cod = sum(error);


%figure
imagesc(mtx);colormap jet;caxis([-1 1]);axis square
hold on
plot(diag_peak(:,2), diag_peak(:,1), 'k-', 'linewidth', 5);
%plot(diag_peak(:,2), diag_peak(:,1), 'k.', 'Markersize', 20);


end