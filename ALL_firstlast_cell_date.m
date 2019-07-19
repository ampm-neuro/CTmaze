function subj_cell = ALL_firstlast_cell_date
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

subj_cell = cell(1,12);


%names%get all the things in neurodata folder...
file_list_subjects = dir('neurodata/');

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);
%file_names_subjects{:}(1:length_subjects,1).name;

counts = zeros(1, length_subjects);

%iterate through subjects
for isubj = 1:length_subjects

    firstlast_dates = cell(1,16); %tt, dates

    all_tt_dates = cell(16,1);

    %print update
    rat = file_names_subjects{:}(isubj,1).name;
    
    %get all the things in subject folder...
    file_list_stages = dir(strcat('neurodata/', num2str(file_names_subjects{:}(isubj,1).name)));

    %hard coded erasure of irrelevant directory folders
    file_list_stages(1:2) = [];

    %exclude non-folders
    file_names_stages = {file_list_stages([file_list_stages(:).isdir])};
    
    %number of folders
    length_stages = size(file_names_stages{:},1);
    
    %iterate through stages %CONTROL WHICH STAGE
    for stage = [2 4]
        
        %print update
        task = file_names_stages{:}(stage,1).name;

        %get all the *.mat in subject folder...
        file_list_sessions = dir(strcat('neurodata/', num2str(file_names_subjects{:}(isubj,1).name), '/', num2str(file_names_stages{:}(stage,1).name, '/*.mat')));
        
        %hard coded erasure of irrelevant directory folders
        file_list_sessions(1:2) = [];
    
        %number of folders
        length_sessions = size(file_list_sessions,1);

        %iterate through sessions
        sesh_rng = 1:length_sessions+1;
        for session = sesh_rng
            
            if isnan(session)
                continue
            end
            
            %day = file_list_sessions{:}(sessions,1).name
            day = session;
            
            try
                %load session
                load(strcat('C:\Users\ampm1\Desktop\oldmatlab\neurodata\',num2str(rat),'\' ,num2str(task),'\' ,num2str(session), '.mat'));
            catch
                continue
            end
            
            %current date
            of_slashs = strfind(origin_file,'/'); 
            
            
            
            
            current_date = origin_file(of_slashs(end)+1:of_slashs(end)+10);

            %active tts
            active_tts = unique(floor(clusters(clusters(:,2)>=3,1)));

                for itt = active_tts'

                    all_tt_dates{itt} = [all_tt_dates{itt}; current_date];

                end


        end
            
    end

%load subject info (all tts)
for itt = 1:16

    if ~isempty(all_tt_dates{itt})

        %all_tt_dates{itt} = sort(all_tt_dates{itt},1);

        firstlast_dates{itt} = [all_tt_dates{itt}(1,:),', ',all_tt_dates{itt}(end,:)];

    end
end

subj_cell{isubj} = firstlast_dates;

end
   
end
