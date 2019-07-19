function ys = ferret_ys(Targets)
%this function pulls out the y corrdinates from Targets, which are encoded 
%in the neuralynx 32 bit encoding scheme or something

%preallocate vector of y coordinates
ys = zeros(2, size(Targets,2));

%through every video sample
for samp = 1:size(Targets,2)
    
    %this video sample
    current_vt = Targets(:, samp);
    
    %y coodinates in this sample
    temp_ys = current_vt(current_vt > 2800000 & current_vt < 30000000);
    
    %fill preallocated vector of y coordinates
    ys(1:length(temp_ys), samp) = temp_ys;

end