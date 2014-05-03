function [V, XYZ] = load_nifti(filename)
% function [V XYZ] = load_nifti(filename)

% gunzip if necessary
if strcmp(filename(end-2:end),'.gz')
    copyfile(filename,'/tmp/tempnifti.nii.gz');
    gunzip('/tmp/tempnifti.nii.gz');
    filename = '/tmp/tempnifti.nii';
end
    
vol = spm_vol(filename);

[V, XYZ] = spm_read_vols(vol);