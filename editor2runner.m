function [true_map,known_map] = editor2runner(editing_handles,...
    running_handles,I,Robby,radio_button,dark)
%go back from editor window to runner window

%reset darkness settings  
set(radio_button,'Enable','on') %allow darkness settings to be altered
setappdata(I,'Dark',dark) 
set(radio_button,'Value',~dark)

%set map
[true_map,known_map] = initialize_plot(I,Robby);

%go back to runner UI objects
set(editing_handles,'Visible','off')
set(running_handles,'Visible','on')

end