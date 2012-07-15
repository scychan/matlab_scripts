function [sample_spikes,spike_times,spike_heights,spike_widths,modelspike] = ...
    spike_sort(V,thresh_low,thresh_high,dt)

ind_baseline_suprathresh = find(V>thresh_low);

if isempty(ind_baseline_suprathresh) % if there are no spikes
    spike_heights = [];
    modelspike = [];
    sample_spikes = [];
    spike_times = [];
else
    
    jumps = find_jumps(ind_baseline_suprathresh,1,.001/dt);
    ind_baseline_spikes = ind_baseline_suprathresh([1;jumps]);
    num_baseline_spikes = numel(ind_baseline_spikes);
    t_reach = .0035;
    t_vec_modelspike = -t_reach/dt:t_reach/dt;
    sample_spikes = zeros(length(t_vec_modelspike),num_baseline_spikes);
    spike_times = zeros(1,num_baseline_spikes);
    spike_widths = zeros(1,num_baseline_spikes);
    for i = 1:num_baseline_spikes
        ind_approx = ind_baseline_spikes(i);
        local_max = max(V((ind_approx-.0005/dt):(ind_approx+.0005/dt)));
        if local_max < thresh_high
            local_ind_max = find(V((ind_approx-.0005/dt):(ind_approx+.0005/dt)) == local_max,1);
            global_ind_max = local_ind_max-1+ind_approx-.0005/dt;
            
            spike_start = find(V(global_ind_max-round(t_reach/dt):global_ind_max)<0,1,'last');
            spike_end = find(V(global_ind_max:global_ind_max+round(t_reach/dt))<0,1,'first');
            if isempty(spike_start) || isempty(spike_end)
                sample_spikes(:,i) = -10000*ones(size(t_vec_modelspike));
            else
                spike_widths(i) = (spike_end-spike_start)*dt+t_reach;
                
                inds = t_vec_modelspike + global_ind_max;
                inds = inds(inds>0);
                sample_spikes(end-length(inds)+1:end,i) = V(inds);
                spike_times(i) = int16(local_ind_max*dt+ind_approx-.0005/dt);
            end
            
        else
            sample_spikes(:,i) = -10000*ones(size(t_vec_modelspike));
        end
    end
    
    not_past_thresh_high = sample_spikes(1,:)>-10000;
    sample_spikes = sample_spikes(:,not_past_thresh_high);
    spike_times = spike_times(:,not_past_thresh_high);
    spike_widths = spike_widths(:,not_past_thresh_high);
    
    figure; hist(spike_widths,40)
    xlabel('spike duration (sec)'); ylabel('num spikes')
    
    spike_heights = sample_spikes(int8(t_reach/dt+1),:);
    figure; hist(spike_heights,30)
    xlabel('spike height (uV)'); ylabel('number of spikes')
    
    figure;plot(1000*dt*t_vec_modelspike,sample_spikes)
    hold on; plot(1000*dt*t_vec_modelspike,zeros(size(t_vec_modelspike)),'--k')
    xlabel('time (ms)'); ylabel('uV')
    
    modelspike = mean(sample_spikes,2);
    figure; plot(1000*dt*t_vec_modelspike,modelspike)
    hold on; plot(1000*dt*t_vec_modelspike,zeros(size(t_vec_modelspike)),'--k')
    xlabel('time (ms)'); ylabel('uV')
    
    figure
    scatter(spike_heights,spike_widths,'.')
    xlabel('spike heights (uV)'); ylabel('spike durations (s)')
    
end