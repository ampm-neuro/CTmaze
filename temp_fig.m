function temp_fig(cor_traj_like_trl_cont, cor_traj_like_trl_ot, first, mid, crit)



%run time maximum
rt = 1000;%1.34;

%plot col
col = 3;


%correct means
firsts = nan(size(first));
for i = 1:length(first)
    sesh = first(i);
    firsts(i) = length(cor_traj_like_trl_cont(cor_traj_like_trl_cont(:,9)==sesh & cor_traj_like_trl_cont(:,7)==1,7))/length(cor_traj_like_trl_cont(cor_traj_like_trl_cont(:,9)==sesh,7));
end

mids = nan(size(mid));
for i = 1:length(mid)
    sesh = mid(i);
    mids(i) = length(cor_traj_like_trl_cont(cor_traj_like_trl_cont(:,9)==sesh & cor_traj_like_trl_cont(:,7)==1,7))/length(cor_traj_like_trl_cont(cor_traj_like_trl_cont(:,9)==sesh,7));
end

crits = nan(size(crit));
for i = 1:length(crit)
    sesh = crit(i);
    crits(i) = length(cor_traj_like_trl_cont(cor_traj_like_trl_cont(:,9)==sesh & cor_traj_like_trl_cont(:,7)==1,7))/length(cor_traj_like_trl_cont(cor_traj_like_trl_cont(:,9)==sesh,7));
end

ot_seshs = unique(cor_traj_like_trl_ot(:,9));
ots = nan(size(ot_seshs));
for i = 1:length(ot_seshs)
    sesh = ot_seshs(i);
    ots(i) = length(cor_traj_like_trl_ot(cor_traj_like_trl_ot(:,9)==sesh & cor_traj_like_trl_ot(:,7)==1,7))/length(cor_traj_like_trl_ot(cor_traj_like_trl_ot(:,9)==sesh,7));
end

c_first = firsts
c_mid = mids
c_crit = crits
c_ot = ots

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
ste_first = std_mid/sqrt(length_mid);

var_ot = var(c_ot);
var_crit = var(c_crit);
var_mid = var(c_mid);
var_first = var(c_first);


%anova
y = [c_first'; c_mid'; c_crit'; c_ot];
training_stage = [ones(size(c_first')); repmat(2,size(c_mid')); repmat(3,size(c_crit')); repmat(4,size(c_ot))];
group = {training_stage};
[p, t, stats, terms] = anovan(y, group, 'continuous', 1, 'sstype',2', 'display', 'on');





%figure


figure
hold on

h1 = plot(1:4, [mean_first mean_mid mean_crit mean_ot],'Color', 'k', 'linewidth', 2.0);

errorbar(1, mean_first, ste_first, 'Color', 'k', 'linewidth', 2.0);
errorbar(2, mean_mid, ste_mid, 'Color', 'k', 'linewidth', 2.0);
errorbar(3, mean_crit, ste_crit, 'Color', 'k', 'linewidth', 2.0);
errorbar(4, mean_ot, ste_ot, 'Color', 'k', 'linewidth', 2.0);



hold off

box 'off'

axis([0.5, 4.5, -.5, .5])
axis 'auto y'
set(gca,'XTick', 1:1:4, 'fontsize', 20)
set(gca, 'XTickLabel',{'First','Mid', 'Crit', 'OT'}, 'fontsize', 12)
ylabel('Percent Correct', 'fontsize', 20)
xlabel('Training Stage', 'fontsize', 20)
set(gca, 'Ticklength', [0 0])
%}

end
