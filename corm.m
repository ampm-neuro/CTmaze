function cm = corm(c1, c2)
%function corm(cell_rates_first, cell_rates_second)
%
% makes correllation matrix of rates in c1 and c2

%preallocate
cm = nan(size(c1,1), size(c2,1));

%normalize
%c1 = c1 - repmat(mean(c1, 2), 1, size(c1,2));%remove c1 means
%c1 = c1./repmat(std(c1, 0, 2), 1, size(c1,2)); %remove c1 stdevs
%c2 = c2 - repmat(mean(c2, 2), 1, size(c2,2));%remove c2 means
%c2 = c2./repmat(std(c2, 0, 2), 1, size(c2,2)); %remove c2 stdevs

c = [c1; c2];
c = c - repmat(nanmean(c), size(c,1),1);%remove c1 means
c = c./repmat(nanstd(c), size(c,1),1); %remove c1 stdevs

c1 = c(1:size(c1,1), :);
c2 = c(size(c1,1)+1:end, :);



%rate differences
%centerrate = mean(c(:));

%[R p] = fit_line(c1(:,1), c2(:,1)); title('c1 c2')

%correllate cell activity in each corresponding bin
for c1_bin = 1:size(c1,1)
    
    for c2_bin = 1:size(c2,1)
        
        cm(c1_bin, c2_bin) = corr(c1(c1_bin,:)', c2(c2_bin,:)');
        
    end
end

%mirror
%cm = (cm + cm') ./2;

%plot
%{
figure;
imagesc(cm)
colormap jet
colorbar
axis square
set(gca,'TickLength',[0, 0]);
%}

end