function decode_corr_w_sesh(varargin)

CTLTot = varargin{1};
%sumdec = varargin{2};
dec_acc = varargin{2};



mtx = nan(length(unique(CTLTot(:,14))), 3);

mtx(:,1) = unique(CTLTot(:, 14));

for sesh = mtx(:,1)'
    
    %percent correct
    mtx(mtx(:,1)==sesh,2) = length(CTLTot(CTLTot(:,13)<2 & CTLTot(:,14)==sesh & CTLTot(:,12)==1,7))/length(CTLTot(CTLTot(:,13)<2 & CTLTot(:,14)==sesh,7));
    %something else
    mtx(mtx(:,1)==sesh,3) = mean(CTLTot(CTLTot(:,13)<2 & CTLTot(:,14)==sesh, 16));
    %mtx(mtx(:,1)==sesh,3) = dec_acc(sesh, 4);

    
end

figure
plot(mtx(dec_acc(:,4)>.28,3), mtx(dec_acc(:,4)>.28,2), '.', 'Color', 'k')

mtx

[rho, pval] = corr(mtx(dec_acc(:,4)>.28,3), mtx(dec_acc(:,4)>.28,2))

hold on

poly1=polyfit(mtx(dec_acc(:,4)>.28,3), mtx(dec_acc(:,4)>.28,2),1);

x=(min(mtx(dec_acc(:,4)>.28,3)):(max(mtx(dec_acc(:,4)>.28,3))-min(mtx(dec_acc(:,4)>.28,3)))/100:max(mtx(dec_acc(:,4)>.28,3)));
f1=polyval(poly1, x);
plot(x,f1, 'k-', 'LineWidth', 2);

hold off

%{

figure
plot(dec_acc(:,4), mtx(:,2), '.', 'Color', 'k')
hold on
poly1=polyfit(dec_acc(:,4), mtx(:,2),1);
x=(min(dec_acc(:,4)):(max(dec_acc(:,4))-min(dec_acc(:,4)))/100:max(dec_acc(:,4)));
f1=polyval(poly1, x);
plot(x,f1, 'k-', 'LineWidth', 2);

[rho, pval] = corr(dec_acc(:,4), mtx(:,2))

hold off


figure
plot(dec_acc(:,4), mtx(:,3), '.', 'Color', 'k')
hold on
poly1=polyfit(dec_acc(:,4), mtx(:,3),1);
x=(min(dec_acc(:,4)):(max(dec_acc(:,4))-min(dec_acc(:,4)))/100:max(dec_acc(:,4)));
f1=polyval(poly1, x);
plot(x,f1, 'k-', 'LineWidth', 2);


[rho, pval] = corr(dec_acc(:,4), mtx(:,3))
%}
hold off