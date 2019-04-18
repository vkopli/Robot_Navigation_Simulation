function rows = find_row(main_cell,comp_cell)
%find rows where comp_cell (1x2 cell) is in main_cell (nx2 cell)

rows = []; %initialize vector of rows

for row = 1:size(main_cell,1) %for each row in main cell
    if isequal(main_cell(row,:),comp_cell) %if comp cell is in row of main cell
        rows = [rows,row]; %add to rows
    end
end
end