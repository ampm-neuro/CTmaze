
time_class_comb = [];
space_class_comb = [];

time_class_comb_shuf = [];
space_class_comb_shuf = [];

trial_type_idx_comb = [];

overall_space_class_post_mean = [];
overall_space_class_pre_median = [];
overall_space_class_post_median = [];
idv_space_class = cell(1, 4);
all_space_class_raw_idx = cell(4, 3);
all_time_class_raw = cell(1);

load(strcat('C:\Users\ampm1\Desktop\oldmatlab\vect2mat_idx_file.mat'))

p_sections_correct = cell(4,1);
p_sections_error = cell(4,1);

accuracy_all = cell(4,1);

count = 0;
window = .2;

for i =  [2.1 2.2 2.3 4]
    count = count+1;
    %
    if i ~= 4
        [time_class, space_class, prop_pages, pp_idx, class_all_comb,...
            time_class_shuf, space_class_shuf, prop_pages_shuf,...
            class_shuf_comb, space_class_d, space_class_smooth,...
            space_class_smooth_d, p_sections_norm, accuracy,...
            posterior_all_cell, sessions_cell, sesh_vel_pos_comb,...
            time_class_sesh, trial_type_idx]...
            = ALL_decode_accuracy(i, 50, window, .05, 2, vect2mat_idx, 1); 
    else
        [time_class, space_class, prop_pages, pp_idx, class_all_comb,...
            time_class_shuf, space_class_shuf, prop_pages_shuf,...
            class_shuf_comb, space_class_d, space_class_smooth,...
            space_class_smooth_d, p_sections_norm, accuracy,...
            posterior_all_cell, sessions_cell, sesh_vel_pos_comb,...
            time_class_sesh, trial_type_idx]...
            = ALL_decode_accuracy(i, 50, window, .05, 4, vect2mat_idx, 1); 
    end
    title(num2str(i)); 
    %}

    time_class_comb = [time_class_comb; time_class];
    space_class_comb = [space_class_comb; space_class];
    
p_sections    time_class_comb_shuf(:,count) = sort(time_class_shuf);
    space_class_comb_shuf(:,count) = sort(space_class_shuf);

    idv_space_class{count} = pp_idx;
    
    all_space_class_raw_idx{count, 1} = space_class_d;
    all_space_class_raw_idx{count, 1} = space_class_smooth;
    all_space_class_raw_idx{count, 1} = space_class_smooth_d;
   
    p_sections_correct{count} = p_sections_norm;
    p_sections_error{count} = p_sections_norm;
    
    accuracy_all{count} = accuracy;
    
    posterior_cells{count} = posterior_all_cell;
    session_cells{count} = sessions_cell;
    
    prop_pages_comb{count} = prop_pages;
    
    time_class_sesh_comb{count} = time_class_sesh;
    time_class_shuf_comb{count} = time_class_shuf;
    
end

prop_pages_plot(prop_pages_comb); title('space class')
prop_pages_plot(time_class_sesh_comb); title('time class')

ftr_traj_temp(p_sections_correct)

%{
time_class_shuf_means_all = [];
for i = 1:4
    time_class_shuf_comb_all{i} = [time_class_shuf_comb_all{i} time_class_shuf_comb{i}];
    time_class_shuf_means_all(:,i) = mean(time_class_shuf_comb_all{i})';
end
    time_class_shuf_means_all = sort(time_class_shuf_means_all);


figure; bar(time_class_comb); title time;
hold on;box off; set(gca,'TickLength',[0, 0]);
for i = 1:4
    for b = unique(idv_space_class{i}(:,5))'
        plot(i, b, 'k.', 'Markersize', 25)
    end
    plot(i, mean(unique(idv_space_class{i}(:,5))), 'k.', 'Markersize', 50)
    
    %shufs
    plot([.5 1 2 3 4 4.5], space_class_comb_shuf(1, [1 1 2 3 4 4]), 'k-')
    plot([.5 1 2 3 4 4.5], space_class_comb_shuf(floor(size(space_class_comb_shuf,1)/2), [1 1 2 3 4 4]), 'k-')
    plot([.5 1 2 3 4 4.5], space_class_comb_shuf(size(space_class_comb_shuf,1), [1 1 2 3 4 4]), 'k-')
end

figure; bar(space_class_comb); title space;
hold on;box off; set(gca,'TickLength',[0, 0]);
for i = 1:4
    for b = unique(idv_space_class{i}(:,6))'
        plot(i, b, 'k.', 'Markersize', 25)
    end
    plot(i, mean(unique(idv_space_class{i}(:,6))), 'k.', 'Markersize', 50)
    
    %shufs
    plot([.5 1 2 3 4 4.5], time_class_comb_shuf(1, [1 1 2 3 4 4]), 'k-')
    plot([.5 1 2 3 4 4.5], time_class_comb_shuf(floor(size(time_class_comb_shuf,1)/2), [1 1 2 3 4 4]), 'k-')
    plot([.5 1 2 3 4 4.5], time_class_comb_shuf(size(time_class_comb_shuf,1), [1 1 2 3 4 4]), 'k-')
end
%}
