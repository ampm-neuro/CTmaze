function [shuffle_outcomes] = shuffle(p_decodes, iterations)


shuffle_outcomes = [];
progress = [];local_progress = '0%'

%preallocate
shuffle_outcomes = nan(iterations, 2);

for i = 1:iterations
    
    [~, cor_traj_like_trl] = ALL_p2(p_decodes, 1);

    %[cor_traj_like_C, cor_traj_like_E, ~, behavioral_contribution] = ALL_p2(p_decodes);
    
    shuffle_outcomes(i, 1) = mean(cor_traj_like_trl(cor_traj_like_trl(:,8)<1.34 & cor_traj_like_trl(:,9)~=5 & cor_traj_like_trl(:,7)==1,3));
    shuffle_outcomes(i, 2) = mean(cor_traj_like_trl(cor_traj_like_trl(:,8)<1.34 & cor_traj_like_trl(:,9)~=5 & cor_traj_like_trl(:,7)==2,3));
    
    
    %report local progress
    if i/iterations > .90 && progress == 81         
        progress = 91;local_progress = '91%'       
    elseif i/iterations > .80 && progress == 71        
        progress = 81;local_progress = '81%'        
    elseif i/iterations > .70 && progress == 61        
        progress = 71;local_progress = '71%'    
    elseif i/iterations > .60 && progress == 51       
        progress = 61;local_progress = '61%'    
    elseif i/iterations > .50 && progress == 41        
        progress = 51;local_progress = '51%'   
    elseif i/iterations > .40 && progress == 31        
        progress = 41;local_progress = '41%'   
    elseif i/iterations > .30 && progress == 21  
        progress = 31;local_progress = '31%'
    elseif i/iterations > .20 && progress == 11 
        progress = 21;local_progress = '21%'        
    elseif i/iterations > .10 && progress == 1   
        progress = 11;local_progress = '11%'   
    elseif i/iterations > .01 && isempty(progress)    
        progress = 1;local_progress = '1%'     
    end
    
i
end


local_progress = '100%'
end