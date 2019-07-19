function angle = cwangle(x1, y1, x2, y2)
%calculates clockwise angle in degrees from (x1,y1) to (x2,y2) with respect
%to the positive y axis.
%
%e.g., 90 = cwangle(0,0,1,0)
%
%outputs NaN if given the same point twice

%radius is distance between points
radius = pdist([x1 y1; x2 y2], 'euclidean');

%shift problem to origin
xx2 = x2 - x1;
yy2 = y2 - y1;
xx1 = 0;
yy1 = radius;

%calculate angle at origin between positive y axis (o,radius) and second point (x2, y2)
if xx2 == abs(xx2)
    angle = acosd((2*radius^2 - pdist([xx1 yy1; xx2 yy2], 'euclidean')^2)/(2*radius^2));
else
  	angle = 360 - acosd((2*radius^2 - pdist([xx1 yy1; xx2 yy2], 'euclidean')^2)/(2*radius^2));
end

end