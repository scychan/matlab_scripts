function save_nifti(volume,filename,voxelsize,origin)

% convert to nifti
if ~exist('origin','var')
    if all(size(volume) == [91 109 91])
        origin = [46 64 37];
    else
        origin = [];
    end
end
nii = make_nii(volume,voxelsize,origin);

% save as .nii.gz OR .nii
if strfind(filename,'.nii.gz')
    save_nii(nii,filename(1:end-3))
    unix(sprintf('gzip %s',filename(1:end-3)));
else
    save_nii(nii,filename)
end