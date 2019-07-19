function [eptrials] = trials_III(event, pos, flags, Targets, TimestampsVT, Angles, CSC)

%%%%% This code runs two times, once to calculate spatial estimates from
%%%%% consistencies in the rat's behavior, and then a second time to 
%%%%% improve upon those estimates by using the reward locations as 
%%%%% spatial anchors.

%eptrials merges event and pos, and adds some additional columns:
%
%   eptrials(:,1) is a common timestamp in the form of 1:.01:N seconds with
%       additional timestamps corresponding to events of different kinds
%   eptrials(:,2) is the rat's X coordinate position data
%   eptrials(:,3) is the rat's Y coordinate position data
%   eptrials(:,4) is the spike event. Unique numbers correspond to unique cells
%   eptrials(:,5) contains the trial number
%   eptrials(:,6) contains the current maze section
%       1 = start area
%       2 = lower stem
%       3 = higher stem
%       4 = choice area
%       5 = choice arm L
%       6 = choice arm R
%       7 = reward area L
%       8 = reward area R
%       9 = return arm L
%       10 = return arm R
%   eptrials(:,7) trial type: contains either 1's (visited left reward) or 2's 
%       (visited right reward) indicating the rat's decision on that trial
%   eptrials(:,8) contains either 1's (correct) or 2's (error) indicating 
%        whether the trial was a correct or an error
%   eptrials(:,9) contains the current stem section 1:4 or NaN
%   eptrials(:,10) contains event flags as either 0 (no flag) or 1 (flag)
%   eptrials(:,11) contains the "folded" maze section
%       1 = start area 
%       2 = lower stem 
%       3 = higher stem
%       4 = choice area 
%       5 = choice arms
%       6 = reward areas
%       7 = return arms
%   eptrials(:,12) contains the tetrode of origin for the spike cluster
%       with an event in that row
%   eptrials(:,13) contains the LFP samples (downsampled in GetCSC). THIS
%       WILL ONLY BE LOADED IF USER SPECIFIES SO IN 'loadnl.m'
%   eptrials(:,14) contains a timesample note. 1 is a timesample, 0 is not.
%       Use this to index when calculating time.
%   eptrials(:,15) contains the rat's head direction.
%
%
% FOR REFERENCE...
% CLUSTERS:
%
% clusters(:,1) contains session cell ID in the form tetrode#.cluster#
% clusters(:,2) contains cluster confidence 1 - 5 (generally just 3-5)
% clusters(:,3) contains waveform shape (0 = unknown; 1 = pyram; 2 = inter;
%                3 = "dip")
% clusters(:,4) contains stability (0 = unstable, fades out or in; 1 =
%                stable)
% clusters(:,5) contains rat cell ID (unique number for that cluster in
%                this rat)
% clusters(:,6) contains "maintained" confidence (same cell as yesterday)
%               (0 = not maintained; 1 = low; 2 = moderate/acceptable; 
%                3= high)
% clusters(:,7) contains hemisphere (0 = Left; 1 = Right)
%
%

%hold originals through first iteration
hold_event = event;
hold_pos = pos;
hold_flags = flags;
if exist('CSC','var')
    hold_CSC = CSC;
end

%excluding the ends of the time range for the upcoming calculation of comxy
rng=(max(pos(:,1)) - min(pos(:,1)))/10;

minx = zeros(10,1);
maxx = zeros(10,1);
miny = zeros(10,1);
maxy = zeros(10,1);

for pct = 1:10
    
    minx(pct,1) = min(pos(pos(:,1) > min(pos(:,1)) + rng*(pct-1) & pos(:,1) < min(pos(:,1) + rng*pct),2));
    maxx(pct,1) = max(pos(pos(:,1) > min(pos(:,1)) + rng*(pct-1) & pos(:,1) < min(pos(:,1) + rng*pct),2));
    miny(pct,1) = min(pos(pos(:,1) > min(pos(:,1)) + rng*(pct-1) & pos(:,1) < min(pos(:,1) + rng*pct),3));
    maxy(pct,1) = max(pos(pos(:,1) > min(pos(:,1)) + rng*(pct-1) & pos(:,1) < min(pos(:,1) + rng*pct),3));
    
end

minx = sort(minx);
maxx = sort(maxx);
miny = sort(miny);
maxy = sort(maxy);

