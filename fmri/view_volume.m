function view_volume(vol,slicedim)

if ~exist('slicedim','var')
    slicedim = 3;
end

    
for i = 1:size(vol,slicedim)
    switch slicedim
        case 1
            slice = vol(i,:,:);
        case 2
            slice = vol(:,i,:);
        case 3
            slice = vol(:,:,i);
    end
    imagesc(squeeze(slice))
    title(sprintf('slice %i',i))
    pause
end