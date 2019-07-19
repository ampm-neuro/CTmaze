function mtx = smooth_rows(mtx, smooth_factor)

for i = 1:size(mtx,1)
    mtx(i,:) = smooth(mtx(i,:),smooth_factor);
end

