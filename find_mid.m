function positions = find_mid(lvector, num_pos)
    %takes logical vector "lvector" and returns num_pos number of
    %coordinate positions of the most-middle logical trues
    %
    % eg, a = [0 0 1 0 1 1 1]
    % [3 5] = find_mid(a, 2)
    %

    lvector = double(lvector);
    
    %check to make sure lvector contains only 0s and 1s
    if sum(~ismember(lvector, [0 1])) > 0 
        error('lvector must contain only 0s and 1s')
    
    %check number of desired items is available
    elseif sum(lvector) < num_pos
        error('too few logical trues in lvector for given num_pos')
    end

    %positions = [];
    low = 0;%counter
    high = 0;%counter

    %loop to find smallest centered window that includes num_pos number of
    %logical trues
    while 1

        %current bounds of search area
        mid_low = round(length(lvector)/2-num_pos/2)+1-low; %+50 for no overlap in corm learning
        mid_high = round(length(lvector)/2-num_pos/2)+num_pos+high; %+50 for no overlap in corm learning
        
        
        %check for dimension error
        if mid_low < 1 || mid_high > length(lvector)
            error('search failed')
        end
           

        %if correct number of logical trues exist in search area
        if sum(lvector(mid_low:mid_high)) == num_pos;

            %set items out of search area to logical false
            lvector(1:mid_low-1) = 0;
            lvector(mid_high+1:end) = 0;

            %return output
            positions = find(lvector==1);

            %break loop
            break

        %if incorrect number, widen range (low-end first)    
        elseif low==high || low<high
            low = low+1;
        else
            high = high + 1;
        end

    end   
end