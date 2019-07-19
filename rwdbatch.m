function [summary] = rwdbatch(eptrials, clusters)

%evaluates each cell in clusters for statistically significant
%discrimination between reward locations using the ratewindow function
%
%cells are given a 1 if the difference between their firing rates at each
%reward location is statistically significant. Otherwise, they are given a
%0.
%
%statistical significance is defined as a t-score greater than 2. Welch's
%test is used instead of the traditional student t-test, as Welch's test
%does not assume equal variances or population sizes.

%preallocate vectors
one_sec_after = nan(length(clusters), 1);
one_sec_surround = nan(length(clusters), 1);
three_sec_after = nan(length(clusters), 1);
dms_rwd = zeros(length(clusters), 1);
dms_rwd_p_values = nan(length(clusters), 1);

%supress figures from ratewindow (actually just makes invisible
%figures)
%set(0,'DefaultFigureVisible','off')

%fill vectors by calling ratewindow for welch t-test score
for c = 1:length(clusters)
        
        [~, dms_rwd(c), dms_rwd_p_values(c)] = ratewindow(eptrials, clusters(c), 20, .5, .5, 0);

end

%reset figure visibility
%set(0,'DefaultFigureVisible','on')

%replace t-test scores with 1's (sig) or 0's (not sig)
one_sec_after(abs(one_sec_after)<=2) = 0;
one_sec_after(abs(one_sec_after)>2) = 1;

one_sec_surround(abs(one_sec_surround)<=2) = 0;
one_sec_surround(abs(one_sec_surround)>2) = 1;

three_sec_after(abs(three_sec_after)<=2) = 0;
three_sec_after(abs(three_sec_after)>2) = 1;



end