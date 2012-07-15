function enableEomGui(on)
global state gh

if nargin < 1
    on=1;
end

if ~state.init.eom.pockelsOn | ~isfield(gh,'powerControl') %VI011609A
    return
end

if on
    % Commence monkeying.
    set(get(gh.powerControl.figure1,'Children'),'Enable','on');
    set(get(gh.powerTransitions.figure1,'Children'),'Enable','on');
    
    %%%VI021009A%%%%
    if get(gh.powerControl.tbShowPowerBox,'Value')
        seeGUI('gh.powerBox.figure1');
    end
    %%%%%%%%%%%%%%%
else
    % Disable monkeying with this stuff.
    set(get(gh.powerControl.figure1,'Children'),'Enable','off');
    set(get(gh.powerTransitions.figure1,'Children'),'Enable','off');
    hideGUI('gh.powerBox.figure1'); %VI021009A
end
