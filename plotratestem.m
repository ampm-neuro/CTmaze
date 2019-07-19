function [stem_dif stem_diff_f_output firing_output, first_trials] = plotratestem(eptrials, clusters, stem_runs, figure_on)
%plotratestem(eptrials, cell) plots a line with error bars for each trial 
%type with firing rate on the y axis and maze section on the x axis.
%
%eptrials is a matrix output by the function 'trials'
%
%cell is the sorted cluster number
%
%The center of the maze is divided into 8 sections

first_last = 1; %1 is first, 2 is last ten trials

min_first_trials = 10;
max_run_time = 1.3;

stem_runs_no_probe = stem_runs(2:end, :);

smplrt=length(eptrials(isnan(eptrials(:,4)),1))/max(eptrials(:,1));

%preallocate summary
stem_diff = nan(length(clusters), 3);
stem_diff_f_output = nan(length(clusters),2);

for c = 1:length(clusters)
    cell = clusters(c);

    if figure_on == 1
        figure
    end

    %zeros(rates, trialtype, section)
    trialrates = zeros(max(eptrials(:,5)), 3, 4);

    %at each section
    for section = 1:4

        %determine firing rate and trialtype for each trial
        for trl = 1:max(eptrials(:,5))

        %Change this between 1 for correct and 2 for error trials.    
        if mode(eptrials(eptrials(:,5)==trl,8))==1

                %how many spikes(c) occured on the section(s) on trial(trl) 
                spikes = length(eptrials(eptrials(:,4)==cell & eptrials(:,5)==trl & eptrials(:,9)==section & eptrials(:,1)>stem_runs(trl,1) & eptrials(:,1)<stem_runs(trl,2), 4));

                %how long was spent in section(s) on trial(trl)
                time = length(eptrials(eptrials(:,5)==trl & eptrials(:,9)==section & eptrials(:,1)>stem_runs(trl,1) & eptrials(:,1)<stem_runs(trl,2) & isnan(eptrials(:,4)), 1))/smplrt;

                rate = spikes/time;

                trialrates(trl, 1, section) = rate;
                trialrates(trl, 2, section) = mode(eptrials(eptrials(:,5)==trl, 7));
                trialrates(trl, 3, section) = section;

        else %NaNs for the incorrect trials.

            trialrates(trl, 1, section) = NaN;
            trialrates(trl, 2, section) = NaN;
            trialrates(trl, 3, section) = NaN;

        end
        end
    end

    
    %delete probe trial
    trialrates = trialrates(2:end, :, :);
    
    %preallocate for means
    leftmeans = zeros (1,4);
    rightmeans = zeros (1,4);
    leftstds = zeros (1,4);
    rightstds = zeros (1,4);
    leftlens = zeros (1,4);
    rightlens = zeros (1,4);

    for secti = 1:4

        %calculating means
        leftmeans(1,secti)=nanmean(trialrates(trialrates(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, secti));
        rightmeans(1,secti)=nanmean(trialrates(trialrates(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, secti));
        leftstds(1,secti)=nanstd(trialrates(trialrates(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, secti));
        rightstds(1,secti)=nanstd(trialrates(trialrates(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, secti));
        leftlens(1,secti)=sum(~isnan(trialrates(trialrates(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, secti)));
        rightlens(1,secti)=sum(~isnan(trialrates(trialrates(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, secti)));

    end

    if figure_on == 1
        grn=[52 153 70]./255;
        blu=[46 49 146]./255;
        
        %4 sectors
        h1=errorbar(1:4, leftmeans(:,1:4), leftstds(:,1:4)./sqrt(leftlens(:,1:4)), 'Color', grn, 'linewidth', 2.0);
        hold on
        h2=errorbar(1:4, rightmeans(:,1:4), rightstds(:,1:4)./sqrt(rightlens(:,1:4)), 'Color', blu, 'linewidth', 2.0);
        
        %3 sectors
        %h1=errorbar(1:3, leftmeans(:,4:6), leftstds(:,4:6)./sqrt(leftlens(:,4:6)), 'Color', grn, 'linewidth', 2.0);
        %hold on
        %h2=errorbar(1:3, rightmeans(:,4:6), rightstds(:,4:6)./sqrt(rightlens(:,4:6)), 'Color', blu, 'linewidth', 2.0);
        
        
        hold off
        box 'off'

        axis([0.5,4.5, 0, 100])
        axis 'auto y'
        set(gca, 'xtick', 1:4)
        set(gca, 'XTickLabel',{'Stem1','Stem2', 'Stem3', 'Stem4'}, 'fontsize', 12)
        ylabel('Firing Rate (Hz)', 'fontsize', 20)
        xlabel('Stem Section', 'fontsize', 20)
        h_leg=legend([h1, h2],'Left Trials', 'Right Trials', 'location', 'northeastoutside');
        title(['Cell ',num2str(cell)],'fontsize', 20)
    end

    %%%%%

    %Two-way ANOVA
    %trial type (correctL & correctR) X sector (4,5,6)
    sector_subset = trialrates(:,1:2,1:4);

    
    
    %good_stem_trials = unique(eptrials(:,5));
    %good_stem_trials = good_stem_trials(stem_runs_no_probe(:,3)<max_run_time);
    %first_trials = min([length(unique(eptrials(eptrials(:,8)==1 & eptrials(:,7) == 1 & ismember(eptrials(:,5), good_stem_trials), 5))) length(unique(eptrials(eptrials(:,8)==1 & eptrials(:,7) == 2 & ismember(eptrials(:,5), good_stem_trials), 5)))])
    %first_trials = 10;
    
    if figure_on == 3
        
        %4 sectors
        left_rates = [sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 1) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 2) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 3) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 4)];
        right_rates = [sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 1) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 2) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 3) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 4)];
        
        
        first_trials = min([length(left_rates(:,1)) length(right_rates(:,1))]);
        
        %3 sectors
        %left_rates = [sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 1) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 2) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 3)];
        %right_rates = [sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 1) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 2) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 3)];

        if c ==1
        
            L_num = length(left_rates(:,1));
            R_num = length(right_rates(:,1));
            
            if L_num < first_trials || R_num < first_trials  || first_trials < min_first_trials
                disp('too few trials. cells are forfeit.')
                num_cells = size(clusters,1)
                stem_dif = nan(num_cells, 1);
                stem_diff_f_output = nan(size(stem_dif));
                firing_output = nan(20,5);
                first_trials = min_first_trials;
                return
            end

        end
        
        first_trials = min_first_trials;
        
        if first_last == 1
            Lefts = left_rates(1:first_trials, :);
            Rights = right_rates(1:first_trials, :);
        elseif first_last == 2
            Lefts = left_rates((end-first_trials+1):end, :);
            Rights = right_rates((end-first_trials+1):end, :);
        end
        
        [p t stats] = anova2([Lefts; Rights], first_trials, 'off');
        
        firing_output = [[Lefts;Rights] [ones([first_trials,1]);repmat(2,[first_trials,1])]];
        
        stem_diff(c,:) = [p(1)<.05 p(2)<.05 p(3)<.05];

        stem_diff_f_output(c, :) = [t{3,5} t{4,5}];


    else

        %4 sectors
        %left_rates = [sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 1); sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 2); sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 3); sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 4)];
        %right_rates = [sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 1); sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 2); sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 3); sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 4)];
        
        left_rates = [sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 1) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 2) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 3) sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 4)];
        right_rates = [sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 1) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 2) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 3) sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 4)];
        
        %3 sectors
        %left_rates = [sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 1); sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 2); sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 3)];
        %right_rates = [sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 1); sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 2); sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 3)];

        first_trials = min([length(left_rates(:,1)) length(right_rates(:,1))]);
        
        
        if c ==1
        
            L_num = length(left_rates(:,1));
            R_num = length(right_rates(:,1));
            
            if L_num < first_trials || R_num < first_trials || first_trials < min_first_trials
                disp('too few trials. cells are forfeit.')
                num_cells = size(clusters,1)
                stem_dif = nan(num_cells, 1);
                stem_diff_f_output = nan(size(stem_dif));
                firing_output = nan(20,5);
                first_trials = 0;
                first_trials = min_first_trials;
                return
            end

        end
        
        first_trials = min_first_trials;
        
        if first_last == 1
            left_rates = left_rates(1:first_trials, :);
            right_rates = right_rates(1:first_trials, :);
        elseif first_last == 2
            left_rates = left_rates((end-first_trials+1):end, :);
            right_rates = right_rates((end-first_trials+1):end, :);
        end
        
        firing_output = [[left_rates;right_rates] [ones([first_trials,1]);repmat(2,[first_trials,1])]];
        
        left_rates = left_rates(:);
        right_rates = right_rates(:);
        
        
        
        %trials_nums = [length(left_rates) length(right_rates)];

        %ANOVAN input
        trial_type_grouping = [ones(size(left_rates)); repmat(2, size(right_rates))];

        %4 sectors
        %sector_grouping = [ones(size(sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 1))); repmat(2, size(sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 2))); repmat(3, size(sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 3))); repmat(4, size(sector_subset(sector_subset(:,2)==1 & stem_runs_no_probe(:,3)<max_run_time, 1, 4))); ones(size(sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 1))); repmat(2, size(sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 2))); repmat(3, size(sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 3))); repmat(4, size(sector_subset(sector_subset(:,2)==2 & stem_runs_no_probe(:,3)<max_run_time, 1, 4)))];
        sector_grouping = [ones(first_trials,1); repmat(2, first_trials,1); repmat(3, first_trials,1); repmat(4, first_trials,1); ones(first_trials,1); repmat(2, first_trials,1); repmat(3, first_trials,1); repmat(4, first_trials,1)];

        grouping_vars = {sector_grouping trial_type_grouping};

        [~, t, ~, ~] = anovan([left_rates; right_rates], grouping_vars, 'continuous', 1, 'model',2, 'sstype',3','varnames', strvcat('sector', 'trial_type'), 'display', 'off');
        
        p_val_lvl = .05;
        
        stem_diff(c,:) = [t{2,7}<p_val_lvl t{3,7}<p_val_lvl t{4,7}<p_val_lvl];
        stem_diff_f_output(c, :) = [t{3,6} t{4,6}];


    end
end

%simplify to stem dif or no

%BOTH MAIN AND INT
%stem_dif = sum(stem_diff(:, 2:3),2)>1;

%EITHER MAIN OR INT
stem_dif = sum(stem_diff(:, 2:3),2)>0;

%JUST MAIN
%stem_dif = sum(stem_diff(:, 2),2)>0;

%JUST INT
%stem_dif = sum(stem_diff(:, 3),2)>0;

end










