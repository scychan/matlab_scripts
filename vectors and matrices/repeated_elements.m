function lengths = repeated_elements(v,element)
% 
% INPUTS:
% v - a vector
% element - the element whos 
% 
% OUTPUTS:
% 

u = (v==element);

is = find(diff([0 u])==1);
ie = find(diff([u 0])==-1);
lengths = ie-is+1;