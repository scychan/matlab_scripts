% Plots confusion matrix for each iteration of MVPA classification.

function h = mvpa_confusion_matrix(results,labels)

niter = length(results.iterations);
h = figure;

for iter = 1:niter
    
    performance = results.iterations(iter).perfmet;
    
    % initialize matrices
    for label=1:length(labels);
        number_guessed(label).label = zeros(1,length(labels));
    end
    for category=1:length(labels)
        number_guessed(category).category=0;
    end
    
    % do the counting
    for attempt=1:length(performance.guesses)
        
        for category_guessed=1:length(labels)
            
            if performance.desireds(attempt)==category_guessed
                number_guessed(category_guessed).category=number_guessed(category_guessed).category+1;
                
                for category_desired=1:length(labels)
                    if performance.guesses(attempt)==category_desired
                        
                        number_guessed(category_guessed).label(category_desired)=...
                            number_guessed(category_guessed).label(category_desired)+1;
                        
                    end
                end
            end
        end
    end
    
    % get proportions
    for category=1:length(labels)
        number_guessed(category).label=number_guessed(category).label/number_guessed(category).category;
    end
    
    % make the bar plots
    
    subplot(niter,1,iter)
    bar_input=[];
    
    for category=1:length(labels)
        bar_input=[bar_input ; number_guessed(category).label];
    end
    
    bar(bar_input)
    set(gca,'YLim',[0 1]);
    set(gca,'xticklabels',labels)
    ylabel('proportion')
    title(sprintf('Iteration %i',iter))
end

% add legend
legend_exec = ['legend('];
for i = 1:length(labels)
    legend_exec = [legend_exec '''Guess ' labels{i} ''','];
end
legend_exec = [legend_exec(1:end-1) ')'];
eval(legend_exec)
