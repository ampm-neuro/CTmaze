while length(od_error_shuffle_ot)<10000
    
   [~, od_error] = c_mtx(hold4_1, hold4_2, sorting_vector_ot, 50, 3, 25);
   od_error_shuffle_ot = [od_error_shuffle_ot; od_error];
   save('cor_mtx_data_saved.mat')
    
end