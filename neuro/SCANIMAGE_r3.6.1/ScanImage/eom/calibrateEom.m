%% function [eom_max, eom_min, avg_dev] = calibrateEom(varargin);
%  Construct an array of output voltages
%  that correspond to attenuations in laser intensity
%  via a Pockels cell.
%
%% SYNTAX
%  The return values are:
%    eom_max - the maximum voltage input measured.
%    eom_min - the minimum voltage input measured.
%    avg_dev - the average standard deviation over all measurements.
%
%% NOTES
%  The array is stored in state.eom.lut, the index into the
%  array reflects the percentage of the maximum possible intensity.
%  The resolution is 1%.

%   This version was rewritten from scratch. To see earlier versions of
%   this function, see makeStripe.mold -- Vijay Iyer 3/19/09
%
%            
%% CREDITS
%  Created by Tim O'Connor, 5/13/03
%  Refactored/modified by Vijay Iyer 3/19/09
%% ************************************************************

function [eom_max, eom_min, avg_dev] = calibrateEom(varargin)
global state;

if ~isempty(varargin)
    beams = varargin{1};
else
    beams = 1:state.init.eom.numberOfBeams;
end

if length(beams) > 1
    for i=1:length(beams)
        calibrateEom(varargin{i});

        %Don't calibrate others when calibration is cancelled.
        if state.init.eom.cancel
            return;
        end
    end
else
    beam = beams;
end

%Get pockels voltage range for this beam
pockelsVoltageRange =getfield(state.init.eom, ['pockelsVoltageRange' num2str(beam)]);

%VI103108A: Handle cases where naive/non calibration is required
if dummyEOMCalibrate(beam)
    markCalibration(beam); %mark it as calibrated, though it's not really

    eom_min = state.init.eom.min(beam);
    eom_max = state.init.eom.maxPhotodiodeVoltage(beam);
    avg_dev = 0;
    return;
end

%Proceed with actual calibration

wb = waitbar(0, sprintf('Calibrating Pockels Cell #%s...', num2str(beam)), 'Name', 'Calibrating...', ...
    'createCancelBtn', 'global state; state.init.eom.cancel = 1; delete(gcf);');
state.init.eom.cancel = 0;

%Create array of modulation voltages, sampling more densely at lower end of range
modulation_voltage = [0:(state.internal.eom.calibration_interval/10):(pockelsVoltageRange/10) (pockelsVoltageRange/10):state.internal.eom.calibration_interval:pockelsVoltageRange]';
photodiode_voltage = zeros(length(modulation_voltage), 1);
state.init.eom.lut(beam, :) = zeros(100, 1);

ao_s_rate = getAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'SampleRate');
ao_repeat_output = getAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'RepeatOutput');
ao_clock_source = getAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'ClockSource');
ao_trig_source = getAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'HwDigitalTriggerSource');
%ao_buffering_config = getAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingConfig');
ao_buffering_mode = getAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingMode');

eval(sprintf('ai = state.init.eom.ai{%s};', num2str(beam))); %VI103108B

set(ai, 'SampleRate', state.internal.eom.calibrationSampleRate);
set(ai, 'SamplesPerTrigger', length(modulation_voltage));
%set(ai, 'TriggerType', 'HwDigital');%This is the important one.
setAITriggerType(ai,'HWDigital');
if strcmpi(whichNIDriver,'DAQmx')
    set(ai,'HWDigitalTriggerSource',state.init.triggerInputTerminal);
end

setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'SampleRate', state.internal.eom.calibrationSampleRate);
setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'RepeatOutput', 0);
setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'ClockSource', 'Internal');
setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'HwDigitalTriggerSource', state.init.triggerInputTerminal);
%setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'BufferingMode', 'auto');

putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 0);

data = zeros(state.internal.eom.calibrationPasses,length(modulation_voltage),1);
calibrationPassTime = length(modulation_voltage) / state.internal.eom.calibrationSampleRate;

for i=1:state.internal.eom.calibrationPasses
    %TO12404a - It should be safe to just return from here. Check at the end of the loop too.
    if state.init.eom.cancel
        restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source,ao_buffering_config,ao_buffering_mode); %VI041908A %VI052108A
        return;
    end

    %Start the acquisition.
    start(ai);

    %Buffer the modulation signal.
    putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beam}, modulation_voltage);

    %Output the modulation signal.
    startChannel(state.acq.dm, state.init.eom.pockelsCellNames{beam});

    %Trigger the I/O.
    dioTrigger;

    %Wait for completion
    wait(getAO(state.acq.dm, state.init.eom.pockelsCellNames{beam}), 1.1*calibrationPassTime);

    %This will automatically wait until all data in the buffer is flushed through the board.
    stopChannel(state.acq.dm, state.init.eom.pockelsCellNames{beam});

    data(i, :, :) = getdata(ai);

    %Stop the acquistion.
    stop(ai);

    waitbar(i / state.internal.eom.calibrationPasses, wb);
