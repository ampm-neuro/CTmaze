function fvals = decode_learning_anova_split(data_cont, data_ot, first, mid, crit, iterations)
%this function calculates the f-value of the interaction. more than 1
%iteration will start a shuffle proceedure, whereby all data points are
%shuffled among all cells and the resulting f values (1 from each shuffle)
%will be output in a single matrix size(iterations, 1)

%preallocate
fvals = nan(iterations, 1);

%run time maximum
rt = 1.34;

%plot col
col = 3;

for i = 1:iterations
    
    %shuffle shit, yo
    if iterations > 1
        if i == 1
            display('shuffle')
        end
        combined_inputs = [data_cont; data_ot];
        shuffled_inputs = combined_inputs(randperm(length(combined_inputs)), :);
        data_cont = shuffled_inputs(1:length(data_cont), :);
        data_ot = shuffled_inputs(length(data_cont)+1:end, :);
    end
    
    
    
    %correct means
    
    %(:,1) = future     (:,2) = not future
    c_first(:,1) = data_cont(ismember(data_cont(:,9), first) & data_cont(:,8)<rt & data_cont(:,7)==1,11);
    c_first(:,2) = data_cont(ismember(data_cont(:,9), first) & data_cont(:,8)<rt & data_cont(:,7)==1,12);
    c_mid(:,1) = data_cont(ismember(data_cont(:,9), mid) & data_cont(:,8)<rt & data_cont(:,7)==1,11);
    c_mid(:,2) = data_cont(ismember(data_cont(:,9), mid) & data_cont(:,8)<rt & data_cont(:,7)==1,12);
    c_crit(:,1) = data_cont(ismember(data_cont(:,9), crit) & data_cont(:,8)<rt & data_cont(:,7)==1,11);
    c_crit(:,2) = data_cont(ismember(data_cont(:,9), crit) & data_cont(:,8)<rt & data_cont(:,7)==1,12);
    c_ot(:,1) = data_ot(data_ot(:,8)<rt & data_ot(:,7)==1,11);
    c_ot(:,2) = data_ot(data_ot(:,8)<rt & data_ot(:,7)==1,12);


    mean_ot = mean(c_ot)
    mean_crit = mean(c_crit)
    mean_mid = mean(c_mid)
    mean_first = mean(c_first)

    std_ot = std(c_ot);
    std_crit = std(c_crit);
    std_mid = std(c_mid);
    std_first = std(c_first);

    length_ot = length(c_ot);
    length_crit = length(c_crit);
    length_mid = length(c_mid);
    length_first = length(c_first);

    ste_ot = std_ot./sqrt(length_ot);
    ste_crit = std_crit./sqrt(length_crit);
    ste_mid = std_mid./sqrt(length_mid);
    ste_first = std_first./sqrt(length_first);


    %errror means

    e_first(:,1) = data_cont(ismember(data_cont(:,9), first) & data_cont(:,8)<rt & data_cont(:,7)==2, 11);
    e_first(:,2) = data_cont(ismember(data_cont(:,9), first) & data_cont(:,8)<rt & data_cont(:,7)==2, 12);
    e_mid(:,1) = data_cont(ismember(data_cont(:,9), mid) & data_cont(:,8)<rt & data_cont(:,7)==2, 11);
    e_mid(:,2) = data_cont(ismember(data_cont(:,9), mid) & data_cont(:,8)<rt & data_cont(:,7)==2, 12);
    e_crit(:,1) = data_cont(ismember(data_cont(:,9), crit) & data_cont(:,8)<rt & data_cont(:,7)==2, 11);
    e_crit(:,2) = data_cont(ismember(data_cont(:,9), crit) & data_cont(:,8)<rt & data_cont(:,7)==2, 12);
    e_ot(:,1) = data_ot(data_ot(:,8)<rt & data_ot(:,7)==2, 11);
    e_ot(:,2) = data_ot(data_ot(:,8)<rt & data_ot(:,7)==2, 12);

    mean_ot_e = mean(e_ot);
    mean_crit_e = mean(e_crit);
    mean_mid_e = mean(e_mid);
    mean_first_e = mean(e_first);

    std_ot_e = std(e_ot);
    std_crit_e = std(e_crit);
    std_mid_e = std(e_mid);
    std_first_e = std(e_first);

    length_ot_e = length(e_ot);
    length_crit_e = length(e_crit);
    length_mid_e = length(e_mid);
    length_first_e = length(e_first);

    ste_ot_e = std_ot_e./sqrt(length_ot_e);
    ste_crit_e = std_crit_e./sqrt(length_crit_e);
    ste_mid_e = std_mid_e./sqrt(length_mid_e);
    ste_first_e = std_first_e./sqrt(length_first_e);


    %two way anova
    %{
    interaction = 1;
    
    if interaction == 1
        y = [c_first; c_mid; c_crit; c_ot; e_first; e_mid; e_crit; e_ot];
        accuracy = [ones(size([c_first; c_mid; c_crit; c_ot])); repmat(2, size([e_first; e_mid; e_crit; e_ot]))];
        training_stage = [ones(size(c_first)); repmat(2,size(c_mid)); repmat(3,size(c_crit)); repmat(4,size(c_ot)); ones(size(e_first)); repmat(2,size(e_mid)); repmat(3,size(e_crit)); repmat(4,size(e_ot))];
        group = {training_stage accuracy};

        [~, t, ~, ~] = anovan(y, group, 'continuous', 1, 'model',2, 'sstype',3','varnames', strvcat('learning', 'accuracy'), 'display', 'off');

    else
        y = [c_first; c_mid; c_crit; c_ot];
        training_stage = [ones(size(c_first)); repmat(2,size(c_mid)); repmat(3,size(c_crit)); repmat(4,size(c_ot))];
        group = {training_stage};

        [~, t, ~, ~] = anovan(y, group, 'continuous', 1, 'model',2, 'sstype',2', 'display', 'off');
    end
    
    

    %load output
    fvals(i) = t{4,6};
    %}
    
end

%figure
if iterations == 1
    
    %{
    if interaction == 1
        [p, t, stats, terms] = anovan(y, group,'continuous', logical([1 0]), 'model',2, 'sstype',3','varnames', strvcat('learning', 'accuracy'), 'display', 'on');
    else
        [p, t, stats, terms] = anovan(y, group, 'continuous', 1, 'sstype',2', 'display', 'on');
    end
    %}
    
    
    figure
    hold on


    emeans_ftr = [mean_first_e(1) mean_mid_e(1) mean_crit_e(1) mean_ot_e(1)];
    emeans_not = [mean_first_e(2) mean_mid_e(2) mean_crit_e(2) mean_ot_e(2)];
    
    ste_emeans_ftr = [ste_first_e(1) ste_mid_e(1) ste_crit_e(1) ste_ot_e(1)];
    ste_emeans_not = [ste_first_e(2) ste_mid_e(2) ste_crit_e(2) ste_ot_e(2)];
    
        h2 = errorbar(1:4, emeans_ftr, ste_emeans_ftr, 'r-', 'linewidth', 2.0);
        h4 = errorbar(1:4, emeans_not, ste_emeans_not, 'r--', 'linewidth', 2.0);
   

    
    means_ftr = [mean_first(1) mean_mid(1) mean_crit(1) mean_ot(1)]
    means_not = [mean_first(2) mean_mid(2) mean_crit(2) mean_ot(2)]
    
    ste_means_ftr = [ste_first(1) ste_mid(1) ste_crit(1) ste_ot(1)];
    ste_means_not = [ste_first(2) ste_mid(2) ste_crit(2) ste_ot(2)];
    
        h1 = errorbar(1:4, means_ftr, ste_means_ftr, 'k-', 'linewidth', 2.0);
        h3 = errorbar(1:4, means_not, ste_means_not, 'k--', 'linewidth', 2.0);


    hold off

    box 'off'

    axis([0.5, 4.5, -.5, .5])
    axis 'auto y'
    set(gca,'XTick', 1:1:4, 'fontsize', 20)
    set(gca, 'XTickLabel',{'First','Mid', 'Crit', 'OT'}, 'fontsize', 12)
    set(gca, 'Ticklength', [0 0])
    ylabel('Trajectory Simulation', 'fontsize', 20)
    xlabel('Training Stage', 'fontsize', 20)
    legend([h1, h2, h3, h4],'Correct Ftr', 'Error Ftr','Correct Not', 'Error Not', 'location', 'northeastoutside');
    %}
    
    
    
    %figure; hold on
    
    
    
end
end
