function [V, XYZ] = load_nifti(filename,doflip)
% function [V XYZ] = load_nifti(filename[,doflip])

if ~exist('doflip','var')
    doflip = 0;
end

% gunzip if necessary
if strcmp(filename(end-2:end),'.gz')
    if isdella
        try
            seed = str2double(getenv('SLURM_JOBID'));
        catch
            seed = str2double(getenv('SLURM_ARRAY_JOB_ID')) * str2double(getenv('SLURM_ARRAY_TASK_ID'));
        end
        rand('twister', seed)
    elseif isrondo
        seed = str2double(getenv('JOB_ID')) * str2double(getenv('SGE_TASK_ID'));
        if isnan(seed)
            seed = str2double(getenv('JOB_ID'));
        end
        rand('twister', seed)
    else
        setseedwclock;
    end
    tempname = sprintf('tempnifti%i',round(rand*100000));
    unix(sprintf('cp %s %s',filename,sprintf('/tmp/%s.nii.gz',tempname)));
    gunzip(sprintf('/tmp/%s.nii.gz',tempname));
    filename = sprintf('/tmp/%s.nii',tempname);
end
    
vol = spm_vol(filename);

[V, XYZ] = spm_read_vols(vol);

% flip left/right
if doflip
    for z = 1:size(V,3)
        V(:,:,z) = flipud(V(:,:,z));
    end
end

if strfind(filename,'/tmp/')
    delete(filename)
    delete([filename '.gz'])
end