end

%TO12404a - It should be safe to just return from here...
if state.init.eom.cancel
    restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source,ao_buffering_config,ao_buffering_mode); %VI041908A VI052108A
end

photodiode_voltage = mean(data, 1);
photodiode_voltage_stdDev = std(data, 1);

%Subtract off any offset in the detector electronics.
photodiode_voltage = photodiode_voltage - getfield(state.init.eom, ['photodiodeOffset' num2str(beam)]);

%     %Throw away the first few, as there seems to be error at very low voltages (disregard anything below state.internal.eom.low_lim% of max).
%     %Still take the data anyway, just for consistency (array sizes, etc).
%     for i = 1 : round(100 * state.internal.eom.low_lim / length(photodiode_voltage))
%         photodiode_voltage(i) = photodiode_voltage(round(100 * state.internal.eom.low_lim / length(photodiode_voltage)));
%     end

%Gather up the return variables.
[eom_min min_p] = min(photodiode_voltage);
eom_max = max(photodiode_voltage);
avg_dev = mean(photodiode_voltage_stdDev ./ eom_max);
state.init.eom.maxPhotodiodeVoltage(beam) = eom_max;

if (avg_dev > .35) || ((eom_min / eom_max) > .15)%Bad data? -- Too noisy or not enough attenuation.
    fprintf(2, '\nWARNING: Pockels cell calibration data seems bad.\n');
    beep;
    if (eom_min / eom_max) > .15
        fprintf(2, '  Pockels cell minimum power not less than 15%% of maximum power. Min: %s%%\n', num2str( 100 * eom_min / eom_max));
    else
        fprintf(2, '  Pockels cell calibration seems excessively noisy.\n  Typical standard deviation per sample: %s%%\n', num2str(100 * avg_dev));
    end

    f = figure('NumberTitle', 'off', 'DoubleBuffer', 'On','Name', 'Pockels Cell Calibration Curve', 'Color', 'White');
    a = axes('Parent', f, 'FontSize', 12, 'FontWeight', 'Bold');
    plot(modulation_voltage, photodiode_voltage, 'Parent', a, 'Color', [0 0 0], 'LineWidth', 2);
    %TO1604 - Added the beam number to the plot.
    t = sprintf('Pockels Cell Calibration Curve (beam: %s)', num2str(beam));
    title(t, 'Parent', a, 'FontWeight', 'bold');
    xlabel('Modulation Voltage (From DAQ Board) [V]', 'Parent', a, 'FontWeight', 'bold');
    ylabel('Photodiode Voltage [V]','Parent', a, 'FontWeight', 'bold');
    state.internal.figHandles = [f state.internal.figHandles]; %VI110708A
end

% Normalize.
photodiode_voltage = photodiode_voltage / eom_max;

%Take measurement from rejected light, if necessary.
%Note: The return values are still in absolute form.
eval(sprintf('rejected = state.init.eom.rejected_light%s;', num2str(beam)));
if rejected
    photodiode_voltage = 1 - photodiode_voltage;
end

%Round off to the nearest %.
photodiode_voltage = round(100 * photodiode_voltage);
photodiode_voltage(photodiode_voltage < 0) = 0;

%%%%%%COMMENTED OUT (VI052108B)%%%%%%%%%%%%%%%%%%
%     state.init.eom.min(beam) = ceil(100 * (eom_min / eom_max));
%     if state.init.eom.min(beam) > 100
%         fprintf(2, 'WARNING: Minimum power for beam %s is over 100%% (%s). Forcing it to 99%%...\n', num2str(beam), num2str(state.init.eom.min(beam)));
%         state.init.eom.min(beam) = 99;
%     elseif state.init.eom.min(beam) < 0
%         fprintf(2, 'WARNING: Minimum power for beam %s is below 0%% (%s). Forcing it to 1%%...\n', num2str(beam), num2str(state.init.eom.min(beam)));
%         state.init.eom.min(beam) = 1;
%     end
%     if state.init.eom.min(beam) < 1
%         state.init.eom.min(beam) = 1;
%     end
%%%%%%END COMMENT%%%%%%%%%%%%%%%%%%

