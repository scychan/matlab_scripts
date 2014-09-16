function [V, XYZ] = load_nifti(filename)
% function [V XYZ] = load_nifti(filename)

% gunzip if necessary
if strcmp(filename(end-2:end),'.gz')
    if isdella
        try
            seed = str2num(getenv('SLURM_JOBID'));
        catch
            seed = str2num(getenv('SLURM_ARRAY_JOB_ID')) * str2num(getenv('SLURM_ARRAY_TASK_ID'));
        end
        rand('twister', seed)
    elseif isrondo
        error('need to write this')
    else
        setseedwclock
    end
    tempname = sprintf('tempnifti%i',round(rand*100000));
    copyfile(filename,sprintf('/tmp/%s.nii.gz',tempname));
    gunzip(sprintf('/tmp/%s.nii.gz',tempname));
    filename = sprintf('/tmp/%s.nii',tempname);
end
    
vol = spm_vol(filename);

[V, XYZ] = spm_read_vols(vol);

if strfind(filename,'/tmp/')
    delete(filename)
    delete([filename '.gz'])
end