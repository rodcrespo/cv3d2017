% Copyright: Stefan  M. Karlsson, Josef Bigun 2014
function [myHandles, pathToSave] = setupGraphicsScript(in,curIm, varargin)
global g;
pathToSave = in.pathToSave;
switch in.method
    case 'nothing'
      myHandles.figH  = figure('NumberTitle','off','Name',in.method);
      myHandles.hImObj= imagesc( curIm,[0,250]);
      colormap gray;axis off;axis manual;axis image;
      hold on;
    case 'edge'
    %setup graphics based on edgeIm
      myHandles.figH = figure('NumberTitle','off'); set(myHandles.figH, 'Name',in.method);
      subplot(1,2,1); myHandles.hImObjEdge = imagesc(varargin{1},[0 max(max(varargin{1}))*0.96  ]);
      set(myHandles.hImObjEdge,'CData',zeros(size(varargin{1})));
%       subplot(1,2,1); hImObjEdge = imagesc(edgeIm);
      axis off;axis image;colormap gray(256); title(gca,'Edge Image');
      myHandles.hEdgeAxesObj = gca; 
      
      subplot(1,2,2); myHandles.hImObj = imagesc( curIm,[0,255]); 
      axis off;axis image;colormap gray(256);title(gca,'original sequence');
    case {'flow1full','hsfull','syntheticfull'}
          myHandles.figH = figure; set(myHandles.figH, 'Name',in.method);
          myHandles.hImObj = image(zeros([size(curIm), 3]));
          axis off;axis image; title(gca,[in.method ', dedicated function, full resolution Image']);
          if in.bRecordFlow
            if strcmp(in.pathToSave,'')
              saveNum =1;
              while exist(['savedOutput' num2str(saveNum)],'dir')
                saveNum = saveNum+1;
              end
              pathToSave = ['savedOutput' num2str(saveNum)];
            else
                pathToSave = in.pathToSave;
            end
            if ~exist(pathToSave,'dir'), mkdir(pathToSave);end 
            if in.bRecordFlow == 1 %do lossless compression
                g.writeVidFlow = VideoWriter(fullfile(pathToSave, 'tmp.avi'),'Archival');
            else %in.bRecordFlow > 1: do lossy compression
                g.writeVidFlow = VideoWriter(fullfile(pathToSave, 'tmp.avi'),'Motion JPEG AVI');
                if in.bRecordFlow == 2
                    g.writeVidFlow.Quality = 100;
                else
                    g.writeVidFlow.Quality = 90;
                end
            end
            g.writeVidFlow.FrameRate = min(in.targetFramerate,30);
            open(g.writeVidFlow);
            save(fullfile(pathToSave, 'flow.mat'),'in');
          end
    case 'gradient'
        pathToSave = '';
   % setup graphics based on dx, dy and dt
   dx = varargin{1};dy = varargin{2};dt = varargin{3}; 
      myHandles.figH = figure('NumberTitle','off'); set(myHandles.figH,'Name','3D gradient');
      plotRange = max(max(sqrt(dx.^2+dy.^2)))+0.001;
    
      subplot(2,2,1); myHandles.hImObjDx = imagesc(dx,[-plotRange,plotRange]); 
      axis off;axis image;colormap gray(256);title(gca,'dx');

      subplot(2,2,2); myHandles.hImObjDy = imagesc(dy,[-plotRange,plotRange]); 
      axis off;axis image;colormap gray(256);title(gca,'dy');

      subplot(2,2,3); myHandles.hImObjDt = imagesc(dt,[-plotRange,plotRange]); 
      axis off;axis image;colormap gray(256);title(gca,'dt');

	  subplot(2,2,4); myHandles.hImObj = imagesc( curIm,[0,255]); 
      axis off;axis image;colormap gray(256);title(gca,'original sequence'); 
    otherwise %setup based on flow field U, V
%       flowRes = max(size(U1));

      U = varargin{1};
      myHandles.figH  = figure('NumberTitle','off','Name',in.method);
      myHandles.hImObj= imagesc( curIm,[0,250]);
      colormap gray;axis off;axis manual;axis image;
      hold on;
      iY = linspace(1,size(curIm,1),size(U,1)+2);      iY = iY(2:end-1) ;
      iX = linspace(1,size(curIm,2),size(U,2)+2);      iX = iX(2:end-1) ;

%       myHandles.hQvObjLines  = quiver(iX,iY, zeros(size(U)),  zeros(size(U)),0 ,'m','MaxHeadSize',5,'Color',[.9 .2 .1]);%, 'LineWidth', 1);
      myHandles.hQvObjPoints = quiver(iX,iY, zeros(size(U)),  zeros(size(U)),0 ,'m','MaxHeadSize',0.1,'Color',[0 .9 .3]);%, 'LineWidth', 1);
      axis image;
      title(gca,['current image. Flow vectors are scaled by ' num2str(in.sc) ':1' ]);
      
      if in.bRecordFlow
        if strcmp(in.pathToSave,'')
          saveNum =1;
          while exist(['savedOutput' num2str(saveNum)],'dir')
            saveNum = saveNum+1;
          end
          pathToSave = ['savedOutput' num2str(saveNum)];
        else
            pathToSave = in.pathToSave;
        end
        if ~exist(pathToSave,'dir'), mkdir(pathToSave);end 
        g.writeVidFlow = VideoWriter(fullfile(pathToSave, 'flow.avi'));
        g.writeVidFlow.FrameRate = min(in.targetFramerate,30);
        open(g.writeVidFlow);
        save(fullfile(pathToSave, 'flow.mat'),'in', 'iX','iY');
        g.writeFlow = fopen(fullfile(pathToSave, 'flow.bin'),'w');
      end
end
g.figH = myHandles.figH;
%setup keyboard callback
set(myHandles.figH, 'WindowKeyPressFcn',@myKeypress,'WindowKeyReleaseFcn',@myKeyrelease);

if strcmpi(in.movieType, 'synthetic')
    set(myHandles.figH, 'Name',[get(myHandles.figH, 'Name') ' -- (shut down figure to stop), keys (q,a,w,s,e,d,p) for lag time and pattern speed --' ]);
else
    set(myHandles.figH, 'Name',[get(myHandles.figH, 'Name') ' -- shut down figure to stop']);
end






