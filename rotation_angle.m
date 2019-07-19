function rotang = rotation_angle(avgXYrwdL, avgXYrwdR, comxy)

%rotation_angle calculates rotang, the rotation angle required to level out the
%reward locations. It is used by trials_III to rotate all rat x,y
%coordinates.

%calculating what the new right reward location should be in order to find
%rotang, the angle that all points must be rotated

    %rotations occur around the origin, so we correct the reward location
    %to the origin before finding the angle
    oldX_R_origin = avgXYrwdR(1) - comxy(1);
    oldY_R_origin = avgXYrwdR(2) - comxy(2);
 
    %radius can be found using pythag theorum
    radius = sqrt(oldX_R_origin^2 + oldY_R_origin^2);

    %the y coordinate of the new reward location is the average y coordinate 
    %of both reward locations - this levels them out.
    newY_R_origin = oldY_R_origin + (avgXYrwdL(2) - avgXYrwdR(2))/2;

    %the new x coordinate can be found using pythag theorum
    newX_R_origin = sqrt(radius^2 - newY_R_origin^2);

    
%using new reward location to determine rotation angle (in clockwise
%degrees), with a calculus equation generously provided by the internet.
%acosd is the inverse cosine
    
    %if the new R_RWD y coordinate is lower than the old, turn clockwise
    %(positive rotang)
    if newY_R_origin < oldY_R_origin %== abs(newY_R_origin - oldY_R_origin)
        rotang = acosd((2*radius^2 - pdist([oldX_R_origin oldY_R_origin; newX_R_origin newY_R_origin], 'euclidean')^2)/(2*radius^2));
    
    %if the new R_RWD y coordinate is higher than the old, turn counter-clockwise
    %(negative rotang)
    else
        rotang = -acosd((2*radius^2 - pdist([oldX_R_origin oldY_R_origin; newX_R_origin newY_R_origin], 'euclidean')^2)/(2*radius^2));
    end

end