function inspect_dicom_v2
% For dicoms transferred via Conquest. No longer useful starting 11/14/2012.
% (extra field to dicom names)

% You must be in the dicom directory.
% You must have SPM on your path.

%% 
% run_numbers
% first_slice_names
% length_each_run

run_numbers = [];
first_slice_names = [];
length_each_run = [];

run_number = 0;
while true
  run_number = run_number + 1;
  run_files = dir_filenames([num2str(run_number) '-*.dcm']);
  
  if isempty(run_files)
    break
  else
    run_numbers = [run_numbers run_number];
  end

  currmax = 0;
  for i = 1:length(run_files)
    filename = run_files{i};
    bname = filename(1:end-4);
    dashlocs = strfind(filename,'-');
    imnum = bname(dashlocs(1)+1:end);
    if strcmp(imnum,'1')
      first_slice_names = [first_slice_names;{filename}];
    end
    currmax = max(str2num(imnum),currmax);
  end
  length_each_run(end+1) = currmax;
end
  
disp([run_numbers(:),length_each_run(:)])



%% look at dicom headers
% interesting headers:
% SeriesDescription

fid = fopen('../info.txt','w');

third_slice_names = first_slice_names
%third_slice_names(:,end) = '3';

%headers = spm_dicom_headers(first_slice_names);

% fprintf('\n\n\n\n')
nruns = length(run_numbers);
for irun = 1:nruns
  run = run_numbers(irun);
  whos(first_slice_names{irun})
  header = spm_dicom_headers(first_slice_names{irun});
  header = header{1};
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
save('../run_lengths','run_lengths')

