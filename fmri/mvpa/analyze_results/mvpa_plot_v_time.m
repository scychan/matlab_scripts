%%This function plots the classifier's performcance over time.
%it returns a plot of how strongly it identified with each category at
%any particulat moment, as well as what the correct category was. It plots
%in both the forward and backward directions.

function h = mvpa_plot_v_time(results,labels,iter_to_plot)

h = figure;

if ~exist('iter_to_plot','var')
    
    niter = length(results.iterations);
    if niter==12
        nploty = 6;
        nplotx = 2;
    else
        nploty = niter;
        nplotx = 1;
    end
    
    for iter=1:niter
        
        act=results.iterations(iter).acts;
        
        celebrities=act(1,:);
        locations=act(2,:);
        objects=act(3,:);
        
        time=(1:length(act));
        
        % determine correct category
        
        correct=results.iterations(iter).perfmet.desireds;
        separate_correct=zeros(3,length(act));
        for guess=1:length(act)
            if correct(guess)==1
                separate_correct(1,guess)=1.5;
                
            elseif correct(guess)==2
                separate_correct(2,guess)=1.5;
                
            elseif correct(guess)==3
                separate_correct(3,guess)=1.5;
            end
        end
        
        separate_correct(~separate_correct)=NaN;
        subplot(nploty,nplotx,iter)
        plot(time,celebrities,'r',time,locations,'g',time,objects,'b',...
            time,separate_correct(1,:),'r+',time,separate_correct(2,:),'g+',time,separate_correct(3,:),'b+')
        title(sprintf('Iteration %i',iter))
    end
    
    % add legend
    legend_exec = ['legend('];
    for i = 1:length(labels)
        legend_exec = [legend_exec '''Guess ' labels{i} ''','];
    end
    legend_exec = [legend_exec(1:end-1) ')'];
    eval(legend_exec)
    
else
    
    act=results.iterations(iter_to_plot).acts;
    
    celebrities=act(1,:);
    locations=act(2,:);
    objects=act(3,:);
    
    time=(1:length(act));
    
    % determine correct category
    
    correct=results.iterations(iter_to_plot).perfmet.desireds;
    separate_correct=zeros(3,length(act));
    for guess=1:length(act)
        if correct(guess)==1
            separate_correct(1,guess)=1.5;
            
        elseif correct(guess)==2
            separate_correct(2,guess)=1.5;
            
        elseif correct(guess)==3
            separate_correct(3,guess)=1.5;
        end
    end
    separate_correct(~separate_correct)=NaN;
    
    nplot = 4;
    tstarts = [1 round(length(time)/nplot * (1:(nplot)))];
    for iplot = 1:nplot
        subplot(nplot,1,iplot)
        TRs = tstarts(iplot) : (tstarts(iplot+1)-1);
        plot( TRs, celebrities(TRs),'r', TRs, locations(TRs),'g', TRs, objects(TRs),'b', ...
            tstarts(iplot) : (tstarts(iplot+1)-1), ...
            separate_correct(1,TRs),'r+',TRs,separate_correct(2,TRs),'g+',TRs,separate_correct(3,TRs),'b+')
    end
    
    subplot(nplot,1,1)
    title(sprintf('Iteration %i',iter_to_plot))
    
    % add legend
    legend_exec = ['legend('];
    for i = 1:length(labels)
        legend_exec = [legend_exec '''Guess ' labels{i} ''','];
    end
    legend_exec = [legend_exec(1:end-1) ')'];
    eval(legend_exec)
end