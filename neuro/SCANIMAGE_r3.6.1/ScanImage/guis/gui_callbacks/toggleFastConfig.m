function toggleFastConfig(handleOrConfigNum,forceValue)
%% function toggleFastConfig(handleOrConfigNum,forceValue)
%   Callback through which all changes to fastConfig toggle buttons are routed
%% SYNTAX
%   toggleFastConfig(hObject)
%   toggleFastConfig(configNum,forceValue)
%       hObject: Handle to fastConfig toggle button 
%       configNum: Integer value specifying the fastConfig button to toggle
%       forceValue: Logical value which forces the toggle button to the specified state. Must be supplied if configNum is supplied.
%% NOTES
%   Function is used in two cases: 1) directly as a callback when the button is pressed, and 2) programatically, where the configuration is identified by number and forced to a value
%% *****************************

global state gh

if nargin < 2 % Fucntion is result of direct toggle (callback)
    configNumStr = deblank(get(handleOrConfigNum,'Tag'));
    configNum = str2num(configNumStr(end));
    hButton = handleOrConfigNum;

    if get(hButton,'Value')
        newVal = loadConfigFast(configNum);
    else %disallow direct toggle off
        newVal = 1;
    end        
else
    configNum = handleOrConfigNum;
    hButton = gh.mainControls.(['tbFastConfig' num2str(configNum)]);

    newVal = forceValue;
end

if newVal == 1
    set(hButton,'ForegroundColor',[0 .5 0],'Value',1);
    offConfigs = setdiff(1:state.files.numFastConfigs,configNum);
    arrayfun(@(num)toggleFastConfig(num,0),offConfigs);
else
    set(hButton,'ForegroundColor',[.314 .318 .314],'Value',0);
end


        


