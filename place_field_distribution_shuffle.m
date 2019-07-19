shuf_ss = nan(1,10000);
shuffled_fields = nan(size(fields_all_ot));
for i1 = 1:100
    
    %shuffle field locations
    for i2 = 1:size(fields_all_ot,1)
        
        hold_fields = fields_all_ot(i2,:); 
        hold_fields = hold_fields(randperm(length(hold_fields)));
        
        shuffled_fields(i2,:) = hold_fields;
        
        
        
    end
    
    %calculate distribution
    fields_comb = [shuffled_fields(:,1) sum(shuffled_fields(:,2:3),2) shuffled_fields(:,4) sum(shuffled_fields(:,5:6),2) shuffled_fields(:,7)];
        
    weighted_dist_comb = (sum(fields_comb)./visit_proportions_ot)./sum((sum(fields_comb)./visit_proportions_ot))./(1/length(visit_proportions_ot))

    shuf_ss(i1) = sum((weighted_dist_comb - ones(size(weighted_dist_comb))).^2);

    
    
    
end