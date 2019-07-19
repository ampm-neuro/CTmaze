
%load('revisions_choicedec_prep.mat')
% which saved the output of temp_decode_script.m for stems only and correct
% trials only

%bring pdecodes (normalized by area) from each stage into single cell for ease
all_decode_vars = cell(4,1);
all_decode_vars{1} = all_decode_vars_21{13};
all_decode_vars{2} = all_decode_vars_22{13};
all_decode_vars{3} = all_decode_vars_23{13};
all_decode_vars{4} = all_decode_vars_4{13};

%cell of unnormalized pdecodes 

all_decode_vars_nnorm = cell(4,1);
all_decode_vars_nnorm{1} = all_decode_vars_21{21};
all_decode_vars_nnorm{2} = all_decode_vars_22{21};
all_decode_vars_nnorm{3} = all_decode_vars_23{21};
all_decode_vars_nnorm{4} = all_decode_vars_4{21};

%all_decode_vars = all_decode_vars_nnorm;


%visited pixel areas
all_decode_area = cell(4,1);
all_decode_area{1} = all_decode_vars_21{22}; all_decode_area{1}(3,:) = nan; 
    all_decode_area{1} = all_decode_area{1}./nansum(all_decode_area{1});   
all_decode_area{2} = all_decode_vars_22{22}; all_decode_area{2}(3,:) = nan; 
    all_decode_area{2} = all_decode_area{2}./nansum(all_decode_area{2});
all_decode_area{3} = all_decode_vars_23{22}; all_decode_area{3}(3,:) = nan; 
    all_decode_area{3} = all_decode_area{3}./nansum(all_decode_area{3});
all_decode_area{4} = all_decode_vars_4{22}; all_decode_area{4}(3,:) = nan; 
    all_decode_area{4} = all_decode_area{4}./nansum(all_decode_area{4});

%preallocate figures
figure; hold on

