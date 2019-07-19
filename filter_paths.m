function [all_norm_pathlengths, included_norm_pathlengths, excluded_norm_pathlengths] = filter_paths(eptrials, stem_runs, varargin)
%plot the paths from each trial that day after filtering paths by length

if nargin > 2
    count = varargin{1};
else
    count = 0;
end
xplot_correction = 500*count;

%for visualizing distributions
all_norm_pathlengths = [];
included_norm_pathlengths = [];
excluded_norm_pathlengths = [];


%CHOSE PLOT LENGTH
    %too generous TBH
    %len_hi_bnd = [155 220 281 370];%75%
    %traj_lens = [115 200 250 320]; %prototypical lengths
    %overly generous USED
    %len_hi_bnd = [135 200 261 350];%75%
    %traj_lens = [100 191 241 312]; %prototypical lengths
    %generous
    len_hi_bnd = [120 195 250 340];%50%
    traj_lens = [94 188 236 303]; %prototypical lengths
    %moderate
    %len_hi_bnd = [112 193 241 328];
    %traj_lens = [94 187 230 303];
    %strict
    %len_hi_bnd = [104 190 232 315];%30%
    %traj_lens = [94 186 225 303]; %prototypical lengths
    %strict fig
    %len_hi_bnd = [104 190 241 325];%30%
    %traj_lens = [94 186 225 303]; %prototypical lengths


%for screening later
rew_y = mean(rewards(eptrials)); rew_y = rew_y(2);

%prename 3 figures
figure(1); %title('All Paths')
set(gca,'TickLength',[0, 0]); box off
%figure(2); title('Included Paths')
%set(gca,'TickLength',[0, 0]); box off
%figure(3); title('Excluded Paths')
%set(gca,'TickLength',[0, 0]); box off



%for each trial
for trl = 2:max(eptrials(:,5))

    %trial timingvars
    stem_ent = stem_runs(trl, 1);
    stem_ext = stem_runs(trl, 2);
    first_lick = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,1)>stem_ext, 1));
        %deal with (error) trials without a lick
        if isempty(first_lick)
            first_lick = min(eptrials(eptrials(:,5)==trl & eptrials(:,11)==6 & eptrials(:,3)<=rew_y+5 & eptrials(:,1)>stem_ext, 1));
        end
    dep_rwd = max(eptrials(eptrials(:,5)==trl & eptrials(:,3)>rew_y-10, 1));

    %times and positions along trajectories
    pos_start = eptrials(eptrials(:,5)==trl & eptrials(:,1)<=stem_ent & eptrials(:,14)==1, 1:3);
    pos_stem = eptrials(eptrials(:,1)>=stem_ent & eptrials(:,1)<=stem_ext & eptrials(:,14)==1, 1:3);
    pos_choice = eptrials(eptrials(:,1)>=stem_ext & eptrials(:,1)<=first_lick & eptrials(:,14)==1, 1:3);
    pos_return = eptrials(eptrials(:,5)==trl & eptrials(:,1)>=dep_rwd & eptrials(:,14)==1, 1:3);

    %trajectory lengths
    cum_start = linelength(pos_start(:, 2:3));
        normalized_start = cum_start(end)/traj_lens(1);
    cum_stem  = linelength(pos_stem(:, 2:3));
        normalized_stem = cum_stem(end)/traj_lens(2);
    cum_choice = linelength(pos_choice(:, 2:3));
        normalized_choice = cum_choice(end)/traj_lens(3);
    cum_return = linelength(pos_return(:, 2:3));
        normalized_return = cum_return(end)/traj_lens(4);

    %plot all routes
    figure(1); 
    hold on;
    plot(pos_start(:,2)+xplot_correction, pos_start(:,3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
    plot(pos_stem(:,2)+xplot_correction, pos_stem(:,3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
    plot(pos_choice(:,2)+xplot_correction, pos_choice(:,3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
    plot(pos_return(:,2)+xplot_correction, pos_return(:,3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
    hold off
    all_norm_pathlengths = [all_norm_pathlengths; ...
        normalized_start; normalized_stem; normalized_choice; normalized_return];
    
    %plot ballistic routes
    figure(1); 
    hold on; 
    if  cum_start(end) < len_hi_bnd(1)
        plot(pos_start(:,2)+xplot_correction, pos_start(:,3)-400, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        included_norm_pathlengths = [included_norm_pathlengths; normalized_start];
    end
    if  cum_stem(end) < len_hi_bnd(2)
        plot(pos_stem(:,2)+xplot_correction, pos_stem(:,3)-400, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        included_norm_pathlengths = [included_norm_pathlengths; normalized_stem];
    end
    if  cum_choice(end) < len_hi_bnd(3)
        plot(pos_choice(:,2)+xplot_correction, pos_choice(:,3)-400, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        included_norm_pathlengths = [included_norm_pathlengths; normalized_choice];
    end
    if  cum_return(end) < len_hi_bnd(4)
        plot(pos_return(:,2)+xplot_correction, pos_return(:,3)-400, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        included_norm_pathlengths = [included_norm_pathlengths; normalized_return];
    end
    
    %plot excluded routes
    figure(1); 
    hold on; 
    if  cum_start(end) > len_hi_bnd(1)
        plot(pos_start(:,2)+xplot_correction, pos_start(:,3)-800, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        excluded_norm_pathlengths = [excluded_norm_pathlengths; normalized_start];
    end
    if  cum_stem(end) > len_hi_bnd(2)
        plot(pos_stem(:,2)+xplot_correction, pos_stem(:,3)-800, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        excluded_norm_pathlengths = [excluded_norm_pathlengths; normalized_stem];
    end
    if  cum_choice(end) > len_hi_bnd(3)
        plot(pos_choice(:,2)+xplot_correction, pos_choice(:,3)-800, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        excluded_norm_pathlengths = [excluded_norm_pathlengths; normalized_choice];
    end
    if  cum_return(end) > len_hi_bnd(4)
        plot(pos_return(:,2)+xplot_correction, pos_return(:,3)-800, 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-');
        excluded_norm_pathlengths = [excluded_norm_pathlengths; normalized_return];
    end
end

%beautify
ylim([-10 1250]);
end



%line length function
    function [cumlen] = linelength(xypos)
    % find length of line defines by 2D position point vectors x and y.
    % xypos = eptrials(:,[2 3])
    % cumlen gives the cummulitive length at each point
    % cumlen(end) = llen
    
        d = diff(xypos);
        %llen = sum(sqrt(sum(d.*d,2)));
        cumlen = cumsum(sqrt(sum(d.*d,2)));
    end 