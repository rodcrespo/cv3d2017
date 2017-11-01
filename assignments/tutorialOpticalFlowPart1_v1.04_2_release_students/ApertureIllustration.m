% Author: Stefan Karlsson, Josef Bigun, 2014

function ApertureIllustration(type)
%interactive visualization of the aperture problem in optical flow
%estimation. This script animates a pattern of horizontal smooth bars within 
% the support of a large disk. The pattern is in a circular motion pattern.
% a smaller apperture is present in the middle of the image. The
% only view the user gets is through the aperture, except for a periodic
% reveal of the scene
% input:
% type = 1, circular aperture, single motion
% type = 2, rectangular aperture, barberpole illusion
% type = 3, circular aperture, multiple motions
% type = 4, circular aperture, multiple motions in seperate color channels
%%%%%%%%%%%%
% The script supports the following interface:
% MOUSE: 
% click to enable mouse move of aperture, mouse scroll to change aperture
% radius
% KEYBOARD:
% Arrow Keys: move the aperture around
% Q/A : Radius of the aperture
% W/S : the fuzziness of the boundary(higher values makes it Gaussian like)
%%%%%%%
if nargin < 1
    type = 1;end
%widht and height of the image
w = 200;
h = 200;
innerRadius = 0.3; %initial radius of aperture
%initial position of aperture, x and y:
innerPx = 0;
innerPy = 0;
minFuz  = 0.01;
%initial fuzziness of aperture:
if type == 2
    innerFuz = minFuz;
else
    innerFuz = 1/10; 
end
fuz = 1/20;      %fuzziness of the moving pattern
%limits in the image are in [-1,+1] for both x and y:
xlims = linspace(-1,1,w);
ylims = linspace(-1,1,h);
[x,y] = meshgrid(xlims,ylims);
p  = linspace(0,2*pi,200);   %used for painting the red boundary of aperture

%keep track of mouse clicked:
bHasClicked = 0;
%create figure, set up callback functions:
hFig = figure('WindowKeyPressFcn',@localKeyFunc,...
              'WindowButtonDownFcn', @localMousepress); 
hold on
%create the graphics objects, store handles
if type < 4
    hIm = imagesc(xlims, ylims,x,[0,1]);colormap gray(256);
else
    hIm = imagesc(xlims, ylims,zeros([size(x),3]));
end
if type ~= 2
    hCirc = plot(innerRadius*sin(p)-innerPx,innerRadius*cos(p)-innerPy,'color',[0.6 0.2 0.2],'LineSmoothing','on');
end

axis off;axis image;

t    = 0;  %simulation time
tInc = 0.1; %time increment, simulation
targetFramerate = 15; %target framerate, in real-world time

%as long as the user hasnt shut down the figure, loop:
while ishandle(hFig)
    tic;  %time every iteration to control framerate
    %screener will hold the "characterisitc function" of the aperture:
if type ~= 2
	screener = sig((innerRadius-0.01)-sqrt((x-innerPx).^2+(y-innerPy).^2),innerFuz);
else
	screener = sig(x-innerPx+innerRadius,innerFuz).*sig(-(x-innerPx-innerRadius),innerFuz).*...
               sig(y-innerPy+innerRadius*2  ,innerFuz).*sig(-(y-innerPy-innerRadius*2  ),innerFuz);
end
    t = t+ tInc;
    %the update equation: sigmoidal function for disk boundaries,
    %trigonometric tricks for slowly varying bars:
    cX = 0.15*cos(t);     %centre of the moving pattern is at (cX,xY)
    cY = 0.15*sin(t);
    if type < 4
        im = sig(0.84^2-(x-cX).^2-(y-cY).^2,fuz).*(cos(40*(sin(t/100)*(x-cX)+cos(t/100)*(y-cY)))+1)/2;
    else
        im(:,:,2) = sig(0.84^2-(x-cX).^2-(y-cY).^2,fuz).*(cos(40*(sin(t/100)*(x-cX)+cos(t/100)*(y-cY)))+1)/2;
    end
    if type > 2
        t2 = -t-100*pi/2;
        cX = 0.15*cos(t2);     %centre of the moving pattern is at (cX,xY)
        cY = 0.15*sin(t2);
        if type ==3
%             newIm = (newIm + backWeight*(250-newIm).*(iix>0)); %apply the background, fixed with hard boundary
        	im = im + (1-im).*...
             sig(0.84^2-(x-cX).^2-(y-cY).^2,fuz).*(cos(40*(sin(t2/100)*(x-cX)+cos(t2/100)*(y-cY)))+1)/2;
        else %type ==4
            im(:,:,3) = (1-im(:,:,2)).*...
             sig(0.84^2-(x-cX).^2-(y-cY).^2,fuz).*(cos(40*(sin(t2/100)*(x-cX)+cos(t2/100)*(y-cY)))+1)/2;
        end
    end

    %alpha is used for the periodical unveiling of the full motion pattern
    alpha =  max(min(((-0.8- 1.55*sin(t*0.35))/2), 0.35),0);
    if type < 4
        if type == 2
            im = alpha*im + (1-alpha)*(screener.*im + (1 - screener)/2);
        else
            im = alpha*im + (1-alpha)*screener.*im;
        end
    else
        im = alpha*im + (1-alpha)*bsxfun(@times,screener,im);
    end
    %update graphics:
    set(hIm,'CData',im);
if type ~= 2    
    set(hCirc,'XData',innerRadius*sin(p)+innerPx,'YData',innerRadius*cos(p)+innerPy);
end
    %restrict frame rate:
    timeToSpare = (1/targetFramerate) - toc; 
    pause(  max(timeToSpare  , 1/100)  ); 
end

%%%%%% nested helper functions
% sigmoidal function for fuzzy rendering:
function out=sig(x,fuzziness)
if (fuzziness == 0)
    out = x > 0;
else
    out= (1+erf(x./fuzziness))/2;
end
end
%%% keyboard event handler, callback function
function localKeyFunc(~,evnt)
switch evnt.Key,
  case 'q', innerRadius = innerRadius +0.01;
  case 'a', innerRadius = max(innerRadius -0.01,0.06);
  case 'w', innerFuz = innerFuz +0.005;
  case 's', innerFuz = max(innerFuz -0.005,minFuz);
  case 'downarrow' , innerPy = max(-1,innerPy -0.02);
  case 'uparrow'   , innerPy = min(1,innerPy +0.02);
  case 'rightarrow', innerPx = min(1,innerPx +0.02);
  case 'leftarrow' , innerPx = max(-1,innerPx -0.02);
end
end

%%%mouse press event handler
function localMousepress(~,~)
mousePos=get(gca,'CurrentPoint');
if max(max(abs(mousePos(1,:))))<1.1
    innerPy = mousePos(1,2);
    innerPx = mousePos(1,1);
    if ~bHasClicked
        set (hFig, 'WindowButtonMotionFcn', @mouseMove,'WindowScrollWheelFcn',@mouseScroll);
        bHasClicked = 1;
    else
        set (hFig, 'WindowButtonMotionFcn', '','WindowScrollWheelFcn','');
        bHasClicked = 0;    
    end
end
end

%%%mouse scroll event handler, activated on click
function mouseScroll(~,callbackdata)
   innerRadius = max(innerRadius +0.02*callbackdata.VerticalScrollCount,0.06);
end 

%%%mouse move event handler, activated on click
function mouseMove (~, ~)
mousePos=get(gca,'CurrentPoint');
if max(max(abs(mousePos(1,:))))<1.1
    innerPy = mousePos(1,2);
    innerPx = mousePos(1,1);
end
end
end