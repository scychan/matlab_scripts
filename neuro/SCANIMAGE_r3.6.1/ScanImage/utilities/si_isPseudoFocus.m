function tf = si_isPseudoFocus()
%SI_NEEDTOSAVE Determines if in 'pseudofocus' mode -- a GRAB/LOOP acquisition where no data saving is done (or planned).
%In almost all cases, one saves (or plans to save) for GRAB/LOOP acqs. 
%However, if disk logging is active and framesPerFile=0, this is termed 'pseudo-focus' mode. Data is not expected to be saved.

global state

tf = (state.acq.saveDuringAcquisition && state.standardMode.standardModeOn &&  ~state.standardMode.framesPerFileGUI); 
