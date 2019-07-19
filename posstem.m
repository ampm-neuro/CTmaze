function [trialxpos, mean_stem_diff, vel_trls, percent_correct] = posstem(eptrials, stem_runs)
%posplotstem (eptrials) is a script that (1) plots the rats stem locations (in green and blue) from the X and Y
%vectors within the pos matrix and (2) plots x pos on a line with error bars for each trial type with firing rate
%on the y axis and stem section on the x axis.
%
%eptrials is a matrix output by the function 'trials'


all_trl = 2:max(eptrials(:,5));

trialbysect_idx = reshape(1:max(eptrials(:,5))*4, 4, max(eptrials(:,5)))';

%
grn=[52 153 70]./255;
blu=[46 49 146]./255;
smooth_factor = 15;

XYLR = rewards(eptrials); hold on;

XYLR = mean(XYLR);

comx = XYLR(1);
comy = XYLR(2)-119.2466;


for trl = 2:max(eptrials(:,5))
    
    
     %& eptrials(:,1)>=stem_runs(trl, 1) & eptrials(:,1)<=stem_runs(trl, 2)
   
    if mode(eptrials(eptrials(:,5)==trl, 8))==1 && mode(eptrials(eptrials(:,5)==trl, 7))==1
        
        a=eptrials(eptrials(:,5)==trl & eptrials(:,2)>(comx-50) & eptrials(:,2)<(comx+50) & eptrials(:,3)>(comy-200) & eptrials(:,3)<(comy+200), 2);
        b=eptrials(eptrials(:,5)==trl & eptrials(:,2)>(comx-50) & eptrials(:,2)<(comx+50) & eptrials(:,3)>(comy-200) & eptrials(:,3)<(comy+200), 3);
        %this plot is HARD CODED to remove pos data points from the end of each
        %trial that, for some reason, occur back in the start area.
        if stem_runs(trl, 3)<2            
            plot(smooth(a(1:(length(a)-6)), smooth_factor),smooth(b(1:(length(b)-6)), smooth_factor), 'Color', grn, 'LineWidth', 0.5, 'LineStyle', '-')
        end
    elseif mode(eptrials(eptrials(:,5)==trl, 8))==1 && mode(eptrials(eptrials(:,5)==trl, 7))==2
        
        a=eptrials(eptrials(:,5)==trl & eptrials(:,2)>(comx-50) & eptrials(:,2)<(comx+50) & eptrials(:,3)>(comy-200) & eptrials(:,3)<(comy+200), 2);
        b=eptrials(eptrials(:,5)==trl & eptrials(:,2)>(comx-50) & eptrials(:,2)<(comx+50) & eptrials(:,3)>(comy-200) & eptrials(:,3)<(comy+200), 3);
        %this plot is HARD CODED to remove pos data points from the end of each
        %trial that, for some reason, occur back in the start area.
        if stem_runs(trl, 3)<2
            plot(smooth(a(1:(length(a)-6)), smooth_factor),smooth(b(1:(length(b)-6)), smooth_factor), 'Color', blu, 'LineWidth', 0.5, 'LineStyle', '-')
        end
    end
    hold on
end

axis equal
stem(eptrials);
%}


%CALCULATING trialxpos

%zeros(trial, L/R-type, section)
trialxpos = zeros((max(eptrials(:,5))-1)*4, 4);


%determine firing rate and trialtype for each trial
for t = 1:(max(eptrials(:,5))-1)

    trl = all_trl(t);
    
    type = mode(eptrials(eptrials(:, 5)==trl, 7));
    
    for section = 1:4

            trialxpos(trialbysect_idx(t, section), 1) = mean(eptrials(eptrials(:, 5)==trl & eptrials(:,9)==section & eptrials(:,1)>stem_runs(trl,1) & eptrials(:,1)<stem_runs(trl,2), 2));
            trialxpos(trialbysect_idx(t, section), 2) = section; %1:8
            trialxpos(trialbysect_idx(t, section), 3) = type; %L/R
            trialxpos(trialbysect_idx(t, section), 4) = mode(eptrials(eptrials(:,5)==trl,8)); %accuracy

    end