for i = 1:length(all_decode_vars)
    subplot(4,1,i); hold on

    %test suceptibility to outliers %TEST TEST TEST
    %
    if i == 3
        
        all_decode_vars{i} = all_decode_vars{i}(:,:,setdiff(1:size(all_decode_vars{i},3), [6]));
        all_decode_vars_nnorm{i} = all_decode_vars_nnorm{i}(:,:,setdiff(1:size(all_decode_vars_nnorm{i},3), [6]));
        all_decode_area{i} = all_decode_area{i}(:,:,setdiff(1:size(all_decode_area{i},3), [6]));
    
    elseif i == 4        
        all_decode_vars{i} = all_decode_vars{i}(:,:,setdiff(1:size(all_decode_vars{i},3), [15 12]));
        all_decode_vars_nnorm{i} = all_decode_vars_nnorm{i}(:,:,setdiff(1:size(all_decode_vars_nnorm{i},3), [15 12]));
        all_decode_area{i} = all_decode_area{i}(:,:,setdiff(1:size(all_decode_area{i},3), [15 12]));
    end
    %}

    %choice decoding
    celle_chc{i} = [];
    future_chc = [];
    past_chc = [];
    try
        future_chc = squeeze((all_decode_vars{i}(10, 1, :) + all_decode_vars{i}(11, 2, :))./2);
        past_chc = squeeze((all_decode_vars{i}(11, 1, :) + all_decode_vars{i}(10, 2, :))./2);
        future_chc_area = squeeze((all_decode_area{i}(10, 1, :) + all_decode_area{i}(11, 2, :))./2);
        past_chc_area = squeeze((all_decode_area{i}(11, 1, :) + all_decode_area{i}(10, 2, :))./2);
        norm_chc = (future_chc - past_chc)./(future_chc + past_chc);
        plot(1, norm_chc, 'o', 'color', [.8 .8 .8])
        plot(1, mean(norm_chc), 'k.', 'markersize', 8)
        errorbar(1, mean(norm_chc), std(norm_chc)/sqrt(length(norm_chc)), 'k')
        if ttest(norm_chc)
            plot(1,0.8, 'k*', 'markersize', 10)
        end       
        celle_chc{i} = norm_chc;
    catch
    end
    
    
    %approach decoding
    celle_arm{i} = [];
    future_apr = squeeze((all_decode_vars{i}(4, 1, :) + all_decode_vars{i}(5, 2, :))./2);
    past_apr = squeeze((all_decode_vars{i}(5, 1, :) + all_decode_vars{i}(4, 2, :))./2);
    future_apr_area = squeeze((all_decode_area{i}(4, 1, :) + all_decode_area{i}(5, 2, :))./2);
    past_apr_area = squeeze((all_decode_area{i}(5, 1, :) + all_decode_area{i}(4, 2, :))./2);
    norm_apr = (future_apr - past_apr)./(future_apr + past_apr);
    plot(2, norm_apr, 'o', 'color', [.8 .8 .8])
    plot(2, mean(norm_apr), 'k.', 'markersize', 8)
    errorbar(2, mean(norm_apr), std(norm_apr)/sqrt(length(norm_apr)), 'k')
    if ttest(norm_apr)
        plot(2,0.8, 'k*', 'markersize', 10)
    end
    celle_arm{i} = norm_apr;

    %reward decoding
    celle_rwd{i} = [];
    future_rwd = squeeze((all_decode_vars{i}(6, 1, :) + all_decode_vars{i}(7, 2, :))./2);
    past_rwd = squeeze((all_decode_vars{i}(7, 1, :) + all_decode_vars{i}(6, 2, :))./2);
    future_rwd_area = squeeze((all_decode_area{i}(6, 1, :) + all_decode_area{i}(7, 2, :))./2);
    past_rwd_area = squeeze((all_decode_area{i}(7, 1, :) + all_decode_area{i}(6, 2, :))./2);
    norm_rwd = (future_rwd - past_rwd)./(future_rwd + past_rwd);
    plot(3, norm_rwd, 'o', 'color', [.8 .8 .8])
    plot(3, mean(norm_rwd), 'k.', 'markersize', 8)
    errorbar(3, mean(norm_rwd), std(norm_rwd)/sqrt(length(norm_rwd)), 'k')    
    if ttest(norm_rwd)
        plot(3,0.8, 'k*', 'markersize', 10)
    end
    celle_rwd{i} = norm_rwd;

    %return decoding
    celle_rtn{i} = [];
    future_rtn = squeeze((all_decode_vars{i}(8, 1, :) + all_decode_vars{i}(9, 2, :))./2);
    past_rtn = squeeze((all_decode_vars{i}(9, 1, :) + all_decode_vars{i}(8, 2, :))./2);
    future_rtn_area = squeeze((all_decode_area{i}(8, 1, :) + all_decode_area{i}(9, 2, :))./2);
    past_rtn_area = squeeze((all_decode_area{i}(9, 1, :) + all_decode_area{i}(8, 2, :))./2);
    norm_rtn = (future_rtn - past_rtn)./(future_rtn + past_rtn);
    plot(4, norm_rtn, 'o', 'color', [.8 .8 .8])
    plot(4, mean(norm_rtn), 'k.', 'markersize', 8)
    errorbar(4, mean(norm_rtn), std(norm_rtn)/sqrt(length(norm_rtn)), 'k')
    if ttest(norm_rtn)
        plot(4,0.8, 'k*', 'markersize', 10)
    end
    celle_rtn{i} = norm_rtn;

    %traj decoding (chc + arm)
    celle_ChcArm{i} = [];
    try
        future_ChcArm = future_chc + future_apr;
        past_ChcArm = past_chc + past_apr;
        future_ChcArm_area = future_chc_area + future_apr_area;
        past_ChcArm_area = past_chc_area + past_apr_area;
        norm_ChcArm = (future_ChcArm - past_ChcArm)./(future_ChcArm + past_ChcArm);
        plot(5, norm_ChcArm, 'o', 'color', [.8 .8 .8])
        plot(5, mean(norm_ChcArm), 'k.', 'markersize', 8)
        errorbar(5, mean(norm_ChcArm), std(norm_ChcArm)/sqrt(length(norm_ChcArm)), 'k')
        if ttest(norm_ChcArm)
            plot(5,0.8, 'k*', 'markersize', 10)
        end

        %load celle for choice+arm trajectory figure
        celle_ChcArm{i} = norm_ChcArm;
    catch
    end


    %traj decoding (arm + rwd)
    future_ArmRwd = future_apr + future_rwd;
    past_ArmRwd = past_apr + past_rwd;
    future_ArmRwd_area = future_apr_area + future_rwd_area;
    past_ArmRwd_area = past_apr_area + past_rwd_area;
    norm_ArmRwd = (future_ArmRwd - past_ArmRwd)./(future_ArmRwd + past_ArmRwd);
    plot(6, norm_ArmRwd, 'o', 'color', [.8 .8 .8])
    plot(6, mean(norm_ArmRwd), 'k.', 'markersize', 8)
    errorbar(6, mean(norm_ArmRwd), std(norm_ArmRwd)/sqrt(length(norm_ArmRwd)), 'k')


    if ttest(norm_ArmRwd)
        plot(6,0.8, 'k*', 'markersize', 10)
    end


    %traj decoding (chc + arm + rwd)
    try
        future_traj = future_chc + future_apr + future_rwd;
        past_traj = past_chc + past_apr + past_rwd;
        future_traj_area = future_chc_area + future_apr_area + future_rwd_area;
        past_traj_area = past_chc_area + past_apr_area + past_rwd_area;
        norm_trj = (future_traj - past_traj)./(future_traj + past_traj);
        plot(7, norm_trj, 'o', 'color', [.8 .8 .8])
        plot(7, mean(norm_trj), 'k.', 'markersize', 8)
        errorbar(7, mean(norm_trj), std(norm_trj)/sqrt(length(norm_trj)), 'k')

        if ttest(norm_trj)
            plot(7,0.8, 'k*', 'markersize', 10)
        end
        catch
    end



    %figure aesthetics
    set(gca,'TickLength',[0, 0])
    xlim([.5 7.5])
    ylim([-1 1])
    hold on; plot(xlim, [0 0], 'k--')
    xticks(1:7)
    xticklabels({'Choice', 'Arm', 'Reward', 'Return', 'Chc+Arm', 'Arm+Rwd', 'Chc+Arm+Rwd'})
    
    
    %total decoding to section (total section / total nonstem) * area_correction
    stem_dec = squeeze((all_decode_vars{i}(2, 1, :) + all_decode_vars{i}(2, 2, :))./2);
    stem_area = squeeze((all_decode_area{i}(2, 1, :) + all_decode_area{i}(2, 2, :))./2);
    
    celle_chc_total{i} = (future_chc+past_chc) ./ (1-stem_dec);
        celle_chc_area{i} = (future_chc_area+past_chc_area) ./ (1-stem_area);
        %celle_chc_total{i} = celle_chc_total{i}./celle_chc_area{i};
        celle_chc_total{i} = norm_diff_by_sum(celle_chc_total{i}, celle_chc_area{i});
        
    celle_arm_total{i} = (future_apr+past_apr) ./ (1-stem_dec);
        celle_arm_area{i} = (future_apr_area+past_apr_area) ./ (1-stem_area);
        %celle_arm_total{i} = celle_arm_total{i}./celle_arm_area{i};
        celle_arm_total{i} = norm_diff_by_sum(celle_arm_total{i}, celle_arm_area{i});
        
        
    %rwd
    celle_rwd_total{i} = (future_rwd+past_rwd) ./ (1-stem_dec);
    celle_rwd_area{i} = (future_rwd_area+past_rwd_area) ./ (1-stem_area);
    celle_rwd_total{i} = celle_rwd_total{i}./celle_rwd_area{i};
    %celle_rwd_total{i} = norm_diff_by_sum(celle_rwd_total{i}, celle_rwd_area{i});
        
        %past
        celle_rwd_total_past{i} = (past_rwd) ./ (1-stem_dec);
        celle_rwd_area_past{i} = (past_rwd_area) ./ (1-stem_area);
        celle_rwd_total_past{i} = celle_rwd_total_past{i}./celle_rwd_area_past{i};
        %celle_rwd_total_past{i} = norm_diff_by_sum(celle_rwd_total_past{i}, celle_rwd_area_past{i});
        
        %future
        celle_rwd_total_future{i} = (future_rwd) ./ (1-stem_dec);
        celle_rwd_area_future{i} = (future_rwd_area) ./ (1-stem_area);
        celle_rwd_total_future{i} = celle_rwd_total_future{i}./celle_rwd_area_future{i};
        %celle_rwd_total_future{i} = norm_diff_by_sum(celle_rwd_total_future{i}, celle_rwd_area_future{i});
        
        
        
        
    celle_ChcArm_total{i} = (future_ChcArm+past_ChcArm) ./ (1-stem_dec);
        celle_ChcArm_area{i} = (future_ChcArm_area+past_ChcArm_area) ./ (1-stem_area);
        celle_ChcArm_total{i} = celle_ChcArm_total{i}./celle_ChcArm_area{i};
        %celle_ChcArm_total{i} = norm_diff_by_sum(celle_ChcArm_total{i}, celle_ChcArm_area{i});
        
        
    %old traj    
    celle_ArmRwd_total{i} = (future_ArmRwd+past_ArmRwd) ./ (1-stem_dec);
        celle_ArmRwd_area{i} = (future_ArmRwd_area+past_ArmRwd_area) ./ (1-stem_area);
        celle_ArmRwd_total{i} = celle_ArmRwd_total{i}./celle_ArmRwd_area{i};
        %celle_ArmRwd_total{i} = norm_diff_by_sum(celle_ArmRwd_total{i}, celle_ArmRwd_area{i});
        
        %past
        celle_ArmRwd_total_past{i} = (past_ArmRwd) ./ (1-stem_dec);
        celle_ArmRwd_area_past{i} = (past_ArmRwd_area) ./ (1-stem_area);
        %celle_ArmRwd_total_past{i} = celle_ArmRwd_total_past{i}./celle_ArmRwd_area_past{i};
        celle_ArmRwd_total_past{i} = norm_diff_by_sum(celle_ArmRwd_total_past{i}, celle_ArmRwd_area_past{i});
        
        %future
        celle_ArmRwd_total_future{i} = (future_ArmRwd) ./ (1-stem_dec);
        celle_ArmRwd_area_future{i} = (future_ArmRwd_area) ./ (1-stem_area);
        %celle_ArmRwd_total_future{i} = celle_ArmRwd_total_future{i}./celle_ArmRwd_area_future{i};
        celle_ArmRwd_total_future{i} = norm_diff_by_sum(celle_ArmRwd_total_future{i}, celle_ArmRwd_area_future{i});

