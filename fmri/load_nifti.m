function [V XYZ] = load_nifti(filename)

vol = spm_vol(filename);

[V XYZ] = spm_read_vols(vol);