function flushAOData
global state gh

% Function that removes data from the engine of the AO objects used for acquisition.
% The AO objects will then have their SamplesAvailable property set to 0.
% It also will reput data to the devices...

% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 5, 2001
% Modified July 10, 2003 
%
% Modified 11/24/03 Tim O'Connor - Start using the daqmanager object.
% VI011609A: Changed state.init.pockelsOn to state.init.eom.pockelsOn -- Vijay Iyer 1/16/09

objs = [state.init.ao2F state.init.ao2];
if state.init.eom.pockelsOn == 1 %VI011609A
    for beamCounter = 1 : state.init.eom.numberOfBeams
        clearAOData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter});
    end
end

for objCounter = 1 : length(objs)
    if ~isempty(get(objs(objCounter), 'SamplesAvailable')) & get(objs(objCounter), 'SamplesAvailable') > 0 & strcmp(get(objs(objCounter), 'Running'), 'Off')
        start(objs(objCounter));
        stop(objs(objCounter));
    end
end

putDataGrab;
putDataFocus;