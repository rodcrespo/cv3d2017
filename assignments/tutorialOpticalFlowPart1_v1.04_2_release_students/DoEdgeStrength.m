% Authors: Stefan Karlsson and Josef Bigun, copyright 2013

function edgeIm = DoEdgeStrength(dx, dy,tInt,edgeIm)

% version 1, gradient magnitude:
% edgeIm = sqrt(dx.^2+dy.^2);

% version 2, gamma corrected magnitude:
% gam = 0.5;                     %gam = 1 is the same as version 1 above
% edgeIm = (dx.^2+dy.^2).^(gam/2);

% version 3, recursive temporal integration:
% gam = 0.5;
% edgeIm = tInt*edgeIm + (1-tInt)*(dx.^2+dy.^2).^(gam/2);

% version 4, same as above, interactive gamma:
global g;
gam = g.gamma;
edgeIm = tInt*edgeIm + (1-tInt)*(dx.^2+dy.^2).^(gam/2);
