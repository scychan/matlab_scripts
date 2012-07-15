function setPockelsVoltage(beam, volt)
%% function setPockelsVoltage(beam, volt)
% This will set the pockels cell to the voltage specified in volt
%TPMOD 2/6/02
%% MODIFICATIONS
% VI041808A Vijay Iyer 4/18/2008 - Use pockelsVoltageRange from standard.ini file to determine valid range
% VI011609A Vijay Iyer 1/16/2009 - Changed state.init.pockelsOn to state.init.eom.pockelsOn
%
%% ********************************************************

global state
if state.init.eom.pockelsOn %VI011609A
    if volt >= 0 & volt <= getfield(state.init.eom,['pockelsVoltageRange' num2str(beam)]) %VI041808A
        putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{beam}, volt);
    else
        warning('Voltage out of range 0 to 2 [V].');
        beep;
        return
    end
end

