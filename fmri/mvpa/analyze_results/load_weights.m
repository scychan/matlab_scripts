function weights = load_weights(results,avg_iters,unmask,mask,rm_emptyslices)
% function weights = load_weights(results,avg_iters,unmask,mask)
% 
% INPUTS:
%   results     - output struct from Princeton MVPA toolbox's cross_validation.m
%   avg_iters   - whether or not to average over xvalidation iterations to form a single set of weights
%                   [optional. DEFAULT = 1]
%   unmask      - whether to unmask to end up in a 3D space
%                   [optional. DEFAULT = 0]
%   mask        - maskfile that was used to mask the original data in the MVPA analysis
%                   (use load_nifti.m or spm_vol)
%                   Required if unmask==1.
%   
% OUTPUT:
%   Without unmasking:
%       weights = [num voxels x num categories x num iterations]
%   With unmasking:
%       weights = [braindim1 x braindim2 x braindim3 x num categories x num iterations]

if ~exist('avg_iters','var'), avg_iters = 1; end
if ~exist('unmask','var'), unmask = 0; end

%% load MVPA results
iterations = results.iterations;
niter = length(iterations);

% get weights for all the iterations
[nvox, ncat] = size(iterations(1).scratchpad.weights); % # voxels, # categories
weights = nan(nvox,ncat,niter);
for iter = 1:niter
    weights(:,:,iter) = iterations(iter).scratchpad.weights;
end

%% average over the iterations

if avg_iters == 1
    weights = mean(weights,3);
    niter = 1;
end

%% un-mask the weights (so that they are in 3D brain space)

if unmask == 1
        
    % un-mask the weights
    weights3D = nan(size(mask,1),size(mask,2),size(mask,3),ncat,niter);
    for iter = 1:niter
        for icat = 1:ncat
            weights3Dtemp = zeros(size(mask));
            weights3Dtemp(mask==1) = weights(:,icat,iter);
            weights3D(:,:,:,icat,iter) = weights3Dtemp;
        end
    end
    
    weights = weights3D;
    
    % remove the slices with all zeros
    if rm_emptyslices
        nslices = size(weights,3);
        for islice = 1:nslices
            temp = weights(:,:,islice,:) > 0;
            allzeros(islice) = ~any(temp(:));
        end
        weights = weights(:,:,~allzeros,:);
    end
end