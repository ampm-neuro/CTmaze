function [correlation_matrix, od_error, all_test_rows, all_comp_rows, all_included_cells] = c_mtx(v1, v2, cell_sort_idx, min_cells, first_last_seshs, varargin)
%make a correllation matrix from two vectors of equal length, v1 & v2
%uses cell_sort_idx to order v1 and v2 (can input empty vect to skip)    


%varargin shuffles
shuffles = 0;
od_error = [];
if nargin == 6
    shuffles = varargin{1};
    od_error = nan(shuffles,1);
end


%preallocate
correlation_matrix = nan(size(v1,1), size(v2,1));

%sort v1 and v2
if ~isempty(cell_sort_idx)  
    v1 = v1(:,cell_sort_idx);
    v2 = v2(:,cell_sort_idx);
end


all_test_rows = nan(min_cells, size(v1,1));
all_comp_rows = nan(min_cells, size(v1,1));
all_included_cells = [];
if shuffles == 0 %do not shuffle, do not calculate error

    for bin_test = 1:size(v1,1)
            for bin_comp = 1:size(v2,1)

                %compare these two rows
                test_row = v1(bin_test, :);
                comp_row = v2(bin_comp, :);

                %common cell idx
                com_cells = ~isnan(test_row) & ~isnan(comp_row);

                %catch no overlap
                if sum(com_cells)<min_cells
                    correlation_matrix(bin_test, bin_comp) = nan;
                    continue
                end

                %corr inputs
                if first_last_seshs == 1
                    included_cells = find(com_cells==1, min_cells, 'first');
                    %included_cells = setdiff(included_cells, [192, 194]);
                    test_row = test_row(included_cells)';
                    comp_row = comp_row(included_cells)';
                elseif first_last_seshs == 2
                    included_cells = find_mid(com_cells==1, min_cells);
                    %included_cells = setdiff(included_cells, [192, 194]);
                    test_row = test_row(included_cells)';
                    comp_row = comp_row(included_cells)';
                elseif first_last_seshs == 3
                    included_cells = find(com_cells==1, min_cells, 'last');
                    %included_cells = setdiff(included_cells, [192, 194]);
                    test_row = test_row(included_cells)';
                    comp_row = comp_row(included_cells)';
                end

                %[length(test_row) length(comp_row)]
                
                %load output
                all_included_cells = unique([all_included_cells included_cells]);
                %all_test_rows(:, bin_test) = test_row;
                %all_comp_rows(:, bin_comp) = comp_row;

                %fill correllation matrix
                correlation_matrix(bin_test, bin_comp) = corr(test_row, comp_row);
                
                %{
                if bin_test == 153 && bin_comp == 75
                    fit_line(test_row, comp_row)
                end
                %}
                
            end
            
    end

elseif shuffles == 1 %do not shuffle, but calculate error
    
    for bin_test = 1:size(v1,1)
            for bin_comp = 1:size(v2,1)

                %compare these two rows
                test_row = v1(bin_test, :);
                comp_row = v2(bin_comp, :);

                %common cell idx
                com_cells = ~isnan(test_row) & ~isnan(comp_row);

                %catch no overlap
                if sum(com_cells)<min_cells
                    correlation_matrix(bin_test, bin_comp) = nan;
                    continue
                end

                %corr inputs
                if first_last_seshs == 1
                    included_cells = find(com_cells==1, min_cells, 'first');
                    %included_cells = setdiff(included_cells, [192, 194]);
                    test_row = test_row(included_cells)';
                    comp_row = comp_row(included_cells)';
                elseif first_last_seshs == 2
                    included_cells = find_mid(com_cells==1, min_cells);
                    %included_cells = setdiff(included_cells, [192, 194]);
                    test_row = test_row(included_cells)';
                    comp_row = comp_row(included_cells)';
                elseif first_last_seshs == 3
                    included_cells = find(com_cells==1, min_cells, 'last');
                    %included_cells = setdiff(included_cells, [192, 194]);
                    test_row = test_row(included_cells)';
                    comp_row = comp_row(included_cells)';
                end
                
                %[length(test_row) length(comp_row)]

                %fill correllation matrix
                correlation_matrix(bin_test, bin_comp) = corr(test_row, comp_row);
            end
    end
    
    %mirror
    correlation_matrix = mirror_matrix(correlation_matrix);
    %calculate off-diagonal distances
    od_error = off_diagonal_sum(correlation_matrix);%learning early
    
    
