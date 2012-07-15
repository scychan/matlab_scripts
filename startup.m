



%------------ FreeSurfer -----------------------------%
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
if (exist(fsmatlab) == 7)
    path(path,fsmatlab);
end
clear fshome fsmatlab;
%-----------------------------------------------------%

%------------ FreeSurfer FAST ------------------------%
fsfasthome = getenv('FSFAST_HOME');
fsfasttoolbox = sprintf('%s/toolbox',fsfasthome);
if (exist(fsfasttoolbox) == 7)
    path(path,fsfasttoolbox);
end
clear fsfasthome fsfasttoolbox;
%------------ NIFTI_MATLAB ---------------------------%
addpath /usr/pni/pkg/MATLAB/toolboxes_thirdparty/NIFTI_MATLAB/

%------------ MVPA Toolbox (commented out) ---------------------------%
% addpath /mnt/cd/PNI_classes/NEU480/software/mvpa ;
% mvpa_add_paths;

%------------ SPM ---------------------------%
addpath(genpath('/usr/pni/pkg/SPM8'));
%------------ Synthemiser -------------------%
addpath(genpath('/mnt/cd/PNI_classes/NEU480/software/Synthemiser'));
%------------ Searchmight -------------------%
%addpath(genpath('/mnt/cd/PNI_classes/NEU480/software/SearchmightToolbox'));
%------------ Simitar -----------------------%
%addpath(genpath('/mnt/cd/PNI_classes/NEU480/software/SimitarToolbox'));


%----------- All MATLAB Toolboxes (including lightspeed, fastfit, pwmetric)  --------------------%
addpath(genpath('/usr/pni/lib/matlab'));

%----------- My MATLAB scripts  --------------------%
addpath(genpath('/jukebox/people/scychan/matlab/'));





