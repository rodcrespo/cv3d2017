% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [U, V] = DoFlow1(dx, dy, dt,tInt, bInitialize,flowResIn)
% function DoFlow1 inputs images, dx, dy, dt, corresponding to the
% 3D gradients of a video feed. Outputs Tikhinov regularized and vectorized
% local optical flow, with temporal integration

persistent m200 m020 m110 m101 m011 gg flowRes;

if nargin < 6
    flowResIn = size(dx)/8;end
if nargin < 5
    bInitialize = 0;end
if nargin<4
    tInt = 0;end

if isempty(gg) || bInitialize
    stdTensor = 1.8; 
    gg  = single(gaussgen(stdTensor)); %% filter for tensor smoothing
    flowRes = flowResIn;
    m200 = zeros(flowRes,'single');
    m020 = zeros(flowRes,'single');
    m110 = zeros(flowRes,'single');
    m101 = zeros(flowRes,'single');
    m011 = zeros(flowRes,'single');
end

%Tikhinov Constant:
TC = single(150); 

%     MOMENT CALCULATIONS
%     moment m200, calculated in 5 steps explicitly
%     1) make elementwise product
      momentIm = dx.^2;
     
%     2) smooth with large seperable gaussian filter (spatial integration)
      momentIm = conv2(gg,gg,momentIm,'same');

%     3) downsample to specified resolution (imresizeNN function is found in "helperFunctions"):     
      momentIm =  imresizeNN(momentIm ,flowRes);

%     4) ...  add Tikhonov constant if a diagonal element (for m200, m020):
      momentIm =  momentIm + TC;
      
%    5) update the moment output (recursive filtering, temporal integration)
     m200 = tInt*m200 + (1-tInt)*momentIm;


%  L1:  The remaining moments are calculated as one liners:
 m020=tInt*m020 + (1-tInt)*(imresizeNN(conv2(gg,gg, dy.^2,'same'),flowRes)+ TC);
 m110=tInt*m110 + (1-tInt)* imresizeNN(conv2(gg,gg, dx.*dy,'same'),flowRes);
 m101=tInt*m101 + (1-tInt)* imresizeNN(conv2(gg,gg, dx.*dt,'same'),flowRes);
 m011=tInt*m011 + (1-tInt)* imresizeNN(conv2(gg,gg, dy.*dt,'same'),flowRes);
 
 %  L2: Implement the vectorized formulation of the solver:
U =( m101.*m110 - m011.*m200)./(m020.*m200 - m110.^2);%-2*TC^2/3);
V =(-m101.*m020 + m011.*m110)./(m020.*m200 - m110.^2);%-2*TC^2/3);

