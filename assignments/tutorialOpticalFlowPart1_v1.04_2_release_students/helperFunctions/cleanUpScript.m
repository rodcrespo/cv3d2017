% Clears up memory
% persistent variables in functions:

function cleanUpScript(in,vid)
global g;
clear functions;

if strcmpi(g.kindOfMovie,'file')
    delete(vid);   
elseif strcmpi(g.kindOfMovie,'camera')
  if vid.bUseCam ==2
      vi_stop_device(vid.camIn, vid.camID-1);
      vi_delete(vid.camIn);
  else
      delete(vid.camIn); 
  end
end 
if in.bRecordFlow
   if strcmpi(in.method(end-1:end),'ll')
	close(g.writeVidFlow);
    %rename the file to "flow.bin", so the user wont think it is an avi that is readily playable.
    movefile(fullfile(g.writeVidFlow.Path, g.writeVidFlow.Filename), fullfile(g.writeVidFlow.Path, 'flow.bin'))
  else
  try
	close(g.writeVidFlow);
    fclose(g.writeFlow);
  catch
  end
  end
end