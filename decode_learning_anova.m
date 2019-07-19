function fvals = decode_learning_anova(cor_traj_like_trl_cont, cor_traj_like_trl_ot, first, mid, crit, iterations)
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
        combined_inputs = [cor_traj_like_trl_cont; cor_traj_like_trl_ot];
        shuffled_inputs = combined_inputs(randperm(length(combined_inputs)), :);
        cor_traj_like_trl_cont = shuffled_inputs(1:length(cor_traj_like_trl_cont), :);
        cor_traj_like_trl_ot = shuffled_inputs(length(cor_traj_like_trl_cont)+1:end, :);
    end
    
    
    
    %correct means
    
    c_first = cor_traj_like_trl_cont(ismember(cor_traj_like_trl_cont(:,9), first) & cor_traj_like_trl_cont(:,8)<rt & cor_traj_like_trl_cont(:,7)==1,col);
    c_mid = cor_traj_like_trl_cont(ismember(cor_traj_like_trl_cont(:,9), mid) & cor_traj_like_trl_cont(:,8)<rt & cor_traj_like_trl_cont(:,7)==1,col);
    c_crit = cor_traj_like_trl_cont(ismember(cor_traj_like_trl_cont(:,9), crit) & cor_traj_like_trl_cont(:,8)<rt & cor_traj_like_trl_cont(:,7)==1,col);
    c_ot = cor_traj_like_trl_ot(cor_traj_like_trl_ot(:,8)<rt & cor_traj_like_trl_ot(:,7)==1,col);

    mean_ot = mean(c_ot);
    mean_crit = mean(c_crit);
    mean_mid = mean(c_mid);
    mean_first = mean(c_first);

    std_ot = std(c_ot);
    std_crit = std(c_crit);
    std_mid = std(c_mid);
    std_first = std(c_first);

    length_ot = length(c_ot);
    length_crit = length(c_crit);
    length_mid = length(c_mid);
    length_first = length(c_first);

    ste_ot = std_ot/sqrt(length_ot);
    ste_crit = std_crit/sqrt(length_crit);
    ste_mid = std_mid/sqrt(length_mid);
    ste_first = std_first/sqrt(length_first);

    var_ot = var(c_ot);
    var_crit = var(c_crit);
    var_mid = var(c_mid);
    var_first = var(c_first);



    %errror means

    e_first = cor_traj_like_trl_cont(ismember(cor_traj_like_trl_cont(:,9), first) & cor_traj_like_trl_cont(:,8)<rt & cor_traj_like_trl_cont(:,7)==2, col);
    e_mid = cor_traj_like_trl_cont(ismember(cor_traj_like_trl_cont(:,9), mid) & cor_traj_like_trl_cont(:,8)<rt & cor_traj_like_trl_cont(:,7)==2, col);
    e_crit = cor_traj_like_trl_cont(ismember(cor_traj_like_trl_cont(:,9), crit) & cor_traj_like_trl_cont(:,8)<rt & cor_traj_like_trl_cont(:,7)==2, col);
    e_ot = cor_traj_like_trl_ot(cor_traj_like_trl_ot(:,8)<rt & cor_traj_like_trl_ot(:,7)==2, col);

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

    ste_ot_e = std_ot_e/sqrt(length_ot_e);
    ste_crit_e = std_crit_e/sqrt(length_crit_e);
    ste_mid_e = std_mid_e/sqrt(length_mid_e);
    ste_first_e = std_first_e/sqrt(length_first_e);

    var_ot_e = var(e_ot);
    var_crit_e = var(e_crit);
    var_mid_e = var(e_mid);
    var_first_e = var(e_first);


    %two way anova
    
    interaction = 0;
    
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
    
    
end

%figure
if iterations == 1
    
    if interaction == 1
        [p, t, stats, terms] = anovan(y, group,'continuous', logical([1 0]), 'model',2, 'sstype',3','varnames', strvcat('learning', 'accuracy'), 'display', 'on');
    else
        [p, t, stats, terms] = anovan(y, group, 'continuous', 1, 'sstype',2', 'display', 'on');
    end
    
    
    
    figure
    hold on


    %h2 = plot(1:4, [mean_first_e mean_mid_e mean_crit_e mean_ot_e],'Color', 'r', 'linewidth', 2.0);

    %errorbar(1, mean_first_e, ste_first_e, 'Color', 'r', 'linewidth', 2.0);
    %errorbar(2, mean_mid_e, ste_mid_e, 'Color', 'r', 'linewidth', 2.0);
    %errorbar(col, mean_crit_e, ste_crit_e, 'Color', 'r', 'linewidth', 2.0);
    %errorbar(4, mean_ot_e, ste_ot_e, 'Color', 'r', 'linewidth', 2.0);

    h1 = plot(1:4, [mean_first mean_mid mean_crit mean_ot],'Color', 'k', 'linewidth', 2.0);

    errorbar(1, mean_first, ste_first, 'Color', 'k', 'linewidth', 2.0);
    errorbar(2, mean_mid, ste_mid, 'Color', 'k', 'linewidth', 2.0);
    errorbar(col, mean_crit, ste_crit, 'Color', 'k', 'linewidth', 2.0);
    errorbar(4, mean_ot, ste_ot, 'Color', 'k', 'linewidth', 2.0);


    hold off

    box 'off'

    axis([0.5, 4.5, -.5, .5])
    axis 'auto y'
    set(gca,'XTick', 1:1:4, 'fontsize', 20)
    set(gca, 'XTickLabel',{'First','Mid', 'Crit', 'OT'}, 'fontsize', 12)
    set(gca, 'Ticklength', [0 0])
    ylabel('Future Trajectory Simulation', 'fontsize', 20)
    xlabel('Training Stage', 'fontsize', 20)
%    h_leg=legend([h1, h2],'Correct', 'Error', 'location', 'northeastoutside');
    %}
end
end
