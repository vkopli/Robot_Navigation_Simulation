function [fig,I,Robby] = create_plot_handles(fig_color,ui_color)
%creates plot handles to be altered throughout code (only run once)

%get screen size
s = get(0,'ScreenSize');

%set default appearance of UI controls
set(0,'defaultUicontrolFontSize',14,'defaultUicontrolFontName',...
    'Times New Roman','defaultUicontrolUnits','Normalized',...
    'defaultUicontrolBackgroundColor',ui_color)

%initialize the figure/gui window
fig = figure('Visible','off','Position',s.*.7,'Color',fig_color,...
    'menubar','none');
set(fig,'name','Robby the Robot: Grassfire Simulation','numbertitle','off')
movegui(fig,'center')

%make a colormap for plotting (use uisetcolor to visualize colors) 
colormap = [0,0,0; %1: black, unknown cells
            0.32,0.19,0.19; %2: brown, barriers
            0.196,0.7412,0.1333; %3: green, end position
            0.2000,0.4667,0.8275; %4: blue
            [0.9725,0.9725,0.9725]]; %5: gray, known empty cells 

[rob_head,~,aData] = imread('robothead.png'); %read in image of robot head
rob_head = flip(rob_head,1); %flip image vertically
aData = flip(aData,1); %flip alpha data vertically

%initialize plot of map
axes('position',[0.23,0.15,0.63,0.8])
I = imshow([],colormap,'InitialMagnification','fit');
hold on %allow robot head and other things to be plotted on same axes

%initialize plot of robot head (must be "over" map)
Robby = imshow(rob_head);
set(Robby,'alphadata',aData)

%flip x and y axes so that positive is to the right and up, respectively
set(gca,'ydir','normal') 
end