%determining common x and common y by averaging the min and max
comx = (mean(minx(4:7,1)) + mean(maxx(4:7,1)))/2;
comy = (mean(miny(4:7,1)) + mean(maxy(4:7,1)))/2;

%merges event and pos and flags matrices. Also CSC is loaded.
if exist('CSC','var')
    eptrials = sortrows([event;pos;flags;CSC], 1);
else
    eptrials = sortrows([event;pos;flags], 1);
end

%remove and hold columns added after this code was written. These will
%become columns 11 (), 12 (GetTT adds tetrode of origin), 13 (GetCS adds CSC Samples, rest add NaNs), 14 (GetVT adds 1's, rest add 0's).
tempflags = eptrials(:,5);
tempcols = eptrials(:,6:8);
eptrials = eptrials(:,1:4);

%adds empty columns
eptrials = [eptrials zeros(length(eptrials(:,1)),4) NaN(length(eptrials(:,1)),1) tempflags NaN(length(eptrials(:,1)),1) tempcols];

 
%CURRENT MAZE SECTION
%
%This section builds maze section boundaries from (comx, comy) and then 
%fills eptrials(:,6) with maze section at each timestamp / (x,y).


%establishes maze section boundaries [xlow xhigh ylow yhigh]
strt = [comx-50 comx+50  comy-200 comy-80]; %start area 1 1
%stem = [comx-50 comx+50 comy-80 comy+105]; %common stem
stem1 = [comx-50 comx+50 comy-80 comy+12.5]; %low common stem 2 2
stem2 = [comx-50 comx+50 comy+12.5 comy+105]; %high common stem 3 3
chce = [comx-50 comx+50 comy+105 comy+205]; %choice area 4 4
chmL = [comx-120 comx-50 comy+85 comy+205]; %approach arm left 5 5
chmR = [comx+50 comx+120 comy+85 comy+205]; %approach arm right 6 5
rwdL = [comx-230 comx-120 comy+85 comy+205]; %reward area left 7 6
rwdR = [comx+120 comx+225 comy+85 comy+205]; %reward area right 8 6
rtnL = [comx-230 comx-50 comy-200 comy+85]; %return arm left 9 7
rtnR = [comx+50 comx+225 comy-200 comy+85]; %return arm right 10 7

for i = 1:length(eptrials(:,1));
    switch logical(true)
        
        case eptrials(i,2)>=strt(1,1) & eptrials(i,2)<=strt(1,2) & eptrials(i,3)>=strt(1,3) & eptrials(i,3)<=strt(1,4), eptrials(i,6) = 1;
        %case eptrials(i,2)>stem(1,1) & eptrials(i,2)<stem(1,2) & eptrials(i,3)>stem(1,3) & eptrials(i,3)<stem(1,4), eptrials(i,6) = 2;
        case eptrials(i,2)>=stem1(1,1) & eptrials(i,2)<=stem1(1,2) & eptrials(i,3)>=stem1(1,3) & eptrials(i,3)<stem1(1,4), eptrials(i,6) = 2;
        case eptrials(i,2)>=stem2(1,1) & eptrials(i,2)<=stem2(1,2) & eptrials(i,3)>=stem2(1,3) & eptrials(i,3)<stem2(1,4), eptrials(i,6) = 3;
        case eptrials(i,2)>=chce(1,1) & eptrials(i,2)<=chce(1,2) & eptrials(i,3)>=chce(1,3) & eptrials(i,3)<=chce(1,4), eptrials(i,6) = 4;
        case eptrials(i,2)>chmL(1,1) & eptrials(i,2)<chmL(1,2) & eptrials(i,3)>chmL(1,3) & eptrials(i,3)<chmL(1,4), eptrials(i,6) = 5;
        case eptrials(i,2)>chmR(1,1) & eptrials(i,2)<chmR(1,2) & eptrials(i,3)>chmR(1,3) & eptrials(i,3)<chmR(1,4), eptrials(i,6) = 6;
        case eptrials(i,2)>=rwdL(1,1) & eptrials(i,2)<=rwdL(1,2) & eptrials(i,3)>=rwdL(1,3) & eptrials(i,3)<=rwdL(1,4), eptrials(i,6) = 7;
        case eptrials(i,2)>=rwdR(1,1) & eptrials(i,2)<=rwdR(1,2) & eptrials(i,3)>=rwdR(1,3) & eptrials(i,3)<=rwdR(1,4), eptrials(i,6) = 8;
        case eptrials(i,2)>rtnL(1,1) & eptrials(i,2)<rtnL(1,2) & eptrials(i,3)>rtnL(1,3) & eptrials(i,3)<rtnL(1,4), eptrials(i,6) = 9;
        case eptrials(i,2)>rtnR(1,1) & eptrials(i,2)<rtnR(1,2) & eptrials(i,3)>rtnR(1,3) & eptrials(i,3)<rtnR(1,4), eptrials(i,6) = 10;
            
        otherwise
            eptrials(i,6) = NaN;
            
    end;
    
    
    %FOLDED MAZE SECTION
    %This section assigns numbers to eptrials(:,11) based on the numbers
    % in eptrials(:,6).
    
    if eptrials(i,6)==1
        eptrials(i,11)=1;
    elseif eptrials(i,6)==2
        eptrials(i,11)=2;
    elseif eptrials(i,6)==3
        eptrials(i,11)=3;
    elseif eptrials(i,6)==4
        eptrials(i,11)=4;
    elseif eptrials(i,6)==5 || eptrials(i,6)==6
        eptrials(i,11)=5;
    elseif eptrials(i,6)==7 || eptrials(i,6)==8
        eptrials(i,11)=6;
    elseif eptrials(i,6)==9 || eptrials(i,6)==10
        eptrials(i,11)=7;
    else
        eptrials(i,11)=NaN;
    end
    
