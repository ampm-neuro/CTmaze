function [traj_corr_mtx, LMD_coords, desired_x_coord, desired_y_coord, sections] = trajectory_correlation(ts_details, ts_pmatrix, bins, folded_sections)
%trajectory_correlation(ts_details, ts_pmatrix, bins)
%
%trajectory_correlation takes as input matrices of time-sample decodes
%across the entire maze and outputs the correlation between the spatial
%position of the maximum decode and time during stem trip
%
%this is the second part to decoder_correllation_p1



%TAKE JUST THE TIME SAMPLES DESIRED FROM INPUTS
%       
    %define sessions by learning stage
    sessions = session_type(8); %session_type(min_acceptable_population_size)

    %use these to control desired inputs
    maze_section = 2:3;
    learning_stage = 2;
    accuracy = 1:2;

    %preallocate cells to hold desired time samples
    details = cell(size(ts_details));
    decodes = cell(size(ts_details));

    %iterate through input cells and load preallocated cells
    for i = 1:size(ts_details,1)
        %if desired learning stage
        if ismember(i, sessions(ismember(sessions(:,2), learning_stage), 1))
            %open current details cell
            temp_det = ts_details{i};
            %load desired timesamples from details
            details{i} = temp_det(ismember(temp_det(:,2),maze_section) & ismember(temp_det(:,4),accuracy), :);
            %open current decodes cell
            temp_dec = ts_pmatrix{i};
            %load desired timesamples (defined by temp_det) from pmatrices
            decodes{i} = temp_dec(ismember(temp_det(:,2),maze_section) & ismember(temp_det(:,4),accuracy), :,:);
        end
    end

    %remove empty cells 
    details = details(~cellfun('isempty',details));
    decodes = decodes(~cellfun('isempty',decodes));
    

%CALCULATE (session, trial, timesamp) TOTALS
%
    %number of sessions
    num_sessions = size(details,1); %total number of sessions
    num_sessions_mtx = (1:size(details,1))'; %vector of number of sessions
    %number of trials
    num_trials = 0;
    for sesh = 1:num_sessions
        num_trials = num_trials + max(details{sesh}(:,1)); %total number of trials
    end   
    num_trials_mtx = nan(num_trials, 3);
    trial_sum = 1;
    for sesh = 1:num_sessions
        running_total = trial_sum + max(details{sesh}(:,1)) -1;
        num_trials_mtx(trial_sum:running_total, 1) = sesh; %session
        num_trials_mtx(trial_sum:running_total, 2) = 1:max(details{sesh}(:,1));%trial number within session
        trial_sum = running_total;
    end
    num_trials_mtx(:, 3) = (1:num_trials)'; %overall trial
    
    
    %number of time samples
    num_timesamps = 0;
    for sesh = 1:num_sessions
        num_timesamps = num_timesamps + size(details{sesh}(:,1),1); %total number of timesamps
    end
    num_timesamps_mtx = nan(num_timesamps, 6);
    
    overall_timesamp_count = 1;
    overall_trial_count = 1;
    
    for sesh = 1:num_sessions
                
        swit = 1;
        timesample_within_trial_count = 1;
        
        for time = 1:size(details{sesh},1)
            
            num_timesamps_mtx(overall_timesamp_count, 1) = sesh; %session
            num_timesamps_mtx(overall_timesamp_count, 2) = details{sesh}(time, 1); %trial within session
            num_timesamps_mtx(overall_timesamp_count, 3) = overall_trial_count; %overall trial
            
            %timesamp within trial
            if details{sesh}(time, 1) == swit;
                num_timesamps_mtx(overall_timesamp_count, 4) = timesample_within_trial_count;
                timesample_within_trial_count = timesample_within_trial_count+1;
            else
                %when new trial reset count
                timesample_within_trial_count = 1;
                overall_trial_count = overall_trial_count + 1;
                swit = details{sesh}(time, 1);
                num_timesamps_mtx(overall_timesamp_count, 4) = timesample_within_trial_count;
                timesample_within_trial_count = timesample_within_trial_count+1;   
            end
            
            num_timesamps_mtx(overall_timesamp_count, 5) = time; %timesample within session
            
            overall_timesamp_count =  overall_timesamp_count + 1;
            
        end
    end
    
    num_timesamps_mtx(:,6) = 1:num_timesamps;%overall timesample
    
    
    
