function cormout = singlesessions_spacecorms(bins, min_visit, sessions)
%correllates first and second half session firing across a simultaneously
%recorded population

cormout = nan(1,length(sessions));

for sesh = 1:length(sessions)
    
    load(sessions{sesh});
    
    figure; hold on;
    
    %find rates
    eptrials_complete = eptrials;
    stem_runs_complete = stem_runs;
    
    for half = 1:2
        
        if half == 1
            eptrials = eptrials(eptrials(:,5)<ceil(max(eptrials(:,5))/2),:);
            [rate_matrix_1, cs_1, all_bins_dwell_times_1, sect_bins_1] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusters(clusters(:,4)==1,1), min_visit);
            [rate_matrix_complete_1] = correllate_trialtypepaths(eptrials_complete, stem_runs_complete, bins, clusters(clusters(:,4)==1,1), min_visit);
        elseif half == 2
            eptrials = eptrials(eptrials(:,5)>=ceil(max(eptrials(:,5))/2),:);
            stem_runs = stem_runs(ceil(max(eptrials(:,5))/2)-1:end, :);
            stem_runs(:,1:2) = stem_runs(:,1:2) - repmat(min(eptrials(:,1)), size(stem_runs(:,1:2)));
            eptrials(:,1) = eptrials(:,1) - repmat(min(eptrials(:,1)), size(eptrials(:,1)));
            eptrials(:,5) = eptrials(:,5) - repmat(min(eptrials(:,5))-2, size(eptrials(:,5)));
            [rate_matrix_2, cs_2, all_bins_dwell_times_2, sect_bins_2] = correllate_trialtypepaths(eptrials, stem_runs, bins, clusters(clusters(:,4)==1,1), min_visit);
            [rate_matrix_complete_2] = correllate_trialtypepaths(eptrials_complete, stem_runs_complete, bins, clusters(clusters(:,4)==1,1), min_visit);
        end
    end
    
    %stack left and right trial blocks
    rate_matrix_1 = [rate_matrix_1(:,:,1); rate_matrix_1(:,:,2)];
    rate_matrix_2 = [rate_matrix_2(:,:,1); rate_matrix_2(:,:,2)];
    
    %correllate firing from all cells at every bin
    cor_matrix = corm(rate_matrix_1, rate_matrix_2);
    
    %drop stems
    %cor_matrix_nostem = cor_matrix([30:100 130:end], [30:100 130:end]);
    cor_matrix_nostem = cor_matrix([1:5 15:end], [1:5 15:end]);

    %{
    if sum(sum(isnan(cor_matrix_nostem))) > 0
        continue
    end
    %}
    
    %decode error
    cormout(sesh) = corm_offdiag(cor_matrix_nostem);
    
    
end