function mtx_out = reshape_pages(mtx_in)
%stacks pages vertically

mtx_out = nan(size(mtx_in,1)*size(mtx_in,3), size(mtx_in,2));
for ipage = 1:size(mtx_in,3)
    mtx_out(((ipage-1)*size(mtx_in,1)+1):((ipage)*size(mtx_in,1)),:) = mtx_in(:,:,ipage);
end