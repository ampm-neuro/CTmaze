function [mean_bin_rates, carryover_start, times_in_all_bins, sect_bins, rate_matrix, smoothed_rates_out, trial_type_idx] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusters)

%function [mean_bin_rates, carryover_start, times_in_all_bins, sect_bins, left_bin_means, right_bin_means] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusters, min_visit, eptrials_origin)
%need average firing rate of every single cell at every single point along
%track.
%
%1. bin track
%2. get firing rates from each cell in each bin
%3. find average rates for left and right trials

traj_plots = 0;
trial_type_idx = [];

if traj_plots == 1
    figure; hold on
end

min_visit = 2;

%~ALL
len_hi_bnd = [350 450 450 500]; %~ALL
traj_lens = [145 200 250 320]; %prototypical lengths ??
%len_hi_bnd = [220 300 350 500];%~ALL
%traj_lens = [125 200 250 320]; %prototypical lengths ??


%TOO GENEROUS TBH
%len_hi_bnd = [155 220 281 370];%
%traj_lens = [115 200 250 320]; %prototypical lengths

%overly generous USED
%len_hi_bnd = [135 200 261 350];%75%
%traj_lens = [100 191 241 312]; %prototypical lengths

%generous
%len_hi_bnd = [120 195 250 340];%50%
%traj_lens = [94 188 236 303]; %prototypical lengths

%moderate
%len_hi_bnd = [112 193 241 328];
%traj_lens = [94 187 230 303];

%strict
%len_hi_bnd = [104 190 232 315];%30%
%traj_lens = [94 186 225 303]; %prototypical lengths

%strict fig
%len_hi_bnd = [104 190 241 325];%30%
%traj_lens = [94 186 225 303]; %prototypical lengths

sect_bins = round(bins*(traj_lens./sum(traj_lens)));
bins = sum(sect_bins); %report
cum_sect_bins = cumsum(sect_bins);

%split up start
%carryover_start = ceil(sect_bins(1)*(2/3));
carryover_start = ceil(sect_bins(1));
true_start = sect_bins(1)-carryover_start;

%overall bin ranges
overall_bins{1} = 1:cum_sect_bins(1);
overall_bins{2} = cum_sect_bins(1)+1:cum_sect_bins(2);
overall_bins{3} = cum_sect_bins(2)+1:cum_sect_bins(3);
overall_bins{4} = cum_sect_bins(3)+1:cum_sect_bins(4);

%lower upper
bin_times = nan(sum(sect_bins),2);

%(overall_bin, idices and cells, trials w/o probe))
rate_matrix = nan(bins, length(clusters)+4, max(eptrials(:,5))-1);

%all times in bins
times_in_all_bins = nan(bins, max(eptrials(:,5))-1);


