function [fillFraction, msPerLine] = decodeFillFractionGUI(fillFractionGUI)
%DECODEFILLFRACTIONGUI Extracts fill fraction and ms/line values from fillFractionGUI value (index)

global state

incrementMultiplier = state.internal.linePeriodIncrementMultipliers(fillFractionGUI);
msPerLine = state.internal.nominalMsPerLine + incrementMultiplier * state.internal.linePeriodIncrement * 1e3;
fillFraction = state.internal.activeMsPerLine / msPerLine;




