function [true_map,known_map] = runner2editor(running_handles,...
    editing_handles,I,Robby,radio_button)
%go to editor window from runner window

%change visibility of ui controls (open editor)
set(running_handles,'Visible','off')
set(editing_handles,'Visible','on')

%set darkness values
setappdata(I,'Dark',0)
set(radio_button,'Value',1) %show full view of map

%don't allow view to be changed while editing
set(radio_button,'Enable','off') 
[true_map,known_map] = initialize_plot(I,Robby); %visualize map

end