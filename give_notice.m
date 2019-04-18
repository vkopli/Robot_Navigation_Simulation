function give_notice(all_handles,popup_size,fig_color)
%gives message that robot can't reach target 
%(called by release_robot function, a main interface UI callback)

%figure for warning
notice_fig = figure('Visible','off','Position',popup_size,'Color',...
    fig_color,'menubar','none','CloseRequestFcn',{@close_req,all_handles});
set(notice_fig,'name','Warning','numbertitle','off')
movegui(notice_fig,'center')
axis off

%ui control for text box
uicontrol('Style','text','Position',[0.1,0.5,0.8,0.2],...
    'BackgroundColor',fig_color,'String','Robot cannot reach target')
uicontrol('Style','pushbutton','Position',[0.35,0.2,0.3,0.2],...
    'String','OK','Callback',{@ok,notice_fig})

notice_fig.Visible = 'on'; %show notice figure window
set(all_handles,'Enable','off') %don't allow other interactions

function ok(~,~,notice_fig)
%function called by release_robot to close warning box (can't reach target)
    close(notice_fig)
end
end
