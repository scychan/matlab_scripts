function inspect_dicom(subj_prefix)

%%

%cd MM110_021712

%%

% addpath(genpath('C:\Users\yenne\Documents\Princeton\MM Experiment\code\analysis\fmri\spm8'))

%% 
% run_numbers
% first_slice_names
% length_each_run


filenames = dir_filenames([subj_prefix '*']);
num_files = length(filenames);

run_numbers = [];
first_slice_names = [];
length_each_run = [];


for i = 1:num_files
    filename = filenames{i};
    if strcmp(filename(end-4:end),'_0001')
        first_slice_names = [first_slice_names;filename];
        %run_numbers(end+1) = str2num(filename(12:14));
        run_numbers(end+1) = str2num(filename([5:7] + length(subj_prefix)));
        
        if i>1
            prev_filename = filenames{i-1};
            length_each_run(end+1) = str2num(prev_filename(end-3:end));
        end
    end
end

last_filename = filenames{num_files};
length_each_run(end+1) = str2num(last_filename(end-3:end));

disp([run_numbers(:),length_each_run(:)])

%% look at dicom headers
% interesting headers:
% SeriesDescription

fid = fopen('info.txt','w');

third_slice_names = first_slice_names;
third_slice_names(:,end) = '3';

headers = spm_dicom_headers(first_slice_names);

% fprintf('\n\n\n\n')
nruns = length(run_numbers);
for irun = 1:nruns
	run = run_numbers(irun);
    header = headers{irun};
     value = header.SeriesDescription;
%     value = strrep(value, '\', '\\');
%     value = num2str(header.EchoTime);
%    value = num2str(header.ImageOrientationPatient);
    fprintf(fid,'%i - %i - %s\n',run,length_each_run(irun),value);
%     fprintf([num2str(run) ': ' value '\n'])
end
fclose('all');
