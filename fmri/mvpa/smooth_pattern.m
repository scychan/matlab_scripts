function subj = smooth_pattern(subj,old_pat_name,FWHM,disp_size_in_new_patname)
% SMOOTH_PATTERN - Spatially smoothes a pattern.
%
% Usage:
%
%  [SUBJ] = SMOOTH_PATTERN(SUBJ, PATNAME, FWHM, disp_size_in_new_patname)
%
% Spatially smoothes a pattern by 3D convolution with a Gaussian
% kernel with Full-Width Half Max of FWHM voxels. FWHM is
% not restricted to integers. Each timepoint of the pattern is
% blurred separately.
%   
% if disp_size_in_new_patname = 0:   
% The new spatially smoothed pattern will be [patname]_sm, where
% [patname] is the old pattern name.
%
% if disp_size_in_new_patname = 1:    
% The new spatially smoothed pattern will be [patname]_sm%s, where
% [patname] is the old pattern name and %s is FWHM
%    
    
    if nargin < 4 
        disp_size_in_new_patname = 0;
    end

    if disp_size_in_new_patname
        if 0 == mod(FWHM,1)
            new_pat_name = sprintf('%s_sm%d',old_pat_name,FWHM);
        else
            new_pat_name = sprintf('%s_sm%1.1f',old_pat_name,FWHM);
        end
    else
        new_pat_name = sprintf('%s_sm',old_pat_name);
    end
    subj = blur_pattern(subj,old_pat_name,FWHM,...
                        'new_patname',new_pat_name);
    pat_single = get_mat(subj,'pattern',new_pat_name);
    subj = set_mat(subj,'pattern',new_pat_name,double(pat_single));
end