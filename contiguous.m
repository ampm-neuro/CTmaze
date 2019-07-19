function [logic_contiguitymatrix] = contiguous(matrix)
%finds contiguous patches of ones that are atleast a certain size (defined
%below)

%troubleshoot
%matrix = ones(10);
%matrix = [matrix; matrix.*((rand(10).*100)>65); matrix.*((rand(10).*100)>65); matrix];


%SET MINIMUM SIZE HERE
%field always requires a square of atleast ~4cm^2 pixles
size_x = round(size(matrix,2)./40);
size_y = round(size(matrix,1)./40);


%start positions
x=1;y=1;

%figure; imagesc(matrix); title('minimum firing rate')

%FIRST PASS: find patches of 1s of minimum size
while 1
    
    %if every item in minimum size region is nonzero
    if isempty(find(matrix(y:y+size_y, x:x+size_x) == 0, 1))
 
    	%change items to 2
      	matrix(y:y+size_y, x:x+size_x) = 2;
       

     	x = x+1;
    else
      	x = x+1;
    end

 	%at end of row, shift down one and begin again on left
  	if x+size_x > length(matrix(1,:))
       	x = 1; y = y+1;
    end
    
  	%at end of last row, break
  	if y+size_y > length(matrix(:,1))
        
      	break
    end
    
end

%counter to see when secton pass is complete
complete = 1;

%figure; imagesc(matrix); title('nuggets identified')

%SECOND PASS: include contiguous 1s
%start positions
x=1;y=1;


while 1

    %spotlight
    spotlight = matrix(y:y+1, x:x+1);
    
    
    %if 2x2 spotlight includes at least two 2s and at least one 1
    if sum(sum(spotlight == 2))>1 && ~isempty(find(spotlight == 1, 1))

    %change 1s to 2s
        spotlight(spotlight == 1) = 2;
      	matrix(y:y+1, x:x+1) = spotlight;

     	x = x+1;
        
        %reset completeness measure
        complete = 1;
        
    else
      	x = x+1;
        
        %increase completeness measure
        complete = complete+1;
        
        if complete > length(matrix(:))
            break
        end
        
    end

 	%at end of row, shift down one and begin again on left
  	if x+1 > length(matrix(1,:))
       	x = 1; y = y+1;
    end
    
  	%at end of last row, break
  	if y+1 > length(matrix(:,1))
      	x = 1; y = 1;
    end
    
end

%set to just 1's (field) and 0's (not field)
matrix(matrix == 1) = 0;
matrix(matrix == 2) = 1;

%THIRD PASS: Give a unique number to each isolated field
%global fill;
%fill = matrix;

%figure; imagesc(matrix); title('contiguous pixles included')

%start positions
id = 1;
x=1;y=1;

while 1

    %iterating a spotlight to identify pixles in need of changing
    if isequal(matrix(y:y+size_y, x:x+size_x), ones(size(matrix(y:y+size_y, x:x+size_x))))
 
        %next unique field ID
        id = id+1;
        
        %Find first unIDed field coordinate (first 1)
        yc = y;
        xc = x;
        
        %Change first 1 and all contiguous 1's to a unique, higher number
        %flood_fill(xc,yc,xc,yc,id,1,size(fill,2),size(fill,1));
        field_items = flood_fill(matrix, yc, xc);
        matrix(field_items) = id;

     	x = x+1;
    else
      	x = x+1;
    end

 	%at end of row, shift down one and begin again on left
  	if x+size_x > length(matrix(1,:))
       	x = 1; y = y+1;
    end
    
  	%at end of last row, break
  	if y+size_y > length(matrix(:,1))
        %matrix
      	break
    end

end


%subtrack all nonzero numbers by 1
matrix = matrix - (matrix>0);

%figure; imagesc(matrix); title('contiguous nuggests uniquely labled')


%clear fill

logic_contiguitymatrix = matrix;


end