end;



%CURRENT TRIAL
%
%This section breaks the continuous trajectory into discrete trials begining and
%ending in the start area. Entering the start area while going in the 
%"forward" direction initiates a new lap. This algorithm allows the rat to 
%turn around and go backwards (at least for a long distance) without 
%triggering a new lap. 
%
%We start with current lap and current section set at one.
%
%This will output 1 more trial that was intended. The extra trial is the
%rat waiting to be removed from the maze, and is not plotted by plottrials


lap = 1;
sect = 1;
sections = [3 4 5 6 7 1 2 3 4 5 6 7]; %deals with circular data, 
                                   %allowing for turn-around

for tstmp = 1:length(eptrials(:,1))
    
    pos = eptrials(tstmp,11); %position is defined as the folded maze section within 
                         %which the current x,y coordinates fall. See
                         %above.
                         
    if ismember(pos, 1:7) %NaNs passed along

        while 1 %true. This loop will run infinitely, or until break. It follows
                %the current pos, asigning lap numbers. When the rat returns
                %to the start after a lap, the current lap is increased  by 1
                
            
            if ismember(pos, [sections(sect) sections(sect+1) sections(sect+2) sections(sect+3) sections(sect+4) sections(sect+5)])
                
                eptrials(tstmp, 5) = lap; %set this timestamp as being on current lap
            
                break %leave while loop and move on to next timestamp
        
            elseif pos == 1 %if we've moved beyond the current sect, and that 
                        %sect was a return arm, move to start area and 
                        %begin next lap. THIS CAN BE CHANGED TO pos > 7 in
                        %order to begin laps at the return arms.
                sect = 1;
                lap = lap+1;
            
                continue           
            else           
                sect = sect+1; %if we're not in the current sect, and the last
                           %sect was not a return arm, check the next sect
                           %EDIT
                continue
            end
        end   
    else
         eptrials(tstmp, 5) = NaN; %NaN input results in NaN output
    end   
end


%CHOICE MADE
%
%This section determines whether the rat made a left (1) or right (2) turn by
%asking whether the trial contained a 6 (left reward area) or a 7 (right 
%reward area) section visit AFTER A vist to sections 2 and 3. If neither 
%(which indicates an innacurately flagged trial), NaN.
%

for trial = 1:max(eptrials(:,5));
    
    %pulling out trial-related eptrials to help indexing. May be able to
    %index directly?
    trialeptrials = eptrials(eptrials(:,5)==trial, :);
    
    %...the first trial will never be the one..and this works with the next
    %line
    for i = 2:length(trialeptrials(:,1))
 
        %high stem (3) and choice (4) will add to 7.
        if trialeptrials(i, 11) + trialeptrials(i-1, 11)==7
            
            %moment rat enters choice section from stem section.
            tmstmp=trialeptrials(i,1);
            
            if mode(eptrials(eptrials(:,5)==trial & eptrials(:,11)==6 & eptrials(:,1)>tmstmp, 6)) == 7
            
                eptrials(eptrials(:,5)==trial,7) = 1;
            
            elseif mode(eptrials(eptrials(:,5)==trial & eptrials(:,11)==6 & eptrials(:,1)>tmstmp, 6)) == 8
            
                eptrials(eptrials(:,5)==trial,7) = 2;
            
            else
                
                eptrials(eptrials(:,5)==trial,7) = NaN;
            
            end
            
            %stop searching trialeptrials after finding tmstmp
            break 
        end             
    end
