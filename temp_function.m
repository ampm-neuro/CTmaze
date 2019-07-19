function cm = temp_function(corm)

    cm(1:100, 1:100) = (corm(1:100, 1:100) + corm(1:100, 1:100)')./2;
    cm(1:100, 101:200) = (corm(1:100, 101:200) + corm(1:100, 101:200)')./2;
    cm(101:200, 1:100) = (corm(101:200, 1:100) + corm(101:200, 1:100)')./2;
    cm(101:200, 101:200) = (corm(101:200, 101:200) + corm(101:200, 101:200)')./2;
    figure; imagesc(cm); colorbar; colormap jet; caxis([-1 1]); axis square
    hold on; m = cm; for h = 1:size(m,1); a(h, 1:2) = [h find(m(h,:) == nanmax(m(h,:)),1)]; end; plot(a(:,2), a(:,1), 'k')
    
end