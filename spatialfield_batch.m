function [dms_place, field_loc_matrix, folded_section_area, meta_mtx_batch, field_sizes, rate_ratios, reliability_scores] = spatialfield_batch(varargin)

switch nargin
    case 3
        eptrials = varargin{1};
        clusters = varargin{2};
        min_visits = varargin{3};
        
        field_sizes = [];
        rate_ratios = [];
        reliability_scores = [];
        
    case 4 
        eptrials = varargin{1};
        clusters = varargin{2};
        min_visits = varargin{3};
        stem_runs = varargin{4};
        
        field_sizes = [];
        rate_ratios = [];
        reliability_scores = [];
    
    case 6 
        eptrials = varargin{1};
        clusters = varargin{2};
        min_visits = varargin{3};
        
        field_sizes = varargin{4};
        rate_ratios = varargin{5};
        reliability_scores = varargin{6};    
        
    case 7 
        eptrials = varargin{1};
        clusters = varargin{2};
        min_visits = varargin{3};
        stem_runs = varargin{4};
        
        field_sizes = varargin{5};
        rate_ratios = varargin{6};
        reliability_scores = varargin{7};
        
    otherwise
        error(message('incorrect var input'))
end

meta_mtx_batch = [];
dms_place = nan(size(clusters,1),1);
field_locations = nan(size(clusters,1), 2);
count=1;

%rwdpos = mean(rewards(eptrials)); %[X,Y]
%close

clusters = clusters';

for i = 1:size(clusters,1)
    cluster = clusters(i,1);
    
    if exist('stem_runs', 'var')
        [summary, folded_section_area, meta_mtx_cell, field_sizes, rate_ratios, reliability_scores]=spatialfield(eptrials, cluster, stem_runs, comx, comy, min_visits, field_sizes, rate_ratios, reliability_scores);
    else
        [summary, folded_section_area, meta_mtx_cell, field_sizes, rate_ratios, reliability_scores]=spatialfield(eptrials, cluster, min_visits, field_sizes, rate_ratios, reliability_scores);
    end
    
     if isempty(summary(:))
         
         dms_place(i) = 0;
         field_locations(count:count+length(summary(:,1))-1, 2) = nan;
         
     else
         
         dms_place(i) = 1;
         field_locations(count:count+length(summary(:,1))-1, 2) = sort(summary(:,2));
         
     end
    
     field_locations(count:count+length(summary(:,1))-1, 1) = cluster;
     
     
     count = count + length(summary(:,1));
     
     meta_mtx_batch = cat(3, meta_mtx_batch,meta_mtx_cell);
          

end

%field locations matrix
field_loc_matrix = zeros(length(unique(field_locations(~isnan(field_locations(:,1)),1))), 7);

%clever way to derive y coordinates from the clusters of field_locations
[~, ~, size_rank] = unique(field_locations(:,1));

%erase coordinates belonging to clusters without fields
size_rank = size_rank(~isnan(field_locations(:,2)));

%use coordinates to change appropriate elements of field_loc_matrix
coordinates = [size_rank field_locations(~isnan(field_locations(:,2)),2)];

for i = 1:length(coordinates(:,1))
    field_loc_matrix(coordinates(i,1), coordinates(i,2)) = field_loc_matrix(coordinates(i,1), coordinates(i,2)) + 1;
end

