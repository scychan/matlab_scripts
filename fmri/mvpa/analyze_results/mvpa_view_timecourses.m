function mvpa_view_timecourses(acts,desireds,timepoints)
% function mvpa_view_timecourses(acts,desireds[,timepoints])
%
% View classifier output timecourse for a single iteration.
% 'timepoints' input is optional
% 
% acts - should be [ncategories x ntimepoints]
%      - if wanting to view intervals (rather than a single line for each category),
%        acts{1} should be the lower bounds, and acts{2} should be the upper bounds.

hold on

% figure out whether it is CI or means
doCI = iscell(acts);
if ~doCI, temp{1} = acts; acts = temp; end

% basics
[ncats ntimepts] = size(acts{1});
colors = jet(ncats);
if ~exist('timepoints','var')
    timepoints = 1:ntimepts;
end

% plot classifier activations
if doCI
    allcolors = 'bgm';
    for icat = 1:ncats
        fill_curve(allcolors(icat), 1:ntimepts, acts{1}(icat,:), acts{2}(icat,:));
    end
else
    for icat = 1:ncats
        plot(timepoints,acts{1}(icat,timepoints),'.-','color',colors(icat,:))
    end
end

% plot dot labels just above 1
for icat = 1:ncats
    thiscat = find(desireds(timepoints)==icat);
    scatter(thiscat, 1.1*ones(size(thiscat)), 20, colors(icat,:))
end