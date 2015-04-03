function figuredump(h,name)


if ~isempty(strfind(pwd,'/mnt/cd')) % we are on Rondo
  d = '/scratch/scychan/figuredump/';
else % we are on Gauntlet
  d = '~/mnt/scratch/scychan/figuredump/';
end

if ~exist('name','var')
  name = datestr(now,'mm.dd.yy_HH.MM.SS.FFF.png');
else
  d = [d datestr(now,'mm.dd.yy/')];
end

if ~exist(d,'dir')
  mkdir(d)
end
saveas(h,fullfile(d,name))
