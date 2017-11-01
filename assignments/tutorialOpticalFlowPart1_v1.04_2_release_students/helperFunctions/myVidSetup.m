% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [vid,width,height] =  myVidSetup(kindOfMovie,movieType,width, height,camID,startingTime)
% myVidSetup- setups the video feed. 3 types are handled different,
% depending on the 'kindOfMovie' input arg. Can be 'file'(file on disk),
% 'synthetic'(manufactured test sequence) or 'camera' (setups the default 
% video input device for capturing video for this application)
if nargin < 6
    startingTime = 1;
end
if nargin < 5
    camID = 1;
end

vid.camID = camID;

if strcmpi(kindOfMovie, 'file')
  if startingTime == 1
        %we open the file for reading
    try  %first try to get the computer vision toolbox videoreader:
        vid = vision.VideoFileReader(movieType,...
            'ImageColorSpace','Intensity',...
            'VideoOutputDataType','single');        
    catch %if that didnt work, we go with the built in Videoreader:
%         disp('computer vision avi reading not available')
        vid = VideoReader(movieType);
    end
  else %if startingTime ~= 1
      vid = VideoReader(movieType); %only the built in VideoReader can handle seeking
  end
  
    info = mmfileinfo(movieType);
    height = info.Video.Height;
    width = info.Video.Width;

elseif strcmpi(kindOfMovie, 'synthetic') 
    vid.Height = height;   vid.Width  = width;
elseif strcmpi(kindOfMovie, 'camera')
    vid.bUseCam = 1; %matlab built in
    vid.Height = height;   vid.Width  = width;
%         first, reset image aqcuisition devices. This also tests if the
%         toolbox is available. 
    try
       imaqreset;
    catch %#ok<CTCH>
        fprintf('\nImage Aquisition toolbox not available! \n Looking for videoinput library(this is a windows ONLY library)... ');
        vid.bUseCam = 2; %videoInput
        try
            VI = vi_create();
            vi_delete(VI);
            fprintf('FOUND IT!\n');
        catch %#ok<CTCH>
            error('no library available for camera input');
        end
    end
    if(vid.bUseCam==1) %matlab built-in

        %get info on supported formats for this capture device
        dev_info = imaqhwinfo('winvideo',vid.camID);
        strVid = dev_info.SupportedFormats;
    
        % strVid contains all the supported formats as strings , for example 
        %     'I420_320x240' is one such format. I want to pick the smallest
        %     resolution available, but still supporting the requested output
        %     resolution. I parse these driver strings in what follows
        splitStr = regexpi(strVid,'x|_','split');
        pickedFormat = 0;          %integer, indicating which format chosen
        resolutionFormat = Inf;    %we will minimize the resolution below
        for ik = 1:length(strVid)
            resW = str2double(splitStr{ik}{2}); %width  of this format
            resH = str2double(splitStr{ik}{3}); %height of this format
            
            %we will pick this format, if it supports the requested height
            %and width, AND if its resolution (resW*resH) is smaller than
            %previously found formats
            if (resW > (vid.Width-1) )&&(resH > (vid.Height-1) )&& (resW*resH)<resolutionFormat
                resolutionFormat = (resW*resH);
                pickedFormat = ik;
            end
        end
        % pick the selected format, color format and a region of interest:
        vid.camIn = videoinput('winvideo',vid.camID,strVid{pickedFormat});
        set(vid.camIn, 'ReturnedColorSpace', 'gray');
    %     set(vid.camIn, 'ReturnedColorSpace', 'rgb');

        set(vid.camIn, 'ROIPosition', [1 1 vid.Width vid.Height]);
        %let the video go on forever, grab one frame every update time, maximum framerate:
        triggerconfig(vid.camIn, 'manual');
        src = getselectedsource(vid.camIn);
        if isfield(get(src), 'FrameRate')
            frameRates = set(src, 'FrameRate');
            src.FrameRate = frameRates{1};    
        end
        %other things you may want to play around with on your system:
    %         set(getselectedsource(vid.camIn), 'Sharpness', 1);
    %         set(getselectedsource(vid.camIn), 'BacklightCompensation','off');
    %         set(getselectedsource(vid.camIn), 'WhiteBalanceMode','manual');    
    % if running with the camera, now we start it:
    start(vid.camIn);
    pause(0.05);  %ask mathworks why I do this :P
    else %if vid.bUseCam == 2 
    % using videoinput library. This is an external windows library for 
    % grabbing from the connected camera. You may need to get compiled
    % binaries, see instructions in "helperFunctions" folder.
        vid.camIn = vi_create();
        numDevices = vi_list_devices(vid.camIn);
        if numDevices<1,    error('video input found no cameras');end
        vi_setup_deviceProper(vid.camIn, camID-1, vid.Height, vid.Width, 30);
    end 
end
