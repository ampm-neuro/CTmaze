function ftr_past_foldfig(posterior_all, sessions)
%makes futr/past aligned (folded) probability heatmaps where left trials
%are flipped to keep future along the right arm.

%bins
bins = sqrt(length(posterior_all{1}(1,:)));

for sesh = 1:length(posterior_all)

    stem_runs = [];
    
    ptrn = 'MATLAB'; 
    sesh_id_start = strfind(sessions{sesh},ptrn) + length(ptrn);
    load([cd sessions{sesh}(sesh_id_start:end)], 'eptrials', 'stem_runs');
    
    trials = unique(eptrials(eptrials(:,8)>0, 5));
    trials = trials(stem_runs(2:end,3)<1.25);
    
    left_trials = intersect(trials, unique(eptrials(eptrials(:,7)==1 & eptrials(:,8)==1, 5)));
    right_trials = intersect(trials, unique(eptrials(eptrials(:,7)==2 & eptrials(:,8)==1, 5)));

        
    left_probs = reshape(nanmean(posterior_all{sesh}(ismember(trials,left_trials),:)), 50, 50);
    right_probs = reshape(nanmean(posterior_all{sesh}(ismember(trials,right_trials),:)), 50, 50);
        
    hold = mean(cat(3, fliplr(left_probs), right_probs),3);
    %hold = (hold-fliplr(hold))./(hold+fliplr(hold));
    %hold(hold>0)=1;
    %hold(hold<0)=0;
    aligned_mtx(:,:,sesh) = hold;

end

occupied_pixles = sum(~isnan(aligned_mtx),3);

aligned_mtx = nanmean(aligned_mtx,3);
aligned_mtx(occupied_pixles<1) = nan;

matrix = aligned_mtx;

size_fix = matrix; 
size_fix(~isnan(size_fix))=1;

mask = [1 3 1; 3 4 3; 1 3 1]./20;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');%matrix = matrix.*size_fix;
matrix = conv2nan(matrix, mask, 'same');
matrix = matrix.*size_fix;

matrix = matrix./nansum(matrix(:));

figure; pcolor(matrix); shading flat

colormap jet
caxis([0 .01])

figure; 
Z = matrix;
b=bar3(Z);

matrix
sum(sum(~isnan(matrix)))

for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end





end