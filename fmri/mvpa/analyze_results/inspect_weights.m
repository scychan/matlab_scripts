ncat = size(results.iterations(1).acts,1)

%% histogram of weights

weights = load_weights(results,1,0);

h1 = figure;
h2 = figure;
for icat = 1:ncat
    w = weights(:,icat);
    
    figure(h1)
    subplot(ncat,1,icat)
    hist(w)
    
    figure(h2)
    subplot(ncat,1,icat)
    hist(w(abs(w)>0.01),20)
    %     set(gca,'xlim',clims)
    %     set(gca,'ylim',[0 30])
end


%% make 3D plots (one for each category)
% average across iterations XX

weights3D = load_weights(results,1,1,mask,1);

nslices = size(weights3D,3);
nrows = floor(sqrt(nslices));
ncols = ceil(nslices/nrows);

for icat = 1:3
    
    figure; figuresize('fullscreen')
    colormap('cool')
    
    for islice = 1:nslices
        
        subplot(nrows,ncols,islice)
%         imagesc(weights3D(:,:,islice,icat))
        
%         clims = [-0.015 0.015];
        clims = [min(weights(:,icat)) max(weights(:,icat))];
        imagesc(weights3D(:,:,islice,icat),clims)
    end
    suptitle(sprintf('Category %i',icat))
    colorbar
end
