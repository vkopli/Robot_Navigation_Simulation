function close_req(source,event,all_handles)
%called by save_map/ok when text window is closed prematurely
    
delete(source) %delete figure

if all(ishandle(all_handles)) %enable all handles if main window if still open
    set(all_handles,'Enable','on')
end
end
