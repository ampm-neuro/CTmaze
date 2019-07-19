%file = '2015-03-04_10-11-51_cont_1'
%file = '1836del2'
file = '1835/2014-09-19_15-54-14_delay_2';
subject = 1789;

[eptrials, clusters, ~, ~, ~, ~, ~, Targets, TimestampsVT, Angles] = loadnl(file, subject);

%for CSC data, see: 'loadnl'