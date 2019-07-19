function scores = info_score(eptrials, bins, min_visits, varargin)
%finds the spatial information content of all clusters in bits per spike

if nargin ==4
    clusters = varargin{1};
elseif nargin == 5
    clusters = varargin{1};
    stage = varargin{2};
else
    clusters = unique(eptrials(~isnan(eptrials(:,4)),4))';
end

%how much time the rat spent in every pixle
min_time = 0.5; %seconds

%preallocate
scores = nan(size(clusters));
info_content = nan(bins);

for clust = clusters
    
    %mean spike counts and occupancy (in seconds) for every bin
    %[~, ~, ~, spk_ct, spc_occ] = hist2_vd(eptrials, clust, bins, min_visits);
    %[~, spk_ct, spc_occ] = trlfree_heatmap(eptrials, clust, bins, 0);
    [~, spk_ct, spc_occ] = ...
        trialbased_heatmap(eptrials, clust, 30, min_visits, min_time, 0);
    
    
    %set non-visted pixles to nans for both spikes and occupancy
    spc_occ(spc_occ<min_time) = 0;
    spk_ct(spc_occ<min_time) = 0;
    spc_occ(spc_occ==0) = nan;
    spk_ct(spk_ct==0) = nan;
        
    %how big should the gaussian kernel be?
    smooth_factor = 3; %kernel size = smooth_factor*smooth_factor
    
    %smooth occupancy and spikes
    %spc_occ = smooth2a(spc_occ, smooth_factor);
    %spk_ct = smooth2a(spk_ct, smooth_factor);
    spc_occ = smoothmtx(spc_occ, smooth_factor);
    spk_ct = smoothmtx(spk_ct, smooth_factor);
    
    %R is the overall mean firing rate
    R = nansum(spk_ct(:))/nansum(spc_occ(:));
    
    %exclude cells firing less than 3hz
    if R < 3
        continue
    end
    
    %rate heatmap
    spk_rate = spk_ct./spc_occ;
    spk_rate = reshape(zscore_mtx(spk_rate(:)), size(spk_rate));

    %spatial probabilities
    spc_p = spc_occ./nansum(spc_occ(:));

    %uniform spatial probability
    %
    R = nanmean(spk_rate(:));
    spc_p(spc_p>0) = 1;
    spc_p = spc_p./nansum(spc_p(:));
    
    %}
    
    %heatmap figure
    %
    fig_counter = 0;
    if stage==4 && rand(1) > .975
        figure; imagesc(spk_rate);colormap jet; colorbar; %caxis([0 R*2])
        %figure; imagesc(spc_p);colormap jet; colorbar
        fig_counter = 1;
    elseif stage<4 && rand(1) > .9
        figure; imagesc(spk_rate);colormap jet; colorbar; %caxis([0 R*2])
        %figure; imagesc(spc_p);colormap jet; colorbar
        fig_counter = 1;
    end
    %}
    
    
    for i = 1:numel(spc_occ)
        
        %Pi was the probability for occupancy of bin i
        Pi = spc_p(i);

        %Ri was the mean firing rate for bin i
        Ri = spk_rate(i);
        
        %relative rate
        %rr = Ri/R;
        rr = abs(Ri);
        
        %load info content for each bin        
        info_content(i) = Pi*(rr)*log2(rr);
        
    end
    
    if fig_counter ==1
        figure; imagesc(info_content);colormap jet; colorbar; %caxis([-.05 .05])
        title([num2str(nansum(info_content(:))) ' ' num2str(stage)])
    end

    %load cluster info scores
    scores(clusters==clust) = nansum(nansum(info_content)); 
        
    %clear info_content for next cluster
    info_content = nan(bins);
end


%smooth function
    function smtx_out = smoothmtx(mtx_in, smooth_factor)
        size_fix = mtx_in; 
        size_fix(~isnan(size_fix))=1;

        mask = fspecial('Gaussian',[smooth_factor smooth_factor],1.5);
        
        smtx_out = conv2nan(mtx_in, mask, 'same');smtx_out = smtx_out.*size_fix;
        %smtx_out = conv2nan(smtx_out, mask, 'same');smtx_out = smtx_out.*size_fix;
        %smtx_out = conv2nan(smtx_out, mask, 'same');smtx_out = smtx_out.*size_fix;
        %smtx_out = conv2nan(smtx_out, mask, 'same');%smtx_out = smtx_out.*size_fix;
        %smtx_out = conv2nan(smtx_out, mask, 'same');smtx_out = smtx_out.*size_fix;
        %smtx_out = conv2nan(smtx_out, mask, 'same');smtx_out = smtx_out.*size_fix;

    end

end