%% Intrinsic parameters:
%% Image center: u0 = 378.063263, v0 = 285.467163
   cr0r= [378.063263,  285.467163];

%% Scale factor: 
%% au = 1848.951294, av = 1795.112915
  fsxyr = [1848.951294,  1795.112915];
%% Image size: dimx = 768, dimy = 576
szr=[ 768, 576];
%% Focale: 1.0
%% Extrinsic parameters:
%% Rotation:
Rr=[[0.691297, -0.151556, 0.706498],
 [-0.009506, 0.975764, 0.218620],
 [-0.722508, -0.157848, 0.673102]];
%Translation:
tr=[-991.766602, -212.195465, -1191.052124]';

Mir=diag([-fsxyr 1]); Mir(1:2,3)=cr0r';
Mer=[Rr tr];
