% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [im, u, v,macroDatOut] = getSavedFlow(frameNr, session)
% reads one frame of saved optical flow data
% im - the gray scale image of the video where the flow was calculated
% (u, v) - the optical flow, x and y component images
% macroDatOut - structure with macro data containing all the fields of the
% input argument to vidProcessing for when this data was generated.
% Additional fields:
% macroDatOut.path - path to where data is stored
% macroDatOut.fileReadPointer - the current frame that was read
% macroDatOut.bEOF - flags end of file for the stored data

persistent macroDat vidStream fileStream 

if nargin >0
    if ~isnumeric(frameNr) || frameNr < 0.5
        error('only positive values for frameNr');
    end
    frameNr = round(frameNr);
end

if nargin >2 
    error('max 2 input arguments');
end

if nargin < 2 && isempty(vidStream)
    error('no saved session initialized');
end

if nargin == 2 %then we set initialize
    %if session is a number...
    if isnumeric(session) && isscalar(session)
        %... then it indicates one of the savedOutputX folders
        session = ['savedOutput' num2str(session)];
    end
    if ~exist(session,'dir')
        error('directory does not exist');
    end
	if ~exist(fullfile(session,'flow.mat'),'file') || ~exist(fullfile(session,'flow.bin'),'file')
        error('invalid directory! Does not contain the required files flow.mat and flow.bin');
	end
    load(fullfile(session,'flow.mat')); %loads "in"
	macroDat = in;

    if strcmpi(macroDat.method(end-1:end),'ll')
        macroDat.bQuiver = false;
        vidStream = VideoReader(fullfile(session,'flow.bin'));
    else
        macroDat.bQuiver = true;
        vidStream  = VideoReader(fullfile(session,'flow.avi'));  
        fileStream = fopen(fullfile(session,'flow.bin'),'r');
    end
    macroDat.nofFrames = vidStream.NumberOfFrames;
    tmp = what(session);
    macroDat.path = tmp.path;
    macroDat.fileReadPointer = frameNr;
    macroDat.bEOF = false;
end


%all inputs are ok and we are sure to have initialized, then:
if nargin == 0 
    frameNr = macroDat.fileReadPointer;
elseif nargin > 0
    if macroDat.bQuiver && frameNr ~= macroDat.fileReadPointer
        fseek(fileStream,(frameNr-1)*macroDat.flowRes(1)*macroDat.flowRes(2)*4*2, 'bof');
    end
    macroDat.fileReadPointer = frameNr;
end

if frameNr > macroDat.nofFrames
     macroDat.bEOF = true;
else
    macroDat.bEOF = false;
end

if  macroDat.bEOF
    im = -1;
    u = -1;
    v = -1;
    macroDatOut = macroDat;
    return;
end


imCoded = single(read(vidStream,frameNr));
im  = imCoded(:,:,3);

if macroDat.bQuiver
    u = fread(fileStream,[macroDat.flowRes(1),macroDat.flowRes(2)],'*single');
	v = fread(fileStream,[macroDat.flowRes(1),macroDat.flowRes(2)],'*single');
%     im = single(imTmp(:,:,1));
else % if full flow
% mag = (double(imCoded(:,:,2))/255)*10/macroDat.sc;
% an  = (double(imCoded(:,:,2))/255)*2*pi;
% u   = mag.*cos(an);
% v   = mag.*sin(an);
%     u = (imCoded(:,:,1)/macroDat.rm(2))-macroDat.rm(1);
%     v = (imCoded(:,:,2)/macroDat.rm(2))-macroDat.rm(1);
    u = (imCoded(:,:,1)*(macroDat.rm/127))-macroDat.rm;
    v = (imCoded(:,:,2)*(macroDat.rm/127))-macroDat.rm;
end

macroDat.fileReadPointer = macroDat.fileReadPointer +1;
if macroDat.fileReadPointer > macroDat.nofFrames
     macroDat.bEOF = true;
end
macroDatOut = macroDat;

% %%recording protocoll:
% U2 = (U2+in.rm)*(127/in.rm);
% V2 = (V2+in.rm)*(127/in.rm);



% rm = 3;
% rm2= 20;
% U2 = (U2+rm)*rm2;
% V2 = (V2+rm)*rm2;
%  writeVideo(g.writeVidFlow,...
%    reshape(uint8([U2, V2, curIm]),...
%    [size(an,1) size(an,2) 3]));



% % % OLD The recording protocoll:
% an  = (atan2(V2,U2)+ pi+0.000001)/(2*pi+0.00001);   
% mag = min(0.99999999,sqrt(U2.^2 + V2.^2)*in.sc/10);
% writeVideo(g.writeVidFlow,...
%    reshape([an, mag, curIm/256],...
%    [size(an,1) size(an,2) 3]));
