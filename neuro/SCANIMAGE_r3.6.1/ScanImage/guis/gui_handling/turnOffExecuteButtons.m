function turnOffExecuteButtons(flagName)
global gh state

set(gh.mainControls.focusButton, 'enable', 'off')
set(gh.mainControls.startLoopButton, 'enable', 'off')
set(gh.mainControls.grabOneButton, 'enable', 'off')
set(gh.motorGUI.GRAB, 'enable', 'off')

if nargin>=1    
    if ~ismember(flagName, state.internal.executeButtonFlags)
        state.internal.executeButtonFlags = {state.internal.executeButtonFlags{:} flagName};
    end
end
