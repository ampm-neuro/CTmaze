function out_pre = temp_III(prop_pages, bins)

p_sections = nan(10,size(prop_pages,3));

for i = 1:size(prop_pages,3)
    
    hold = ~isnan(prop_pages(:,:,i));

    warning('off','all')
        
    p_sections(1,i) = sum(sum(hold(1:bins*.3000, bins*0.3750:bins*0.62500))); %start area 1 1
    p_sections(2,i) = sum(sum(hold(bins*.3000:bins*0.5375, bins*0.3750:bins*0.6250))); %low common stem 2 2
    p_sections(3,i) = sum(sum(hold(bins*0.5375:bins*0.7625, bins*0.3750:bins*0.6250))); %high common stem 3 3
    p_sections(4,i) = sum(sum(hold(bins*0.7625:bins, bins*0.3750:bins*0.6250))); %choice area 4 4
    p_sections(5,i) = sum(sum(hold(bins*0.7125:bins, bins*0.2000:bins*0.3750))); %approach arm left 5 5
    p_sections(6,i) = sum(sum(hold(bins*0.7125:bins, bins*0.6250:bins*0.8000))); %approach arm right 6 5
    p_sections(7,i) = sum(sum(hold(bins*0.7125:bins, 1:bins*0.2000))); %reward area left 7 6
    p_sections(8,i) = sum(sum(hold(bins*0.7125:bins, bins*0.8000:bins))); %reward area right 8 6
    p_sections(9,i) = sum(sum(hold(1:bins*0.7125, 1:bins*0.3750))); %return arm left 9 7
    p_sections(10,i) = sum(sum(hold(1:bins*0.7125, bins*0.6250:bins))); %return arm right 10 7

    warning('on','all')
    
    
    %trajectories
    Ls = sum(p_sections([5 7],i));
    Rs = sum(p_sections([6 8],i));
    
    %approaches
    % Ls = sum(p_sections(5,i));
    % Rs = sum(p_sections(6,i));
    
    %rewards
     %Ls = sum(p_sections(7,i));
     %Rs = sum(p_sections(8,i));
    
    both = sum([Ls Rs]);
    %both = sum([Ls Rs])./2;
    
    out_pre(:,i) = both / (sum(p_sections(:,i))-sum(p_sections([2 3],i)));
end

%p_sections = mean(p_sections,2);
    
%out = sum(p_sections([7 8])) / (sum(p_sections)-sum(p_sections([2 3])));