end
        
        
%SUCCESS OR ERROR
%
%This section determines whether the rat alternated (1) or erred (2).
%                    
for trial = 2:max(eptrials(:,5));
    
    if mode(eptrials(eptrials(:,5)==trial,7)) == mode(eptrials(eptrials(:,5)==(trial-1),7))
       
        eptrials(eptrials(:,5)==trial, 8) = 2;      
    else      
        eptrials(eptrials(:,5)==trial, 8) = 1;
    end

end

        

%*************************************************************************
%*************************************************************************
%
%
%
%      Re-Running code with comxy determined from lick detections
%
%
%
%*************************************************************************
%*************************************************************************

%held originals through first iteration
event = hold_event;
pos = hold_pos;
flags = hold_flags;
if exist('CSC','var')
    CSC = hold_CSC;
end



%DETERMINING COMXY FROM LICK DETECTIONS_FIRST (see rewards.m for details)
%
%will have to be redone after rotation
firstLrwdsXY = NaN(max(eptrials(:,5)), 2);
firstRrwdsXY = NaN(max(eptrials(:,5)), 2);

for trl = 2:max(eptrials(:,5))    
        if mode(eptrials(eptrials(:,5)==trl,7))==1            
            if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,10))>0       
            %for some reason one trial was ouputting two values. The
            %nanmean solved that problem.
            firstLrwdsXY(trl,1) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,1)), 2));
            firstLrwdsXY(trl,2) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==7,1)), 3));            
            end        
        elseif mode(eptrials(eptrials(:,5)==trl,7))==2           
            if sum(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,10))>0           
            firstRrwdsXY(trl,1) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,1)), 2));
            firstRrwdsXY(trl,2) = nanmean(eptrials(eptrials(:,1)==min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,6)==8,1)), 3));  
            end           
        end
end
avgXYrwdL = [nanmean(firstLrwdsXY(:, 1)) nanmean(firstLrwdsXY(:, 2))];
avgXYrwdR = [nanmean(firstRrwdsXY(:, 1)) nanmean(firstRrwdsXY(:, 2))];
rwdpos = mean([avgXYrwdL ; avgXYrwdR]);

comx = rwdpos(1);
comy = rwdpos(2)-119.2466; %NOTE: Can I avoid hard coding this y correction?
comxy = [comx comy];



%RESET EPTRIALS
%merges event and pos and flags matrices. Also CSC is loaded.
if exist('CSC','var')
    eptrials = sortrows([event;pos;flags;CSC], 1);
else
    eptrials = sortrows([event;pos;flags], 1);
end

%remove and hold columns added after this code was written. These will
%become columns 11 (), 12 (GetTT adds tetrode of origin), 13 (GetCS adds CSC Samples, rest add NaNs), 14 (GetVT adds 1's, rest add 0's).
tempflags = eptrials(:,5);
tempcols = eptrials(:,6:8);
eptrials = eptrials(:,1:4);

%adds empty columns
eptrials = [eptrials zeros(length(eptrials(:,1)),4) NaN(length(eptrials(:,1)),1) tempflags NaN(length(eptrials(:,1)),1) tempcols NaN(length(eptrials(:,1)),1)];



%ROTATE X,Y COORDINATES 
%
% This section attempts to correct for angular misplacement of the maze 
% below the camera by rotating every rat position around comxy with the
% goal of leveling out the reward locations

%rotation_angle calculates rotang, the rotation angle required to level out the
%reward locations
rotang = rotation_angle(avgXYrwdL, avgXYrwdR, comxy);
display(strcat(['X,Y coordinates were rotated clockwise ', num2str(rotang), ' degrees']))

if abs(rotang) > 30
    error('rotation angle implausible. check rotation angle')
end

%rotate all x y coordinates (the sign of rotang must be reversed, because
%'rotate' works in the counter clockwise direction)
%
%see function rotate_pts for additional documentation
newpts = rotate_pts(rotang*-1, [eptrials(:,2) eptrials(:,3)], comxy);

