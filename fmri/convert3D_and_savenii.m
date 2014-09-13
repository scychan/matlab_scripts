function volume = convert3D_and_savenii(data,brainmask,voxelsize,filename,origin)
% function volume = convert3D_and_savenii(data,brainmask,voxelsize,filename[,origin])

if ~exist('origin','var')
    origin = [];
end

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

% save as .nii or .nii.gz
save_nifti(volume,filename,voxelsize,origin)