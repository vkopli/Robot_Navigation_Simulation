
function [true_map,known_map] = initialize_plot(I,Robby)
%creates true_map with appropriate colormapping values for barriers,
%start position, and end position 

%% CREATE TRUE_MAP
true_map_color = 5; %empty spaces of true_map can be any color
dfn = getappdata(I,'CurrentMap');

start_pos = dfn.start_pos;
target_pos = dfn.target_pos;

%make true_map
true_map = ones(dfn.dim2,dfn.dim1).*true_map_color; 
true_map(target_pos(2),target_pos(1)) = 3; %set target position

b = dfn.barriers;
for m = 1:size(b,1)
true_map(b{m,2},b{m,1}) = 2; %set barriers
end

%% CREATE KNOWN_MAP
%initialize known_map: robot's effective knowledge of map (all black)
known_map = ones(size(true_map));
%add barriers to edges (robot is aware of edges/limitations of map)
known_map = padarray(known_map,[1,1],2); 
%robot is aware of location of target pos
known_map(target_pos(2)+1,target_pos(1)+1) = 3;
known_map = update_known_map(start_pos,known_map,true_map);

%% UPDATE PLOT HANDLES
%x and y bounds of "real" part of map (discludes fake walls on borders)
xb = 2:size(true_map,1)+1; yb = 2:size(true_map,2)+1;
dark = getappdata(I,'Dark');
plot_map = dark*known_map(xb,yb) + ~dark*true_map;
set(I,'cdata',plot_map) %change colors on known_map
set(Robby,'xdata',[-0.5+start_pos(1),0.5+start_pos(1)],... 
    'ydata',[-0.5+start_pos(2),0.5+start_pos(2)]) %set position of robot
drawnow
end