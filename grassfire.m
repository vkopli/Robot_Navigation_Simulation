function new_pos = grassfire(known_map,cur_pos,target_pos)

%initialize grassfire map (same size as known_map) 
g_map = zeros(size(known_map));

%x and y positions adjusted for padded map (known_map)
x = cur_pos(1)+1;
y = cur_pos(2)+1;

%initialize rank for first while loop
g_map(y,x) = 1; %initial position has rank 1
num = 1; %rank num+1 given to surrounding cells on each iteration

%while not all blocks in g_map are filled/known as walls by robot,...
%assign ranks to non-wall cells
while ~all(all(g_map|known_map == 2))
    
    [row,col] = find(g_map==num);
    
    for n = 1:length(row) %for each cell with value num
        i = {row(n)-1:row(n)+1,col(n)-1:col(n)+1};

        %3x3 matrices for surrounding cells indexed by i
        P = g_map(i{1},i{2}); %0's for spots not addressed by grassfire
        W = known_map(i{1},i{2}); %2's: walls, 5's: known blanks, 1's: all else

        %+1 to surrounding cells that contain a 0 and are not walls
        plus_one = num + 1; %value given to surrounding cells
        P(~P & W~=2 & P~=P(2,2)) = plus_one;
        
        g_map(i{1},i{2}) = P; %put values back into g_map
    end
    num = num + 1; %increment rank that is being looked at
end

%initialize row and col indicies for while loop (work backwards from here)
row = target_pos(2)+1; col = target_pos(1)+1;
num = g_map(row,col); %initialize max rank

%work backwards in rank to find best move
while num >= 3
    num = num - 1; %decrement rank by one for next iteration

    surr = g_map(row-1:row+1,col-1:col+1); %3x3 matrix of cells surrounding num

    %find indicies in surr with num
    [rows_s,cols_s] = find(surr==num);  
    %indicies of num relative to original num
    rows_s = rows_s - 2; cols_s = cols_s - 2;
    %use prev row,col to find indicies of num relative to g_map
    rows = rows_s + row; cols = cols_s + col;

    %randomly pick surrounding row, col pair from the best (num-1 rank)
    a = floor(rand*length(rows)) + 1;
    row = rows(a); col = cols(a);
end

%set location of best next move for Robby (rank 2)
new_pos = [col-1,row-1];

end


