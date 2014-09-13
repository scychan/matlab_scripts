function ismultiple = ismultiple(number,factor)
% function ismultiple = ismultiple(number,factor)

ismultiple = roundoff(number,factor)==number;