%ESTABLISH MAZE SECTIONS BASED ON BINS
%
    %establishes maze section boundaries [xlow xhigh ylow yhigh] closely based on
    %sections rectangle plots
    %
    sections = nan(10,4);
    sections(1,:) = [bins*0.3750 bins*0.6250  1 bins*.3000]; %start area 1 1
    sections(2,:) = [bins*0.3750 bins*0.6250 bins*.3000 bins*0.5375]; %low common stem 2 2
    sections(3,:) = [bins*0.3750 bins*0.6250 bins*0.5375 bins*0.7625]; %high common stem 3 3
    sections(4,:) = [bins*0.3750 bins*0.6250 bins*0.7625 bins]; %choice area 4 4
    sections(5,:) = [bins*0.2000 bins*0.3750 bins*0.7125 bins]; %approach arm left 5 5
    sections(6,:) = [bins*0.6250 bins*0.8000 bins*0.7125 bins]; %approach arm right 6 5
    sections(7,:) = [1 bins*0.2000 bins*0.7125 bins]; %reward area left 7 6
    sections(8,:) = [bins*0.8000 bins bins*0.7125 bins]; %reward area right 8 6
    sections(9,:) = [1 bins*0.3750 1 bins*0.7125]; %return arm left 9 7
    sections(10,:) = [bins*0.6250 bins 1 bins*0.7125]; %return arm right 10 7
    
    %replace out of bounds
    sections(sections<1) = 1;
    sections(sections>bins) = bins;
    sections=round(sections);
    
    %desired decoding sections
        %unfold sections
        unfold = [5 7 9;6 8 10];
        unfold_sections = unfold(:, ismember([5 6 7], folded_sections(folded_sections>4)));
        unfolded_sections = sort([folded_sections(folded_sections<5) unfold_sections(:)']);
        
        %x_coords of pmatrix
        desired_x_coord = [];
        temp_x = sections(unfolded_sections, 1:2);
        for sec = 1:size(temp_x,1)
            desired_x_coord = [desired_x_coord temp_x(sec, 1):temp_x(sec, 2)];
        end
        desired_x_coord = unique(desired_x_coord);
        
        %y_coords of pmatrix
        desired_y_coord = [];
        temp_y = sections(unfolded_sections, 3:4);
        for sec = 1:size(temp_y,1)
            desired_y_coord = [desired_y_coord temp_y(sec, 1):temp_y(sec, 2)];
        end
        desired_y_coord = unique(desired_y_coord);
        desired_y_coord = repmat(bins+1, size(desired_y_coord,1), size(desired_y_coord,2)) - desired_y_coord;



%FIND MEDIAN NUMBER OF TIME SAMPLES ACROSS ALL UNIQUE TRIAL-SESSIONs
%

%trial times
trial_times = histc(num_timesamps_mtx(:, 3), unique(num_timesamps_mtx(:, 3)));
ts_trial_lengths = trial_times(num_timesamps_mtx(:, 3)); %vector of trial lengths reported at timesample intervals

%median trial length
median_trial_time = median(trial_times);
warp_coefficients = repmat(median_trial_time, num_timesamps, 1)./ts_trial_lengths;



%FIND COORDINATES OF LOCAL MAXIMUM DECODED PIXLES
%(within specified sections)

    %coords of max
    LMD_coords = nan(num_timesamps, 5);
    count = 0;
    for sesh = 1:num_sessions
        for time = 1:size(details{sesh},1)
            count = count+1;
            
            
            temp_dec = squeeze(decodes{sesh}(time, :, :));
            [LMD_coords(count, 1), LMD_coords(count, 2)] = find(temp_dec==max(max(temp_dec(desired_y_coord, desired_x_coord))),1);
            
            %[LMD_coords(count, 1), LMD_coords(count, 2)] = find(decodes{sesh}(time, :, :)==max(max(decodes{sesh}(time, desired_y_coord, desired_x_coord))),1);
            LMD_coords(count, 3) = num_timesamps_mtx(count, 4)*warp_coefficients(count);%warped_x_corr
            LMD_coords(count, 4) = details{sesh}(time, 3);%trial type
            LMD_coords(count, 5) = details{sesh}(time, 4);%trial accuracy
        end
    end

    %LMD_coords(:, 1) = repmat(60, size(LMD_coords(:, 1), 1), size(LMD_coords(:, 1), 2)) - LMD_coords(:, 1);
    
%BUILD Y-Val MATRIX OF TRAJECTORY LOCATIONS FROM THE COORDINATES OF MAXIMUMS
%

inverse_y_sections = sections;
inverse_y_sections(:,3:4) = repmat(bins+1, size(inverse_y_sections(:,3:4),1), size(inverse_y_sections(:,3:4),2)) - inverse_y_sections(:,3:4);
inverse_y_sections(:,3:4) = [inverse_y_sections(:,4) inverse_y_sections(:,3)];

    %preallocate
    traj_corr_mtx = nan(size(LMD_coords,1), 5);

    %iterate through LMD_coords WHY ARE SOME OF THESE NEGATIVE?
    for tsamp = 1:size(LMD_coords,1)

        traj_corr_mtx(tsamp, 1) = LMD_coords(tsamp, 3);%warped_x_corr

        switch true
            
            
            
            %left approach
            case ismember(LMD_coords(tsamp, 2), inverse_y_sections(5,1):inverse_y_sections(5,2)) & ismember(LMD_coords(tsamp, 1), inverse_y_sections(5,3):inverse_y_sections(5,4))
                traj_corr_mtx(tsamp, 2) = inverse_y_sections(4,1) - LMD_coords(tsamp, 2); %how many columns outward from edge of choice section
            %left reward
            case ismember(LMD_coords(tsamp, 2), inverse_y_sections(7,1):inverse_y_sections(7,2)) & ismember(LMD_coords(tsamp, 1), inverse_y_sections(7,3):inverse_y_sections(7,4))
                traj_corr_mtx(tsamp, 2) = inverse_y_sections(4,1) - LMD_coords(tsamp, 2); %how many columns outward from edge of choice section
            %left return
            case ismember(LMD_coords(tsamp, 2), inverse_y_sections(9,1):inverse_y_sections(9,2)) & ismember(LMD_coords(tsamp, 1), inverse_y_sections(9,3):inverse_y_sections(9,4))
                traj_corr_mtx(tsamp, 2) = (inverse_y_sections(7,1) - inverse_y_sections(4,1)) + (LMD_coords(tsamp, 1) - inverse_y_sections(7,4)); %how many rows downward from edge of reward section (plus number of columns from choice to end)                %right approach    
            case ismember(LMD_coords(tsamp, 2), inverse_y_sections(6,1):inverse_y_sections(6,2)) & ismember(LMD_coords(tsamp, 1), inverse_y_sections(6,3):inverse_y_sections(6,4))
                traj_corr_mtx(tsamp, 2) = LMD_coords(tsamp, 2) - inverse_y_sections(4,2); %how many columns outward from edge of choice section
            %right reward    
            case ismember(LMD_coords(tsamp, 2), inverse_y_sections(8,1):inverse_y_sections(8,2)) & ismember(LMD_coords(tsamp, 1), inverse_y_sections(8,3):inverse_y_sections(8,4))
                traj_corr_mtx(tsamp, 2) = LMD_coords(tsamp, 2) - inverse_y_sections(4,2); %how many columns outward from edge of choice section
            %right return
            case ismember(LMD_coords(tsamp, 2), inverse_y_sections(10,1):inverse_y_sections(10,2)) & ismember(LMD_coords(tsamp, 1), inverse_y_sections(10,3):inverse_y_sections(10,4))
                traj_corr_mtx(tsamp, 2) = (inverse_y_sections(8,2) - inverse_y_sections(4,2)) + (LMD_coords(tsamp, 1) - inverse_y_sections(8,4)); %how many rows downward from edge of reward section (plus number of columns from choice to end)    
        
        end
        
        traj_corr_mtx(tsamp, 3) = LMD_coords(tsamp, 4);%trial type
        traj_corr_mtx(tsamp, 4) = LMD_coords(tsamp, 5);%trial accuracy
        
    end
    
    traj_corr_mtx(:, 2) = traj_corr_mtx(:, 2) + ones(size(traj_corr_mtx(:, 2))); %make "zero boxes away" into "the first box"
    traj_corr_mtx(:, 5) = num_timesamps_mtx(:, 3);%trial number
        


end