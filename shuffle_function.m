function [origin shuffles] = shuffle_function(varargin)

CTLTot = varargin{1};
iterations = varargin{2};

origin = abs(mean(CTLTot(CTLTot(:,2)==0)) - mean(CTLTot(CTLTot(:,2)==1)))

shuffles = nan(iterations, 1);

for i = 1:iterations
    
    LRs = CTLTot(randperm(length(CTLTot(:,2))),2);  
    
    shuffles(i) = mean(CTLTot(LRs==0, 1)) - mean(CTLTot(LRs==1, 1));
    
end

figure
hist(abs(shuffles), 1000)
hold on
plot(abs([origin origin]), [0 400], 'r')

pval = 2*sum(shuffles>origin)/iterations

end
