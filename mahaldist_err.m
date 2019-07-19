function [mean_out, std_out, shuf_out, shuf_out_2,  m_dists_same_opp, comb_safters, percent_correct] = mahaldist_err(stage_numbers, shuffs, varargin)
%instead of classifying each point, it asks how distant is it to items in 
%the other class compared to the distance to items in its own class

if nargin == 3
    rng_ = varargin{1};
end

pc_dims = 12;

%calculate firing rates
[comb_safters, ~, ID_idx, percent_correct] = ALL_keytimes_LR_err(stage_numbers, rng_);

num_cells = size(comb_safters, 2)
left_trials_corr = sum(ID_idx==1)
right_trials_corr = sum(ID_idx==2)
left_trials_eror = sum(ID_idx==3)
right_trials_error = sum(ID_idx==4)

size(comb_safters)

%standardize
%
comb_safters = comb_safters - repmat(mean(comb_safters), size(comb_safters,1), 1);
stds = std(comb_safters);
stds(stds==0) = 1;
comb_safters = comb_safters./repmat(stds, size(comb_safters,1), 1);
comb_safters_full = comb_safters(:,stds~=1);
%}

%{
std_hold = [comb_safters; rwd_rates];
std_hold = std_hold - repmat(mean(std_hold), size(std_hold,1), 1);
stds = std(std_hold);
stds(stds==0) = 1;
std_hold = std_hold./repmat(stds, size(std_hold,1), 1);
comb_safters = std_hold(:,stds~=1);
%}
specificity_out = nan(1,shuffs);

%cell restrict
%rand_cells = randperm(size(comb_safters_full,2));
%comb_safters = comb_safters_full(:, rand_cells(1:10));
%comb_safters = comb_safters(:, end-49:end);
comb_safters_shuf_hold = comb_safters;



%percent correct constrain



%Dimensionality reduction
%[~, comb_safters] = pca(comb_safters);
%comb_safters = comb_safters(:,1:pc_dims);

%{
pcdim = [1 2 3];
id_hold = [ID_idx; ID_idx+repmat(max(ID_idx), size(ID_idx))];
figure; hold on
colors = [255 225 102; 51 153 255;  255 178 102; 0  113.9850  188.9550];
for t = 1:max(id_hold)
    plot(comb_safters(id_hold==t,pcdim(1)), comb_safters(id_hold==t,pcdim(2)), '.', 'Markersize', 30, 'Color', colors(t, :)./255)
    %plot3(comb_safters(id_hold==t,pcdim(1)), comb_safters(id_hold==t,pcdim(2)), comb_safters(id_hold==t,pcdim(3)), '.', 'Markersize', 30, 'Color', colors(t, :)./255)
end
hold off
%}

