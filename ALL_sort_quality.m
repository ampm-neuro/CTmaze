function [L_ratios, I_distances] = ALL_sort_quality
% Get all *.mat files out of each stage folder out of each subject folder
% out of neurodata.

L_ratios = [];
I_distances = [];

%path to raw neuralynx files (origin)
path_origin = 'D:\array_5_15_2017\Project\PC Continuous Alt\Electro\Subjects _ Good Data\';

%get all the things in neurodata folder...
file_list_subjects = dir(path_origin);

%hard coded erasure of irrelevant directory folders
file_list_subjects(1:2) = [];

%exclude non-folders
file_names_subjects = {file_list_subjects([file_list_subjects(:).isdir])};

%number of folders
length_subjects = size(file_names_subjects{:},1);


%names
%file_names_subjects{:}(1:length_subjects,1).name;
%}

%iterate through subjects
for subject = 1:length_subjects

    %print update
    rat = file_names_subjects{:}(subject,1).name
    
    %get all the things in subject folder...
    file_list_sessions = dir(strcat(path_origin, num2str(file_names_subjects{:}(subject,1).name)));

    %hard coded erasure from file_list_stages of irrelevant directory folders
    file_list_sessions(1:2) = [];

    %exclude non-folders
    file_names_sessions = {file_list_sessions([file_list_sessions(:).isdir])};
    
    %number of folders
    length_sessions = size(file_names_sessions{:},1);
    
    %iterate through session folders
    for session = 1:length_sessions
        
        %current session file name
        session_file = file_names_sessions{:}(session,1).name
        
        %identify stage from session file name
        switch logical(true)
            case ~isempty(strfind(session_file, 'accl')), stage = 'acclimation';
            case ~isempty(strfind(session_file, 'cont')), stage = 'continuous';
            case ~isempty(strfind(session_file, 'ot')), stage = 'overtraining';
            case ~isempty(strfind(session_file, 'del')), stage = 'delay';
                
            otherwise
                warning(strcat('stage not identified for -', session_file))
                continue
        end 
            
        
        %check for clusts file (indicating clustering)
        if exist(strcat(path_origin, rat, '\', session_file, '\clusts.csv'), 'file')
            
            %load clusters csv
            clusters = xlsread(strcat(path_origin, '\' ,num2str(filename),'\Cluster_descriptions.xlsx'));
            if isequal(size(clusters), [2,1])
                clusters = [];
            else
                clusters = clusters(~isnan(clusters(:,1)),:);
            end
            
            %constrain clusters
            cluster_confidence = [3 4 5];
            cluster_region = [0 1 2];
            cluster_idx = ismember(clusters(:,2), cluster_confidence) & ismember(clusters(:,4), cluster_region);
            clusts = clusters(cluster_idx, 1);
            
            
            %load tt files
            for i = 1:16
                file_name = [num2str(filename), '\TT', num2str(i), '_sorted.NTT'];
                if exist(file_name, 'file')
                    
                    %load waveform features
                    [TimestampsTT, ScNumbers, CellNumbers, Features, Samples, Header] = Nlx2MatSpike_v3(file_name, [1 1 1 1 1], 1, 1, [] );
            
                
                    %calculate sort quality measures for each neuron
                    for ic = 1:size(clusts,1)
                        
                        %isolate waveforms of interest
                        cluster_locs = Features(CellNumbers==clusts(ic),:)';
                        noise_locs = Features(CellNumbers~=clusts(ic),:)';
                        
                        %calculate energy for each spike
                        %energies = waveform_energy(Samples(:,:,CellNumbers==clusts(ic)));
                        
                        %quality measures
                        L_rat = Lratio(cluster_locs, noise_locs);
                        I_dist = idist(cluster_locs, noise_locs);
                        
                        %load output
                        L_ratios = [L_ratios; L_rat];
                        I_distances = [I_distances; I_dist];
                        
                    end
                end
            end
        end
    end
end

end
