function [mean_pos_info, pos_infos] = pos_info(rates, dwell_times)
%positional information, wilent & nitz

%alter all rates to spike counts per 100ms
dwelltimes_corrections = repmat(0.1, size(dwell_times))./dwell_times;
rates_corrected = rates.*dwelltimes_corrections;
spikecounts = round(rates_corrected.*repmat(0.1, size(dwell_times)));
%spikecounts = rates_corrected.*repmat(0.1, size(dwell_times));

%overall probability of seeing each spike count
all_scs = unique(spikecounts(~isnan(spikecounts)));
sc_all_probs = nan(size(all_scs));
mean_FR_all = nanmean(nanmean(spikecounts));
for isc = 1:length(all_scs)
    sc = all_scs(isc);
    spikecounts_nnan = spikecounts(~isnan(spikecounts));
    
    %empirical probability
    %sc_all_probs(isc) = sum(spikecounts_nnan==sc)./length(spikecounts_nnan);
    
    %pessimistic empirical probability
    %
    sc_all_probs(isc) = (sum(spikecounts_nnan==sc)-1)./length(spikecounts_nnan);
    if sc_all_probs(isc)==0
        sc_all_probs(isc) = 1*45*size(rates,2);
    end
    %}
    
    
    %poisson probability
    %{
    o_spikes = sc;
    e_spikes = mean_FR_all; if e_spikes == 0; e_spikes = 0.000000001; end
    sc_all_probs(isc) = exp(o_spikes.*log(e_spikes)-e_spikes-gammaln(o_spikes+ones(size(o_spikes))));
    if sc_all_probs(isc) < 1/sum(~isnan(spikecounts(:)))
        sc_all_probs(isc) = 1/sum(~isnan(spikecounts(:)));
    end
    %}

end

%probability of seeing spike count at each position
pos_infos = nan(size(spikecounts,2),1);
for ipos = 1:size(spikecounts,2)

    %all spike counts at current position
    %pos_scs = spikecounts(~isnan(spikecounts(:,ipos)),ipos);
    pos_scs = spikecounts(~isnan(spikecounts(:,ipos)),ipos);
    

    %check for minimium number of visits to this position
    min_vis = 15;
    if length(pos_scs)<min_vis
        %disp('too few visits')
        continue
    end
    pos_scs = pos_scs(1:15);
    
    %for each time window at position
    pos_infos_local = nan(length(pos_scs),1);
    for ipos_sc = 1:length(pos_scs)

        %mean FR in this bin
        mean_FR_bin = mean(pos_scs);
        
        %current spike count
        sc = pos_scs(ipos_sc);
        
        %empirical probability of seeing this sc at this location
        %sc_pos_probs = sum(pos_scs==sc)./length(pos_scs);
        
        %pessimistic empirical probability
        sc_pos_probs = (sum(pos_scs==sc)-1)/length(pos_scs);
        if sc_pos_probs==0
            sc_pos_probs = 1/45;
        end
        
        %poisson distribution probability
        %{
        o_spikes = sc;
        e_spikes = mean_FR_bin; if e_spikes == 0; e_spikes = 0.000000001; end
        sc_pos_probs = exp(o_spikes.*log(e_spikes)-e_spikes-gammaln(o_spikes+ones(size(o_spikes))));
        %}
        
        %positional information
        %p(this sc at this location) / p(this sc overall)
        if ~isreal(sc_pos_probs) || ~isreal(sc_all_probs(all_scs==sc))
            continue
        end
        pos_infos_local(ipos_sc) = sc_pos_probs/sc_all_probs(all_scs==sc);
    
    end
    
    %remove outlying values
    pos_infos_local_median = nanmedian(pos_infos_local);
    pos_infos_local_std = nanstd(pos_infos_local);
    lo_bound = pos_infos_local_median - 3*pos_infos_local_std;
    hi_bound = pos_infos_local_median + 3*pos_infos_local_std;
    pos_infos_local(pos_infos_local<lo_bound | pos_infos_local>hi_bound) = [];
    
    %average across time windows
    pos_infos(ipos) = nanmean(pos_infos_local);
    
end

%check for minimium number of positions with sufficient data
min_pos_prop = 0.50;
min_pos = round(size(spikecounts,2)*min_pos_prop);

if sum(~isnan(pos_infos))<min_pos
    mean_pos_info = nan;
else
    
    %average across positons
    mean_pos_info = nanmean(pos_infos);

end












