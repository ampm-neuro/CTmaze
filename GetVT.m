function [pos, starttime, Targets, TimestampsVT, Angles] = GetVT(filename, subject)
%GetVT(filename) takes a file path to a neurolynx .nvt (video) file and
%constructs a 4xN position matrix comprised of columns: Timestamps, X, Y, and
%head direction. The X and Y vectors are then re-written with interpolated
%data (to fill in missed elements). The position matrix, pos, is then output.
%
% Available vectors include: Timestamp, X, Y, Angle, Targets, Points, and
% Header:
%   TimestampsVT: A 1xN vector of timestamps.
%   Extracted X: A 1xN vector of the calculated X coordinate for each record.
%   Extracted Y: A 1xN vector of the calculated Y coordinate for each record.
%   Extracted Angle: A 1xN vector of the calculated head direction angle for
%                    each record. This value is in degrees.
%   Targets: A 50xN matrix of the targets found for each frame. These values
%            are encoded using the VT bitfield encoding.
%   Points: A 480xN matrix of the threshold crossings found for each frame.
%           These values are encoded using the VT bitfield encoding.
%   Header: A Mx1 vector of all the text from the Neuralynx file header, where
%           M is the number of lines of text in the header.


%ESTABLISH pos FROM NEURALYNX OUTPUT
%

%output from Nlx2MatVT_v3, the mac version of standard neuralynx extraction
%code
[TimestampsVT, X, Y, Angles, Targets, ~,~] = Nlx2MatVT_v3(filename, [1 1 1 1 1 1], 1, 1, []);

%translate outputs into pos, the begining of the position vector that is
%input into trials_III
pos = [TimestampsVT', X', Y', NaN(length(TimestampsVT), 1), zeros(length(TimestampsVT), 1), NaN(length(TimestampsVT), 2), zeros(length(TimestampsVT), 1)];


%INTERPOLATE X and Y vectors
%

%builds vector of timestamps that have associated x and y values
tfull = pos(pos(:,2)>0 & pos(:,3)>0,1);

%builds vectors of the x and y values associated with above time stamps
pfullx = pos(pos(:,2)>0 & pos(:,3)>0,2);
pfully = pos(pos(:,2)>0 & pos(:,3)>0,3);

%converts timestamp units into seconds
starttime = zeros(length(tfull(:,1)), 1);
starttime(:,1) = tfull(1,1);
tfull(:,1) = tfull(:,1) - starttime(:,1);
tfull(:,1) = tfull(:,1)./1000000;

%for the function time_and_pos
timepos = [tfull pfullx pfully];

%remove reflection-type dropped position data
scrubbed_timepos = time_and_pos(timepos, 1000, 5);
    function scrubbed_timepos = time_and_pos(timepos, too_big_origin, cum_mod)
    % time_and_pos attempts to correct position data by removing spurious
    % points creates by light interference. It also resamples the data at
    % 100hz.
    %
    % INPUT VARIABLES
    %   vid = the nueralynx video data with columns time, xpos, and ypos
    %   too_big_origin = the max acceptable position change between adjacent
    %      %points. Larger position changes are deleted as noise.
    %   cum_mod = a correction factor that prevents deletions from creating
    %      %unacceptable position changes between points
    %   initial_clock = neuralynx start time
    %
    % OUTPUT VARIABLES
    %   scrubbed_timepos = the overall output; a matrix of all relevant information
    %   initial_clock = the uncorrected session start time
    %
    
        %prep to remove improbable changes in position
        too_big = too_big_origin;
        guilty_by_association = 4;

        %adjacent pos points for evaluating velocity
        p1 = timepos(1, 2:3);
        p2 = timepos(2, 2:3);

        %adjacent time points for evaluating velocity
        t1 = timepos(1,1);
        t2 = timepos(2,1);

        %preallocate
        deletions = zeros(length(timepos(:,2)),1);
        dists = zeros(length(timepos(:,2)),1);

        %iterate through adjacent points to evaluate velocity
        count = 0;
        for il = 1:length(timepos(:,2))-2

            %velocity
            current_distance = pdist([p1; p2])/(t2-t1);
            dists(il+1) = current_distance;

            %if the current velocity is too big
            if current_distance > too_big

                %note that point (and the next 4) should be deleted (index for later)
                if length(timepos(:,2))-2-il > guilty_by_association
                    deletions(il:il+guilty_by_association) = 1;
                end

                %move to the next point, but keep the first of the adjacent pair
                p2 = timepos(il+2, 2:3);
                t2 = timepos(il+2, 1);

                %each time it's too big, increase what is considered "too big"
                count = count + cum_mod;
                too_big = too_big + count;

            %if it's not too big
            else

                %reset what is considered "too big"
                too_big = too_big_origin;
                count = 0;

                %update points
                p1 = timepos(il+1, 2:3);
                p2 = timepos(il+2, 2:3);
                t1 = timepos(il+1, 1);
                t2 = timepos(il+2, 1);

            end
        end

        %index to delete dubious points
        deletions = logical(deletions);
        display(strcat([num2str(sum(deletions)), ' position points were scrubbed']))
        
        %figure 
        %plot3(timepos(:,2), timepos(:,3), timepos(:,1), 'Color', 'g')
        %hold on
        %plot3(timepos(deletions,2), timepos(deletions,3), timepos(deletions,1), '.', 'Color', 'r')

        timepos(deletions, 2:3) = NaN;

        %replace deleted points with interpolated values
        non_nan_pos = ~isnan(timepos(:,2)) & ~isnan(timepos(:,3)); %index        
        timepos(:,2) = interp1(timepos(non_nan_pos, 1), timepos(non_nan_pos, 2), timepos(:,1), 'linear');
        timepos(:,3) = interp1(timepos(non_nan_pos, 1), timepos(non_nan_pos, 3), timepos(:,1), 'linear');

        %resample time and interpolate new position values
        posl(:,1) = (0:0.01:max(timepos(:,1)))';
        posl(:,2) = interp1(timepos(:,1), timepos(:,2), posl(:,1), 'linear');
        posl(:,3) = interp1(timepos(:,1), timepos(:,3), posl(:,1), 'linear');
        scrubbed_timepos = posl;
        
        %figure; plot(scrubbed_timepos(:,2), scrubbed_timepos(:,3))
    end

%resetting pos. FIX THIS IF TRYING TO INCORPORATE MORE ITEMS FROM NEURALYNX
pos = [NaN(floor(max(tfull(:,1)))*100 + 1, 4), zeros(floor(max(tfull(:,1)))*100 + 1, 1), NaN(floor(max(tfull(:,1)))*100 + 1, 2), ones(floor(max(tfull(:,1)))*100 + 1, 1)];

%generating desired timestamps (10ms increments)
pos(:,1) = (0:0.01:floor(max(tfull(:,1))))';

%re-writes the position X and Y vectors with interpolated data
%pos(:,2) = interp1(tfull ,pfullx, pos(:,1), 'linear');
%pos(:,3) = interp1(tfull ,pfully, pos(:,1), 'linear');
pos(:,2) = interp1(scrubbed_timepos(:,1), scrubbed_timepos(:,2), pos(:,1), 'linear');
pos(:,3) = interp1(scrubbed_timepos(:,1), scrubbed_timepos(:,3), pos(:,1), 'linear');


%sessions recorded with HD tracking on require additional smoothing
if subject > 1837
    pos(:,2) = smooth(pos(:,2), 20);
    pos(:,3) = smooth(pos(:,3), 20);
end

%starttime
starttime = starttime(1,1);



end



