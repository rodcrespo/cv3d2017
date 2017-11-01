% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [newIm, GT_motionU,GT_motionV] = generateFrame(vid, t,kindOfMovie,spdFactor,arrowKey,inSyntSettings,flowResIn)
persistent iix iiy k prevT rotAn P0 inertia synt rotAnprev PtXprev PtYprev flowRes edgeTilt;
global g;
if nargin<4
    spdFactor = [1,0];end
if nargin<5
    arrowKey = [0,0];end

if strcmp(kindOfMovie,'file') 
    if isa(vid,'VideoReader')
         %in this case we have absolute time "t", use to bounce the video:
        t=varyT(round(t),vid.NumberOfFrames);
        newIm = single(rgb2gray(read(vid, t)));
    else %computer vision toolbox videoreader:
        newIm = 250*step(vid);
    end
 elseif strcmpi(kindOfMovie,'synthetic') 
    if t==1 || isempty(iix)
        if nargin < 6, 
            error('on first call, generateFrame must have a syntSettings structure, if you generate synthetic sequence');
        end
        if nargin < 7,
            flowResIn = [vid.Width, vid.Height]/8;
        end            
        flowRes  = flowResIn;
        synt      = inSyntSettings;
        [iix,iiy] = meshgrid(linspace(-1,1,vid.Width),linspace(-1,1,vid.Height));
        iix       = single(iix); iiy= single(iiy);
        rotAnprev = 0;
        PtXprev   = 0;
        PtYprev   = 0;
        
        k = 0; %local time;
        prevT = t-1;
        rotAn = 0;
        P0       = [0,0];
        inertia  = [0,0];
        edgeTilt      = synt.edgeTilt;      %initial tilt of the background edge 
    end
        spd  = synt.spd;               %constant factor to speed of motion of the patterns generated
        cen1 = synt.cen1;              %centre ofsets of circles
        cW   = synt.cW;                %radius of circles
        cFuz = synt.cFuz;              %fuzziness of the boundary
        cdet = synt.cdet;              %detail of the interior pattern(frequency of sinusoids)
        backWeight    = synt.backWeight;    %intensity of the global, background edge
        edgeTiltSpd   = synt.edgeTiltSpd;   %speed of rotation for background edge
        flickerWeight = synt.flickerWeight; %amount of flicker (in range [0,1])
        flickerFreq   = synt.flickerFreq;   %frequency of flicker (in range (0,Inf])
        noiseWeight   = synt.noiseWeight;
        


        k = k    +(t-prevT)*spdFactor(1)*spd; %local time
        % arrowKey = arrowKey + spdFactor(1)*[sin(pi*(k+0.5)*2)/2  -cos(pi*(k+0.5))]/10;
        rotAn = rotAn+(t-prevT)*spdFactor(2)*spd; %rotation angle update
        prevT = t;
        arrowKeySpd = 0.0035;
        inertia = (inertia-0.0002*P0.*sign(inertia))*0.988 +...
                   arrowKey*arrowKeySpd - P0*0.001;
        totInertia = sqrt(sum(inertia.^2));
        maxInertia = 0.045;
    if totInertia > maxInertia
        inertia = maxInertia*inertia/totInertia;
    end

    P0 = P0 + inertia;
    PtX = 0.9*sin(pi*(k+0.5)*2)/2 + P0(1); %"figure eight" path in x and y, 
    PtY =-0.9*cos(pi*(k+0.5)  )   + P0(2); %as function of local time
