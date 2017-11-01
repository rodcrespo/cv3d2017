% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [u, v] = DoFlowHS(dx, dy, dt, u, v)

%regularization parameter
alpha= single(10);

%maximum iterations:
MaxIts=20;

%make the kernel, normalize it to EnR. A lower EnR pushes down the
%magnitude of no texture regions faster. As the maximum nof iterations
%go up, EnR should be set closer to 1.
% EnR = 0.98;
EnR = min(1,  0.9 + 0.1*MaxIts/100);
kern=[1       sqrt(2) 1      ; ...
      sqrt(2) 0       sqrt(2); ...
      1       sqrt(2) 1]     ;
kern = single(EnR*kern/sum(kern(:)));  

%first time we call the function, we have no flow to initialize with
if nargin<4
     u = zeros(size(dx));
     v = zeros(size(dx));
end

% explicit algorithm from Horn and Schunks original paper:
for i=1:MaxIts
    uAvg=conv2(u,kern,'same');      
    vAvg=conv2(v,kern,'same');
    u = uAvg - dx.*(dx.*uAvg + dy.*vAvg  + dt)./(alpha.^2 + dx.^2 +dy.^2);
    v = vAvg - dy.*(dx.*uAvg + dy.*vAvg  + dt)./(alpha.^2 + dx.^2 +dy.^2);
end
