function volume = convert3D_and_savenii(data,brainmask,filename)

% basics
brainmask_inds = find(brainmask);
nvox = length(brainmask_inds);

% convert to 3D volume
if isempty(brainmask)
    volume = data;
else
    volume = zeros(size(brainmask));
    for v = 1:nvox
        voxelind = brainmask_inds(v);
        volume(voxelind) = data(v);
    end
end

% convert to nifti
nii = make_nii(volume,[3 3 3]);

% save as .nii.gz
save_nii(nii,filename)
unix(sprintf('gzip %s',filename));