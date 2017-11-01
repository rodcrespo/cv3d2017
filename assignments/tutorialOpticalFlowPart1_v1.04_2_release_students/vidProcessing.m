% Authors: Stefan M. Karlsson, Josef Bigun 2014

function [dx, dy, dt, U, V, pathToSave] = vidProcessing(in)
% Opens a figure and display the video together with whatever else
% information/visualization we request.
% Once finished viewing the results of the video processing,
% close the window to return back from the function. 

% vidProcessing();        - displays interactive synthesized video
% vidProcessing(in);      - contains various setting in the structure "in"

% "in" may contain the following members:
%%%%% argument 'movieType' %%%%%%%%
% The source of the video to process.
%EXAMPLES:
% in.movieType = 'lipVid.avi'; %assumes a file 'LipVid.avi' in current folder.
                               %(variable framerate not supported for video)
% in.movieType = 'camera';     %assumes a camera available in the system.
% in.movieType = 'synthetic';  %generate interactive synthetic video
                               %see "syntSettings" below

%%% Argument "vidRes"
% in.vidRes    = [128 128];    %video resolution, for camera and synthetic

%%% Argument "targetFramerate"
% in.targetFramerate = 25;  %target Framerate of the program. Will take up
                            % computing power until this is reached

%%% Argument "lagTime"
%initial artificial lag time. make the renderings slower with higher values
% is set dynamically with keyboard interface during execution.
%in.lagTime = 0; 
                            
%%% Argument "camID"
% in.camID     = 1;        %(default 1) for "camera" select which camera
%NOTE: some systems have virtual cameras installed. Try to choose different
%values for camID, and see if you get better performance. 

%%% Argument "syntSettings"
%settings for the synthetic sequence
%%% Examples (default values):
% in.syntSettings.spdFactor = [0, 0.5]; %initial motion %spdFactor(1): along 8-shape, 
                                                        %spdFactor(2): rotational
% in.syntSettings.spd        = 1/150;  %constant factor of speed of motion
% in.syntSettings.cen1       = 0.4;    %centre offsets of disks generated
% in.syntSettings.cW         = 0.3;    %radius of disks
% in.syntSettings.cFuz       = 1.5;    %fuzziness of the boundary of disks
% in.syntSettings.cdet       = 0.7;    %detail level of the interior pattern

% in.syntSettings.backWeight = 0;      %Strength of background edge pattern
% in.syntSettings.edgeTilt   = 0;      %initial tilt of background edge
% in.syntSettings.edgeTiltSpd= 0;      %speed of rotation of background edge 

% in.syntSettings.flickerWeight= 0;    %amount of flicker of the disks (in range [0,1])
% in.syntSettings.flickerFreq  = 0.3;  %frequency of flicker (in range (0,Inf])
% in.syntSettings.noiseWeight  = 0;    %signal-to-noise weight (in range [0,1])

%%%%% argument 'method'      %%%%%%%%
%%%%%  method of analysis/visualization
% in.method = 'nothing';        %% (Default) output zero fields
% in.method = 'LK';             %% traditional, explicit Lucas and Kanade
% in.method = 'flow1';          %% Tikhonov-regularized and vectorized method
% in.method = 'synthetic';      %% generate (Lo Res)groundtruth motion for synthetic video
%%%%%% full resolution streamlined functions, color coding
% in.method = 'flow1Full';      %% flow1 in dedicated m-file, with high resolution output
% in.method = 'HSFull';         %% Horn and schunk, dedicated m-file, high resolution
% in.method = 'syntheticFull';  %% generate (Hi Res)groundtruth motion for synthetic video
%%% non-optical flow options for 'method':
% in.method = 'gradient';       %% Displays the gradient component images
% in.method = 'edge';           %% Displays the 2D edge detection

%%%%%%%%% argument "flowRes"
%%%indicates resolution of the flow field, when method is one of: 'LK', 'flow1' or 'HS'
% can be either scalar(percentage of video resolution), or 2D vector (absolute resolution). Examples:
% in.flowRes  = 0.15; 
% in.flowRes  = [25 40]; 

%%% Argument "sc"
%scale optical flow with this constant, for visualization only:
% in.sc = 8;  %(default)

%%%%% argument 'bFineScale' %%%%%%%%
%%% determines the scale of differentiation, fine scale otherwise a coarse 
%%% scale. coarse scale gives better stability to large motions, but at the
%%% cost of loosing fine scale information in the video. It determines the
%%% width and height of dx, dy, dt
% in.bFineScale = 1;

%%%%%%%% argument 'tIntegration'  %%%%%%%%%%%%%%
%%% the amount of temporal integration. This is done by 1st order
%%% recursive filtering. tIntegration should be in the range [0,1). 
%%% if tIntegration = 0, then no integration in time occurs. 
% in.tIntegration = 0; %(default)
                                   
%%%%% arguments "endingTime" and "startingTime" %%%%
%%% time to start and stop the video processing (frame number)
% examples (defaults)
% in.startingTime = 1;
% in.endingTime = Inf;

%%%%%%%% argument 'bRecordFlow'  %%%%%%%%%%%%%%
%%% set bRecordFlow=1 to record the video and the optical flow. 
%%% argument "pathToSave" is optional, if not provided, will generate a
%%% folder "savedOutput" automatically
% in.bRecordFlow = 0;              %(default)
% in.pathToSave = 'MySavedFolder'; %optional argument, a folder "SavedOutputX"
                                   %will otherwise be generated
