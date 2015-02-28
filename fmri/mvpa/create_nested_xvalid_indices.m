function [subj] = create_nested_xvalid_indices(subj,runs_selname,varargin)

% Creates a group of selectors for each iteration for leave-one-out cross-validation.
% 
% For each iteration, we create one group of (niters-1) selectors, 
% excluding the the 'run of interest' completely, and each time
% withholding a different run.
% 
% For example, with four iterations total, we would create this group of
% 3 selectors for iteration 4: 
%   1. train on [1,2], test on [3]
%   2. train on [1,3], test on [2]
%   3. train on [2,3], test on [1]
% Later, the params fitted on these 3 crossvalidation runs can be applied
% to iteration [4].
%
% [SUBJ] = CREATE_NESTED_XVALID_INDICES(SUBJ,RUNS_SELNAME,...)
%
% Adds the following objects:
% - nRuns selectors group, each with [nRuns-1] objects, called NEW_SELSTEM
%
% Each iteration has a selector. One run is withheld on each
% iteration for testing, and one run is ignored completely (for testing on
% the outer cross-validation loop). TRs for that withheld run are set to 2,
% while the TRs for all the other runs are set to 1. Think of the 1s as
% training TRs and the 2s as testing TRs. These selectors get used by the
% nminusone no-peeking anova and for cross-validation classification.
%
% RUNS_SELNAME should consist of a vector with each TR labelled by
% its run number. For instance, an extremely brief experiment with
% 4 runs, with 5 TRs in each run, would look like this:
%    [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4]
% This runs vector should not include any zeros. You should use the
% ACTIVES_SELNAME to censor runs
%
% NEW_SELSTEM (optional, default = runs_selname + 'xval'). This
% determines the group_name and stem for the selector groups that
% will be created
%
% ACTIVES_SELNAME (optional, default = ''). If empty, then this
% doesn't censor any individual TRs. If, however, you do want to use a
% temporal mask selector to exclude some TRs, feed in the name of a
% boolean selector. This will cause those TRs be ignored by later
% scripts. such as the no-peeking ANOVA or a cross-validation
% classifier
%
%   Occasionally, you may want to use the logical AND of multiple
%   boolean selectors at once. If so, you can feed in a cell array of
%   ACTIVES_SELNAME selector object names, and they will be ANDed
%   together before being used to determine active timepoints.
%
% e.g. subj = create_nested_xvalid_indices(subj,'runs');
%
%      subj = create_xvalid_indices( ...
%         subj,'runs','new_selstem','runs_nminusone_xvalid', ...
%         'actives_selname','actives');
%
% IGNORE_JUMBLED_RUNS (optional, default = false). By
% default, you'll get a fatal error if your runs are
% jumbled, e.g. [1 1 1 2 2 2 1 1 1 ...]. However, there
% might be times when you want to create an artificial
% 'runs' vector that deliberately mixes and matches
% non-contiguous timepoints. In that case, set this to true,
% and it will allow jumbled runs.
%
%   xxx - it looks like interspersing zeros (e.g. [0 1 0 2 0 3]) also
%   trips the jumbled-runs detector, even if the runs are in order.
%
% IGNORE_RUNS_ZEROS (optional, default = false). By default,
% you'll get a fatal error if your runs vector contains
% zeros. Set this to true if you just want it to ignore
% zero'd runs timepoints.
%
%   Currently, if your runs contain zeros, they will also
%   trigger the 'jumbled runs' warning.
%
% IGNORE_NO_TESTING_TIMEPOINTS (optional, default = false). By default,
% you'll get a warning if there are runs with no testing timepoints.
%
% N.B. the number of withheld runs = max(runs). So if
% there's a run missing, it still gets its own iteration,
% but with no testing timepoints.
%
% Stephanie Chan 2015
% (Adapted from create_xvalid_indices.m from Princeton MVPA Toolbox)