%now rewrite the x and y coordinates of eptrials (if you want to smooth the
%position data, this is a good time, but it takes FOREVER.
eptrials(:,2) = newpts(:,1);
eptrials(:,3) = newpts(:,2);

%remove positionless rows
eptrials(isnan(eptrials(:,2)) | isnan(eptrials(:,3)),:) = [];

%CENTER MAZE to (1000,1000) II
x_correction = 1000-comx;
y_correction = 1000-comy;
eptrials(:,2) = eptrials(:,2) + repmat(x_correction, size(eptrials(:,2)));
eptrials(:,3) = eptrials(:,3) + repmat(y_correction, size(eptrials(:,3)));
comx = 1000;
comy = 1000;



%CURRENT MAZE SECTION
%
%This section builds maze section boundaries from (comx, comy) and then 
%fills eptrials(:,6) with maze section at each timestamp / (x,y).

%establishes maze section boundaries [xlow xhigh ylow yhigh]
strt = [comx-50 comx+50  comy-200 comy-80]; %start area 1 1
%stem = [comx-50 comx+50 comy-80 comy+105]; %common stem
stem1 = [comx-50 comx+50 comy-80 comy+12.5]; %low common stem 2 2
stem2 = [comx-50 comx+50 comy+12.5 comy+105]; %high common stem 3 3
chce = [comx-50 comx+50 comy+105 comy+205]; %choice area 4 4
chmL = [comx-120 comx-50 comy+85 comy+205]; %approach arm left 5 5
chmR = [comx+50 comx+120 comy+85 comy+205]; %approach arm right 6 5
rwdL = [comx-230 comx-120 comy+85 comy+205]; %reward area left 7 6
rwdR = [comx+120 comx+225 comy+85 comy+205]; %reward area right 8 6
rtnL = [comx-230 comx-50 comy-200 comy+85]; %return arm left 9 7
rtnR = [comx+50 comx+225 comy-200 comy+85]; %return arm right 10 7

for i = 1:length(eptrials(:,1));
    switch logical(true)
        
        case eptrials(i,2)>=strt(1,1) & eptrials(i,2)<=strt(1,2) & eptrials(i,3)>=strt(1,3) & eptrials(i,3)<=strt(1,4), eptrials(i,6) = 1;
        %case eptrials(i,2)>stem(1,1) & eptrials(i,2)<stem(1,2) & eptrials(i,3)>stem(1,3) & eptrials(i,3)<stem(1,4), eptrials(i,6) = 2;
        case eptrials(i,2)>=stem1(1,1) & eptrials(i,2)<=stem1(1,2) & eptrials(i,3)>=stem1(1,3) & eptrials(i,3)<stem1(1,4), eptrials(i,6) = 2;
        case eptrials(i,2)>=stem2(1,1) & eptrials(i,2)<=stem2(1,2) & eptrials(i,3)>=stem2(1,3) & eptrials(i,3)<stem2(1,4), eptrials(i,6) = 3;
        case eptrials(i,2)>=chce(1,1) & eptrials(i,2)<=chce(1,2) & eptrials(i,3)>=chce(1,3) & eptrials(i,3)<=chce(1,4), eptrials(i,6) = 4;
        case eptrials(i,2)>chmL(1,1) & eptrials(i,2)<chmL(1,2) & eptrials(i,3)>chmL(1,3) & eptrials(i,3)<chmL(1,4), eptrials(i,6) = 5;
        case eptrials(i,2)>chmR(1,1) & eptrials(i,2)<chmR(1,2) & eptrials(i,3)>chmR(1,3) & eptrials(i,3)<chmR(1,4), eptrials(i,6) = 6;
        case eptrials(i,2)>=rwdL(1,1) & eptrials(i,2)<=rwdL(1,2) & eptrials(i,3)>=rwdL(1,3) & eptrials(i,3)<=rwdL(1,4), eptrials(i,6) = 7;
        case eptrials(i,2)>=rwdR(1,1) & eptrials(i,2)<=rwdR(1,2) & eptrials(i,3)>=rwdR(1,3) & eptrials(i,3)<=rwdR(1,4), eptrials(i,6) = 8;
        case eptrials(i,2)>rtnL(1,1) & eptrials(i,2)<rtnL(1,2) & eptrials(i,3)>rtnL(1,3) & eptrials(i,3)<rtnL(1,4), eptrials(i,6) = 9;
        case eptrials(i,2)>rtnR(1,1) & eptrials(i,2)<rtnR(1,2) & eptrials(i,3)>rtnR(1,3) & eptrials(i,3)<rtnR(1,4), eptrials(i,6) = 10;
            
        otherwise
            eptrials(i,6) = NaN;
            
    end;

    
    
    %FOLDED MAZE SECTION
    %This section assigns numbers to eptrials(:,11) based on the numbers
    % in eptrials(:,6).
    
    if eptrials(i,6)==1
        eptrials(i,11)=1;
    elseif eptrials(i,6)==2
        eptrials(i,11)=2;
    elseif eptrials(i,6)==3
        eptrials(i,11)=3;
    elseif eptrials(i,6)==4
        eptrials(i,11)=4;
    elseif eptrials(i,6)==5 || eptrials(i,6)==6
        eptrials(i,11)=5;
    elseif eptrials(i,6)==7 || eptrials(i,6)==8
        eptrials(i,11)=6;
    elseif eptrials(i,6)==9 || eptrials(i,6)==10
        eptrials(i,11)=7;
    else
        eptrials(i,11)=NaN;
    end
      
end;


%CURRENT TRIAL
%
%This section breaks the continuous trajectory into discrete trials begining and
%ending in the start area. Entering the start area while going in the 
%"forward" direction initiates a new lap. This algorithm allows the rat to 
%turn around and go backwards (at least for a long distance) without 
%triggering a new lap. 
%
%We start with current lap and current section set at one.
%
%This will output 1 more trial that was intended. The extra trial is the
%rat waiting to be removed from the maze, and is not plotted by plottrials


lap = 1;
sect = 1;
sections = [3 4 5 6 7 1 2 3 4 5 6 7]; %deals with circular data, 
                                   %allowing for turn-around

for tstmp = 1:length(eptrials(:,1))
    
    pos = eptrials(tstmp,11); %position is defined as the folded maze section within 
                         %which the current x,y coordinates fall. See
                         %above.
                         
    if ismember(pos, 1:7) %NaNs passed along

        while 1 %true. This loop will run infinitely, or until break. It follows
                %the current pos, asigning lap numbers. When the rat returns
                %to the start after a lap, the current lap is increased  by 1       
            
            if ismember(pos, [sections(sect) sections(sect+1) sections(sect+2) sections(sect+3) sections(sect+4) sections(sect+5)])
                
                eptrials(tstmp, 5) = lap; %set this timestamp as being on current lap
            
                break %leave while loop and move on to next timestamp
        
            elseif pos == 1 %if we've moved beyond the current sect, and that 
                        %sect was a return arm, move to start area and 
                        %begin next lap. THIS CAN BE CHANGED TO pos > 7 in
                        %order to begin laps at the return arms.
                sect = 1;
                lap = lap+1;
            
                continue           
            else           
                sect = sect+1; %if we're not in the current sect, and the last
                           %sect was not a return arm, check the next sect
                           %EDIT
                continue
            end
        end   
    else
         eptrials(tstmp, 5) = NaN; %NaN input results in NaN output
    end   
end



%CHOICE MADE
%
%This section determines whether the rat made a left (1) or right (2) turn by
%asking whether the trial contained a 6 (left reward area) or a 7 (right 
%reward area) section visit AFTER A vist to sections 2 and 3. If neither 
%(which indicates an innacurately flagged trial), NaN.
%

for trial = 1:(max(eptrials(:,5))-1)
        
    %pulling out trial-related eptrials to help indexing. May be able to
    %index directly?
    trialeptrials = eptrials(eptrials(:,5)==trial, :);
    
    %...the first trial will never be the one..and this works with the next
    %line
    for i = 2:length(trialeptrials)
 
        %high stem (3) and choice (4) will add to 5.
        if trialeptrials(i, 11) + trialeptrials(i-1, 11)==7
            
            %moment rat enters choice section from stem section.
            tmstmp=trialeptrials(i,1);
            
            if mode(eptrials(eptrials(:,5)==trial & eptrials(:,11)==6 & eptrials(:,1)>tmstmp, 6)) == 7
            
                eptrials(eptrials(:,5)==trial,7) = 1;
            
            elseif mode(eptrials(eptrials(:,5)==trial & eptrials(:,11)==6 & eptrials(:,1)>tmstmp, 6)) == 8
            
                eptrials(eptrials(:,5)==trial,7) = 2;
            
            else
                
                eptrials(eptrials(:,5)==trial,7) = NaN;
            
            end
            
            %stop searching trialeptrials after finding tmstmp
            break   
        end               
    end
end
 


%SUCCESS OR ERROR
%
%This section determines whether the rat alternated (1) or erred (2).
%       
        
for trial = 2:max(eptrials(:,5));
    
    if mode(eptrials(eptrials(:,5)==trial,7)) == mode(eptrials(eptrials(:,5)==(trial-1),7))
        
        eptrials(eptrials(:,5)==trial, 8) = 2;
        
    else
        
        eptrials(eptrials(:,5)==trial, 8) = 1;
        
    end
end



%CURRENT STEM SECTION
%
%This section fills eptrials(:,9) with stem section at each timestamp/(x,y)

%stem subsections
stem1 = [comx-50 comx+50 comy-80 comy-33.75];
stem2 = [comx-50 comx+50 comy-33.75 comy+12.5];
stem3 = [comx-50 comx+50 comy+12.5 comy+58.75];
stem4 = [comx-50 comx+50 comy+58.75 comy+105];

for i = 1:length(eptrials(:,1));
    switch logical(true)
        
        case eptrials(i,2)>=stem1(1,1) & eptrials(i,2)<=stem1(1,2) & eptrials(i,3)>=stem1(1,3) & eptrials(i,3)<stem1(1,4), eptrials(i,9) = 1;
        case eptrials(i,2)>=stem2(1,1) & eptrials(i,2)<=stem2(1,2) & eptrials(i,3)>=stem2(1,3) & eptrials(i,3)<stem2(1,4), eptrials(i,9) = 2;
        case eptrials(i,2)>=stem3(1,1) & eptrials(i,2)<=stem3(1,2) & eptrials(i,3)>=stem3(1,3) & eptrials(i,3)<stem3(1,4), eptrials(i,9) = 3;
        case eptrials(i,2)>=stem4(1,1) & eptrials(i,2)<=stem4(1,2) & eptrials(i,3)>=stem4(1,3) & eptrials(i,3)<stem4(1,4), eptrials(i,9) = 4;
            
        otherwise
             eptrials(i,9) = NaN;          
    end
end

%

%HEAD DIRECTION
%
%This section fills column 15 with instantaneous head direction

%if the neuralynx system recorded head direction, use that (STILL TESTING)
if 0 %sum(Targets(6,:)>0)
    
    %STILL IN ALPHA TESTING
    %display('Light tracking was used to estimate Head Direction')
    eptrials(eptrials(:,4)==1,15) = neuralynx_HD(Targets, TimestampsVT, Angles, eptrials(eptrials(:,4)==1, 1), rotang);
    
%otherwise, estimate head direction from Target and trajectory information
else
    
    %print origin of HD information
    display('Trajectory was used to estimate Head Direction')
    
    %set head direction for every video time point
    eptrials(eptrials(:,14)==1,15) = remedial_HD(Targets, TimestampsVT, eptrials(eptrials(:,14)==1, 1), eptrials(eptrials(:,14)==1, 2), eptrials(eptrials(:,14)==1, 3), rotang);
    
    %set head direction for all points. This may or may not be useful.
    %eptrials(:,15) = circ_interp1(eptrials(eptrials(:,14)==1,15)', [0 360], eptrials(:,1)', eptrials(eptrials(:,14)==1, 1)');
    eptrials(:,15) = circ_interp1(eptrials(~isnan(eptrials(:,15)),15)', [0 360], eptrials(:,1)', eptrials(~isnan(eptrials(:,15)), 1)');

    
end
%}


%HOUSE CLEANING
%

%deletes extra-trial samples by removing sample that were not given a 1 or
%2 in column 7 (which reward location visited). These are before the rat is
%placed on the maze, and after the rat returns from its final trial.
eptrials = eptrials(eptrials(:,7)>0,:);

%additionally removes timepoints from begining of session where the rat is outside of
%the start area (e.g., "positions" where the rat is being carried from the
%pedestal)
eptrials = eptrials(eptrials(:,1)>=min(eptrials(eptrials(:, 6)==1, 1)), :);

%sets first time bin to 0.0000
eptrials(:,1) = eptrials(:,1) - ones(length(eptrials(:,1)),1).*eptrials(1,1);



end



        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

