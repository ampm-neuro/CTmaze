%
load('vect2mat_idx_file.mat')

shuffs = 0; %ignore

%check to see if decodehist using correct or all trials
%check to see the number of trial-visits required for each pixel
%check to see if using all time bins or just stem runs

%
[time_class, prop_pages, pp_idx, class_all_comb, time_class_shuf, ...
    prop_pages_shuf, class_shuf_comb, p_sections_norm, accuracy, ...
    posterior_all_cell, sessions_cell, sesh_vel_pos_comb, ...
    time_class_sesh, trial_type_idx, group_ID_comb, ...
    p_sections_nnorm, p_sections_area] ...
            = rev_ALL_decode_accuracy_ShufCellID(4, 50, .2, .05, 2, vect2mat_idx, shuffs);
        
all_decode_vars_4{1} = time_class;
all_decode_vars_4{2} = [];
all_decode_vars_4{3} = prop_pages;
all_decode_vars_4{4} = pp_idx;
all_decode_vars_4{5} = class_all_comb;
all_decode_vars_4{6} = time_class_shuf;
all_decode_vars_4{7} = [];
all_decode_vars_4{8} = prop_pages_shuf;
all_decode_vars_4{9} = class_shuf_comb;
all_decode_vars_4{10} = [];
all_decode_vars_4{11} = [];
all_decode_vars_4{12} = [];
all_decode_vars_4{13} = p_sections_norm;
all_decode_vars_4{14} = accuracy;
all_decode_vars_4{15} = posterior_all_cell;
all_decode_vars_4{16} = sessions_cell;
all_decode_vars_4{17} = sesh_vel_pos_comb;
all_decode_vars_4{18} = time_class_sesh;
all_decode_vars_4{19} = trial_type_idx;
all_decode_vars_4{20} = group_ID_comb;
all_decode_vars_4{21} = p_sections_nnorm;
all_decode_vars_4{22} = p_sections_area;

% total decoding to reward areas
future_rwd_decoding = squeeze(sum(p_sections_nnorm([4 6], 1, :) + p_sections_nnorm([5 7], 2, :)))./2;
past_rwd_decoding = squeeze(sum(p_sections_nnorm([5 7], 1, :) + p_sections_nnorm([4 6], 2, :)))./2;
both_rwd_decoding = sum([future_rwd_decoding past_rwd_decoding],2);

% decoding to the reward / non-stem decoding
stem_decoding = squeeze(sum(p_sections_nnorm(2, :, :),2))./2;
rwd_decoding_proportion = both_rwd_decoding./(1-stem_decoding);

% reward area / non-stem area
future_rwd_area = squeeze(sum(p_sections_area([4 6], 1, :) + p_sections_area([5 7], 2, :)))./2;
past_rwd_area = squeeze(sum(p_sections_area([5 7], 1, :) + p_sections_area([4 6], 2, :)))./2;
both_rwd_area = sum([future_rwd_area past_rwd_area],2);
stem_area = squeeze(sum(p_sections_area(2, :, :),2))./2;
rwd_area_proportion = both_rwd_area./(1-stem_area);

% reward decoding / reward area
rwd_dec_out = rwd_decoding_proportion./rwd_area_proportion;


rwd_rep_shufs = [rwd_rep_shufs rwd_dec_out]