defaults.new_selstem = sprintf('%s_nested_xval',runs_selname);
defaults.actives_selname = '';
defaults.ignore_jumbled_runs = false;
defaults.ignore_runs_zeros = false;
defaults.ignore_no_testing_timepoints = false;
args = propval(varargin,defaults);

runs = get_mat(subj,'selector',runs_selname);
nRuns = max(runs);

if isempty(args.actives_selname)
    % If no actives_selname was fed in, then assume the user wants all
    % TRs to be included, and create a new all-ones actives selector
    actives = ones(size(runs));
else
    % Otherwise, use the one specified, or AND together
    % multiple boolean selectors
    actives = and_bool_selectors(subj,args.actives_selname);
end

sanity_check_for_runs(runs,actives,args)

% For each iteration, we're going to create one group of (niters-1) selectors.
% - Excluding the the 'run of interest' completely, and each time
% withholding a different run.
% E.g. For iteration 4, the selectors would be:
%  train on [1,2], test on [3]
%  train on [1,3], test on [2]
%  train on [2,3], test on [1]
% Later, the params fitted on these 3 crossvalidation runs can be applied
% to iteration [4].
for r_outer = unique(runs)
    for r_inner = setdiff(unique(runs),r_outer)
        % Set up what will go into the selector object
        cur_selname = sprintf('%s_%i_%i',args.new_selstem,r_outer,r_inner);
        
        cursels = zeros(size(runs));        % all but train + testing TRs = 0
        cursels(find(runs)) = 1;            % training TRs = 1
        cursels(find(runs==r_inner)) = 2;   % testing TRs = 2
        cursels(find(runs==r_outer)) = 0;   % exclude r_outer
        
        % Use the actives selector to see if any TRs should be censored
        cursels(find(~actives)) = 0;
        sanity_check_for_cursels(cursels,args);
        
        % Now create the selector object, and fill it with goodies
        subj = duplicate_object(subj,'selector',runs_selname,cur_selname);
        subj = set_mat(subj,'selector',cur_selname,cursels);
        
        subj = set_objfield(subj,...
            'selector',cur_selname,...
            'group_name',sprintf('%s_%i',args.new_selstem,r_outer),...
            'ignore_absence',true);
        
        % Tell it the story of how it came to be
        created.function = 'create_nested_xvalid_indices';
        created.runs_selname = runs_selname;
        created.actives_selname = args.actives_selname;
        subj = add_created(subj,'selector',cur_selname,created);
        
        it_hist = sprintf('Created by create_nested_xvalid_indices - outer iteration #%i - inner iteration #%i',r_outer,r_inner);
        subj = add_history(subj,'selector',cur_selname,it_hist);
    end
end

main_hist = sprintf('Selector groups ''%s_[%i-%i]'' created by create_nested_xvalid_indices',...
    args.new_selstem, min(unique(runs)), max(unique(runs)));
disp( main_hist );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check_for_runs(runs,actives,args)

% check if only one run

% if unique(runs)==1
%   error('You cannot have only one run');
% end

if ~isint(actives)
    error('Use only integers for the active_selector');
end

if find(actives > 1 | actives < 0)
    error('Your active_selector should be binary only');
end

if length(find(runs==0)) & ~args.ignore_runs_zeros
    error('Your runs vector contains zeros');
end

if ~isrow(runs)
    error('Your runs vector should be a row vector');
end

if length(find(diff(runs)<0)) & ~args.ignore_jumbled_runs
    error('Your runs seem to be jumbled');
end

if ~compare_size(actives,runs)
    error('Your actives and runs are different sizes');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check_for_cursels(cursels,args)

if ~length(find(cursels==1))
    warning(['For some reason, you have no training TRs in this iteration. This creates a selector with all twos in it. This will be handled in the cross_validation function'])
end

if ~length(find(cursels==2)) & ~args.ignore_no_testing_timepoints
    warning(['For some reason, you have no testing timepoints in this iteration. This creates a selector with all ones in it. This will be handled in the cross_validation function']);
end
