

timestamp = 2033894772;

sec = 2;

timelow = timestamp - 1000000*sec;
timehi = timestamp + 1000000*sec;

figure; hold on; axis([timelow timehi 0 12]);set(gca,'TickLength',[0, 0]);

csc3 = Samples_3(:, Timestamps_3 >= timelow & Timestamps_3 <= timehi); csc3 = csc3(:);
csc3 = csc3 - repmat(mean(csc3), size(csc3)); 
csc3 = csc3./std(csc3);
csc3 = csc3./(max(abs(csc3)));
csc3 = csc3 + repmat(11, size(csc3));

%time = linspace(-sec, sec, length(csc3));
time = linspace(timelow, timehi, length(csc3));

csc5 = Samples_5(:, Timestamps_5 >= timelow & Timestamps_5 <= timehi); csc5 = csc5(:);
csc5 = csc5 - repmat(mean(csc5), size(csc5)); 
csc5 = csc5./std(csc5);
csc5 = csc5./(max(abs(csc5)));
csc5 = csc5 + repmat(8, size(csc5));


plot(time, csc3, 'k')
plot(time, csc5, 'Color', [.5 .5 .5])

colors = get(groot,'DefaultAxesColorOrder');

plot(TimestampsTT_11_01(TimestampsTT_11_01 >= timelow & TimestampsTT_11_01 <= timehi), repmat(6, size(TimestampsTT_11_01(TimestampsTT_11_01 >= timelow & TimestampsTT_11_01 <= timehi))), '.', 'Markersize', 15, 'Color', colors(1,:))
plot(TimestampsTT_11_02(TimestampsTT_11_02 >= timelow & TimestampsTT_11_02 <= timehi), repmat(5.5, size(TimestampsTT_11_02(TimestampsTT_11_02 >= timelow & TimestampsTT_11_02 <= timehi))), '.', 'Markersize', 15, 'Color', colors(2,:))
plot(TimestampsTT_11_03(TimestampsTT_11_03 >= timelow & TimestampsTT_11_03 <= timehi), repmat(5, size(TimestampsTT_11_03(TimestampsTT_11_03 >= timelow & TimestampsTT_11_03 <= timehi))), '.', 'Markersize', 15, 'Color', colors(3,:))
plot(TimestampsTT_11_04(TimestampsTT_11_04 >= timelow & TimestampsTT_11_04 <= timehi), repmat(4.5, size(TimestampsTT_11_04(TimestampsTT_11_04 >= timelow & TimestampsTT_11_04 <= timehi))), '.', 'Markersize', 15, 'Color', colors(4,:))
plot(TimestampsTT_11_05(TimestampsTT_11_05 >= timelow & TimestampsTT_11_05 <= timehi), repmat(4, size(TimestampsTT_11_05(TimestampsTT_11_05 >= timelow & TimestampsTT_11_05 <= timehi))), '.', 'Markersize', 15, 'Color', colors(5,:))
plot(TimestampsTT_11_06(TimestampsTT_11_06 >= timelow & TimestampsTT_11_06 <= timehi), repmat(3.5, size(TimestampsTT_11_06(TimestampsTT_11_06 >= timelow & TimestampsTT_11_06 <= timehi))), '.', 'Markersize', 15, 'Color', colors(6,:))
plot(TimestampsTT_11_07(TimestampsTT_11_07 >= timelow & TimestampsTT_11_07 <= timehi), repmat(3, size(TimestampsTT_11_07(TimestampsTT_11_07 >= timelow & TimestampsTT_11_07 <= timehi))), '.', 'Markersize', 15, 'Color', colors(7,:))
plot(TimestampsTT_11_08(TimestampsTT_11_08 >= timelow & TimestampsTT_11_08 <= timehi), repmat(2.5, size(TimestampsTT_11_08(TimestampsTT_11_08 >= timelow & TimestampsTT_11_08 <= timehi))), '.', 'Markersize', 15, 'Color', [46 49 146]./255)
plot(TimestampsTT_11_09(TimestampsTT_11_09 >= timelow & TimestampsTT_11_09 <= timehi), repmat(2, size(TimestampsTT_11_09(TimestampsTT_11_09 >= timelow & TimestampsTT_11_09 <= timehi))), '.', 'Markersize', 15, 'Color', [46 49 146]./255)