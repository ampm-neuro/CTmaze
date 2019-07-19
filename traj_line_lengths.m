function [starts, stems, choices, returns] = traj_line_lengths(eptrials, stem_runs)

%find line lengths for each of four sections: start, stem, choice, return
%

%figure;
%sections(eptrials); 
%hold on

    %line length function
    function llen = linelength(xypos)
    %find length of line defines by 2D position point vectors x and y.
    %xypos = eptrials(:,[2 3])
    
        d = diff([xypos]);
        llen = sum(sqrt(sum(d.*d,2)));
    end 
      
    %precalculate
    num_trials = max(eptrials(:,5)-1);
    rew_y = rewards(eptrials); close gcf
    rew_y = rew_y(1,2);

    %preallocate
    starts = nan(num_trials, 3);
    stems = nan(num_trials, 3);
    choices = nan(num_trials, 3);
    returns = nan(num_trials, 3);

    
    %figure;
    %sections(eptrials); 
    %hold on
    
    %for each trial
    for trl = 2:max(eptrials(:,5))
        trial = trl-1;
        trl_type = mode(eptrials(eptrials(:,5)==trl, 7));
        trl_accu = mode(eptrials(eptrials(:,5)==trl, 8));
        
        %trial start to stem entrance
            %times
            stem_ent = stem_runs(trl, 1);
            starts(trial, :) = [linelength(eptrials(eptrials(:,5)==trl & eptrials(:,1)<stem_ent, [2 3])) trl_type trl_accu];
            %plot
            %{
            %if starts(trial,1)<105
            if round(starts(trial,1))==94%prototypical
                hold on
                plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)<stem_ent, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)<stem_ent, 3), 'k')
            end
            %}
            
        %stem entrance to stem exit
            %times
            stem_ext = stem_runs(trl, 2);
            stems(trial, :) = [linelength(eptrials(eptrials(:,1)>=stem_ent & eptrials(:,1)<stem_ext, [2 3])) trl_type trl_accu];
            %plot
            %{
            %if stems(trial,1)<195
            if round(stems(trial,1))==188 %prototypical
                hold on
                plot(eptrials(eptrials(:,1)>=stem_ent & eptrials(:,1)<stem_ext, 2), eptrials(eptrials(:,1)>=stem_ent & eptrials(:,1)<stem_ext, 3), 'b')
            end
            %}
        
        %stem exit to lick
            %times
            first_lick = min(eptrials(eptrials(:,5)==trl & eptrials(:,10)==1 & eptrials(:,1)>stem_ext, 1));
            
                %deal with (error) trials without a lick
                if isempty(first_lick)
                    first_lick = min(eptrials(eptrials(:,5)==trl & eptrials(:,11)==6 & eptrials(:,3)<=rew_y+5 & eptrials(:,1)>stem_ext, 1));
                end
                
                choices(trial, :) = [linelength(eptrials(eptrials(:,1)>=stem_ext & eptrials(:,1)<first_lick, [2 3])) trl_type trl_accu];
            %plot
            %{
            %if choices(trial,1)<250
            if round(choices(trial,1))==236 %prototypical
                hold on
                plot(eptrials(eptrials(:,1)>=stem_ext & eptrials(:,1)<first_lick, 2), eptrials(eptrials(:,1)>=stem_ext & eptrials(:,1)<first_lick, 3), 'r')
            end
            %}
            
        %depart rwd to trial end
            %times
            dep_rwd = max(eptrials(eptrials(:,5)==trl & eptrials(:,3)>rew_y-10, 1));
            returns(trial, :) = [linelength(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=dep_rwd, [2 3])) trl_type trl_accu];
            %plot
            %{
            %if returns(trial,1)<315
            if round(returns(trial,1))==303 %prototypical
                hold on
                plot(eptrials(eptrials(:,5)==trl & eptrials(:,1)>=dep_rwd, 2), eptrials(eptrials(:,5)==trl & eptrials(:,1)>=dep_rwd, 3), 'c')
            end
            %}
        
    end
    
    %sections(eptrials);
    
    
    
    
end