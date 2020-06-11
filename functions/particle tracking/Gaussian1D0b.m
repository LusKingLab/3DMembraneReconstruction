function [ output ] = Gaussian1D0b( P,x )
%1D Gaussian function with out background
%   P(4) background
%   P(3) peak height
%   P(1) peak position
%   P(2) peak width sigma

output=P(3)*exp(-(x-P(1)).^2/P(2)^2);

end

