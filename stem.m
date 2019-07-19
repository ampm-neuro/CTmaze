function stem(eptrials)


axis equal

comx = 1000;
comy = 1000;

%maze section boundaries [xlow xhigh ylow yhigh]
%stem1 = [comx-50 comx+50 comy-80 comy+12.5]; %low common stem 
%stem2 = [comx-50 comx+50 comy+12.5 comy+105]; %high common stem 


stem1 = [comx-50 comx+50 comy-80 comy-33.75];
stem2 = [comx-50 comx+50 comy-33.75 comy+12.5];
stem3 = [comx-50 comx+50 comy+12.5 comy+58.75];
stem4 = [comx-50 comx+50 comy+58.75 comy+105];
%stem5 = [comx-45 comx+45  comy comy+50];
%stem6 = [comx-45 comx+45  comy+50 comy+100];
%stem7 = [comx-45 comx+45  comy+100 comy+150];
%stem8 = [comx-45 comx+45 comy+150 comy+200];

%rectangle plots determined by above boundaries
%recstem1 = rectangle('Position', [stem1(1,1), stem1(1,3), (stem1(1,2) - stem1(1,1)),  (stem1(1,4) - stem1(1,3))]);
%recstem2 = rectangle('Position', [stem2(1,1), stem2(1,3), (stem2(1,2) - stem2(1,1)),  (stem2(1,4) - stem2(1,3))]);

recstem1 = rectangle('position', [stem1(1,1), stem1(1,3), (stem1(1,2) - stem1(1,1)),  (stem1(1,4) - stem1(1,3))]);
recstem2 = rectangle('position', [stem2(1,1), stem2(1,3), (stem2(1,2) - stem2(1,1)),  (stem2(1,4) - stem2(1,3))]);
recstem3 = rectangle('position', [stem3(1,1), stem3(1,3), (stem3(1,2) - stem3(1,1)),  (stem3(1,4) - stem3(1,3))]);
recstem4 = rectangle('position', [stem4(1,1), stem4(1,3), (stem4(1,2) - stem4(1,1)),  (stem4(1,4) - stem4(1,3))]);
%recstem5 = rectangle('position', [stem5(1,1), stem5(1,3), (stem5(1,2) - stem5(1,1)),  (stem5(1,4) - stem5(1,3))]);
%recstem6 = rectangle('position', [stem6(1,1), stem6(1,3), (stem6(1,2) - stem6(1,1)),  (stem6(1,4) - stem6(1,3))]);
%recstem7 = rectangle('position', [stem7(1,1), stem7(1,3), (stem7(1,2) - stem7(1,1)),  (stem7(1,4) - stem7(1,3))]);
%recstem8 = rectangle('position', [stem8(1,1), stem8(1,3), (stem8(1,2) - stem8(1,1)),  (stem8(1,4) - stem8(1,3))]);

end




