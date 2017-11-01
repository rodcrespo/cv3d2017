% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function updateGraphicsScript(in,myHandles,curIm,varargin)
% Update the graphics, depending on the "method" used
global g;
if ~ishandle(myHandles.figH)%only update if user has NOT killed figure
    return;
end

switch lower(in.method)
    case 'edge'
        set(myHandles.hImObj ,'cdata',curIm);
        edgeIm = varargin{1};
        set(myHandles.hImObjEdge ,'cdata',edgeIm);
%         set the threshold g.edgeUpper, for histogram normalization
%         let it adapt to the signal:
        maxVal = max(edgeIm(:));
        maxVal = min(maxVal,0.7*max(edgeIm(:)) + std(edgeIm(:)));        
        alpha = 0.55*exp(-((g.edgeUpper - maxVal)^2)/1000)+0.4;
        g.edgeUpper = alpha*g.edgeUpper + (1-alpha)*maxVal;
        set(myHandles.hEdgeAxesObj,'CLim',[0 g.edgeUpper]);
    case 'gradient'
        dx=varargin{1};dy=varargin{2};dt=varargin{3};
        set(myHandles.hImObjDx,'cdata',dx);
        set(myHandles.hImObjDy,'cdata',dy);
        set(myHandles.hImObjDt,'cdata',dt);
        set(myHandles.hImObj  ,'cdata',curIm);
    case {'hsfull', 'flow1full','syntheticfull'}     
        if in.bFineScale
            U = varargin{1};V = varargin{2};
        else
            U = imresizeNN(varargin{1},size(curIm));
            V = imresizeNN(varargin{2},size(curIm));
        end
        an  = (atan2(V,U)+ pi+0.000001)/(2*pi+0.00001);   
        mag = min(0.99999999,sqrt(U.^2 + V.^2)*in.sc/10);
%         colIm = hsv2rgb(an,  mag,   max(mag,curIm/256));


        set(myHandles.hImObj ,'cdata', hsv2rgb(an,  mag,   max(mag,curIm/256)));
%         set(myHandles.hImObj ,'cdata',colIm);
        if in.bRecordFlow
%             U = (U+in.rm(1))*in.rm(2);
%             V = (V+in.rm(1))*in.rm(2);
            U = (U+in.rm)*(127/in.rm);
            V = (V+in.rm)*(127/in.rm);

%              writeVideo(g.writeVidFlow,...
%                reshape([an, mag, curIm/256],...
%                [size(an,1) size(an,2) 3]));
%             writeVideo(g.writeVidFlow,colIm);
             writeVideo(g.writeVidFlow,...
               reshape(uint8([U, V, curIm]),...
               [size(an,1) size(an,2) 3]));
        end
    case {'lk','flow1','synthetic'}  %coarse flow methods with quiver
        U = varargin{1};V = varargin{2};
        set(myHandles.hImObj ,'cdata',curIm);
%         set(myHandles.hQvObjLines ,'UData', in.sc*U, 'VData', in.sc*V);
        set(myHandles.hQvObjPoints,'UData', in.sc*U, 'VData', in.sc*V);
        if in.bRecordFlow
             writeVideo(g.writeVidFlow,uint8(curIm));
             fwrite(g.writeFlow,U,'single');
             fwrite(g.writeFlow,V,'single');
        end
    otherwise %nothing
        set(myHandles.hImObj ,'cdata',curIm);
end
