function cnvlv_mtx = convolve_mtx(matrix)

size_fix = matrix; 
size_fix(~isnan(size_fix))=1;

mask = [1 3 1; 3 4 3; 1 3 1]./20;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');


cnvlv_mtx = matrix.*size_fix;

end