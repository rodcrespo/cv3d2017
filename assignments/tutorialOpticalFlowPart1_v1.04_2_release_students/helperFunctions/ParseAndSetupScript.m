% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [in,vid]= ParseAndSetupScript(in)
% arguments are:
%movieType, method, bFineScale,tIntegration,vidRes,
%spdFactor, lagTime, bRecordFlow. These are passed as fields in a single
%struct input
% if nargin ~= 1 && ~isstruct(varargin{1})
%     error('invalid input to VidProcessing. Only 1 (or zero) arguments accepted: a struct with relevant fields. See example in RunMe.m')
% elseif nargin == 0
%     in = struct;
% end

%movietype indicates source of video
if ~isfield(in,'movieType'), in.movieType  = 'synthetic';  end

%method indicates what kind of numerical analysis is done and displayed
if ~isfield(in,'method'), in.method = 'nothing'; end
in.method = lower(in.method); %lower characters

if strcmpi(in.method,'synthetic') || strcmpi(in.method,'syntheticFull')
    if ~strcmpi(in.movieType,'synthetic')
        error('method "synthetic" only valid for when movietype is "synthetic"');
    end
end
% Scale of operations, fine or coarse
if ~isfield(in,'bFineScale'), in.bFineScale = 1; end

%tIntegration indicates how much temporal information is integrated
if ~isfield(in,'tIntegration'), in.tIntegration = 0; end

if ~isfield(in,'camID'), in.camID = 1; end

%spdFactor (for synthetic only), initial state of synthetic motion.
% a vector, spdFactor(1) speed along 8-shape, spdFactor(2) rotational
if ~isfield(in,'syntSettings'),            in.syntSettings= []; end
if ~isfield(in.syntSettings,'spdFactor'),  in.syntSettings.spdFactor = [0, 0.5]; end
if ~isfield(in.syntSettings,'spd'),        in.syntSettings.spd=1/150; end
if ~isfield(in.syntSettings,'cen1'),       in.syntSettings.cen1=0.4; end
if ~isfield(in.syntSettings,'cW'),         in.syntSettings.cW=0.3; end
if ~isfield(in.syntSettings,'cFuz'),       in.syntSettings.cFuz=1.5; end
if ~isfield(in.syntSettings,'cdet'),       in.syntSettings.cdet=0.7; end
if ~isfield(in.syntSettings,'backWeight'), in.syntSettings.backWeight=0; end
if ~isfield(in.syntSettings,'edgeTilt'),   in.syntSettings.edgeTilt=0; end
if ~isfield(in.syntSettings,'edgeTiltSpd'),in.syntSettings.edgeTiltSpd=0; end

if ~isfield(in.syntSettings,'flickerWeight'), in.syntSettings.flickerWeight=0; end
if ~isfield(in.syntSettings,'flickerFreq'), in.syntSettings.flickerFreq=0.3; end
if ~isfield(in.syntSettings,'noiseWeight'), in.syntSettings.noiseWeight=0; end

%initial artificial lag time. make the renderings slower
if ~isfield(in,'lagTime'),in.lagTime = 0;end
in.lagTime = abs(in.lagTime(1)); %should be single positive

%boolean to indicate saving the generated flow field
if ~isfield(in,'bRecordFlow'),in.bRecordFlow = 0;end
%%% bRecordFlow is only valid when flow is present(some 'methods' do not
%%% produce flow)
if in.bRecordFlow && (sum(strcmpi(in.method,{'edge','gradient','nothing'})))
    warning(['bRecordFlow is set but this is not supported for method: "' in.method '". Recording is disabled']);
    in.bRecordFlow = 0;
end

    

%folder to save to. If set to '', automatic folder created if saving:
if (~isfield(in,'pathToSave')) || (in.bRecordFlow == 0) 
    in.pathToSave = '';
end

% We assume the magnitude of the flow never exceeds "in.rm"
% "rm" is only for storing the flow. It makes sure we can represent
% the flow using uint8 preciscion. This only has effect for when:
% in.bRecordFlow =1 AND in.method is a "full method" (such as HSFull)
if ~isfield(in,'rm'),in.rm = 5;end
in.rm = single(in.rm); %just want it in single precision

%scale vectors for plotting:
if ~isfield(in,'sc'),in.sc = 8; end

% 'targetFramerate', for displaying only
if ~isfield(in,'targetFramerate'),
%     if strcmpi(in.movieType,'camera')
%         in.targetFramerate = inf;%we just want to capture frames as fast as possible from cameras
%     else
        in.targetFramerate = 25; 
%     end
end

if length(in.syntSettings.spdFactor) == 1
    in.syntSettings.spdFactor = [in.syntSettings.spdFactor, 0]; %if speed of rotation was not given, set zero
end
if (in.tIntegration >=1) || (in.tIntegration < 0)
    error('tIntegration must be in the interval [0,1)');
end

%%%%%%%% NOTE: vidRes and flowRes will be additionally changed at end of
%%%%%%%% this function (at %setup video%)
%vidRes (for synthetic and camera movietypes only) size of the video, can
%be a vector to indicate rectangular spatial input
if ~isfield(in,'vidRes'), in.vidRes = 128; end
if length(in.vidRes) == 1
    in.vidRes = [in.vidRes in.vidRes]; 
end

% flowRes is the resolution of the optical flow. This affects the non-full
% versions (such as method='HS' but not method = 'HSFull')
if ~isfield(in,'flowRes'), in.flowRes = 25; end
if length(in.flowRes) == 1  
    in.flowRes = [in.flowRes in.flowRes];
end

if ~isfield(in,'endingTime'), in.endingTime = Inf; end
if ~isfield(in,'startingTime'), in.startingTime = 1; end
if in.startingTime < 1,in.startingTime = 1; end

%% setup globals
global g;
g.kindOfMovie  = in.movieType; 
if ~strcmpi(g.kindOfMovie,'synthetic') && ~strcmpi(g.kindOfMovie,'camera')
	g.kindOfMovie  = 'file';
end
g.arrowKey = [0,0];
g.spdFactor = in.syntSettings.spdFactor; %will be controlled by keyboard, so put as global
g.lagTime = in.lagTime;
g.bPause = 0;
g.method = in.method;
g.gamma = 1;
g.edgeUpper = 255;

%% Setup video:
[vid,in.vidRes(1),in.vidRes(2)] =  myVidSetup(g.kindOfMovie,in.movieType,in.vidRes(1),in.vidRes(2),in.camID,in.startingTime);

if(in.flowRes(1)<1) %if less than 1, relative to video size
    in.flowRes = round(fliplr(in.vidRes).*in.flowRes); 
end
