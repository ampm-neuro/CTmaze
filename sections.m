function sections

%maze section plots. Better if posplot or evtposplot is already be in a figure.
%FUTURE: consider coding stem y boundaries based on average stem x values 
%between trial types...



axis equal

%super conservative procedure: ask min/max at each of 10 equally spaced
%ranges. This gives four vectors: maxx(1:10) minx(1:10) maxy(1:10)
%miny(1:10)

%first and last eptrials timestamp with pos data
%firstpos = min(eptrials(isreal(eptrials(:,2)) & isreal(eptrials(:,3)),1));
%lastpos = max(eptrials(isreal(eptrials(:,2)) & isreal(eptrials(:,3)),1));

%positions = [eptrials(eptrials(:,1)>firstpos & eptrials(:,1)>lastpos & isreal(eptrials(:,2)) & isreal(eptrials(:,3)), 1) eptrials(eptrials(:,1)>firstpos & eptrials(:,1)>lastpos & isreal(eptrials(:,2)) & isreal(eptrials(:,3)), 2) eptrials(eptrials(:,1)>firstpos & eptrials(:,1)>lastpos & isreal(eptrials(:,2)) & isreal(eptrials(:,3)), 3)];


%determining common x and common y from lick detections
%rwdpos = mean(rewards(eptrials)); %[X,Y]
comx = 1000;
comy = 1000;


hold on

%plot black point at "center" of maze. This point will anchor the rectangle
%grid.
%plot(comx, comy, '.', 'Color', [0 0 0], 'markersize', 15)


%maze section boundaries [xlow xhigh ylow yhigh]
strt = [comx-50 comx+50  comy-200 comy-80]; %start area
%stem = [comx-50 comx+50 comy-80 comy+105]; %common stem
stem1 = [comx-50 comx+50 comy-80 comy+12.5]; %low common stem 
stem2 = [comx-50 comx+50 comy+12.5 comy+105]; %high common stem 
chce = [comx-50 comx+50 comy+105 comy+205]; %choice area
chceL = [comx-50 comx comy+105 comy+205]; %choice area left
chceR = [comx comx+50 comy+105 comy+205]; %choice area right
chmL = [comx+50 comx+120 comy+85 comy+205]; %approach arm left
chmR = [comx-120 comx-50 comy+85 comy+205]; %approach arm right
rwdL = [comx+120 comx+225 comy+85 comy+205]; %reward area left
rwdR = [comx-230 comx-120 comy+85 comy+205]; %reward area right
rtnL = [comx+50 comx+225 comy-200 comy+85]; %return arm left
rtnR = [comx-230 comx-50 comy-200 comy+85]; %return arm right



%rectangle plots determined by above boundaries
recstrt = rectangle('Position', [strt(1,1), strt(1,3), (strt(1,2) - strt(1,1)),  (strt(1,4) - strt(1,3))]);
%recstem = rectangle('Position', [stem(1,1), stem(1,3), (stem(1,2) - stem(1,1)),  (stem(1,4) - stem(1,3))]);
recstem1 = rectangle('Position', [stem1(1,1), stem1(1,3), (stem1(1,2) - stem1(1,1)),  (stem1(1,4) - stem1(1,3))]);
recstem2 = rectangle('Position', [stem2(1,1), stem2(1,3), (stem2(1,2) - stem2(1,1)),  (stem2(1,4) - stem2(1,3))]);
%recchce = rectangle('Position', [chce(1,1), chce(1,3), (chce(1,2) - chce(1,1)),  (chce(1,4) - chce(1,3))]);
recchceL = rectangle('Position', [chceL(1,1), chceL(1,3), (chceL(1,2) - chceL(1,1)),  (chceL(1,4) - chceL(1,3))]);
recchceR = rectangle('Position', [chceR(1,1), chceR(1,3), (chceR(1,2) - chceR(1,1)),  (chceR(1,4) - chceR(1,3))]);
recchmL = rectangle('Position', [chmL(1,1), chmL(1,3), (chmL(1,2) - chmL(1,1)),  (chmL(1,4) - chmL(1,3))]);
recchmR = rectangle('Position', [chmR(1,1), chmR(1,3), (chmR(1,2) - chmR(1,1)),  (chmR(1,4) - chmR(1,3))]);
recrwdL = rectangle('Position', [rwdL(1,1), rwdL(1,3), (rwdL(1,2) - rwdL(1,1)),  (rwdL(1,4) - rwdL(1,3))]);
recrwdR = rectangle('Position', [rwdR(1,1), rwdR(1,3), (rwdR(1,2) - rwdR(1,1)),  (rwdR(1,4) - rwdR(1,3))]);
recrtnL = rectangle('Position', [rtnL(1,1), rtnL(1,3), (rtnL(1,2) - rtnL(1,1)),  (rtnL(1,4) - rtnL(1,3))]);
recrtnR = rectangle('Position', [rtnR(1,1), rtnR(1,3), (rtnR(1,2) - rtnR(1,1)),  (rtnR(1,4) - rtnR(1,3))]);



%hold off

axis([750 1250 750 1250])
set(gca, 'Xtick',(750:50:1250), 'Ytick',(750:50:1250), 'fontsize', 10)