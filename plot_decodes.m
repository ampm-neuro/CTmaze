function [cos ots] = plot_decodes(CTLTcont, CTLTot, first, mid, crit)%, comb_cont, comb_ot)

    
rt = 2;
outlier = 1;

figure; hold on

%col = 2;

    %outputs means and stes with rows as
    %first mid crit ot
    function [means stes] = descriptives(firsts, mids, crits, ots)
        
        means = [mean(firsts) mean(mids) mean(crits) mean(ots)];
        stes = [std(firsts)/sqrt(length(firsts)) std(mids)/sqrt(length(mids)) ...
            std(crits)/sqrt(length(crits)) std(ots)/sqrt(length(ots))];
        
    end



for col = [17]% 17]

%correct trials
    
    c_first = CTLTcont(ismember(CTLTcont(:,14), first) & CTLTcont(:,13)<rt & CTLTcont(:,12)==1 & abs(CTLTcont(:,col))<outlier, col);
    c_mid = CTLTcont(ismember(CTLTcont(:,14), mid) & CTLTcont(:,13)<rt & CTLTcont(:,12)==1 & abs(CTLTcont(:,col))<outlier, col);
    c_crit = CTLTcont(ismember(CTLTcont(:,14), crit) & CTLTcont(:,13)<rt & CTLTcont(:,12)==1 & abs(CTLTcont(:,col))<outlier, col);
    c_ot = CTLTot(CTLTot(:,13)<rt & CTLTot(:, 12)==1 & abs(CTLTot(:,col))<outlier,col);

    [means_c stes_c] = descriptives(c_first, c_mid, c_crit, c_ot);
    
    cos = [c_first; c_mid; c_crit];
    ots = c_ot;
    
    %barweb([mean([c_first; c_mid; c_crit]) mean(c_ot)], [std([c_first; c_mid; c_crit])/sqrt(length([c_first; c_mid; c_crit])) std(c_ot)/sqrt(length(c_ot))])
    
    
%plot
    
%if ismember(col, [1 3 5 7 8 9 15 17])
    errorbar(1:4, means_c, stes_c, 'k-', 'linewidth', 2.0)
%elseif ismember(col, [2 4 6 16])
%    errorbar(1:4, means_c, stes_c, 'k--', 'linewidth', 2.0)
%end


%error trials
%{
    e_first = CTLTcont(ismember(CTLTcont(:,14), first) & CTLTcont(:,13)<rt & CTLTcont(:,12)==2,col);
    e_mid = CTLTcont(ismember(CTLTcont(:,14), mid) & CTLTcont(:,13)<rt & CTLTcont(:,12)==2,col);
    e_crit = CTLTcont(ismember(CTLTcont(:,14), crit) & CTLTcont(:,13)<rt & CTLTcont(:,12)==2,col);
    e_ot = CTLTot(CTLTot(:,13)<rt & CTLTot(:, 12)==2,col);

    [means_e stes_e] = descriptives(e_first, e_mid, e_crit, e_ot);
    rtn_means = [[CTLTot_excl(CTLTot_excl(:,13)<2 & CTLTot_excl(:,12)==1, 5); CTLTot_excl(CTLTot_excl(:,13)<2 & CTLTot_excl(:,12)==1, 6)] [zeros(size(CTLTot_excl(CTLTot_excl(:,13)<2 & CTLTot_excl(:,12)==1, 5)); ones(size(CTLTot_excl(CTLTot_excl(:,13)<2 & CTLTot_excl(:,12)==1, 6)))]];
    
%plot
    
if ismember(col, [1 3 5 7 8 9 15 17])
    errorbar(1:4, means_e, stes_e, 'r-', 'linewidth', 2.0)
elseif ismember(col, [2 4 6 16])
    errorbar(1:4, means_e, stes_e, 'r--', 'linewidth', 2.0)
end
%}

set(gca, 'Ticklength', [0 0])
box off
set(gca, 'XTick', 1:4)

%for colz=1:3
%    meanz = [mean(comb_cont(ismember(comb_cont(:,14), first) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz)) mean(comb_cont(ismember(comb_cont(:,14), mid) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz)) mean(comb_cont(ismember(comb_cont(:,14), crit) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz)) mean(comb_ot(comb_ot(:,14)~=17 & comb_ot(:,13)<2 & comb_ot(:,12)==1,colz))];
%    stez = [std(comb_cont(ismember(comb_cont(:,14), first), colz))/sqrt(length(comb_cont(ismember(comb_cont(:,14), first) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz))) std(comb_cont(ismember(comb_cont(:,14), mid) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz))/sqrt(length(comb_cont(ismember(comb_cont(:,14), mid) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz))) std(comb_cont(ismember(comb_cont(:,14), crit) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz))/sqrt(length(comb_cont(ismember(comb_cont(:,14), crit) & comb_cont(:,13)<2 & comb_cont(:,12)==1, colz))) std(comb_ot(comb_ot(:,14)~=17 & comb_ot(:,13)<2 & comb_ot(:,12)==1,colz))/sqrt(length(comb_ot(comb_ot(:,14)~=17 & comb_ot(:,13)<2 & comb_ot(:,12)==1,colz)))];
%    errorbar(meanz, stez, 'k-', 'linewidth', 2.0)
%end

%figure; hold on
%plot(c_first, 'k.')
%plot(c_mid, 'g.')
%plot(c_crit, 'b.')
%plot(c_ot, 'r.')

%anova
%
    y = [c_first; c_mid; c_crit; c_ot];
    training_stage = [ones(size(c_first)); repmat(2,size(c_mid)); repmat(3,size(c_crit)); repmat(4,size(c_ot))];
    group = {training_stage};
    
    %{
    plot(training_stage,y, 'k.')
    
    figure; hist(c_first, 20);
    axis([-.5 .5 0 16])
    figure; hist(c_mid, 60);
    figure; hist(c_crit, 90);
    figure; hist(c_ot, 250);
    %}
    
    [p, t, stats, terms] = anovan(y, group, 'continuous', 1, 'model',2, 'sstype',3','varnames', strvcat('learning'), 'display', 'on');
%}



%change from crit to ot







end
end