function updateFastConfig(configNum)
%% function updateFastConfig(configNum)
%   Handler once fastConfig value has been set
%
%% NOTES
%   This was created to refactor out common code between setFastConfig() and openusr()
%
%% CREDITS
%   Created 2/10/09, by Vijay Iyer
%   Based on earlier versions of setFastConfig() and openusr()
%% *****************************************

global state gh

if isfield(state.files,['fastConfig' num2str(configNum)])
    [pname,fname] = fileparts(state.files.(['fastConfig' num2str(configNum)]));
    if isempty(fname)
        labelStem = num2str(configNum);
    else
        labelStem = fname;
    end
    h=getfield(gh.mainControls,['fastConfig' num2str(configNum)]);
    label=get(h,'Label');
    ind=findstr(label,' ');
    label(1:ind(end))=[];
    label=[labelStem '   ' label];
    set(h,'Label',label);
    
    if ~isempty(fname)
        set(gh.mainControls.(['tbFastConfig' num2str(configNum)]),'TooltipString',[fname '(F' num2str(configNum) ')']); %VI020909C
    end
end

%     if isempty(fname)
%         fname=num2str(number);
%     else
%         [path,fname]=fileparts(fname);
%     end
%     h=getfield(gh.mainControls,['fastConfig' num2str(number)]);
%     label=get(h,'Label');
%     ind=findstr(label,' ');
%     label(1:ind(end))=[];
%     label=[fname '   ' label];
%     set(h,'Label',label);
% end