%  fprintf([' ' num2str(t)])
    %rotation and translation, composite transform:
    iX = cos(rotAn)*(iix+PtX) + sin(rotAn)*(iiy+PtY);
    iY = sin(rotAn)*(iix+PtX) - cos(rotAn)*(iiy+PtY);
    % generate the textured disks:
        newIm =128*(                           2*sig(cW^2-(iX-cen1).^2-(iY-cen1).^2, cFuz*cW/50)+... disk blank          
                         (1+cos((sqrt(iX.^2+iY.^2))*cdet*24*pi  + 1.2)  ).*sig(cW^2-(iX-cen1).^2-(iY+cen1).^2, cFuz*cW/50)+... disk vert lines
                         (1+cos((iY+iX)*cdet*17*pi + 6/20)).*sig(cW^2-(iX+cen1).^2-(iY-cen1).^2, cFuz*cW/50)+... disk horiz lines
     (1+cos(iY*cdet*15*pi).*cos(iX*cdet*15*pi)).*sig(cW^2-(iX+cen1).^2-(iY+cen1).^2, cFuz*cW/50));  %disk checkerboard

if nargout> 1
    tmpBin = (cW^2>(iX-cen1).^2+(iY-cen1).^2)+(cW^2>(iX-cen1).^2+(iY+cen1).^2)+ ...
             (cW^2>(iX+cen1).^2+(iY-cen1).^2)+(cW^2>(iX+cen1).^2+(iY+cen1).^2);
% 	tmpBin = ((cW/3)^2>(iX-cen1).^2+(iY-cen1).^2);%+((cW/3)^2>(iX-cen1).^2+(iY+cen1).^2)+ ...
%              ((cW/3)^2>(iX+cen1).^2+(iY-cen1).^2)+((cW/3)^2>(iX+cen1).^2+(iY+cen1).^2);
    if strcmpi(g.method,'synthetic')
        GT_motionU = (vid.Width/2)*(imresizeNN(tmpBin.*((cos(rotAnprev-rotAn)-1)*(iix+PtX)+  sin(rotAnprev-rotAn)*(iiy+PtY)-PtX+PtXprev) ,flowRes));
        GT_motionV = -(vid.Height/2)*(imresizeNN(tmpBin.*(sin(rotAnprev-rotAn)    *(iix+PtX) - ((cos(rotAnprev-rotAn)-1)*(iiy+PtY))+PtY-PtYprev),flowRes));
    else %syntheticFull
        GT_motionU = (vid.Width/2)*tmpBin.*((cos(rotAnprev-rotAn)-1)*(iix+PtX)+  sin(rotAnprev-rotAn)*(iiy+PtY)-PtX+PtXprev);
        GT_motionV = -(vid.Height/2)*tmpBin.*(sin(rotAnprev-rotAn)    *(iix+PtX) - ((cos(rotAnprev-rotAn)-1)*(iiy+PtY))+PtY-PtYprev);
    end
end
 
rotAnprev = rotAn;
PtXprev   = PtX;
PtYprev   = PtY;

if flickerWeight > 0
    newIm = (flickerWeight*(cos(t*flickerFreq)+1)/2+(1-flickerWeight))*newIm;
end

if backWeight > 0
  newIm = (newIm + backWeight*(250-newIm).*sig(cos(edgeTilt)*iix+sin(edgeTilt)*iiy,1/40)); %apply the background, with custom tilt
  edgeTilt = edgeTilt + edgeTiltSpd;
% newIm = (newIm + backWeight*(250-newIm).*(iix>0)); %apply the background, fixed with hard boundary
end

if noiseWeight > 0
    newIm = min(max(0,(1-noiseWeight)*newIm + noiseWeight*randn(size(iix))*128/2),255);
end

else %if strcmpi(kindOfMovie,'camera')  % capture from camera:
    if vid.bUseCam==2 %videoinput lib:
        vi_is_frame_new(vid.camIn, vid.camID-1);
        newIm  = vi_get_pixelsProper(vid.camIn, vid.camID-1,vid.Height,vid.Width);
    else %image aqcuisition toolbox:
%         newIm = single(flipdim(squeeze(getsnapshot(vid.camIn)),2));%/256;
        newIm = single(flipdim(getsnapshot(vid.camIn),2));%/256;
    end
end

