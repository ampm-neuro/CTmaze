function [eptrials, clusters, correct_left, correct_right, errors_left, errors_right, session_length, Targets, TimestampsVT, Angles] = loadnl(filename, subject, varargin)

%filename is the name of the folder (INSIDE THE MATLAB FOLDER) containing
%the day's data, e.g., 2013-10-02_08-05-23
%
%This outputs eptrials. See "trials_II" for more info.
%
%Requires that the data folder be inside a folder named 'neurodata' inside
%of the main MATLAB folder
%

filename


if nargin == 3
    noncsc_file = vargarin{1};
end

%Major neuralynx data files (video, spike, flag)

%USB KEY
%[pos, starttime, Targets, TimestampsVT, Angles] = GetVT(strcat('/Volumes/USB20FD/',num2str(filename),'/VT1.nvt'), subject);
%[event] = GetTT(strcat('/Volumes/USB20FD/',num2str(filename)), pos, starttime);
%[flags] = GetEV(strcat('/Volumes/USB20FD/',num2str(filename),'/Events.nev'), pos, starttime);

%MOBILE EXTERNAL HARD DRIVE
[pos, starttime, Targets, TimestampsVT, Angles] = GetVT(strcat('/Volumes/New Volume/PC Alt/Subjects_Good Data_edited_ampm/',num2str(filename),'/VT1.nvt'), subject);
[event] = GetTT(strcat('/Volumes/New Volume/PC Alt/Subjects_Good Data_edited_ampm/',num2str(filename)), pos, starttime);
[flags] = GetEV(strcat('/Volumes/New Volume/PC Alt/Subjects_Good Data_edited_ampm/',num2str(filename),'/Events.nev'), pos, starttime);

%IMMOBILE EXTERNAL HARD DRIVE
%[pos, starttime, Targets, TimestampsVT, Angles] = GetVT(strcat('/Volumes/LaCie/PCAlte/',num2str(filename),'/VT1.nvt'), subject);
%[event] = GetTT(strcat('/Volumes/LaCie/PCAlte/',num2str(filename)), pos, starttime);
%[flags] = GetEV(strcat('/Volumes/LaCie/PCAlte/',num2str(filename),'/Events.nev'), pos, starttime);

%LOCAL DOCUMENTS
%[pos, starttime, Targets, TimestampsVT, Angles] = GetVT(strcat('/Users/ampm/Documents/MATLAB/',num2str(filename),'/VT1.nvt'),  subject);
%[event] = GetTT(strcat('/Users/ampm/Documents/MATLAB/',num2str(filename)), pos, starttime);
%[flags] = GetEV(strcat('/Users/ampm/Documents/MATLAB/',num2str(filename),'/Events.nev'), pos, starttime);


%THIS VARIABLE CONTROLS WHETHER THE CSC FILE IS ADDED TO eptrials
%if you would like the CSC data, it should be a 1. Otherwise, 0.
INCLUDE_CSC = 1;

if INCLUDE_CSC == 1
    
    %best channel based on spike data
    load(strcat(noncsc_file, '.mat'), 'clusters');
    csc_channel = round(clusters(find(clusters(:,2)==max(clusters(:,2)),1),1));
    clear clusters
    
    [CSC] = GetCS(strcat('/Users/ampm/Documents/MATLAB/neurodata_csc/',num2str(filename),'/CSC', num2str(csc_channel), '.ncs'), pos, starttime);
    
    eptrials = trials_III(event, pos, flags, Targets, TimestampsVT, Angles, CSC);

elseif INCLUDE_CSC == 0

    eptrials = trials_III(event, pos, flags, Targets, TimestampsVT, Angles);
    
end

session_length = max(eptrials(:,1))/60

clusters = unique(eptrials(eptrials(:,4)>1,4))

correct_left = length(unique(eptrials(eptrials(:,8)==1 & eptrials(:,7)==1, 5)))
correct_right = length(unique(eptrials(eptrials(:,8)==1 & eptrials(:,7)==2, 5)))
errors_left = length(unique(eptrials(eptrials(:,8)==2 & eptrials(:,7)==1, 5)))
errors_right = length(unique(eptrials(eptrials(:,8)==2 & eptrials(:,7)==2, 5)))

end


