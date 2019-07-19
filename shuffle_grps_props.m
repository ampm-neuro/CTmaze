function shuf_out = shuffle_grps_props(iterations, vector_cell_array)
%shuf_out = shuffle_grps_props(iterations, vector_cell_array)
%
% this function takes a cell array of multiple column vectors (of 0s and 
% 1s) and shuffles the values between them, maintaining the original 
% length of each vector.
%
% CAN BE MODIFIED TO DEAL WITH MEANS, NOT PROPORTIONS
%
% the proportion of 1s in each vector is then calculated and the absolute
% mean error between the groups is reported.
%
% this is done iterations number of times, all reported in shuf_out
%
% if iterations is 0, no shuffle is performed, and observed data is
% reported
%

%combined vector
cmb_vect = [];
for v = 1:length(vector_cell_array)
    cmb_vect = [cmb_vect; double(vector_cell_array{v})];
end

if iterations > 0
    
    %preallocate shuf_out
    shuf_out = nan(1, iterations);
    
    for i = 1:iterations
        
        %shuffle
        cmb_vect = cmb_vect(randperm(length(cmb_vect)));
    
        %calculate error and load
        shuf_out(i) = mean_sqr_err_prop(cmb_vect, vector_cell_array);
        
    end
    
else
    
    %calculate error and load
    shuf_out = mean_sqr_err_prop(cmb_vect, vector_cell_array);
    
    
end


    %calculate mean squared error
    function out = mean_sqr_err_prop(combo_vect, cell_array_vects)
        
        props = nan(size(cell_array_vects));
        
        count = 0; 
        for vect = 1:length(cell_array_vects)
            
            cell_array_vects{vect} = combo_vect(count+1 : count+length(cell_array_vects{vect}));
            %props(vect) = sum(cell_array_vects{vect}==1)/sum(~isnan(cell_array_vects{vect}));
            props(vect) = mean(cell_array_vects{vect});
            
            count = count+length(cell_array_vects{vect});
        end
        
        out = sum((props - repmat(mean(props), size(props))).^2)/length(props);
    end


end