% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
clear in;
% This script calls the function 'vidProcessing'. vidProcessing is our main
% entry point for all video processing. Once its called, a
% figure will open and display the video together with whatever else
% information we desire
% Once you have finished viewing the results of the video processing,
% simply close the window to return back from the function. 
% This file is different from "runMe.m" only in that it contains more 
% examples of how to use the function

%%%%% argument 'movieType' %%%%%%%%
% This indicates the source of the video to process. You may choose from a
% synthetic video sequence(created on the fly), or load a video through a
% video file (such as 'LipVid.avi'), or to capture video from a connected
% camera(requires the image acquisition toolbox). 

% in.movieType = 'lipVid.avi'; %assumes a file 'LipVid.avi' in current folder. 
%%% NOTE: variable framerate videos not supported
% in.movieType = 'camera'; %assumes a camera available in the system.
% in.camID        = 1;        %(default 1) if several connected cameras, select ID
% NOTE: some systems have virtual cameras installed. Try to choose different
% values for camID, and see if you get better performance. 
in.movieType = 'synthetic'; %generate synthetic video

%%%%settings for the synthetic sequence
%speed of motion of the patterns generated. This affects the speed of
%everything in the synthetic patterns including reaction time to user interfacing:
in.syntSettings.spd        = 1/120; 
in.syntSettings.spdFactor = [0, -1]; %starting speed, spdFactor(1) along 8, spdFactor(2) rotational
in.syntSettings.cen1       = 0.4;   %centre offsets of circles
in.syntSettings.cW         = 0.3;   %radius of circles
in.syntSettings.cFuz       = 1.5;   %fuzziness of the boundary
in.syntSettings.cdet       = 0.7;   %detail of the interior pattern(frequency of sinusoids)

in.syntSettings.backWeight = 0.3;   %background edge pattern weight
in.syntSettings.edgeTilt   =2*pi/10;%tilt of the edge of the background
in.syntSettings.edgeTiltSpd=2*pi/300;%speed of rotation of the background edge

in.syntSettings.flickerWeight= 0.8;   %amount of flicker of the disks (in range [0,1])
in.syntSettings.flickerFreq  = 0.8;  %frequency of flicker (in range (0,Inf])

in.syntSettings.noiseWeight = 0.3;    %signal to noise weight (in range [0,1])


% in.vidRes   = [100 100];  %video resolution, for camera and synthetic
                            % input
% resolution of the estimated flow (only valid for the lower resolution
% methods, where vectors(quiver) are used for visualization):
% in.flowRes  = 0.15;      %as a factor of the in.vidRes
% in.flowRes  = [25 40];   %as direct values [width height]

%%%%% argument 'method'      %%%%%%%%
%%%%% optical flow methods(low res)  %%%%%%%
% in.method = 'LK';             %% traditional, explicit Lucas and Kanade
% in.method = 'flow1';          %% Tikhonov-regularized and vectorized method
in.method = 'synthetic';      %% generate (Lo Res)groundtruth motion for synthetic video

%%%%%% full resolution streamlined functions, color coding
% in.method = 'flow1Full';      %% flow2 in dedicated m-file, with high resolution output
% in.method = 'HSFull';       %% Horn and schunk
% in.method = 'syntheticFull';  %% generate (Hi Res)groundtruth motion for synthetic video

%%% additional options for 'method', will not give optical flow output
% in.method = 'gradient';  %Displays the gradient values
% in.method = 'edge';      %Displays the 2D edge detection
% in.method = 'nothing';        %% output zero fields

%%%%% argument 'bFineScale' %%%%%%%%
%%% determines the scale of differentiation, fine scale otherwise a coarse 
%%% scale. coarse scale gives better stability to large motions, but at the
%%% cost of loosing fine scale information in the video. It determines the
%%% width and height of dx, dy, dt
in.bFineScale = 1;

%%%%%%%% argument 'tIntegration'  %%%%%%%%%%%%%%
%%% the amount of temporal integration. This is done by 1st order
%%% recursive filtering. tIntegration should be in the range [0,1). 
%%% if tIntegration = 0, then no integration in time occurs. 
 in.tIntegration = 0;

%%%%% endingTime %%%%
%%% time to stop the video processing (frame number)
% in.startingTime = 45;
% in.endingTime = 350;

%%% scale the flow for visualization (default is in.sc = 8)
% in.sc = 1;

%%%%%%%% argument 'bRecordFlow'  %%%%%%%%%%%%%%
%%% set bRecordFlow=1 to record the video and the optical flow. 
%%% argument "pathToSave" is optional, if not provided, will generate a
%%% folder "savedOutput" automatically
in.bRecordFlow = 1;
%optional argument, save folder. If not given, a new folder will be created
%as "savedOutputX", where X is incremented for each new experiment
in.pathToSave = 'MySavedFolder'; 

%make the call:
[dx, dy, dt,U1,V1,pathToSave] = vidProcessing(in);

%%%% if the flow output was saved to file, do play-back of it:
if ~strcmp(pathToSave,'')
  disp(['playing back from folder: "' pathToSave '"']);
  flowPlayBack(pathToSave);
end


%%%%% regarding saving and loading stored data
% In order to extract data you have saved, look into function
% getSavedFlow
% flowPlayBack uses this function internally. You do not want to look into
% the save folder and try to figure out how the data is saved internally by
% the toolbox. That will lose you alot of time. "getSavedFlow" reads one
% frame of recorded video/flow field at a time, and is memory efficient.

% with high res optical flow, there may be some quantization errors. Play
% around with the parameter
% in.rm = 5; 
% rm is the upper bound of how high the output flow may be (for high res
% flow only). If you increase it, you loose quantization preciscion, but
% that is preferrable from having your data being corrupted by truncation