end


%accessory plots
%try; errorbar_plot(celle_chc); title choice; hold on; plot(xlim, [0 0], 'k--'); catch; end
%errorbar_plot(celle_arm); title arm; hold on; plot(xlim, [0 0], 'k--')
%errorbar_plot(celle_rwd); title reward; hold on; plot(xlim, [0 0], 'k--')
%try; figure; errorbar_plot(celle_ChcArm); title ChoiceArm; hold on; plot(xlim, [0 0], 'k--'); catch; end

%reward only
figure; errorbar_plot(celle_rwd_total); title('Reward total'); hold on; plot(xlim, [1 1], 'k--')
%figure; errorbar_plot(celle_rwd_total_past); title('Reward past'); hold on; plot(xlim, [0 0], 'k--')
%errorbar_plot(celle_rwd_total_future); title('Reward future'); hold on; plot(xlim, [0 0], 'k--')

%old traj only
%figure; errorbar_plot(celle_ArmRwd_total); title('Traj total'); hold on; plot(xlim, [0 0], 'k--'); ylim([-1 1])
%figure; errorbar_plot(celle_ArmRwd_total_past); title('Traj past'); hold on; plot(xlim, [1 1], 'k--')
%errorbar_plot(celle_ArmRwd_total_future); title('Traj future'); hold on; plot(xlim, [1 1], 'k--')


%figure; errorbar_plot(celle_arm_total); title('Arm total'); hold on; plot(xlim, [0 0], 'k--')
%figure; errorbar_plot(celle_ChcArm_total); title('ChcArm total'); hold on; plot(xlim, [1 1], 'k--')
%figure; errorbar_plot(celle_ArmRwd_total); title('ArmRwd total'); hold on; plot(xlim, [0 0], 'k--')