%find firing rates in bins for each of four sections: start, stem, choice, return
%

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
      
    %precalculate
    num_trials = max(eptrials(:,5)-1);
    %figure; hold on;
    rew_y = rewards(eptrials);
    
    
    %if traj_plots == 1
    %    close gcf
    %end
    
    rew_y = rew_y(1,2);

    %way to prevent repeat bins
    hold_high_bintime = 0;
    
    %for each trial
    for trl = 2:max(eptrials(:,5))
        
        %trial info
        trial = trl-1;
        trl_type = mode(eptrials(eptrials(:,5)==trl, 7));
            trial_type_idx = [trial_type_idx; trl_type];
        trl_accu = mode(eptrials(eptrials(:,5)==trl, 8));
        
        %set indices
        rate_matrix(:, 1:3, trl-1) = repmat([trial trl_type trl_accu], bins, 1);
        
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
        cum_stem  = linelength(pos_stem(:, 2:3));
        cum_choice = linelength(pos_choice(:, 2:3));
        cum_return = linelength(pos_return(:, 2:3));
        
        
        %START SECTION bin time bounds
            %ballistic check
            if  cum_start(end) < len_hi_bnd(1)
                
                %how far the rat travels in each bin (theoretically)
                %bin_len = traj_lens(1)/sect_bins(1);
                bin_len = cum_start(end)/sect_bins(1); %actual
                
                %relevant times
                nonfirst_bin_times = pos_start(2:end, 1);
                
                %for each local bin
                for b = 1:sect_bins(1)
                    
                    %overall bin number
                    o_bin = overall_bins{1}(b);
                    
                    %closest actual distance to the theoretical distance
                    [~, idx_min] = min(abs(cum_start - repmat(b*bin_len, size(cum_start)))); 
                                        
                    %session time corresponding to that distance traveled
                    %along this trajectory
                    bin_times(o_bin,2) = nonfirst_bin_times(idx_min, 1);%upper time on bin

                    
                    %prevent repeat bin time bounds
                    if bin_times(o_bin,2) <= hold_high_bintime

                        if isempty(min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1))))
                            break
                        end
                        
                        bin_times(o_bin,2) = min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1)));
                        hold_high_bintime = bin_times(o_bin,2);
                    else
                        hold_high_bintime = nonfirst_bin_times(idx_min, 1);
                    end
                    

                        %deal with intricacies of first bin
                        if b == 1
                            bin_times(o_bin,1) = pos_start(1,1); %first lower bin time
                        else
                            bin_times(o_bin,1) = bin_times(o_bin-1,2); %lower bin times
                        end

                    %rates
                    time_in_bin = (bin_times(o_bin, 2) - bin_times(o_bin, 1)); %seconds
                    %times_in_all_bins = [times_in_all_bins; time_in_bin];
                    times_in_all_bins(o_bin, trial) = time_in_bin;
                    bin_idx = eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<bin_times(o_bin, 2); %bin time bounds
                    
                    %firing rates and orientation check
                    rates = (histc(eptrials(bin_idx, 4), clusters)./time_in_bin)';%rate
                    %rates = histc(eptrials(bin_idx, 4), clusters)';%count
                    if size(rates,1)>size(rates,2)
                        rates = rates';
                    end

                    
                    if isnan(rates)
                        cur_bin = b
                        spkcount = histc(eptrials(bin_idx, 4), clusters)
                        dwell_times = time_in_bin
                    end
                    
                    rate_matrix(o_bin, 4:end, trl-1) = [1 rates]; %sect idx and rates

                    %plot (more complicated to deal with rotated bins)
                    if traj_plots == 1 && trl_accu == 1
                        if trl_type == 1
                            
                            if ismember(b, 1:carryover_start)
                                if ~rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'r')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'color', [255 215 0]./255)
                                end
                            else
                                if ~rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'g')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'b')
                                end
                            end

                        else
                            
                            if ismember(b, 1:carryover_start)
                            
                                if ~rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'g')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'b')
                                end

                            else
                                
                                if ~rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'r')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'color', [255 215 0]./255)
                                end
                                
                            end
                        end
                    end
                    
                end
            end
            
        %STEM SECTION bin time bounds
            %ballistic check
            if cum_stem(end) < len_hi_bnd(2)
                
                %how far the rat travels in each bin
                %bin_len = traj_lens(2)/sect_bins(2);
                bin_len = cum_stem(end)/sect_bins(2); %actual
                
                %relevant times
                nonfirst_bin_times = pos_stem(2:end, 1);
                
                for b = 1:sect_bins(2)
                    
                    %overall bin number
                    o_bin = overall_bins{2}(b);
                    
                    %closest actual distance to the theoretical distance
                    [~, idx_min] = min(abs(cum_stem - repmat(b*bin_len, size(cum_stem)))); 
                    
                    %session time corresponding to that distance traveled
                    %along this trajectory
                    bin_times(o_bin,2) = nonfirst_bin_times(idx_min, 1);%upper time on bin
                    
                    if b == 1
                        bin_times(o_bin,1) = pos_stem(1,1); %first lower bin time
                    else
                        bin_times(o_bin,1) = bin_times(o_bin-1,2);%lower bin times
                    end
                    
                    
                    %prevent repeat bin time bounds
                    if bin_times(o_bin,2) <= hold_high_bintime

                        if isempty(min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1))))
                            break
                        end
                        
                        bin_times(o_bin,2) = min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1)));
                        hold_high_bintime = bin_times(o_bin,2);
                    else
                        hold_high_bintime = nonfirst_bin_times(idx_min, 1);
                    end
                    
                    %rates
                    time_in_bin = (bin_times(o_bin, 2) - bin_times(o_bin, 1)); %seconds
                    times_in_all_bins(o_bin, trial) = time_in_bin;
                    bin_idx = eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<bin_times(o_bin, 2); %bin time bounds
                    
                    %firing rates and orientation check
                    rates = (histc(eptrials(bin_idx, 4), clusters)./time_in_bin)';
                    %rates = histc(eptrials(bin_idx, 4), clusters)';%count
                    
                    if size(rates,1)>size(rates,2)
                        rates = rates';
                    end
                    rate_matrix(o_bin, 4:end, trl-1) = [2 rates]; %spikes counts / time_in_bin
                    
                    %plot
                    if traj_plots == 1 && trl_accu == 1
                            if trl_type ==1
                                if rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'g')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'b')
                                end

                            else
                                if rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'r')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'color', [255 215 0]./255)
                                end
                            end
                    end
                end
            end
            
        %CHOICE/TRAJS SECTION bin time bounds
            %ballistic check
            if cum_choice(end) < len_hi_bnd(3)
                
                %how far the rat travels in each bin
                %bin_len = traj_lens(3)/sect_bins(3);
                bin_len = cum_choice(end)/sect_bins(3); %actual
                
                %relevant times
                nonfirst_bin_times = pos_choice(2:end, 1);
                
                for b = 1:sect_bins(3)
                    
                    %overall bin number
                    o_bin = overall_bins{3}(b);
                    
                    %closest actual distance to the theoretical distance
                    [~, idx_min] = min(abs(cum_choice - repmat(b*bin_len, size(cum_choice)))); 
                    
                    %session time corresponding to that distance traveled
                    %along this trajectory
                    bin_times(o_bin,2) = nonfirst_bin_times(idx_min, 1);%upper time on bin
                    
                    if b == 1
                        bin_times(o_bin,1) = pos_choice(1,1); %first lower bin time
                    else
                        bin_times(o_bin,1) = bin_times(o_bin-1,2);%lower bin times
                    end
                    
                   %prevent repeat bin time bounds
                    if bin_times(o_bin,2) <= hold_high_bintime

                        if isempty(min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1))))
                            break
                        end
                        
                        bin_times(o_bin,2) = min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1)));
                        hold_high_bintime = bin_times(o_bin,2);
                    else
                        hold_high_bintime = nonfirst_bin_times(idx_min, 1);
                    end
                    
                    %rates
                    time_in_bin = (bin_times(o_bin, 2) - bin_times(o_bin, 1)); %seconds
                    times_in_all_bins(o_bin, trial) = time_in_bin;
                    bin_idx = eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<bin_times(o_bin, 2); %bin time bounds
                    
                    %firing rates and orientation check
                    rates = (histc(eptrials(bin_idx, 4), clusters)./time_in_bin)';
                    %rates = histc(eptrials(bin_idx, 4), clusters)';%count
                    if size(rates,1)>size(rates,2)
                        rates = rates';
                    end
                    rate_matrix(o_bin, 4:end, trl-1) = [3 rates]; %spikes counts / time_in_bin

                    %plot                    
                    if traj_plots == 1 && trl_accu == 1
                            if trl_type ==1
                                if rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'g')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'b')
                                end

                            else
                                if rem(b,2)==1
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'r')
                                else
                                    hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'color', [255 215 0]./255)
                                end
                            end
                    end
                end
            end
            
             
        %RETURNS SECTION bin time bounds
            %ballistic check
            if cum_return(end) < len_hi_bnd(4)

                %how far the rat travels in each bin
                %bin_len = traj_lens(4)/sect_bins(4);
                bin_len = cum_return(end)/sect_bins(4); %actual
                
                %relevant times
                nonfirst_bin_times = pos_return(2:end, 1);
                
                for b = 1:sect_bins(4)
                    
                    %overall bin number
                    o_bin = overall_bins{4}(b);
                    
                    %closest actual distance to the theoretical distance
                    [~, idx_min] = min(abs(cum_return - repmat(b*bin_len, size(cum_return)))); 
                    
                    %session time corresponding to that distance traveled
                    %along this trajectory
                    bin_times(o_bin,2) = nonfirst_bin_times(idx_min, 1);%upper time on bin
                    
                    if b == 1
                        bin_times(o_bin,1) = pos_return(1,1); %first lower bin time
                    else
                        bin_times(o_bin,1) = bin_times(o_bin-1,2);%lower bin times
                    end
                    
                    %prevent repeat bin time bounds
                    if bin_times(o_bin,2) <= hold_high_bintime

                        if isempty(min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1))))
                            break
                        end
                        
                        bin_times(o_bin,2) = min(nonfirst_bin_times(nonfirst_bin_times > nonfirst_bin_times(idx_min, 1)));
                        hold_high_bintime = bin_times(o_bin,2);
                    else
                        hold_high_bintime = nonfirst_bin_times(idx_min, 1);
                    end
                    
                    %rates
                    time_in_bin = (bin_times(o_bin, 2) - bin_times(o_bin, 1)); %seconds
                    times_in_all_bins(o_bin, trial) = time_in_bin;
                    bin_idx = eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<bin_times(o_bin, 2); %bin time bounds
                    
                    %firing rates and orientation check
                    rates = (histc(eptrials(bin_idx, 4), clusters)./time_in_bin)';
                    %rates = histc(eptrials(bin_idx, 4), clusters)';%count
                    if size(rates,1)>size(rates,2)
                        rates = rates';
                    end
                    rate_matrix(o_bin, 4:end, trl-1) = [4 rates]; %spikes counts / time_in_bin

                    %plot
                    if traj_plots == 1 && trl_accu == 1 
                        if trl_type ==1
                            if rem(b,2)==1
                                hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'g')
                            else
                                hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'b')
                            end

                        else
                            if rem(b,2)==1
                                hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'r')
                            else
                                hold on; plot(eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 2), eptrials(eptrials(:,1)>=bin_times(o_bin, 1) & eptrials(:,1)<=bin_times(o_bin, 2), 3), 'color', [255 215 0]./255)
                            end
                        end
                    end
                end
            end
            
            %reset for next trial
            bin_times = nan(size(bin_times));
    end
    
    %find average rates in each bin
    %min_visit = 2;
    
    %reshape to 2d
    %rate_matrix_mis_hold = rate_matrix;
    rate_matrix_rshp = reshape(permute(rate_matrix, [1 3 2]), bins*(max(eptrials(:,5))-1), length(clusters)+4);
    
    %remove nans
    rate_matrix_rshp = rate_matrix_rshp(~isnan(rate_matrix_rshp(:,end)), :);
    
    %preallocate    
    mean_bin_rates = nan(cum_sect_bins(end), length(clusters), 2);
    
    %if enough section visits
    sect_len_check = unique(rate_matrix_rshp(:,[1 2 3 4]), 'rows');
    
    %trl pages indx
    trl_pages_idx = mode(squeeze(rate_matrix(:,1,:)));

    
    for sect = 1:4

        %number of L and R trials with good (including correct) section visits
        lefts = sect_len_check(sect_len_check(:,2)==1 & sect_len_check(:,3)==1 & sect_len_check(:,4)==sect, 1);
        rights = sect_len_check(sect_len_check(:,2)==2 & sect_len_check(:,3)==1 & sect_len_check(:,4)==sect, 1);
        %incl errors:
        %lefts = sect_len_check(sect_len_check(:,2)==1 & sect_len_check(:,4)==sect, 1);
        %rights = sect_len_check(sect_len_check(:,2)==2 & sect_len_check(:,4)==sect, 1);

        %whole session required
        %{
        if length(lefts) >= min_visit && length(rights) >= min_visit
            left_bin_means = mean(rate_matrix(rate_matrix(:, 4, lefts(1))==sect, 5:end, ismember(trl_pages_idx, lefts)),3);
            right_bin_means = mean(rate_matrix(rate_matrix(:, 4, rights(1))==sect, 5:end, ismember(trl_pages_idx, rights)),3);
            mean_bin_rates(overall_bins{sect},:,2) = right_bin_means;
            mean_bin_rates(overall_bins{sect},:,1) = left_bin_means;
        else
            %if insufficient visits
            mean_bin_rates =[];
            return
        end
        %}

        %max data
        %
        if length(lefts) >= min_visit

            %rand 3 only
            %perm_l = lefts(randperm(length(lefts)));
            %lefts = perm_l(1:3);            
            left_bin_means = nanmean(rate_matrix(rate_matrix(:, 4, lefts(1))==sect, 5:end, ismember(trl_pages_idx, lefts)),3);
            mean_bin_rates(overall_bins{sect},:,1) = left_bin_means;
        else
            %if insufficient visits, nans
            mean_bin_rates(overall_bins{sect},:,1) = nan(size(mean_bin_rates(overall_bins{sect},:,1)));
        end

        if length(rights) >= min_visit

            %rand 3 only
            %perm_r = rights(randperm(length(rights)));
            %rights = perm_r(1:3);

            right_bin_means = nanmean(rate_matrix(rate_matrix(:, 4, rights(1))==sect, 5:end, ismember(trl_pages_idx, rights)),3);
            
            mean_bin_rates(overall_bins{sect},:,2) = right_bin_means;
        else
            %if insufficient visits, nans
            mean_bin_rates(overall_bins{sect},:,2) = nan(size(mean_bin_rates(overall_bins{sect},:,2)));
        end
        %}
    end
    
    set(gca,'TickLength',[0, 0]); axis square; axis off
    %CLOSE FIGURE
    close
    
    
    
    
    %plot nitz line graphs (can comment out)
    % ONLY PLOTS FIRST CLUST, TO GET PLOTS FOR ALL RUN THIS FOR EACH CELL
    
    %eliminate error trials 
    trl_accuracy = mode(rate_matrix(:,3,:));
    trl_type = mode(rate_matrix(:,2,:));
    arb_trl_num = 1:length(trl_type);

    %preallocate
    count_left = 0;
    count_right = 0;
    high_val = 0;
    smoothed_rates_left = nan(sum(trl_type==1 & trl_accuracy==1), cum_sect_bins(end));
    smoothed_rates_right = nan(sum(trl_type==2 & trl_accuracy==1), cum_sect_bins(end));
    
    %
    %plot lefttrial lines
    for it = arb_trl_num
        
         %CORRECT TRIALS ONLY?
        if trl_accuracy(it) == 2
            %continue
        end
        
        %smooth firing rates (instantaneous rates)
        smoothed_rates = nanfastsmooth(rate_matrix(:, 5, it), 5);
        %smoothed_rates = nanfastsmooth(smoothed_rates, 2);
        
        %assign by trial type
        if trl_type(it) == 1
            count_left = count_left+1;
            smoothed_rates_left(count_left, :) = smoothed_rates;
        elseif trl_type(it) == 2
            count_right = count_right+1;
            smoothed_rates_right(count_right, :) = smoothed_rates;
        end
        smoothed_rates_out = {{smoothed_rates_left} {smoothed_rates_right}};
        
        %find maximum rate (for plotting)
        local_max = max(smoothed_rates);
        if local_max > high_val
            high_val = local_max;
        end
    end

    %{
    try
        
        figure('units','normalized','position',[.2 .2 .26 .26]); hold on;
        %plot lefts
        %figure; hold on
        subplot(2, 8, 1:6); hold on; axis([0 cum_sect_bins(end) 0 1.1*high_val])
        %title([num2str(clusters) ' lefts'])
        for itl = 1:size(smoothed_rates_left,1)
            plot(smoothed_rates_left(itl,:), 'color', [.7 .7 .7])
        end
        sml = nanfastsmooth(nanmean(smoothed_rates_left), 3);
        plot(sml, 'k', 'LineWidth', 3)
        %plot section boundaries
        for is = 1:length(cum_sect_bins)-1
            plot([cum_sect_bins(is) cum_sect_bins(is)], [0, 1.1*high_val], 'r')
        end
        xlim([0 bins+1])
        set(gca,'TickLength',[0, 0]); box off
        dasx = 35/(1.1*high_val);
        dasy = 1;
        daspect([dasx   dasy    1.0000])
        ylabel('left trial rates (Hz)')

        %plot rights
        %figure; hold on;
        subplot(2, 8, 9:14); hold on; axis([0 cum_sect_bins(end) 0 1.1*high_val])
        %title([num2str(clusters) ' rights'])
        for itr = 1:size(smoothed_rates_right,1)
            plot(smoothed_rates_right(itr,:), 'color', [.7 .7 .7])
        end
        smr = nanfastsmooth(nanmean(smoothed_rates_right), 3);
        plot(smr, 'k', 'LineWidth', 3)
        %plot section boundaries
        for is = 1:length(cum_sect_bins)-1
            plot([cum_sect_bins(is) cum_sect_bins(is)], [0, 1.1*high_val], 'r')
        end
        xlim([0 bins+1])
        set(gca,'TickLength',[0, 0]); box off
        dasx = 35/(1.1*high_val);
        dasy = 1;
        daspect([dasx   dasy    1.0000])
        ylabel('right trial rates (Hz)')
    
    catch
    end
  %}
    
    
    %plot heatmap
    %{
    bins = 50;
    [at_l] = smooth2a(trialbased_heatmap_LR(eptrials, clusters, bins, 9, .1, 1, 0),1);
    [at_r] = smooth2a(trialbased_heatmap_LR(eptrials, clusters, bins, 9, .1, 2, 0),1);
    %figure;
    max_smoothed_rate = max([max(sml) max(smr)]);
    %subplot(1,4,1:2); 
                                                                                                                                                                                                                                                                ot(2, 8, 7:8);
    imagesc(at_l); 
        caxis([0 max_smoothed_rate]); colorbar
        %title([num2str(clusters) ' lefts']); 
        xlim([0 floor(bins*.7)]); 
        axis off; %axis square;
        colormap jet
        daspect([17.5000   18.0000    1.0000])
        
    %subplot(1,4,3:4); 
    subplot(2, 8, 15:16);
    imagesc(at_r); 
        caxis([0 max_smoothed_rate]); colorbar 
        %title([num2str(clusters) ' rights']); 
        xlim([ceil(bins*.3) bins]); 
        axis off; %axis square;
        colormap jet
        daspect([18.000   17.3000    1.0000])
        
     %}   
     

end