%distances
m_dist_specificity = nan(size(comb_safters,1),1);
m_dists_same_opp = nan(size(comb_safters,1),3);
%dist_specificity = nan(size(comb_safters,1),1);
for i = 1:size(comb_safters,1)

    current = comb_safters(i,:);
    comp_idx = 1:size(comb_safters,1); comp_idx = comp_idx~=i;
    
    if ismember(ID_idx(i), [1 3])
        id_idx_opposite = (ismember(ID_idx, [2 4]))'; 
        id_idx_same = (ismember(ID_idx, [1 3]))';
    elseif ismember(ID_idx(i), [2 4])
        id_idx_opposite = (ismember(ID_idx, [1 3]))'; 
        id_idx_same = (ismember(ID_idx, [2 4]))';
    end
    opposite = comb_safters(comp_idx & id_idx_opposite, :);
    same = comb_safters(comp_idx & id_idx_same, :);
    opposite_center = mean(comb_safters(comp_idx & id_idx_opposite, :));
    same_center = mean(comb_safters(comp_idx & id_idx_same, :));

    %rwd = logical((id_hold>2)');
    %rwd_same = logical((id_hold==id_hold(i)+2)');
    %opposite = comb_safters(rwd & ~rwd_same, :);
    %same = comb_safters(rwd & rwd_same, :);

    %{
    m_dist_opposite = mahal(current, opposite)/sqrt(size(comb_safters,2))
    m_dist_same = mahal(current, same)/sqrt(size(comb_safters,2))
    
    m_dist_specificity(i) = (m_dist_opposite-m_dist_same)/(m_dist_opposite+m_dist_same);
    m_dists_same_opp(i, :) = [m_dist_same m_dist_opposite m_dist_specificity(i)];
    %}

    %
    dist_opposite = mean(dist(current, opposite_center'))/sqrt(size(comb_safters,2));
    dist_same = mean(dist(current, same_center'))/sqrt(size(comb_safters,2));
    m_dist_specificity(i) = (dist_opposite-dist_same)/(dist_opposite+dist_same);
    m_dists_same_opp(i, :) = [dist_same dist_opposite m_dist_specificity(i)];
    %}
end

%figure; hist(dist_specificity)
%mean_out = nanmean(m_dist_specificity(ismember(ID_idx, [1 2])))
mean_out = m_dist_specificity(ismember(ID_idx, [1 2]))

std_out = nanstd(m_dist_specificity);

%shuffle
shuf_out = nan(shuffs, 1);
shuf_out_2 = nan(shuffs, 1);
for shuf = 1:shuffs

    %shuffle index matrix
    comb_safters_shuf = nan(size(comb_safters_shuf_hold)); 
    for i = 1:size(comb_safters_shuf_hold,2)
        comb_safters_shuf(:,i) = comb_safters_shuf_hold(randperm(size(comb_safters_shuf_hold,1)), i);
    end

    %dr
    %[~, comb_safters_shuf] = pca(comb_safters_shuf);
    %comb_safters_shuf = comb_safters_shuf(:,1:pc_dims);
    
    %measure and report
    m_dist_specificity_shuf = nan(size(comb_safters_shuf,1),1);
    for i = 1:size(comb_safters_shuf,1)
        
        current_shuf = comb_safters_shuf(i,:);
        comp_idx_shuf = 1:size(comb_safters_shuf,1); comp_idx_shuf = comp_idx_shuf~=i;
        id_idx_opposite_shuf = (ID_idx~=ID_idx(i))'; id_idx_same_shuf = (ID_idx==ID_idx(i))';
        %opposite_shuf = comb_safters_shuf(comp_idx_shuf & id_idx_opposite_shuf, :);
        %same_shuf = comb_safters_shuf(comp_idx_shuf & id_idx_same_shuf, :);
        opposite_center_shuf = mean(comb_safters_shuf(comp_idx_shuf & id_idx_opposite_shuf, :));
        same_center_shuf = mean(comb_safters_shuf(comp_idx_shuf & id_idx_same_shuf, :));
    
        %m_dist_opposite_shuf = mahal(current_shuf, opposite_shuf)/sqrt(size(comb_safters_shuf,2));
        %m_dist_same_shuf = mahal(current_shuf, same_shuf)/sqrt(size(comb_safters_shuf,2));
        %m_dist_specificity_shuf(i) = m_dist_opposite_shuf/m_dist_same_shuf;  
        
        dist_opposite_shuf = mean(dist(current_shuf, opposite_center_shuf'))/sqrt(size(comb_safters_shuf,2));
        dist_same_shuf = mean(dist(current_shuf, same_center_shuf'))/sqrt(size(comb_safters_shuf,2));
        m_dist_specificity_shuf(i) = (dist_opposite_shuf-dist_same_shuf)/(dist_opposite_shuf+dist_same_shuf);
        
        
    end
    
    shuf_out(shuf) = mean(m_dist_specificity_shuf);
    shuf_out_2(shuf) = sum(m_dist_specificity_shuf>0)/sum(~isnan(m_dist_specificity_shuf));
end
    shuf_out = sort(shuf_out);
    shuf_out_2 = sort(shuf_out_2);
end