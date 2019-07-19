function lin_pos_col = linearize_pos(eptrials, bins)
% Computes the linearized position along the continuous tmaze by replacing
% the rat's instantaneous position with one of 'bins' bins starting at the 
% right arm / choice point and ending at the left entrance to the start 
% area. Outputs a column of bin numbers length size(eptrials,1).


% find reward anchor positions
[XYLR] = rewards(eptrials);

% bin positions
%
bin_xy = nan(53, 2);

    % right choice
    bin_xy(01,:) = [1012.5, 1162.5];
    bin_xy(02,:) = [1037.5, 1170.0];
    
    % right arm
    bin_xy(03,:) = [1062.5, 1170.0];
    bin_xy(04,:) = [1087.5, 1165.0];
    bin_xy(05,:) = [1112.5, 1160.0];
    
    % right reward
    bin_xy(06,:) = [1135.5, 1149.5];
    bin_xy(07,:) = [1149.0, 1127.0];
    bin_xy(08,:) = [1156.5, 1104.0];
    
    % right return
    bin_xy(09,:) = [1163.5, 1080.0];
    bin_xy(10,:) = [1161.0, 1055.0];
    bin_xy(11,:) = [1155.5, 1030.5];
    bin_xy(12,:) = [1150.0, 1006.0];
    bin_xy(13,:) = [1143.0, 981.5];
    bin_xy(14,:) = [1135.0, 957.0];
    bin_xy(15,:) = [1127.0, 932.5];
    bin_xy(16,:) = [1118.5,908.5];
    bin_xy(17,:) = [1109.5, 884.5];
    bin_xy(18,:) = [1090.5, 867.5];
    bin_xy(19,:) = [1065.5, 867.5];
    
    % right start
    bin_xy(20,:) = [1040.5, 867.5];
    bin_xy(21,:) = [1015.5, 867.5];
    bin_xy(22,:) = [1000.0, 887.5];
    bin_xy(23,:) = [1000.0, 912.5];
    
    % stem 
    bin_xy(24,:) = [1000.0, 937.5];
    bin_xy(25,:) = [1000.0, 962.5];
    bin_xy(26,:) = [1000.0, 987.5];
    bin_xy(27,:) = [1000.0, 1012.5];
    bin_xy(28,:) = [1000.0, 1037.5];
    bin_xy(29,:) = [1000.0, 1062.5];
    bin_xy(30,:) = [1000.0, 1087.5];
    
    % left choice
    bin_xy(31,:) = [1000.0, 1113.5];
    bin_xy(32,:) = [1000.0, 1139.5];
    
    % mirror bins (left choice - left start)
    bin_xy(33:53,:) = [bin_xy(1:21,1) - 2*(bin_xy(1:21,1)-1000) bin_xy(1:21,2)];
    
    % interp to find input number of spatial bin locations
    cpe = [bin_xy(32,:); bin_xy; bin_xy(22,:)];   
    bin_xy = [interp1(1:size(cpe,1), cpe(:,1), linspace(1,size(cpe,1),bins+2))'...
        interp1(1:size(cpe,1), cpe(:,2), linspace(1,size(cpe,1),bins+2))'];
    bin_xy = bin_xy(2:end-1,:);
    
    % plot check
    %{
    posplot(eptrials, 1000); 
    %plot(bin_xy(:,1), bin_xy(:,2), 'ko')
    for i = 1:size(bin_xy,1)
        text(bin_xy(i,1), bin_xy(i,2),num2str(i))
    end
    %}

% distance between bins
inter_bin_dists = nan(size(bin_xy,1)-1,1);
for ibin = 1:size(bin_xy,1)-1
    inter_bin_dists(ibin) = pdist(bin_xy(ibin:ibin+1,:));
end
mean_ibd = mean(inter_bin_dists);
    
% assign bin numbers based on the distance between every observed position 
% and every spatial bin
obs_pos = eptrials(:,2:3);
bin_nums = 1:bins;
lin_pos_col = nan(size(obs_pos,1),1);
for ipos = 1:size(obs_pos,1)
    
    local_dists = pdist([obs_pos(ipos,:); bin_xy]);
    local_dists = local_dists(1:size(bin_xy,1));
    assigned_bin = bin_nums(local_dists==min(local_dists));
    if min(local_dists) < mean_ibd*1.5
        lin_pos_col(ipos) = assigned_bin;
    else
        lin_pos_col(ipos) = nan;
    end
end



  