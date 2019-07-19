function [reliability_score] = reliability(eptrials, logic_contiguitymatrix, time_binpos, field, cluster)
%detirmines the proportion of passes through field during which the cell fires

%counters
success = 0;
pass = 0;
    
%time bounds
pass_start = nan;
pass_end = nan;
    
%figure;
%plot(eptrials(isfinite(eptrials(:, 2)) & isfinite(eptrials(:, 3)), 2), eptrials(isfinite(eptrials(:, 2)) & isfinite(eptrials(:, 3)), 3), 'Color', [0.8 0.8 0.8] , 'LineWidth', 0.5, 'LineStyle', '-')
%set(gca,'xdir','reverse')
%hold on

%identify set of coordinates coorresponding to field
[i,j] = find(logic_contiguitymatrix == field);
    
%iterate through every time point
for time = 1:length(time_binpos(:,1))
        
 	%if the rat's position at the current time point is within the field
 	if sum(time_binpos(time,2) == j & time_binpos(time,3) == i) > 0
        
       	%if we haven't found a pass start yet 
       	if isnan(pass_start)
    
          	%record start time
         	pass_start = time;
            
           	%erase previous end time
          	pass_end = nan;
           
        end
        
  	%if the rat is NOT in the field
    else
        
        %if we haven't found pass end yet
     	if ~isnan(pass_start) && isnan(pass_end)
                 
          	%record end time
          	pass_end = time;
            
            %increas pass counter
          	pass = pass + 1;
            
            %plot dud pass (black)
            %plot(eptrials(eptrials(:,1) >= time_binpos(pass_start,1) & eptrials(:,1) <= time_binpos(pass_end,1), 2), eptrials(eptrials(:,1) >= time_binpos(pass_start,1) & eptrials(:,1) <= time_binpos(pass_end,1), 3), 'Color', [0 0 0], 'LineWidth', 0.5, 'LineStyle', '-');
                
            
            %fires during window pass_start : pass_end
            
            sum(time_binpos(time_binpos(:,4) == cluster, 4));
            
           	if sum(time_binpos(time_binpos(:,1) >= time_binpos(pass_start,1) & time_binpos(:,1) <= time_binpos(pass_end,1) & time_binpos(:,4) == cluster, 4)) > 0
                    
              	%increase success counter
             	success = success +1;
                
                %plot successful pass (red)
                %plot(eptrials(eptrials(:,1) >= time_binpos(pass_start,1) & eptrials(:,1) <= time_binpos(pass_end,1), 2), eptrials(eptrials(:,1) >= time_binpos(pass_start,1) & eptrials(:,1) <= time_binpos(pass_end,1), 3), 'Color', [1 0 0], 'LineWidth', 0.5, 'LineStyle', '-');
                
            end
            
            %reset pass_start
            pass_start = nan;
            
        end
    end
end
%sections(eptrials);


%reliability (high numbers = more reliability)
%must have at least 5 passes!
if pass < 5
    reliability_score = 0;
else
    reliability_score = success/pass;
end


