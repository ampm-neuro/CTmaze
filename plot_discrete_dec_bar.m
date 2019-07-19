function cell_e = plot_discrete_dec_bar(all_decode_vars_4)
%plot bar of discrete decodes to each folded maze region

%load
%load('discrete_dec_loc_props.mat')

%proportion of discrete decodes normalized by maze area
prop_dec = all_decode_vars_4{13};

%average across trials
prop_dec = mean(prop_dec,2);

%reshape
for i = 1:size(prop_dec,3)
    prop_dec_rshp(:,i) = prop_dec(:,:,i);
end
prop_dec = prop_dec_rshp;

%normalize
prop_dec_norm = prop_dec./sum(prop_dec);

%combine like regions
prop_dec_fold = ...
        [prop_dec_norm(1:3,:); sum(prop_dec_norm(4:5,:)); sum(prop_dec_norm(6:7,:)); sum(prop_dec_norm(8:9,:))];
prop_dec_fold = prop_dec_norm;
prop_dec_fold(6:7,1) = prop_dec_fold([7 6],1);
%prep for errorbar plot
cell_e = cell(1, size(prop_dec_fold,1));
for i = 1:length(cell_e)
    cell_e{i} = prop_dec_fold(i,:);
end

%plot
errorbar_plot(cell_e)
hold on; bar(mean(prop_dec_fold,2))

xlabel('maze region')
xticks auto
xticklabels({'start', 'stem', 'choice', 'arm', 'reward', 'return'})
ylabel('Proportion decodes (normalized by area)')
title('Spatial Decoding on Stem of Alternation Task')
title('Spatial Decoding on Stem of Continuous Alternation Task')