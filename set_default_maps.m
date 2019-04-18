function df = set_default_maps()
%Initialize default start map values
%df: cell array of default map structures ({df1,df2,...dfn})
%Warning: all saved maps in interface will be deleted when run

%MAP 1
df1.dim1 = 10; 
df1.dim2 = 10;
df1.start_pos = [2,1]; %initialize start position
df1.target_pos = [9,10]; %initialize target position
df1.barriers = {1:3,2;5,1:5;7,7:10}; %barriers 

%MAP 2
df2.dim1 = 25; 
df2.dim2 = 25;
df2.start_pos = [5,9]; %initialize start position
df2.target_pos = [25,25]; %initialize target position
df2.barriers = {1:3,5;8,7:10;7:10,2;2:25,10;10,15:25}; %barriers 

%cell of structures containing data in default maps
df = {df1,df2};

%names of default maps
df_names = {'Default 1','Default 2'};

%map number being viewed
value = 1; %map number being viewed on startup

save('maps.mat','df','df_names','value')

end