%%% NOTE, see below on output argument "pathToSave"

%%upperbound for optical flow for saving purposes. only applies to the 
%%hi-res versions (method strings ending with "full"). The flow will be
%%saved in fixed point, 8 bit representation. Any component that exceeds
%%in.rm will be cropped.
% in.rm = 5;   

%%% OUTPUT ARGUMENTS
%%% Output dx, dy and dt are all WxH matrices containing the x, y, and t 
% partial derivatives over time. 
% W and H are the height and width of the video
%
%%%% outputs U, V, are optical flow estimates of the video.

%pathToSave 
% full path to where saved data is stored, when bRecordFlow = 1

% ensure access to functions and scripts in the folder "helperFunctions"
addpath('helperFunctions');
global g; %contains shared information, ugly solution, but fastest
if nargin > 0
    if nargin > 1 || ~isstruct(in)
    error('invalid input to VidProcessing. Only 1 (or zero) arguments accepted: a struct with relevant fields. See example in RunMe.m');
    end
elseif nargin == 0
    in = struct;
end

[in, vid] = ParseAndSetupScript(in); %script for parsing input and setup environment
% index variable for time:
t=in.startingTime;

%from this point on, we handle the video by the object 'vid'. This is how
%we get the first frame:
curIm = generateFrame(vid, t,g.kindOfMovie,g.spdFactor,g.arrowKey,in.syntSettings,in.flowRes);

% gradient calculations of the subvolume will be handled by "Grad3Dm". 
% It has a local copy internally of the previous frame, which we initialize now:
[dx, dy, dt] = grad3D(curIm,in.bFineScale,1);

U = 0; V =0;

% different methods, different functions, get the first output:
switch in.method
    case 'nothing'
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm);
    case 'edge'
        edgeIm = DoEdgeStrength(200*ones(size(dx)),200*ones(size(dx)),0,zeros(size(dx)));
        checkEdgeOutput(edgeIm); %sanity check of DoEdgeStrength function
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,edgeIm);
        edgeIm = zeros(size(dx));
    case 'gradient'
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,dx,dy,dt);
    case 'flow1full'
        [U, V] = DoFlow1Full(dx,dy,dt,in.tIntegration);
        checkFlowOutput(U, V);%sanity check on flow
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,U,V);
    case 'syntheticfull'
        U = zeros(size(dx));           V = zeros(size(dx));
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,U,V);
    case 'synthetic'
        U = ones(in.flowRes,'single'); V = ones(in.flowRes,'single');
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,U,V);        
    case 'flow1'
        [U, V] = DoFlow1(dx,dy,dt,in.tIntegration,1,in.flowRes);
        checkFlowOutput(U, V);%sanity check on flow
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,U,V);        
    case 'hsfull'
        [U, V] = DoFlowHS(dx,dy,dt);
        checkFlowOutput(U, V);%sanity check on flow
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,U,V);
    case 'lk'
        [U, V] = DoFlowLK(dx, dy, dt,in.flowRes);
        checkFlowOutput(U, V); %sanity check on flow
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,U,V);
    otherwise
        error(['unsuported method ' in.method]);
        [myHandles,pathToSave] = setupGraphicsScript(in,curIm,U,V);

end
%%%%%% MAIN LOOP, runs until user shuts down the figure  %%%%%
while ishandle(myHandles.figH) && t <= in.endingTime
    tic; %time each loop iteration;
    t=t+1;
    if strcmpi(in.method,'syntheticfull') ||strcmpi(in.method,'synthetic')
        [curIm,U,V] = generateFrame(vid, t,g.kindOfMovie,g.spdFactor,g.arrowKey);
        updateGraphicsScript(in,myHandles,curIm,U,V);
    else
        curIm = generateFrame(vid, t,g.kindOfMovie,g.spdFactor,g.arrowKey);
        [dx, dy, dt] = grad3D(curIm,in.bFineScale);    
    end
    switch in.method
        case 'edge'
            edgeIm = DoEdgeStrength(dx,dy,in.tIntegration,edgeIm);
            updateGraphicsScript(in,myHandles,curIm,edgeIm);
        case 'gradient'%do nothing, gradient already given
            updateGraphicsScript(in,myHandles,curIm,dx,dy,dt);
        case 'flow1full'
            [U, V] = DoFlow1Full(dx,dy,dt,in.tIntegration);
            updateGraphicsScript(in,myHandles,curIm,U,V);
        case 'hsfull'
            [U, V] = DoFlowHS(dx, dy, dt,U, V);
            updateGraphicsScript(in,myHandles,curIm,U,V);
        case 'flow1'
            [U, V] = DoFlow1(dx,dy,dt,in.tIntegration);
            updateGraphicsScript(in,myHandles,curIm,U,V);            
        case 'lk'
            [U, V] = DoFlowLK(dx, dy, dt,in.flowRes);
            updateGraphicsScript(in,myHandles,curIm,U,V); 
        case 'nothing'
            updateGraphicsScript(in,myHandles,curIm); 
    end
    %if paused, stay here:
    while (g.bPause && ishandle(myHandles.figH)), pause(0.3);end
    % Pause to achieve target framerate, with some added lag time:
    timeToSpare = (1/in.targetFramerate) - toc + g.lagTime; 
    pause(  max(timeToSpare  , 1/50)  ); 
end  %%%%%%% END MAIN LOOP  %%%%%%%%%
cleanUpScript(in,vid);