end

% absolute difference between mean positions on right and left trials (at that section)
% then averaged across sections

for section = 1:4
    idx = trialxpos(:,2)==section & trialxpos(:,4)==1;
    mean_stem_diff(section) = abs(mean(trialxpos(idx & trialxpos(:,3)==1,1)) - mean(trialxpos(idx & trialxpos(:,3)==2,1)));
end
mean_stem_diff = mean(mean_stem_diff);

corr_err = []; 
for trial = unique(eptrials(:,5))'
    corr_err = [corr_err; mode(eptrials(eptrials(:,5)==trial,8))];
end

mean_stem_veloc = 1.2./stem_runs(corr_err==1 & stem_runs(:,3)<1.25, 3);
mean_stem_veloc = mean(mean_stem_veloc);



%old velocity method
velocity_column = vid_velocity(eptrials);
sr_accept = stem_runs(corr_err==1 & stem_runs(:,3)<1.25, :);
vel_trls = nan(size(sr_accept,1),1);
for i = 1:size(sr_accept,1)
    vel_trls(i) = nanmean(velocity_column(eptrials(:,1)>sr_accept(i, 1) & eptrials(:,1)<sr_accept(i, 2))); %trial veloc
end
vel_trls = mean(vel_trls);


%percent_correct = sum(corr_err==1 & stem_runs(:,3)<1.25)/sum(ismember(corr_err, [1 2]) & stem_runs(:,3)<1.25);
percent_correct = sum(corr_err==1)/sum(ismember(corr_err, [1 2]));



%{
leftmeans = zeros (1,8);
rightmeans = zeros (1,8);
leftstds = zeros (1,8);
rightstds = zeros (1,8);
leftlens = zeros (1,8);
rightlens = zeros (1,8);

for sect = 1:8

    %calculating means
    leftmeans(1,sect)=nanmean(trialxpos(trialxpos(:, 1, sect)>0, 1, sect));
    rightmeans(1,sect)=nanmean(trialxpos(trialxpos(:, 2, sect)>0, 2, sect));
    leftstds(1,sect)=nanstd(trialxpos(trialxpos(:, 1, sect)>0, 1, sect));
    rightstds(1,sect)=nanstd(trialxpos(trialxpos(:, 2, sect)>0, 2, sect));
    leftlens(1,sect)=sum(~isnan(trialxpos(trialxpos(:, 1, sect)>0, 1, sect)));
    rightlens(1,sect)=sum(~isnan(trialxpos(trialxpos(:, 2, sect)>0, 2, sect)));

    %l_means = trialxpos(trialxpos(:, 1, sect)>0, 1, sect);
    %r_means = trialxpos(trialxpos(:, 1, sect)>0, 1, sect);
    
end




left = squeeze(trialxpos(trialxpos(:, 1, sect)>0, 1, 3:6));
right = squeeze(trialxpos(trialxpos(:, 2, sect)>0, 2, 3:6));
l_means = rightmeans;
r_means = leftmeans;
    


h1=errorbar(1:8, leftmeans, leftstds./sqrt(leftlens), 'Color', grn, 'linewidth', 2.0);
hold on
h2=errorbar(1:8, rightmeans, rightstds./sqrt(rightlens), 'Color', blu, 'linewidth', 2.0);
hold off

box 'off'

axis([0.5, 8.5, 0, 100])
view(-90,90) 
%daspect([1 10 1])
axis 'auto y'
set(gca, 'XTickLabel',{'Start1','Start2', 'LowStem1', 'LowStem2', 'HighStem1', 'HighStem2', 'Choice1', 'Choice2'}, 'fontsize', 12)
ylabel('X position', 'fontsize', 20)
xlabel('Stem Section', 'fontsize', 20)
h_leg=legend([h1, h2],'Left Trials', 'Right Trials', 'location', 'northeastoutside');
%}

