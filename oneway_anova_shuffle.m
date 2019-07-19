function [obs_mse, shuf_mses] = oneway_anova_shuffle(celle, shuffs)
%find MSE among groups (each cell) in cell vector celle
%compare to distribution of mses after shuffling group lables

%number of groups
numgrp = max(size(celle));

%individual groups
grpsizes = nan(numgrp,1);
for i=1:numgrp
    grpsizes(i) = length(celle{i}); 
end

%single vect
all_vect = [];
for i = 1:numgrp
   all_vect = [all_vect; celle{i}]; 
end

%obs
all_vect_mean = nanmean(all_vect);

%group means, mse
grpmeans = nan(numgrp,1);
se = nan(numgrp,1);
for i=1:numgrp
    grpmeans(i) = nanmean(celle{i}); 
    se(i) = (grpmeans(i) - all_vect_mean)^2;
end

%mean squared error
obs_mse = nanmean(se);

errorbar_plot(celle); %xlim([.5 5.5]); ylim([-1 1])
hold on; plot(xlim,[0 0], 'k--')



%shuffles
shuf_mses = nan(shuffs,1);
for ishuf = 1:shuffs
    
    %shuffle
    shuf_all_vect = all_vect(randperm(length(all_vect)));

    %preallocate repopulate celle
    shuf_celle = cell(size(celle));
    
    
    %group means, mse
    shuf_grpmeans = nan(numgrp,1);
    shuf_se = nan(numgrp,1);
    count = 1;
    for i=1:numgrp
        %repopulate celle
        shuf_celle{i} = shuf_all_vect(count : count+grpsizes(i)-1);
        count = count+grpsizes(i);
        
        %calculate se of means
        shuf_grpmeans(i) = nanmean(shuf_celle{i}); 
        shuf_se(i) = (shuf_grpmeans(i) - all_vect_mean)^2;
    end

    %mean squared error
    shuf_mses(ishuf) = nanmean(shuf_se);
 
end







end