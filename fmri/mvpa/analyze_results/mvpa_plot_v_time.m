%%This function plots the classifier's performcance over time.
%it returns a plot of how strongly it identified with each category at
%any particulat moment, as well as what the correct category was. It plots
%in both the forward and backward directions.

function h = mvpa_plot_v_time(results,labels)

niter = length(results.iterations);
h = figure;

for iter=1:niter
    
    act=results.iterations(iter).acts;
    
    celebrities=act(1,:);
    locations=act(2,:);
    objects=act(3,:);
    
    time=(1:length(act));
    
    %%%%%determine correct category
    
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
    subplot(niter,1,iter)
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