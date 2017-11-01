% Intrinsic parameters:
%Image center: u0 = 378.236053, v0 = 283.902802
   cr0l = [378.236053  283.902802];
% Scale factor between focus and pixel dimensions: 
% au = 1854.758789, av = 1798.011963
   fsxyl=[ 1854.758789 1798.011963];
% Image size: dimx = 768, dimy = 576
szl= [768 576];
% Focale: 1.0
% Extrinsic parameters:
% Rotation:
   Rl=[[0.442128, -0.186504, 0.877348],
      [-0.015656, 0.976390, 0.215447],
     [-0.896816, -0.108991, 0.428769]];
%Translation:
tl=[-1348.430908, -214.044937, -945.597900]';


Mil=diag([fsxyl 1]); Mil(1:2,3)=cr0l';
Mel=[Rl Rl'*tl];
