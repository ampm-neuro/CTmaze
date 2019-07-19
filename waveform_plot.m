function waveform_plot(filename, cell, downsampling)
%outputs four plots (one from each tetrode) of the waveform of each spike
%classified as cluster 'cell'
%
%downsampling should be high. Perhaps 100. No less than 10.


[~, ~, CellNumbers, ~, Samples, ~] = Nlx2MatSpike_v3(filename, [1 1 1 1 1], 1, 1, [] );


Samples = Samples(:,:,CellNumbers==cell);

%clean traces
%
for electrode = 1:4
    
    %clean trace min
    %
    [~, min_cols] = min(Samples(:,electrode,:));
    vect_min_cols = squeeze(min_cols);
    median_min = median(squeeze(min_cols));
    dist_to_median = vect_min_cols - repmat(median_min, size(vect_min_cols));
    misses_min = abs(dist_to_median)>3;
    Samples(:,electrode,misses_min) = NaN;
    %}
    
    %clean trace max
    %
    [~, max_cols] = max(Samples(:,electrode,:));
    vect_max_cols = squeeze(max_cols);
    median_max = median(squeeze(max_cols));
    dist_to_median = vect_max_cols - repmat(median_max, size(vect_max_cols));
    misses_max = abs(dist_to_median)>3;
    Samples(:,electrode,misses_max) = NaN;
    %}
end
%}


%determine y-axis
min_y = min(Samples(:));
max_y = max(Samples(:));
ylimit = max(abs([min_y max_y]));


%plot
for electrode = 1:4
    
    figure
    hold on
    
    for spike = 1:downsampling:size(Samples,3)
        
        plot(1:32, Samples(:, electrode, spike), 'Color', [.5 .5 .5])
    
    end
    
    ylim([-ylimit ylimit].*1.05)
    title(num2str(electrode))
    set(gca, 'Ticklength', [0 0])

end





end