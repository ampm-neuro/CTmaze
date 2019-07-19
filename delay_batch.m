function summary = delay_batch(eptrials, clusters, stem_entrance)
%tests three delay related firing questions of each in clusters between
%left and right trial types
%
% (1) Does the cell fire differently, on average, during the 30s prior to
%    true stem entrance on left and right trials?
%
% (2) Does the cell fire differently in the last second before stem
%    entrance than during the rest of the delay?
%
% (3) Does the cell fire differently in the last second before stem
%    entrance on left vs right trials?
%

summary = nan(length(clusters), 3);

    for cell = 1:length(clusters)

        [end_trial_response, end_trial_diff, delay_trial_diff] = delay_end_resp(eptrials, clusters(cell), 30, 30, 0, stem_entrance); 
        summary(cell, :) = [end_trial_response, end_trial_diff, delay_trial_diff];

    end
end



