function [Ls, Rs, all_velocities, vel_means, vel_stds, mean_pos,mean_vel,mean_hd ] = all_winpos(training_stage, window_back, window_forward, event, split)
% calculates the average xpos for each correct l and r trial

%set counters
Ls = [];
Rs = [];
all_velocities = [];
mean_pos = [];
mean_vel = [];
mean_hd = [];

h1 = figure; hold on;
h2 = figure; hold on

%cramped coding of folder access. see ALL.m file types for documentation
file_list_subjects=dir('C:\Users\ampm1\Desktop\oldmatlab\neurodata\');
file_list_subjects(1:2) = [];
file_names_subjects={file_list_subjects([file_list_subjects(:).isdir])};
length_subjects = size(file_names_subjects{:},1);

    %iterate through subjects...and stages...and sessions
    for subject = 1:length_subjects
        %print update
        rat = file_names_subjects{:}(subject,1).name
        %get all the things in subject folder...
        file_list_stages = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name)));
        file_list_stages(1:2) = [];
        file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
        length_stages = size(file_names_stages{:},1);

        %iterate through stages...and sessions
    for stage = training_stage
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];

        %session folders
        if size(file_list_sessions,1) == 0
            continue
        elseif size(file_list_sessions,1) == 1
            sesh_list = {file_list_sessions.name};
        else
            sesh_list = vertcat({file_list_sessions.name});
        end
       
        
        %iterate through select sessions
        if training_stage == 2
            
            %early = 1:round(length(sesh_list)\2)
            %late = (round(length(sesh_list)\2)+1):length(sesh_list)
            %total = 1:length(sesh_list)
            %split = 1.3;
            
            
            sesh_rng = first_mid_last(length(sesh_list), split, 0);
            
            %{
            if split == 1
                sesh_rng = 1:ceil(length(sesh_list)\2);
            elseif split == 2
                if rem(length(sesh_list),2) == 0
                    sesh_rng = (ceil(length(sesh_list)\2)+1):length(sesh_list);
                else
                    sesh_rng = ceil(length(sesh_list)\2):length(sesh_list);
                end
                sesh_rng(sesh_rng==1)=[];
            elseif split == 0
                sesh_rng = 1:length(sesh_list);
            elseif split == 1.1
                sesh_rng = 1;
            elseif split == 1.2
                sesh_rng = ceil(length(sesh_list)\2)+1;
                sesh_rng(sesh_rng==1)=[];
            elseif split == 1.3
                sesh_rng = length(sesh_list);
                sesh_rng(sesh_rng==1)=[];
            end
            %}
            
            
            %sesh_rng = 1:round(length(sesh_list)\2); 
            %sesh_rng = (round(length(sesh_list)\2)+1):length(sesh_list);
            %sesh_rng = ceil(length(sesh_list)\2):length(sesh_list);
            
        else
            sesh_rng = 1:length(sesh_list);
        end
        
            for session = sesh_rng

                %day = file_list_sessions{:}(sessions,1).name
                day = session

                if exist(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'), 'file')
                    %load session
                    load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
                else
                    display('no file')
                    continue
                end
                %only stable cells
                clusters = clusters(clusters(:,4)==1, :);

                if isempty(clusters)
                    continue
                end

                if training_stage == 1
                    eptrials(isnan(eptrials(:,5)),:) = [];
                end
                
                    
                    [~, ~, vel_holds, h1, h2, mean_posLR, mean_velLR, mean_hdLR] = wndwpos(eptrials, window_back, window_forward, event, h1, h2);
                    %close all

                        %Ls = [Ls; leftmeans];
                        %Rs = [Rs; rightmeans];
                        
                        all_velocities = [all_velocities; vel_holds];
                        mean_pos = [mean_pos; mean_posLR];
                        mean_vel = [mean_vel; mean_velLR];
                        mean_hd = [mean_hd; mean_hdLR];

            end
        end
    end
 
    
figure(h1)
sections
rewards(eptrials,1)
axis off
    
a = -window_back:.1:window_forward;
a(end) = window_forward +.0001;
[~, time_idx] = histc(all_velocities(:,1), a);
vel_means = nan(length(unique(time_idx)),1);
vel_stds = nan(length(unique(time_idx)),1);
for i = 1:length(unique(time_idx));
    vel_means_L(i) = mean(all_velocities(time_idx==i & all_velocities(:,3)==1,2)); 
    vel_stds_L(i) = std(all_velocities(time_idx==i & all_velocities(:,3)==1,2)); 
    vel_means_R(i) = mean(all_velocities(time_idx==i & all_velocities(:,3)==2,2)); 
    vel_stds_R(i) = std(all_velocities(time_idx==i & all_velocities(:,3)==2,2)); 
end
figure(h2)
plot([0 0], [0 2], 'k-')
%errorbar(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means(~isnan(vel_means)), vel_stds(~isnan(vel_means)))
%errorbar(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_L(~isnan(vel_means_L)), vel_stds_L(~isnan(vel_means_L)), 'k')
%errorbar(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_R(~isnan(vel_means_R)), vel_stds_R(~isnan(vel_means_R)), 'b')

plot(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_L(~isnan(vel_means_L)), 'Color', [52 153 70]./255)
plot(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_L(~isnan(vel_means_L))+vel_stds_L(~isnan(vel_means_L)), 'Color',[52 153 70]./255)
plot(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_L(~isnan(vel_means_L))-vel_stds_L(~isnan(vel_means_L)), 'Color',[52 153 70]./255)

plot(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_R(~isnan(vel_means_R)), 'Color',[46 49 146]./255)
plot(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_R(~isnan(vel_means_R))+vel_stds_R(~isnan(vel_means_R)), 'Color',[46 49 146]./255)
plot(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_R(~isnan(vel_means_R))-vel_stds_R(~isnan(vel_means_R)), 'Color',[46 49 146]./255)

%errorbar(a(1:end-1)+repmat(.05, size(a(1:end-1))), vel_means_R(~isnan(vel_means_R)), vel_stds_R(~isnan(vel_means_R)), 'b')
xlabel('time (s)')
ylim([0 2])
xlim([-window_back window_forward])
ylabel('velocity (m/s)')
set(gca,'TickLength',[0, 0]);
xlabel('time (ms)')
    
end






                
                
                
              