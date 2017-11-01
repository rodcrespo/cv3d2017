% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [U, V] = DoFlowLK(dx, dy, dt,flowRes)
% function DoFlow inputs images, dr, dy, dt, corresponding to the
% 3D gradients of a video feed
if nargin < 4
    flowRes = size(dx)/8;end

stdTensor = 1.8; 
gg  = single(gaussgen(stdTensor)); %% filter for tensor smoothing

U = zeros(flowRes,'single');
V = zeros(flowRes,'single');

%     MOMENT CALCULATIONS
%     moment m200, calculated in 3 steps explicitly
%     1) make elementwise product
      momentIm = dx.^2;
     
%     2) smooth with large seperable gaussian filter (spatial integration)
      momentIm = conv2(gg,gg,momentIm,'same');

%     3) downsample to specified resolution (imresizeNN function is found in "helperFunctions"):     
      m200 =  imresizeNN(momentIm ,flowRes);
      
%    The remaining moments are calculated in EXACTLY the same way as above, condensed to one liners:
%TODO: fill in the missing moments(should not be zero):
    m002 = zeros(flowRes,'single');
    m110 = zeros(flowRes,'single');
    m101 = zeros(flowRes,'single');
    m011 = zeros(flowRes,'single');
 
 % Thresholds:
EPSILONLK = 0.3;  

for r=1:size(m011,1)
for c=1:size(m011,2)
    %%%TODO: build the 2D structure tensor, call it S2D!
    %%% (here you can assume that m20 = m200, m02 = m020)
    %%% you have access to the elements as m200(r,y), m020(r,y) and m110(r,y)
    %%% (it should NOT be the  matrix, below...
    S2D  = [m200(r,c), 0;...
               0, 1];       %zero and one should be replaced with  moments that you fill in
    if(rcond(S2D)>EPSILONLK) %"L1"

        %%%%%TODO form the vector 'DTd')
        %%%%% (it should NOT be the zero vector)
            b = [0;...
                 0];
        %%%% TODO finally, calculate the velocity vector by the relation 
        %%%% between vector b, and matrix S2D (2D structure tensor)
        %%%% (it should NOT be the zero vector)
         v = -S2D\b;
%              v = -pinv(S2D,1.5)*b; %this also works, but never do this
%             v = [0;...
%                  0];
        U(r,c) = v(1);
        V(r,c) = v(2);
    end
    end
end
