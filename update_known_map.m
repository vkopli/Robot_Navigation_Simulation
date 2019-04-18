function [known_map] = update_known_map(cur_pos,known_map,true_map)
%updates robot's knowledge of map by adding info from cells immediately 
%surrounding robot's current position in map to known_map

%initialize 'map' (walls on all borders so robot doesn't go off map)
map = padarray(true_map,[1,1],2);

%(map and known_map are padded -> cur_pos indicies shifted [y-1,x-1]
i = {cur_pos(2):2+cur_pos(2),cur_pos(1):2+cur_pos(1)};

%surrounding cells of known_map that need to be changed
surr = known_map(i{1},i{2});

%logical 3x3 matrix of surr walls that still aren't registered in known_map
new_walls = map(i{1},i{2}) == 2 & surr == 1;

%add changes to surr (new walls/cells that robot can see now)
surr = surr + new_walls; %add walls (1+1=2)
surr = surr + (surr==1).*4; %add empty white cells where no walls (1+4=5)

known_map(i{1},i{2}) = surr; %put surrouding cells back into known_map

end