function [hd_scores_ic, hd_scores_R] = ALL_hdcell
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.
num_cells = 0;
hd_scores_ic = [];
hd_scores_R = [];

%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata\');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])}

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;


%iterate through subjects
for subject = 1:length_subjects

    %print update
    rat = file_names_subjects{:}(subject,1).name;
    
    %get all the things in subject folder...
    file_list_stages = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name)));

    %hard coded erasure of irrelevant directory folders
    file_list_stages(1:2) = [];

    %exclude non-folders
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = [2]%1:length_stages
        
        %print update
        task = file_names_stages{:}(stage,1).name
        
        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\', num2str(file_names_subjects{:}(subject,1).name), '\', num2str(file_names_stages{:}(stage,1).name, '\*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %exclude non-folders
        %file_list_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
           
        %number of folders
        length_sessions = size(file_list_sessions,1);
    
        %iterate through sessions
        for session = 1:length_sessions
            %in ot
            if stage == 4
            %cancel last two (dropped) 1860 sessions
                if subject==11 && session>length_sessions-2
                    continue
                end
            end
            
           
            day = session
            
            try
                %load session
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
                num_cells = num_cells + size(clusters,1);
                [rd, ic] = hd_cell(eptrials, clusters(:,1), 11, 5, 1);
                ic = real(ic);

                %rayleigh test for resultant vector length
                for icell = 1:size(rd,1)
                    [~,R] = rayleigh(rd(icell,:));
                    hd_scores_R = [hd_scores_R; R];
                end
                
                %load hd info scores
                hd_scores_ic = [hd_scores_ic; ic];
                

                %plot putative HD cells
                %{
                for iic = 1:length(ic)
                    if ic(iic) > 0.2
                        figure;
                        plot(smooth(rd(iic,:),5), 'k', 'linewidth', 1.1)
                        set(gca,'TickLength',[0, 0]); box off
                        axis([0 360 0 max(rd(iic,:))*1.2])
                        set(gca,'XTick', [1 90 180 270 360], 'fontsize', 17)
                        title(...
                            [num2str(rat),'\' ,num2str(task),'\' ,num2str(session),...
                            ' ', num2str(clusters(iic,1)), ', ic: ', num2str(ic(iic))])
                        ylabel('Mean Firing Rate (Hz)', 'fontsize', 15)
                        xlabel('Head Direction (clockwise degrees)', 'fontsize', 15) 
                    end
                end
                %}
                
            catch
                
                display('no file')
            end
            
            
            
                       
            
        end
    end
    
    
end

num_cells

end
