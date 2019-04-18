function [known_map] = navigation(true_map,known_map,fig,I,Robby)
%I: plot handle for map
%Robby: plot handle for robot head

setappdata(Robby,'Running',1) %indicate that while loop is underway

%get map information
dfn = getappdata(I,'CurrentMap');
start_pos = dfn.start_pos;
target_pos = dfn.target_pos;

%x and y bounds of "real" part of map (discludes fake walls on borders)
xb = 2:size(true_map,1)+1; yb = 2:size(true_map,2)+1;

cur_pos = start_pos; %initialize current position of robot

%while robot still hasn't reached target position
while ~all(cur_pos == target_pos)
    
%SET OLD_POS = CUR_POS
old_pos = cur_pos;

%USE GRASSFIRE METHOD TO CALCULATE NEW CUR_POS
cur_pos = grassfire(known_map,old_pos,target_pos);

%UPDATE KNOWN_MAP
known_map = update_known_map(cur_pos,known_map,true_map);
    
%UPDATE TRUE_MAP/KNOWN_MAP PLOT WITH ROBBY
if ~ishandle(fig)
    return %if figure is closed, terminate
elseif ~isequal(getappdata(I,'CurrentMap'),dfn) || getappdata(Robby,'Stop')
    setappdata(Robby,'Running',0)
    setappdata(Robby,'Stop',0)
    return %if map has changed or reset, terminate
else
    dark = getappdata(I,'Dark');
    timestep = getappdata(Robby,'TimeStep');
    plot_map = dark*known_map(xb,yb) + ~dark*true_map;
    set(I,'cdata',plot_map)
    set(Robby,'xdata',[-0.5+cur_pos(1),0.5+cur_pos(1)],...
        'ydata',[-0.5+cur_pos(2),0.5+cur_pos(2)])
    pause(timestep)
end
end
%at end of loop, indicate that navigation() isn't running
setappdata(Robby,'Running',0) 
end