function [p_value] = backwards_prediction(p_matrices, p_decodes)

%this code answers david's quesiton of whether decoding
%back to the stem from the trajectory is similar to the 'predictive' decoding
%from the stem to the future trajectory.

%find distribution of pixles among regions
%
    area = ALL_area;
    area = area';
    %combine trajectory
    area(:, 5) = area(:, 5) + area(:, 6);
    area(:, 6) = [];
    %combine stem
    area(:, 2) = area(:, 2) + area(:, 3);
    area(:, 3) = [];

%find how many timesamples there are for the approach arm and reward area. 
%This will allow for weighted averages later.
%
    visit_durations = nan(size(p_decodes,1),2);

    for sesh = 1:size(p_decodes,1)
        %number of correct arm timesamples
        visit_durations(sesh,1) = length(p_decodes{sesh,1}{1,1}(ismember(p_decodes{sesh,1}{1,1}(:,12), [5 6]) & p_decodes{sesh,1}{1,1}(:,14)==1, :));

        %number of correct reward timesamples
        visit_durations(sesh,2) = length(p_decodes{sesh,1}{1,1}(ismember(p_decodes{sesh,1}{1,1}(:,12), [7 8]) & p_decodes{sesh,1}{1,1}(:,14)==1, :));
    end

%iterate through decode matrices and avg the decoding to each section
    [comb_decod_prop_L, comb_decod_prop_R] = decodesection_p2(p_matrices, p_decodes);

%combine left and right sections decode matrices into a single matrix of 
%'future' sections
    future_decode = (comb_decod_prop_L(:, [1 2 3 4 6 8], :) + comb_decod_prop_R(:, [1 2 3 5 7 9], :))./2;

%decoding from when the rat was on the stem, arm, rwd
    stem_decodes = squeeze(future_decode(2,:,:))';
    arm_decodes = squeeze(future_decode(4,:,:))';
    rwd_decodes = squeeze(future_decode(5,:,:))';
    
    %weighted sum of arm and rwd
        traj_decodes = nan(size(arm_decodes));

        for sect = 1:size(arm_decodes,2)
            traj_decodes(:,sect) = sum([arm_decodes(:,sect) rwd_decodes(:,sect)].*visit_durations,2)./sum(visit_durations,2);
        end

        traj_decodes(:,4) = traj_decodes(:,4) + traj_decodes(:,5);
        traj_decodes(:,5) = [];
        traj_decodes = bsxfun(@rdivide, traj_decodes, sum(traj_decodes,2));
        
    %combining traj on stem
        stem_decodes(:,4) = stem_decodes(:,4) + stem_decodes(:,5);
        stem_decodes(:,5) = [];
        stem_decodes = bsxfun(@rdivide, stem_decodes, sum(stem_decodes,2));

%decoding to the trajectory while the rat was on the stem
    stem2traj_decodes = sum(stem_decodes(:,4),2);
    
%decoding while the rat was on the arm and rwd (weighted by visit duration)
    traj2stem_decodes = traj_decodes(:,2);
    
%bar plot general
    figure; barweb([mean(stem_decodes); mean(traj_decodes)], [std(stem_decodes); std(traj_decodes)])
    ylim([0 1])
    
%bar plot general (weighted by space)
    stem_spaceweight = stem_decodes./area;
    traj_spaceweight = traj_decodes./area;
    
    figure; barweb([mean(stem_spaceweight); mean(traj_spaceweight)], [std(stem_decodes); std(traj_decodes)])
    title('weighted by space')
    %ylim([0 1])

%bar plot specific
    figure; barweb([mean(stem2traj_decodes); mean(traj2stem_decodes)], [std(stem2traj_decodes); std(traj2stem_decodes)])
    ylim([0 1])
    
%bar test
    figure; barweb(mean(stem2traj_decodes-traj2stem_decodes), std(stem2traj_decodes-traj2stem_decodes), .5)
    
%ttest (null hyp is that diff is equal to zero)
    [~, p_value] = ttest(stem2traj_decodes-traj2stem_decodes);
     
end