elseif shuffles > 1
    
    for shuffles = 1:shuffles
        
        shuffles
        
        %shuffle idx
        shuffle_idx = randperm(min_cells);
        
        for bin_test = 1:size(v1,1)
                for bin_comp = 1:size(v2,1)

                    %compare these two rows
                    test_row = v1(bin_test, :);
                    comp_row = v2(bin_comp, :);

                    %common cell idx
                    com_cells = ~isnan(test_row) & ~isnan(comp_row);

                    %catch no overlap
                    if sum(com_cells)<min_cells
                        correlation_matrix(bin_test, bin_comp) = nan;
                        continue
                    end

                    %corr inputs
                    if first_last_seshs == 1
                        included_cells = find(com_cells==1, min_cells, 'first');
                        %included_cells = setdiff(included_cells, [192, 194]);
                        test_row = test_row(included_cells)';
                        comp_row = comp_row(included_cells)';
                    elseif first_last_seshs == 2
                        included_cells = find_mid(com_cells==1, min_cells);
                        %included_cells = setdiff(included_cells, [192, 194]);
                        test_row = test_row(included_cells)';
                        comp_row = comp_row(included_cells)';
                    elseif first_last_seshs == 3
                        included_cells = find(com_cells==1, min_cells, 'last');
                        %included_cells = setdiff(included_cells, [192, 194]);
                        test_row = test_row(included_cells)';
                        comp_row = comp_row(included_cells)';
                    end

                    %[length(test_row) length(comp_row)]
                    
                    %shuffle just the comp_row (thereby shuffling matchups)
                    
                    
                    %fill correllation matrix
                    correlation_matrix(bin_test, bin_comp) = corr(test_row, comp_row(shuffle_idx));
                end
        end
    
        %mirror
        correlation_matrix = mirror_matrix(correlation_matrix);
        %calculate off-diagonal distances
        od_error(shuffles) = off_diagonal_sum(correlation_matrix);%learning early
        
        shuffles
    end
    
    
end

%make figure
%{
figure; imagesc(correlation_matrix); hold on
axis square
caxis([-1 1])
colorbar
colormap jet
set(gca,'TickLength',[0, 0]);
%}


%FUNCTIONS
%function for calculating off diagonal
    function ods = off_diagonal_sum(mtx)
    
        %find maximum correlation in each row
        diag_peak = nan(size(mtx,1), 2);
        for bin = 1:size(mtx,1)
            diag_peak(bin, 1:2) = [bin find(mtx(bin,:) == nanmax(mtx(bin,:)),1)];
        end

        %{
        figure
        imagesc(mtx)
        colormap jet
        hold on
        plot(diag_peak(:,2), diag_peak(:,1), 'k', 'LineWidth', 5)
        %}

        %sum distance off diagonal
        error_ = abs(diag_peak(:,2) - diag_peak(:,1)); 
        error_(error_>max(diag_peak(:,1))/2) = repmat(max(diag_peak(:,1)), size(error_(error_>max(diag_peak(:,1))/2))) - error_(error_>max(diag_peak(:,1))/2); %correct for circularity
        ods = sum(error_);
    end
        
%mirror
    function mmtx = mirror_matrix(mtx)
        mmtx = mtx; %DO NOT MIRROR
        %mmtx = (mtx+mtx')./2;
    end

end