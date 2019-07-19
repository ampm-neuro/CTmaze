function cpcolor(matrix)

%cpcolor(matrix) uses a corrected (non-flipped, non-cut-off) pcolor to plot
%a heatmap of the input matrix.


figure
pcolor(flipud([[zeros(1,length(matrix(1,:))); matrix] zeros(length(matrix(:,1))+1,1)]))

end