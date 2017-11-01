% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [U, V] = DoFlow1Full(dx, dy, dt,tInt,bInit)
persistent m200 m020 m110 m101 m011 gg;
%%initialization:
if isempty(gg) || ((nargin > 4)&& bInit)
    stdTensor = 1.8; 
    gg   = single(gaussgen(stdTensor)); %% filter for moment generation
    m200 = zeros(size(dx),'single');
    m020 = zeros(size(dx),'single');
    m110 = zeros(size(dx),'single');
    m101 = zeros(size(dx),'single');
    m011 = zeros(size(dx),'single');
end

%Tikhonov Constant:
TC  = single(150);

%generate moments 
m200= tInt*m200 + (1-tInt)*(conv2(gg,gg, dx.^2 ,'same')+TC);
m020= tInt*m020 + (1-tInt)*(conv2(gg,gg, dy.^2 ,'same')+TC);
m110= tInt*m110 + (1-tInt)* conv2(gg,gg, dx.*dy,'same');
m101= tInt*m101 + (1-tInt)* conv2(gg,gg, dx.*dt,'same');
m011= tInt*m011 + (1-tInt)* conv2(gg,gg, dy.*dt,'same');
 
%flow calculations:
U =( m101.*m110 - m011.*m200)./(m020.*m200 - m110.^2);
V =(-m101.*m020 + m011.*m110)./(m020.*m200 - m110.^2);