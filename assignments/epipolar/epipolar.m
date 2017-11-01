% Implementation of the 8 point algorithm. The
% epipolar constraint is verified by drawing the
% epipolar lines associated to two points on the
% images (for further details Big�n 13.6)
%
% (C) F. Smeraldi, Oct 11th 2000
% Modified by M. Persson, Feb 8th 2006
% Modified by J. Bigun Dec. 2013
%Modified by J. Bigun, Nov. 2013


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These comments mark parts to be completed
%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Image size
XSIZE=768;
YSIZE=576;

%JB
normalize=0; %First no-normalization...
figure(1+normalize*2); 
%Show the left image 
% ...
imshow('images/left.bmp');
hold on;   %OPTIONAL...to plot the points we click and then keep them

figure(2+normalize*2);
%Show the right image in figure 2
% ...
imshow('images/right.bmp');
hold on;   %OPTIONAL...to plot the points we click and then keep them




%%%%%%%%%%%%%%%%%%%%
% Write the number of clicked points here (see below)
%%%%%%%%%%%%%%%%%%%%
NPOINTS=15;%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
% Find the coordinates of at least NPOINTS corresponding points in the
% (left and right) image frame (pixel coordinates):
%%%%%%%%%%%%%%%%%%%%%%

% Left image; You can use ginput to get the points...and then comment the
% code after having secured pl, pr by displaying and cutting and pasting
% into pl, pr, so that you dont need to click more than 15 NPOINTS (otherwise
% you end-up clicking everytime you run this code;
% pl=[]; pr=[];
% for k=1:NPOINTS
% % Left image
% figure(1); %put focus on the left image for clicking...
% onepl= ginput(1);
%     pl= [pl
%         onepl 1 
%      ];
% text(pl(k,1),pl(k,2),['* ' num2str(k)],'FontSize',10,'color','r'); %OPTIONAL visualize what you clicked
%   
%  
% % Right image
% figure(2); %put focus on the right image  for clicking...
% onepr= ginput(1);
%     pr= [pr
%         onepr 1 %%%
%      ];
% text(pr(k,1),pr(k,2),['* ' num2str(k)],'FontSize',10,'color','g'); %OPTIONAL visualize what you clicked
%      
% end


pl =[
%display pl in command window and copy and paste it here.
  245.0000  379.0000    1.0000
  443.0000  151.0000    1.0000
  602.0000   25.0000    1.0000
   43.0000   29.0000    1.0000
   62.0000  502.0000    1.0000
  608.0000  348.0000    1.0000
  255.0000   50.0000    1.0000
  207.0000  247.0000    1.0000
  444.0000  339.0000    1.0000
  543.0000  216.0000    1.0000
  263.0000  446.0000    1.0000
  508.0000  424.0000    1.0000
   89.0000  179.0000    1.0000
  235.0000  146.0000    1.0000
  177.0000  326.0000    1.0000
];



pr =[
  %display pr in command window and copy and paste it here.
  215.0000  425.0000    1.0000
  464.0000  182.0000    1.0000
  754.0000   43.0000    1.0000
  112.0000   40.0000    1.0000
  134.0000  532.0000    1.0000
  658.0000  418.0000    1.0000
  411.0000   65.0000    1.0000
  227.0000  277.0000    1.0000
  474.0000  396.0000    1.0000
  579.0000  265.0000    1.0000
  234.0000  499.0000    1.0000
  526.0000  499.0000    1.0000
  170.0000  197.0000    1.0000
  378.0000  168.0000    1.0000
  220.0000  358.0000    1.0000
  ];


figure(1+normalize*2); %put focus on the right image  for displaying clicked points...
for k=1:NPOINTS
text(pl(k,1),pl(k,2),['* ' num2str(k)],'FontSize',10,'color','r'); %OPTIONAL visualize what you clicked
end

figure(2+normalize*2); %put focus on the right image  for displaying clicked points.... 
for k=1:NPOINTS
text(pr(k,1),pr(k,2),['* ' num2str(k)],'FontSize',10,'color','g'); %OPTIONAL visualize what you clicked
end



prhat=pr;
plhat=pl;


% %FIRST DO THE EXERCISE WITHOUT NORMALIZATION, I.E. ENTER BRANCHES 
% %                      "Normaliztion consequence   x" 
% %

if normalize==1
%Normalization consequence 1
% Construct matrices hl and hr to normalize these coordinates
% so that the average of each component is 0 
%(forcing the centroid to be the origin) and its variance
% is normalized to 1 (making the lengths be represented more accurately)

plr=[pl; pr];
plr_msd=plr(:,1)+i*plr(:,2);
d= mean(abs(plr_msd-mean(plr_msd)));
%%%%%%%%%%%%%%%%%%%%%
% First construct hl...
%%%%%%%%%%%%%%%%%%%%%
hl=[
    1/d   0  -mean(pl(:,1))/d
    0    1/d  -mean(pl(:,2))/d 
    0     0    1
    ];

%%%%%%%%%%%%%%%%%%%%%
% ...and then hr:
%%%%%%%%%%%%%%%%%%%%%
hr=[
    1/d   0  -mean(pr(:,1))/d
    0    1/d  -mean(pr(:,2))/d 
    0     0    1
    ];

 plhat=(hl*pl')'; 
 prhat=(hr*pr')'; %produce normalized coordinates...
end
 %END Normalization Consequence 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now compute Ftilde from Q.
% Row i of the matrix Q of the coefficients is obtained
% from the components in prhat(i,:) and plhat(i,:).
% So first create matrix Q (equations 13.125 to 13.129 of the book should give you an
% idea) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%...

% for i=1:NPOINTS
%     Q(i,:) = [pr(i,1)*pl(i,:) pr(i,2)*pl(i,:) pr(i,3)*pl(i,:)];
% end

ons=ones(NPOINTS,1);
q1=[prhat(:,1)  prhat(:,1)  prhat(:,1)  prhat(:,2)  prhat(:,2)  prhat(:,2)  ons         ons         ons];
q2=[plhat(:,1)  plhat(:,2)  ons         plhat(:,1)  plhat(:,2)  ons         plhat(:,1)  plhat(:,2)  ons];
Q=q1.*q2;

%%%%%%%%%%%%%%%%%%%%%
% And then compute the total least square solution of Q*Ftilde=0, which is given by the
%eigenvector corresponding to the smallest eigenvalue
% of Q'*Q or alternatively you can use the SVD decomposition (Q=U*S*V')for this.
%%%%%%%%%%%%%%%%%%%%%
%...
[U, S, V] = svd(Q);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reshape vector  Ftilde into  matrix F. 
%%%%%%%%%%%%%%%%%%%%%%%%%%
%...
Ftilde = V(:,9);
F = reshape(Ftilde, 3, 3)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ensure that F is singular: first compute its SVD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%...
[UF, SF, VF] = svd(F);

%%%%%%%%%%%%%%%%%%%%%%%
% Then enforce singularity by setting the smallest singular value to
% zero
%%%%%%%%%%%%%%%%%%%%%%%
%...
SF(3,3) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ... and finally recompute F
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%...
F = UF*SF*VF';

%Normalization consequence 2 
%Now we get our real F that takes in unnormalized coordinates from left and
%right to produce a scalar from a quadratic form....
if normalize==1
F=hr'*F*hl;
end
%End Normalization consequence 2

 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % The left epipole lies in the null space of F; the right epipole
% % belongs to the null space of F'. You can obtain them directly
% % from the SVD of F you have just computed
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%...

 disp('Left epipole');
 el= VF(3,:); %%%%%
 disp('Right epipole');
 er= UF(3,:); %%%%%

% 
% % ############ Verification of the epipolar constraint ###############
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Verify the epipolar constraint: choose a point,  in one image
% % (say the right). Draw the corresponding epipolar line on the other
% % image by changing the pixel-value to 255 (or 9) when epipolar line equation is
% %fullfilled.
% % Verify that the line passes through the corresponding point in the other image.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% This is the epipolar line on the left image
		% associated to point pr(%%,:) on the right image.
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for i=1:15

figure(1+normalize*2)
abc=pr(1,:)*F;
abc=abc/abc(2);
x=[1:XSIZE];
y=-(abc(1)*x+abc(3));
plot(x,y,'g')
set(gcf, 'Name', 'left');
%end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% This is the epipolar line on the right image
		% associated to point pl(%%,:) on the left image.
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2+normalize*2)
abc=F*pl(1,:)';
abc=abc/abc(2);
x=[1:XSIZE];
y=-(abc(1)*x+abc(3));
plot(x,y,'r')
set(gcf, 'Name', 'right');


% Write the two images with the epipolar lines to the disk
% figure(1+normalize*2);Im=getframe; imwrite(Im.cdata,'left.jpg')
% figure(2+normalize*2);Im=getframe; imwrite(Im.cdata,'right.jpg')
