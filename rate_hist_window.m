function [rate_mean, poisson_std, bin_rates] = rate_hist_window(eptrials, cell, window_size)
%window size in seconds

%time edges, cuts off remainder at end of session
nm = max(eptrials(:,1))-rem(max(eptrials(:,1)), window_size);%new max
time_edges = linspace(min(eptrials(:,1)), nm, floor(max(eptrials(:,1))/window_size)+1);
time_edges(end) = time_edges(end)+.00000001;

%spike times
spike_times = eptrials(eptrials(:,4)==cell & eptrials(:,1)<=nm, 1);

%counts
bin_rates = histc(spike_times, time_edges); %rates at each time bin
rate_mean = mean(bin_rates); %mean rate
%poisson_std = std(bin_rates); %CAUTION
poisson_std = sqrt(rate_mean); %standard deviation of the rate

%figure; hist(bin_rates,1000)

end