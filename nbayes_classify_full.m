function [class_pca_prop, class, shuf_out, comb_safters, ID_idx, m_dist_specificity] = nbayes_classify_full(stage_numbers, shuffs)
%function calculates firing rates at multiple times on the maze and
%then attempts to classify the times based on the firing rates
%
%times on maze determined by ALL_keytimes

%calculate firing rates
[comb_safters, ID_idx] = ALL_keytimes_LR(stage_numbers);

num_cells = size(comb_safters, 2)
left_trials = sum(ID_idx==1)
right_trials = sum(ID_idx==2)

%standardize
comb_safters = comb_safters - repmat(mean(comb_safters), size(comb_safters,1), 1);
stds = std(comb_safters);
stds(stds==0) = 1;
comb_safters = comb_safters./repmat(stds, size(comb_safters,1), 1);
%comb_safters = comb_safters(:, stds~=1);
comb_safters_full = comb_safters;


%cell restrict
%rand_cells = randperm(size(comb_safters,2));
%comb_safters = comb_safters(:, rand_cells(1:55));
comb_safters = comb_safters(:, end-49:end);
comb_safters_shuf_hold = comb_safters;

%mahalanobis distance
%left_centroid = 
%mdist = mean([mahal(, ) mahal(, )]);


%Dimensionality reduction
[~, comb_safters] = pca(comb_safters);
dims = 1:10;


%PCA 2d plots
%
components = [1 2]; 
figure; hold on
for id = unique(ID_idx)'
    plot(comb_safters(ID_idx==id, components(1)), comb_safters(ID_idx==id, components(2)), '.', 'MarkerSize', 30);
end
borderx = (max(comb_safters(:,components(1))) - min(comb_safters(:,components(1))))/10;
bordery = (max(comb_safters(:,components(2))) - min(comb_safters(:,components(2))))/10;
axis([min(comb_safters(:,components(1)))-borderx max(comb_safters(:,components(1)))+borderx min(comb_safters(:,components(2)))-bordery max(comb_safters(:,components(2)))+bordery])
box off; set(gca,'TickLength',[0, 0]);
hold off
%}

%classify all data one trial at a time
class = nan(size(comb_safters,1),1);
m_dist_specificity = nan(size(comb_safters,1),1);
prior = repmat(1/length(unique(ID_idx)), 1, length(unique(ID_idx)));
for i = 1:size(comb_safters,1)
    
    test = comb_safters(i, dims);
    train = comb_safters(setdiff(1:size(comb_safters,1),i), dims);
    group_id = ID_idx(setdiff(1:size(ID_idx,1),i));
        
   	class(i) = classify(test, train, group_id);
    
    %nb_model = fitcnb(train, group_id, 'Distribution', 'kernel', 'Prior', prior);
    %class(i) = predict(nb_model, test);
    
    current = comb_safters_full(i,:);
    comp_idx = 1:size(comb_safters_full,1); comp_idx = comp_idx~=i;
    id_idx = (ID_idx~=ID_idx(i))';
    opposite = comb_safters_full(comp_idx & id_idx, :);
    same = comb_safters_full(comp_idx & id_idx, :);
    
    m_dist_opposite = mahal(current, opposite);
    m_dist_same = mahal(current, same);
    m_dist_specificity(i) = m_dist_opposite/m_dist_same;
    
    
end
 
%nb_model

%calculate success
class_pca_prop = sum(class == ID_idx)/length(class);

%FIGURES (hardish coded)
%

%classification success bar plot
%
figure; hold on

%event-specific classification success rates
bar_in = nan(1, length(unique(ID_idx)));
for id = unique(ID_idx)'
    bar_in(id) = sum(class(ID_idx==id) == ID_idx(ID_idx==id))./length(class(ID_idx==id));
end
%barchart
bar_in = mean(reshape(bar_in, length(bar_in)/2, 2),2);
bar(bar_in)
ylim([0 1.05])
box off; set(gca,'TickLength',[0, 0]);
%}

%shuffle
%
shuf_out = nan(shuffs, 1);

%warning('off','all') %pca cries about dimensionality during shuffles. 
                     %That's expected. The shuffle is creating a flat 
                     %(i.e. random) dimension.

for shuf = 1:shuffs

    %shuffle index matrix
    comb_safters_shuf = nan(size(comb_safters_shuf_hold)); 
    for i = 1:size(comb_safters_shuf_hold,2)
        comb_safters_shuf(:,i) = comb_safters_shuf_hold(randperm(size(comb_safters_shuf_hold,1)), i);
    end

    %dr
    [~, comb_safters_shuf] = pca(comb_safters_shuf);
    
    %classify and report success
    class_shuf = nan(size(comb_safters_shuf,1),1);
    for i = 1:size(comb_safters_shuf,1)
        
        test_shuf = comb_safters_shuf(i, dims);
        train_shuf = comb_safters_shuf(setdiff(1:size(comb_safters_shuf,1),i), dims);
        group_id = ID_idx(setdiff(1:size(ID_idx,1),i));

        %nb_model_shuf = fitcnb(train_shuf, group_id, 'Distribution', 'kernel', 'Prior', prior);
        %class_shuf(i) = predict(nb_model_shuf, test_shuf);

        class_shuf(i) = classify(test_shuf, train_shuf, group_id);    
    end
    
    %[class_shuf ID_idx class_shuf==ID_idx]
    
    shuf_out(shuf, 1) = sum(class_shuf == ID_idx)/length(class_shuf);
    
end

%warning('on','all')


if shuf > 0
    %overlay shuffle output on barchart
    shuf_out_sorted = sort(shuf_out);

    try

        plot([.25 1.75], [mean(shuf_out_sorted) mean(shuf_out_sorted)], 'k-') %mean shuffles
        plot([.25 1.75], [shuf_out_sorted(floor(size(shuf_out_sorted,1)*.025)) shuf_out_sorted(floor(size(shuf_out_sorted,1)*.025))], 'k--') %low bound
        plot([.25 1.75], [shuf_out_sorted(ceil(size(shuf_out_sorted,1)*.975)) shuf_out_sorted(ceil(size(shuf_out_sorted,1)*.975))], 'k--') %high bound

    catch
        
        plot([.25 1.75], [mean(shuf_out_sorted) mean(shuf_out_sorted)], 'k-') %mean shuffles
        plot([.25 1.75], [shuf_out_sorted(1) shuf_out_sorted(1)], 'k--') %low bound
        plot([.25 1.75], [shuf_out_sorted(end) shuf_out_sorted(end)], 'k--') %high bound
        display('plotted range')
    end
end
end