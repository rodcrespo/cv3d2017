% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
clear in;
% This script calls the function 'vidProcessing'. vidProcessing is our main
% entry point for all video processing. Once its called, a
% figure will open and display the video together with whatever else
% information we desire
% Once you have finished viewing the results of the video processing,
% simply close the window to return back from the function. 

% NOTE: for an extensive list of all possible inputs and how they are used, 
% see the file :
%  exampleUsage.m

% [Height Width]:
%in.vidRes = [64 64];
% video resolution, for camera and synthetic input

%%%%% argument 'movieType' %%%%%%%%
% This indicates the source of the video to process. You may choose from a
% synthetic video sequence(created on the fly), or load a video through a
% video file (such as  subplot(1,2,1);

% NOTE: variable framerate videos not supported
                               
% in.movieType = 'camera';    %assumes a camera available in the system.
% in.camID        = 1;        %(default 1) if several connected cameras, select ID
% NOTE: some systems have virtual cameras installed. Try to choose different
% values for camID, and see if you get better performance. 
% % in.movieType = 'synthetic'; %generate synthetic video
% in.syntSettings.backWeight = 0.5;   %background edge pattern

%%% argument 'method'      %%%
%%%  optical flow method.  %%%
% in.method = 'LK';             %% traditional, explicit Lucas and Kanade
% in.method = 'flow1';          %% Tikhonov-regularized and vectorized method

%%% full resolution streamlined optical flow functions, color coded visualization
% in.method = 'flow1Full';      %% flow2 in dedicated m-file, with high resolution output

%%% There are 2 other options for 'method' that gives no flow:
 in.method = 'gradient';  %Displays the gradient values
% in.method = 'edge';      %Displays the 2D edge detection
% in.method = 'nothing';       

%%%%% argument 'bFineScale' %%%%%%%%
%%% determines the scale of differentiation, fine scale otherwise a coarse 
%%% scale. coarse scale gives better stability to large motions, but at the
%%% cost of loosing fine scale information in the video. It determines the
%%% width and height of dx, dy, dt
% in.bFineScale = 0;

%%%%%%%% argument 'tIntegration'  %%%%%%%%%%%%%%
%%% the amount of temporal integration. This is done by 1st order
%%% recursive filtering. tIntegration should be in the range [0,1). 
%%% if tIntegration = 0, then no integration in time occurs. 
in.tIntegration = 0.25;

disp('Shut down figure to stop.');
[dx, dy, dt,U1,V1,pathToSave] = vidProcessing(in);
