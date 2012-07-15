%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function is a subfunction of initGUIs that allows the data to be
%  passed in as a cell array as opposed to a text file.
%  opens and interprets and initialization file 
%
%
%% CHANGES
%   VI012109A: Establish the ArrayString/Array convention strictly by implementing the unpacking here -- Vijay Iyer 1/22/09
%
%% CREDITS
%   Created - Thomas Pologruto 1/28/04
%   Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%% *******************************************
function initGUIsFromCellArray(file)

if ~iscell(	file)
	error('initGUIsFromCellArray: Input must be a cell array (like output from textread)')
end

currentStructure=[];
variableList={};

lineCounter=0;
while lineCounter<length(file)				% step through each line of the file
	lineCounter=lineCounter+1;
	tokens=tokenize(file{lineCounter});		% turn each line into a cell array of tokens (words)
	if length(tokens)>0	        		% are there words on this line?
		if strcmp(tokens{1}, '%')       % if comment line, skip it
		elseif strcmp(tokens{1}, 'structure')		% are we starting a new structure?
			if length(currentStructure)>0
				currentStructure=[currentStructure '.' tokens{2}];
			else
				currentStructure=tokens{2};
			end
			[topName, structName, fieldName]=structNameParts(currentStructure);	
			
			eval(['global ' topName ';']);		% get a global reference to the correct top level variable
			if ~exist(topName,'var')
				eval([topName '=[];']);
			end
			if length(fieldName)>0
				if ~eval(['isfield(' structName ',''' fieldName ''');'])
					eval([currentStructure '=[];']);
				end
			end
			
		elseif strcmp(tokens{1}, 'endstructure') 		% are we ending a structure?
			periods=findstr(currentStructure, '.');		% then trim currentStructure depending on whether it
			if any(periods)								% has any subfields
				currentStructure=currentStructure(1:periods(length(periods))-1);
			else
				currentStructure=[];
			end
			
		else											% it must be a fieldname[=val] [param, value]* line 
			fieldName=tokens{1};						% get fieldName
			startingValue=[];
			equ=findstr(fieldName, '=');				% is there a initialization value?
			if any(equ)
				startingValue=fieldName(equ(1)+1:end);	% get initialization value
				fieldName=fieldName(1:equ(1)-1);		% get fieldname without init value
				val=str2num(startingValue);
				if length(val)==0 | ~isnumeric(val)
					if length(startingValue)>0 
                        %Note this should no longer be needed -- since all non-numeric-scalar values are now stored as strings
						if startingValue(1)~='''' | startingValue(end)~=''''
							startingValue=['''' startingValue ''''];
						end
					else
						startingValue='0';
					end
				end
			end
			
			if length(currentStructure)==0						% must be a global variable and not the field of a global
				fullVariableName=fieldName;
				eval(['global ' fullVariableName]);				% get access to the global
				if ~exist(fullVariableName,'var')				% if global does not exist...
					eval([fullVariableName '=' startingValue ';']);		% create it.
				elseif length(startingValue)>0					% if global exists and there is an init value ...
					eval([fullVariableName '=' startingValue ';']) 	% initialize global.
				end
			else												% we are dealing with the field of a global
				fullVariableName=[currentStructure '.' fieldName];
				if length(startingValue)>0	%there is an init value
                    
                    %Determine if this is an Array/ArrayString pairing (NOTE: This is no longer meant to be utilized -- Vijay Iyer 2/10/09
                    patLoc = findstr(fullVariableName,'ArrayString');
                    if  ~isempty(patLoc) && patLoc == length(fullVariableName) - 10 % && ~strcmpi(startingValue,'0')
                        evalVarName = fullVariableName(1:end-6);
                        arrayVar = true;
                    else
                        evalVarName = fullVariableName;
                        arrayVar = false;
                    end
                    
                    if ~isempty(findstr(startingValue,'&'))                        
                        eval([evalVarName '= ndArrayFromStr(' startingValue ');']);
                    elseif arrayVar %NOTE: This should no longer be utilized -- Vijay Iyer 2/10/09
                        if ~strcmpi(startingValue,'0')
                            eval([evalVarName '= str2num(' startingValue ');']);
                        else
                            eval([evalVarName '=[];']);
                        end
                    elseif ischar(eval(startingValue)) && ~isempty(str2num(eval(startingValue))) %String represeents a non scalar/empty numeric value
                        eval([evalVarName '= str2num(' startingValue ');']);
                    else %String represents a scalar/empty numeric value, or a non-numeric value (maybe even a string!) 
                        eval([evalVarName '= ' startingValue ';']); 
                    end
%                     elseif strfind(startingValue,'''[')==1
%                         eval([evalVarName '= eval(' startingValue ');']); %Convert string array representation into a numeric array
%                     else
%                         eval([evalVarName '= eval(' startingValue ');']); %Convert string array representation into a numeric array
%                         %eval([evalVarName '=' startingValue ';']) 	% set it
%                     end
        
                    %                     % Set
                    %                     if ~isempty(findstr(startingValue,'&'))
                    %                         eval([fullVariableName '= ndArrayFromStr(' startingValue ');']);
                    %                     else
                    %                         eval([fullVariableName '=' startingValue ';']) 	% set it
                    %                     end
                    %
                    %                     %%%VI012209A%%%%%%%%
                    %                     patLoc = findstr(fullVariableName,'ArrayString');
                    %                     if  ~isempty(patLoc) && patLoc == length(fullVariableName) - 10 && ~strcmpi(startingValue,'0')
                    %                         arrayVariableName = fullVariableName(1:end-6);
                    %                         if ~isempty(findstr(startingValue,'&'))
                    %                             eval([arrayVariableName '= ndArrayFromStr(' startingValue ');']);
                    %                         else
                    %                             eval([arrayVariableName '= str2num(' startingValue ');']);
                    %                         end
                    %                     end
                    %                     %%%%%%%%%%%%%%%%%%%%
				elseif ~eval(['isfield(' currentStructure ',''' fieldName ''');']) 	% if not, if field does not exist ...
					eval([fullVariableName '=[];'])					% initialize it
                end
                
			end
			
			variableList=[variableList, {fullVariableName}];
			validGUI=0;
			if length(tokens)>1
				tokenCounter=2;
				while tokenCounter<length(tokens)							% loop through [param, value]* 
					param=tokens{tokenCounter};
					if strcmp(param, '...')					% continuation marker
						lineCounter=lineCounter+1;				% advance to next line in file
						tokens=tokenize(file{lineCounter});		% turn each line into a cell array of tokens (words)
						tokenCounter=1;
						param=tokens{tokenCounter};
					end
					value=tokens{tokenCounter+1};
					if strcmp(param, '%')                       % found comment field. Skip line
						break;
					else                                        % not a comment line
						if strcmp(param, 'Gui')						% special case for associating a GUI to a Global
							if ~existGlobal(value)
								disp(['initGUIs: GUI ' value ' for ' fullVariableName ' does not exist.  Skipping userdata...']);
							else
								validGUI=1;
								addGUIOfGlobal(fullVariableName, value);
								setUserDataByGUIName({value}, 'Global', fullVariableName);	
							end
						elseif strcmp(param, 'Config')				% special case for labelling a global as part of a configuration
							setGlobalConfigStatus(fullVariableName, value);
						else										% put everything else in UserData
							if validGUI==1
								vNum=str2num(value);
								if isnumeric(vNum) & length(vNum)==1	% can it be a number?
									value=vNum;							% yes, then make it a number
								end
								setUserDataByGlobal(fullVariableName, param, value);	% put in UserData
							end
						end
					end
					tokenCounter=tokenCounter+2;
				end
            end                
			updateGUIByGlobal(fullVariableName);				% update all the GUIs that deal with the global variable
 
		end
	end
end


% Now execute all the callbacks that were collected during the processing of the
% *.ini.  This ensures that everything is correct after the fields in the GUIs
% have been changed by the initialization.

doneCallBacks=';;;';
for i=1:length(variableList)
	entry=variableList{i};
	GUIList=getGuiOfGlobal(entry);
	if length(GUIList)>0
		for count=1:length(GUIList)
			GUI=GUIList{count};
			if length(GUI)>0
				[topGUI, sGui, fGui]=structNameParts(GUI);
				eval(['global ' topGUI]);
				funcName='';
				eval(['funcName=getUserDataField(' GUI ', ''Callback'');']);
				if length(funcName)>0
					if length(findstr(doneCallBacks, [';' funcName ';']))==0
						doneCallBacks=[doneCallBacks funcName ';'];
						%							disp(['DoGUICallback(' GUI ');']);		% for debugging
						eval(['doGUICallback(' GUI ');']);
					end
				end
			end
		end
	end
end