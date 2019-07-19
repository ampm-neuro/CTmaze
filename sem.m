function SEM = sem(data)
%Standard Error of the Mean
    
SEM = std(data(~isnan(data)))/sqrt(numel(data(~isnan(data))));


end