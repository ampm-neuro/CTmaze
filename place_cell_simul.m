%proportions from top and left
center = [.6 .3]; 

%determines size of field
width = 10; 

%noise proportion of mean
noise_prop = 1.5;

%num pixles /side
rez = 100;

place_cell_mtx = ones(100); 
center_work = round(center.*rez);

incline = 0;
for ridge = 5:-1:1
    
    incline = incline+1;
    
    xbins = (center_work(1)-width*ridge):(center_work(1)+width*ridge);
        xbins(xbins<=0 | xbins>rez) = [];
    ybins = (center_work(2)-width*ridge):(center_work(2)+width*ridge);
        ybins(ybins<=0 | ybins>rez) = [];
    place_cell_mtx(xbins,ybins) = incline;
 
end

%set to rsc-like rates
place_cell_mtx = place_cell_mtx.*10;

%mean
mean_FR = mean(place_cell_mtx(:));


%add noise
place_cell_mtx = place_cell_mtx + (((rand(rez).*2)-1).*mean_FR).*noise_prop;

%smooth
place_cell_mtx = smooth2a(place_cell_mtx, round(rez./10));

%plot
figure; imagesc(place_cell_mtx); axis square


%metric of interest
%moi = var(place_cell_mtx(:));
moi = var(place_cell_mtx(:));

title(['GoodVar = ' num2str(moi)])