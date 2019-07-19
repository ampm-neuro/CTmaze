function flood_fill_OLD(xc,yc,x,y,new,old,width,height)
% flood fills area of (global) fill
% (xc,yc) = start point of flood fill
% (x,y) = current test location
% new = new value to write
% old = old value to replace
%

global fill;
global call;

call = call + 1;

if (x<1 | x>width)
    x = xc;
end

if (y<1 | y>height)
    y = yc;
end

if (fill(y,x) == old) 
    fill(y,x) = new;
    flood_fill(xc,yc,x+1,y,new,old,width,height);
    flood_fill(xc,yc,x,y+1,new,old,width,height);
    flood_fill(xc,yc,x-1,y,new,old,width,height);
    flood_fill(xc,yc,x,y-1,new,old,width,height);
    %diagonals
    flood_fill(xc,yc,x+1,y+1,new,old,width,height);
    flood_fill(xc,yc,x+1,y-1,new,old,width,height);
    flood_fill(xc,yc,x-1,y+1,new,old,width,height);
    flood_fill(xc,yc,x-1,y-1,new,old,width,height);
end

end