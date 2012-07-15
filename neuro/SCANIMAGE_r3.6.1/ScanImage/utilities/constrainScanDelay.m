function scanDelayOut = constrainAccelerationTime(scanDelayIn, fillFraction, msPerLine)
%CONSTRAINSCANDELAY Constrains scan delay to valid values, where scan delays are in microseconds

global state

scanDelayIncrement = 2 * state.internal.minAOPeriodIncrement * 1e6; %Allow steps of 2 AO sampling periods
scanDelayOut = round(scanDelayIn / scanDelayIncrement) * scanDelayIncrement;

%Do not allow scan delay to exceed the non-fill-fraction
maxScanDelay = (1 - fillFraction) * msPerLine * 1e3;
scanDelayOut = min(scanDelayOut, maxScanDelay); %assumes that maxScanDelay satisfies the appropriate integer-multiple constraint











