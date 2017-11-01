% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function macroDat = flowPlayBack(pathToSave)
% Function to play-back a sequence of recorded optical flow. This functions
% main purpose is to illustrate how to use "getSavedFlow".

%% recorded flow will be in loaded matrices "u" and "v"
% load the first frame, sets up "getSavedFlow" for consecutive calls
[im, u, v, macroDat] = getSavedFlow(1, pathToSave);

%figure for the plotting
hFig = figure('Name',['Save Files in ' macroDat.path]);

%original input video for the flow displayed to the left:
subplot(1,2,1);
hIm = imagesc(im,[0 255]);colormap gray; axis image; axis off;
title(['Source of video input: ' macroDat.movieType]);

%loaded flow shown to the right, in color coding:
subplot(1,2,2); 
hFlow = imagesc(flow2colIm(u,v)); axis image; axis off;
hText = title(macroDat.method);


while ishandle(hFig)
    set(hIm,  'CData' ,im);
    set(hFlow,'CData' ,flow2colIm(u,v));
    T = macroDat.nofFrames       + macroDat.startingTime -1;
    t = macroDat.fileReadPointer + macroDat.startingTime -1;
    
    set(hText,'String',[macroDat.method ', frame = ' num2str(t) '/' num2str(T)]);
    
    if macroDat.bEOF %if we reach the end of recording ...
        [im, u, v, macroDat] = getSavedFlow(1); %... then start over...
    else
        [im, u, v, macroDat] = getSavedFlow(); %otherwise continue to the next frame
    end
    pause(0.01);
end

% clear the persistent variables in getSavedFlow (ugly solution? yes)
clear getSavedFlow;


% local helper to conver flow components to color coding:
function colIm = flow2colIm(u,v)
H  = (atan2(v,u)+ pi+0.000001)/(2*pi+0.00001);   
V = min(0.99999999,sqrt(u.^2 + v.^2)*8/10);
colIm = hsv2rgb(H,  ones(size(H),'single'),V);
% S = min(0.99999999,sqrt(u.^2 + v.^2)*8/10);
% colIm = hsv2rgb(H,  S,  ones(size(H),'single'));
