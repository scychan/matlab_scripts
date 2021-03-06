%% one set of results

figure

icat = 1;

for iter = 1:12
    
    desireds = results{icat}.iterations(iter).perfmet.desireds;
    acts = results{icat}.iterations(iter).acts;
    
    subplot(211)
    plot(desireds')
    
    subplot(212)
    plot(acts')
    
    pause
end

%% two sets of results
% results1 + results2

subjnum = 109;
driftrate = 0.10;
dirname = dir_filenames(sprintf('CLO%i/*RW%1.2f_maskWB_noNB',subjnum,driftrate))
load(
load(sprintf(

figure

results1name = 'train and test on leftovers';
results2name = 'train on full timecourse, test on leftovers';
icat = 1;

for iter = 1:12
    
    % results1
    
    desireds1 = results1{icat}.iterations(iter).perfmet.desireds;
    acts1 = results1{icat}.iterations(iter).acts;
    
    subplot(221)
    plot(desireds1')
    title([results1name ' - target output'])
    
    subplot(223)
    plot(acts1')
    title([results1name ' - classifier output'])
    
    
    % results2
    
    desireds2 = results2{icat}.iterations(iter).perfmet.desireds;
    acts2 = results2{icat}.iterations(iter).acts;
    
    subplot(222)
    plot(desireds2')
    title([results2name ' - target output'])
    
    subplot(224)
    plot(acts2')
    title([results2name ' - classifier output'])

    % compute correlation
    correlations(iter) = corr(acts1(:),acts2(:))
    
    pause
end

mean(correlations)