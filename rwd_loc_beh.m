%rwd_location things
winfwd = 3;
winback = -1;
[~, ~, ~, ~, ~, mean_pos_21 ,mean_vel_21, mean_hd_21] = all_winpos(2, winback, winfwd, 0, 2.1);
[~, ~, ~, ~, ~, mean_pos_22 ,mean_vel_22, mean_hd_22] = all_winpos(2, winback, winfwd, 0, 2.2);
[~, ~, ~, ~, ~, mean_pos_23 ,mean_vel_23, mean_hd_23] = all_winpos(2, winback, winfwd, 0, 2.3);
[~, ~, ~, ~, ~, mean_pos_ot ,mean_vel_ot, mean_hd_ot] = all_winpos(4, winback, winfwd, 0, 4);


figure; bar([mean(mean_vel_21); mean(mean_vel_22); mean(mean_vel_23); mean(mean_vel_ot)])
hold on; errorbar([mean(mean_vel_21); mean(mean_vel_22); mean(mean_vel_23); mean(mean_vel_ot)],...
    [std(mean_vel_21)./sqrt(length(mean_vel_21)); std(mean_vel_22)./sqrt(length(mean_vel_22));...
    std(mean_vel_23)./sqrt(length(mean_vel_23)); std(mean_vel_ot)./sqrt(length(mean_vel_ot))], '.')
title velocity


figure; bar([mean(mean_hd_21); mean(mean_hd_22); mean(mean_hd_23); mean(mean_hd_ot)])
hold on; errorbar([mean(mean_hd_21); mean(mean_hd_22); mean(mean_hd_23); mean(mean_hd_ot)],...
    [std(mean_hd_21)./sqrt(length(mean_hd_21)); std(mean_hd_22)./sqrt(length(mean_hd_22)); ...
    std(mean_hd_23)./sqrt(length(mean_hd_23)); std(mean_hd_ot)./sqrt(length(mean_hd_ot))], '.')
figure;
hold on

mp = mean(mean_pos_21);
se = std(mean_pos_21);%./sqrt(length(mean_pos_21));
plot(mp(1), mp(2),'b.')
plot([-se(1) se(1)]+mp(1), [mp(2) mp(2)], 'b-') 
plot([mp(1) mp(1)], [-se(2) se(2)]+mp(2), 'b-')

mp = mean(mean_pos_22);
se = std(mean_pos_22);%./sqrt(length(mean_pos_22));
plot(mp(1), mp(2),'y.'); 
plot([-se(1) se(1)]+mp(1), [mp(2) mp(2)], 'y-'); 
plot([mp(1) mp(1)], [-se(2) se(2)]+mp(2), 'y-')

mp = mean(mean_pos_23);
se = std(mean_pos_23);%./sqrt(length(mean_pos_23));
plot(mp(1), mp(2),'r.'); 
plot([-se(1) se(1)]+mp(1), [mp(2) mp(2)], 'r-'); 
plot([mp(1) mp(1)], [-se(2) se(2)]+mp(2), 'r-')

mp = mean(mean_pos_ot);
se = std(mean_pos_ot)%./sqrt(length(mean_pos_ot));
plot(mp(1), mp(2),'g.'); 
plot([-se(1) se(1)]+mp(1), [mp(2) mp(2)], 'g-'); 
plot([mp(1) mp(1)], [-se(2) se(2)]+mp(2), 'g-')


mp = mean(mean_pos_21);
se = std(mean_pos_21);%./sqrt(length(mean_pos_21));
plot(mp(3), mp(4),'b.')
plot([-se(3) se(3)]+mp(3), [mp(4) mp(4)], 'b-') 
plot([mp(3) mp(3)], [-se(4) se(4)]+mp(4), 'b-')

mp = mean(mean_pos_22);
se = std(mean_pos_22);%./sqrt(length(mean_pos_22));
plot(mp(3), mp(4),'y.')
plot([-se(3) se(3)]+mp(3), [mp(4) mp(4)], 'y-') 
plot([mp(3) mp(3)], [-se(4) se(4)]+mp(4), 'y-')

mp = mean(mean_pos_23);
se = std(mean_pos_23);%./sqrt(length(mean_pos_23));
plot(mp(3), mp(4),'r.')
plot([-se(3) se(3)]+mp(3), [mp(4) mp(4)], 'r-') 
plot([mp(3) mp(3)], [-se(4) se(4)]+mp(4), 'r-')

mp = mean(mean_pos_ot);
se = std(mean_pos_ot);%./sqrt(length(mean_pos_ot));
plot(mp(3), mp(4),'g.')
plot([-se(3) se(3)]+mp(3), [mp(4) mp(4)], 'g-') 
plot([mp(3) mp(3)], [-se(4) se(4)]+mp(4), 'g-')