%Identify minimum power percentage
p = ceil(100 * eom_min / eom_max);

if isnan(p) %dud data
    fprintf(2,'WARNING: Photodiode data is flat--possibly disconnected. Using naive linear calibration instead\n');
    naiveEOMCalibrate(beam);
    p=1;
else
    if p < 1
        p = 1;
    elseif p > 100   %TO1604 - This seemed to happen when the laser was acting funny (not mode-locked?).
        p = 100;
        fprintf(2, 'WARNING: Pockels cell calibration appears saturated or noisy');
    end
    state.init.eom.lut(beam, 1:p) = modulation_voltage(min_p);
end
%TO1604 - Look into this some more...
state.init.eom.min(beam) = p;

%Set the real values.
for i = (p+1):100

    pos = find(photodiode_voltage == i); %Locate a modulation voltage that gives the desired transmittance.
    if length(pos) > 0
        %Take the one closest to the last voltage.
        pos_diff = abs(modulation_voltage(pos) - state.init.eom.lut(beam, i - 1));
        [val loc] = min(pos_diff);
        state.init.eom.lut(beam, i) = modulation_voltage(pos(loc));
    else %if length(pos) > 0
        if i == 100 %Just keep the last one.
            state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1);
        elseif i == state.init.eom.min(beam)
            state.init.eom.lut(beam, i) = modulation_voltage(min_p);
        elseif i > state.init.eom.min(beam)
            %Assume local linearity.
            %This can result in something very ugly...  but, it's still a reasonable method.
            if i > 2
                step = state.init.eom.lut(beam, i - 1) - state.init.eom.lut(beam, i - 2);
                if abs(step) < (.2 * pockelsVoltageRange)
                    state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1) + step;%Project outwards.
                else
                    state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1);%Give up, and just use the last value.
                end
            else %if i > 2
                state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1);
            end %if i > 2
        end %if i == 100
    end %if length(pos) > 0
end  %for i = p + 1:100

restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source); %VI041908A  VI052108A   VI081208A

if state.init.eom.started
    flushAOData;
end

close(wb);

%Provide warnings if modulation voltages determined are outside of range
over = find(state.init.eom.lut > pockelsVoltageRange);
if over
    if find((state.init.eom.lut(over) - pockelsVoltageRange) >= .005)
        fprintf(2, ['Warning: Illegal entries found in the Pockels cell voltage lookup table (exceeded maximum value of ' num2str(pockelsVoltageRange) 'V specified. in INI file). Resetting them into legal range.' sprintf('\n')]); %VI101608A, VI110208A
    end
    state.init.eom.lut(over) = pockelsVoltageRange;
end
under0 = find(state.init.eom.lut < 0);
if under0
    if find(state.init.eom.lut(under0) <= -.005)
        fprintf(2, 'Warning: Illegal entries found in the Pockels cell voltage lookup table (under 0V), resetting them into legal range.\n');
    end
    state.init.eom.lut(under0) = 0;
end

if size(state.init.eom.lut(beam, :), 2) ~= 100
    error(sprintf('Pockels cell %s lookup table size out of bounds: %s', num2str(beam), num2str(size(state.init.eom.lut(beam, :), 2))));
end

%TO12204a - Tim O'Connor 1/24/04: Somehow the min wasn't a cardinal value when one laser was configured but turned off.
state.init.eom.min(beam) = ceil(state.init.eom.min(beam));

markCalibration(beam); %VI041008B

return;

%Handle end of calibration (VI041008B)
function markCalibration(beam)
global state  %VI050508A

state.init.eom.changed(beam) = 1;
ensureEomGuiStates(beam);%TO22604g

%Flag that it's been calibrated (at least once). TO22604e
state.init.eom.calibrated(beam) = 1;
return;

%Ensure that AO settings are restored, regardless of calibration outcome (VI041908A)
function restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source,ao_buffering_config,ao_buffering_mode)
global state

setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'SampleRate', ao_s_rate);
setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'RepeatOutput', ao_repeat_output);
setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'ClockSource', ao_clock_source);
setAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'HwDigitalTriggerSource',ao_trig_source);
%setAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingConfig',ao_buffering_config); %VI052108A, VI081208A
%setAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingMode',ao_buffering_mode); %VI052108A, VI081208A


return;


