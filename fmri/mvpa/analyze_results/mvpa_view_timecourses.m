function mvpa_view_timecourses(acts,desireds,timepoints)
% function mvpa_view_timecourses(acts,desireds[,timepoints])
%
% View classifier output timecourse for a single iteration.
% 'timepoints' input is optional

% clear figure
clf; hold on

% basics
[ncats ntimepts] = size(acts);
colors = jet(ncats);
if ~exist('timepoints','var')
    timepoints = 1:ntimepts;
end

% plot classifier activations
for icat = 1:ncats
    plot(timepoints,acts(icat,timepoints),'.-','color',colors(icat,:))
end

% plot dot labels just above 1
for icat = 1:ncats
    thiscat = find(desireds(timepoints)==icat);
    scatter(thiscat, 1.1*ones(size(thiscat)), 20, colors(icat,:))
end