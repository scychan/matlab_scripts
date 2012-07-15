%RS: change for windows:
if ispc
    mex pochhammer.c ../lightspeed/util.obj -I../lightspeed
    mex di_pochhammer.c ../lightspeed/util.obj -I../lightspeed
end
if isunix
    mex pochhammer.c ../lightspeed/util.o -I../lightspeed
    mex di_pochhammer.c ../lightspeed/util.o -I../lightspeed
end
%mex tri_pochhammer.c ../lightspeed/util.obj -I../lightspeed
%mex s_derivatives.c ../lightspeed/util.obj -I../lightspeed
