function success = is_possible(I,true_map)
%similar to grassfire function, checks whether robot can reach target_pos

success = 0; %initialize success status;

%get current map's start_pos
%(could be nm, new map being made, or m, current saved map)
m = getappdata(I,'CurrentMap'); 
start_pos = m.start_pos;

%initialize 'map' (walls on all borders so robot doesn't go off map)
%(5's for all blank spaces, 2's for walls, 3 for target_pos)
map = padarray(true_map,[1,1],2);

%initialize grassfire map (same size as known_map) 
g_map = zeros(size(map));

%x and y positions adjusted for padded map (known_map)
x = start_pos(1)+1;
y = start_pos(2)+1;

%initialize rank for first while loop
g_map(y,x) = 1; %initial position has rank 1
num = 1; %rank num+1 given to surrounding cells on each iteration

%while not all blocks in g_map are filled/known as walls by robot,...
%assign ranks to non-wall cells
while ~all(all(g_map|map == 2))
    
    [row,col] = find(g_map==num);
    ns = length(row); %number of cells with value num
    ws = zeros(3,3,ns); %preallocate matrix of W's for each cell with value num
    ps = ws; %preallocate matrix of W's for each cell with value num
    
    for n = 1:ns %for each cell with value num
        i = {row(n)-1:row(n)+1,col(n)-1:col(n)+1};

        %3x3 matrices for surrounding cells indexed by i
        P = g_map(i{1},i{2}); %0's for spots not addressed by grassfire
        W = map(i{1},i{2}); %2's: walls, 5's: known blanks, 3 for target_pos
        ws(:,:,n) = W; %index W for instance of num
        
        %+1 to surrounding cells that contain a 0 and are not walls
        plus_one = num + 1; %value given to surrounding cells
        P(~P & W~=2 & P~=P(2,2)) = plus_one;    
        ps(:,:,n) = P;
        g_map(i{1},i{2}) = P; %put num+1 values back into g_map
    end

    %check for success/failure
    if any(any(any(ws == 3))) %if target is next to any cell with number num (in true_map)
        success = 1; %navigation is possible
        return 
    elseif ~any(any(any(ps==plus_one))) 
    %if robot isn't able to move anywhere new for all possible paths(in g_map)
        success = 0; %navigation is impossible
        return
    end %otherwise, continue checking navigation
    num = num + 1; %increment rank that is being looked at
end