function plot_p_sections_norm(p_sections_norm)

%num trials
ntrl = size(p_sections_norm,3);

%flip left trials
for itrl = 1:ntrl
    
    p_sections_norm(:,1,itrl) = ...
        [p_sections_norm(1:3,1,itrl);...
         p_sections_norm([5 4],1,itrl);...
         p_sections_norm([7 6],1,itrl);...
         p_sections_norm([9 8],1,itrl)];
end

%average like regions
%{
p_sections_norm_fold = nan(6, 2, ntrl);
for itrl = 1:ntrl
    for iLR = 1:2
        p_sections_norm_fold(:,iLR,itrl) = ...
            [p_sections_norm(1:3,iLR,itrl);...
            mean(p_sections_norm(4:5,iLR,itrl));...
            mean(p_sections_norm(6:7,iLR,itrl));...
            mean(p_sections_norm(8:9,iLR,itrl))];
    end
end
p_sections_norm = p_sections_norm_fold;
%}

%average across trial types
p_sections_norm = mean(p_sections_norm,2);

%renorm
for itrl = 1:ntrl
    p_sections_norm(:,:,itrl) = p_sections_norm(:,:,itrl)./sum(p_sections_norm(:,:,itrl));
end

%bar plot +/- se
figure; hold on
bar(mean(p_sections_norm, 3));
errorbar(mean(p_sections_norm, 3), std(p_sections_norm, [], 3)./sqrt(ntrl), 'k.')
set(gca,'TickLength',[0, 0]); box off;


end