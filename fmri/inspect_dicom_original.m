function inspect_dicom
% You must be in the dicom directory.
% You must have SPM on your path.

%% 
% run_numbers
% first_slice_names
% length_each_run


filenames = dir_filenames('*.dcm');
num_files = length(filenames);

run_numbers = [];
first_slice_names = [];
length_each_run = [];


for i = 1:num_files
    filename = filenames{i}
    bname = filename(1:end-4);
    bnames{i} = bname;
    dashlocs{i} = strfind(filename,'-');
    bname(dashlocs{i}(1)+1:end)
    if strcmp(bname(dashlocs{i}(1)+1:end),'1')
        first_slice_names = [first_slice_names;{filename}];
	% run_numbers(end+1) = str2num(filename(12:14)); 
	% run_numbers(end+1) = str2num(filename([1:3] + length(subj_prefix)));
	run_numbers(end+1) = str2num(filename([1:(dashlocs{i}(1)-1)]));
        
        if i>1
            prev_bname = bnames{i-1};
	    length_each_run(end+1) = str2num(prev_bname(dashlocs{i-1}(1)+1:end));
        end
    end
end

last_bname = bnames{num_files};
%length_each_run(end+1) = str2num(last_filename(end-3:end));
length_each_run(end+1) = str2num(last_bname( (dashlocs{i}(1)+1):end ));

disp([run_numbers(:),length_each_run(:)])

%% look at dicom headers
% interesting headers:
% SeriesDescription

fid = fopen('info.txt','w');

third_slice_names = first_slice_names
%third_slice_names(:,end) = '3';

%headers = spm_dicom_headers(first_slice_names);

% fprintf('\n\n\n\n')
nruns = length(run_numbers);
for irun = 1:nruns
  run = run_numbers(irun);
  whos(first_slice_names{irun})
  header = spm_dicom_headers(first_slice_names{irun});
  headers{irun} = header;
%  header = headers{irun};
  value = header.SeriesDescription;
%     value = strrep(value, '\', '\\');
%     value = num2str(header.EchoTime);
%    value = num2str(header.ImageOrientationPatient);
    fprintf(fid,'%i - %i - %s\n',run,length_each_run(irun),value);
%     fprintf([num2str(run) ': ' value '\n'])
end
fclose('all');

%%

run_lengths = length_each_run;
save('run_lengths','run_lengths')

