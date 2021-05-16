function [ k_r ] = cartesiantoreciprocal(k_c)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
kx_c=k_c(:,1);
ky_c=k_c(:,2);
kx_r= (kx_c*sqrt(3)+ky_c)/2;
ky_r= (kx_c*sqrt(3)-ky_c)/2;
k_r=[kx_r, ky_r];
end

