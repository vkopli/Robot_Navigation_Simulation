function Launch_Interface()
%launch user interface

%% Initialize Variables and Saved/Default Maps

timestep = 0.1;
dark = 1; %visualization type of map (black for all cells unknown by robot)
j = []; %map number into which next map will be saved

n_default = 2; %number of default maps (maps that shouldn't be cleared)
save_name = 'maps.mat'; %file name for saved variables (all_maps and all_names) 

%coloring of windows and ui objects
fig_color = [0.3922,0.4745,0.6353];
ui_color = 'w';
%color of depressed toggle button
depressed_color = [0.8627,0.8627,0.8627];

%pop-up window size
s = get(0,'ScreenSize');
popup_size = 0.2*s;

%ui handles
dim1_box = 0; 
dim2_box = 0;
%default dimensions
dim1_str = '10';
dim2_str = '10';

%editor variables
clicked_Robby = 0;
clicked_targ = 0;
clicked_barrier = 0;
new_bar = {};
barriers = [];

%Load Maps into Workspace (all_maps, all_names, view)
S = load(save_name);
all_maps = S.all_maps; %cell of structures containing data in each map 
all_names = S.all_names; %names of maps
value = S.value; %map number viewed last
if value > length(all_names)
    value = 1; %set value as 1 if value from workspace is invalid
end
old_value = value; %initialize last map number viewed while running interface
m = all_maps{value}; %set current map
nm = m; %initialize new map (editor)

%Initialize plot handles
[fig,I,Robby] = create_plot_handles(fig_color,ui_color);
%mouse UI callbacks for mouse on figure
set(fig,'CloseRequestFcn',@close_main,'WindowButtonMotionFcn',@move,...
    'WindowButtonDownFcn',@click,'WindowButtonUpFcn',@release)

%initialize Robby/I state info
setappdata(Robby,'TimeStep',timestep)
setappdata(Robby,'Running',0) %1 for navigation loop running, 0 otherwise
setappdata(Robby,'Stop',0) %1 message for Robby to stop, 1 to go
setappdata(I,'Dark',dark) %1 for dark view, 0 for full view
setappdata(I,'CurrentMap',m) %current viewing map

%Initialize plot
[true_map,known_map] = initialize_plot(I,Robby);

%% UI Controls for Runner (main interface)

%Pushbutton make robot start moving
start_button = uicontrol('Style','pushbutton','Position',[0.8 0.5 0.15 0.05],...
    'String','Start','Callback',@release_robot);

%Radio button to make unknown parts of map black
radio_button = uicontrol('Style','radiobutton','Position',[0.815 0.64 0.2 0.1],...
    'BackgroundColor',fig_color,'String','Full View','Callback',@toggle_view);

%Textbox to enter timestep
dt_box = uicontrol('Style','edit','Position',[0.8,0.3,0.15,0.05],'String',...
    num2str(timestep),'Callback',@dt);
uicontrol('Style','text','Position',[0.8,0.35,0.15,0.05],'BackgroundColor',...
    fig_color,'String','timestep:')

%Drop down menu to choose default map
drop_down = uicontrol('Style', 'popup','Position',[0.08 0.82 0.15 0.1],...
    'Value',value,'String',all_names,'Callback', @toggle_maps);
%set(drop_down,'String',all_names) %add map as entry in drop down list

%Pushbutton to create your own map
create_button = uicontrol('Style','pushbutton','Position',[0.08 0.45 0.15 0.05],...
    'String','Create','Callback',@create);

%Pushbutton to edit current map
edit_button = uicontrol('Style','pushbutton','Position',[0.08 0.6 0.15 0.05],...
    'String','Edit','Callback',@edit);

%Pushbutton to save current map
clear_button = uicontrol('Style','pushbutton','Position',[0.08 0.3 0.15 0.05],...
    'String','Clear','Callback',@clear);

%% UI Controls for Editor (editing interface)

%Pushbutton to remove barriers from map being created
remove_button = uicontrol('Style','togglebutton','Position',[0.08 0.68 0.15 0.05],...
    'Visible','off','String','Remove Barriers','Callback',@remove_barriers);

%Pushbutton to add barriers to map being created
add_button = uicontrol('Style','togglebutton','Position',[0.08 0.53 0.15 0.05],...
    'Visible','off','String','Add Barriers','Callback',@add_barriers);

%Pushbutton to cancel creating map
cancel_button = uicontrol('Style','pushbutton','Position',[0.08 0.38 0.15 0.05],...
    'Visible','off','String','Cancel','Callback',@cancel);

%Pushbutton to finish creating map and to initialize map (initially invisible)
done_button = uicontrol('Style','pushbutton','Position',[0.08 0.23 0.15 0.05],...
    'Visible','off','String','Done','Callback',@done);

%Text to give message that mouse can move start and target position
move_text = uicontrol('Style','text','Position',[0.25,0.83,0.5,0.1],...
    'BackgroundColor',fig_color,'Visible','off','String',...
    'Move Robby and the target position with your cursor');

%% UI Control Handle Arrays

%UI control handle arrays
running_handles = [drop_down,create_button,edit_button,clear_button];
editing_handles = [add_button,remove_button,cancel_button,done_button,...
    move_text];
rh_handles = [start_button,radio_button,dt_box];
lh_handles = [drop_down,create_button,edit_button,clear_button,...
    add_button,remove_button,cancel_button,done_button];
all_handles = [rh_handles,lh_handles];

fig.Visible = 'on'; %make figure window visible
check_clear_button() %enable/disable clear button according to map value

%% UI Callbacks for Runner

function release_robot(~,~)
%callback for start button (allow robot to start moving to target position)
    
    success = is_possible(I,true_map); %check if robot can reach target_pos
    if success %if navigation is possible]
        
        %change 'start' button into 'reset' button
        set(start_button,'String','Reset','Callback',@reset_robot)
        [true_map,known_map] = initialize_plot(I,Robby); %initialize plot
        
        set([add_button,remove_button],'Enable','off') %deactivate barrier editing button
        [known_map] = navigation(true_map,known_map,fig,I,Robby); %release robot on path
        if ~ishandle(fig) 
            return %end function if main window is closed
        end
        set([add_button,remove_button],'Enable','on') %reactivate
        
        %if in editor interface, reset Robby to start position after navigation
        if strcmp(get(add_button,'Visible'),'on')
            sp = nm.start_pos;
            set(Robby,'xdata',[-0.5+sp(1),0.5+sp(1)],...
                'ydata',[-0.5+sp(2),0.5+sp(2)])   
            %change from reset button to start button
            set(start_button,'String','Start','Callback',@release_robot)
        end
    else
        give_notice(all_handles,popup_size,fig_color)
    end
end

function reset_robot(~,~)
    %reset robot at initial position
    if getappdata(Robby,'Running') %if navigation() is running
        setappdata(Robby,'Stop',1) %terminate navigation
    end
    [true_map,known_map] = initialize_plot(I,Robby); %initialize visualization
    %change 'reset' button into 'start' button
    set(start_button,'String','Start','Callback',@release_robot)
end

function toggle_view(source,~)
%change view settings of map (robot's view/full view)

    dark = ~source.Value; %switch darkness value
    setappdata(I,'Dark',dark) %set map view to Robot's view/fullmap
    
    %update plot manually if robot isn't in navigation loop
    if ~getappdata(Robby,'Running')
        plot_map = dark*known_map(2:end-1,2:end-1) + ~dark*true_map;
        set(I,'cdata',plot_map) %change colors on known_map
    end
end

function dt(source,~) 
    %text box to change timestep of robot movement
    entry = source.String;
    [entry,suc] = str2num(entry); 
    if suc
        timestep = entry;
        setappdata(Robby,'TimeStep',timestep)
    else
        set(dt_box,'String',num2str(timestep))
    end
end

function toggle_maps(source,~)
%if map is chosen from drop-down menu, change map
    value = source.Value; %index of map
    old_value = value;
    check_clear_button()
    m = all_maps{value}; %current map (field)
    init(m)
end

function create(~,~)
%create new map manually
    size = popup_size;
    size(4) = popup_size(4)*4/3;
    
    %initialize the figure/gui window
    dim_fig = figure('Visible','off','Position',size,'Color',fig_color,...
        'menubar','none','CloseRequestFcn',@close_req);
    set(dim_fig,'name','Save As','numbertitle','off')
    movegui(dim_fig,'center')
    axis off

    %ui control for text box (enter dimensions)
    dim1_box = uicontrol('Style','edit','Position',[0.2,0.5,0.6,0.2],...
        'String',dim1_str,'KeyPressFcn',@set_dim);
    dim2_box = uicontrol('Style','edit','Position',[0.2,0.2,0.6,0.2],...
        'String',dim2_str,'KeyPressFcn',@set_dim);
    uicontrol('Style','text','Position',[0.02,0.7,0.7,0.2],...
        'BackgroundColor',fig_color,'String','Dimensions:');
    uicontrol(dim1_box) %put cursor in dim1 box

    dim_fig.Visible = 'on';
    set(all_handles,'Enable','off') %don't allow other interactions
end

function edit(~,~)  
    %new map starts out as current map (don't need to set as current map)
    nm = m; 
    go2editor()
end

%% UI Callbacks for Editor

function click(~,~)
%callback for clicking mouse (in editing interface)
    
    %find position that was clicked
    pos = get(gca,'CurrentPoint');
    click_pos = pos(1,1:2);
    
    %if add barriers toggle button is pressed
    addb = get(add_button,'Value');
    %if remove barriers toggle button is pressed
    removeb = get(remove_button,'Value'); 
    
    if addb || removeb %if adding/removing barriers
        
        clicked_barrier = 1; %clicked while add/remove barriers pressed
        p = round(click_pos); %map position to cell
        suc1 = in_map(click_pos); %check whether clicked on axes 
        
        if addb && suc1 && ~all(p==nm.start_pos) && ~all(p==nm.target_pos)
        %if adding barriers but not over start/target position
            new_bar = {p(1),p(2)}; %record new bar position
            %visualize change temporarily
            true_map(p(2),p(1)) = 2;
            set(I,'cdata',true_map)
            drawnow
        
        elseif removeb && suc1 && ~all(p==nm.start_pos) && ~all(p==nm.target_pos)
        %if removing barriers but not over start/target position
            bar = {p(1),p(2)}; %bar to be removed
            barriers = nm.barriers;
            rows = find_row(barriers,bar);
            for i = size(rows,2):-1:1
                barriers(rows(i),:) = [];
            end
            nm.barriers = barriers;
            init(nm)
        end
    else
    %find out whether Robby of target position were clicked
        
        %find position of start_pos and target_pos
        sp = nm.start_pos;
        tp = nm.target_pos; 
        
        %find if Robby was clicked
        clicked_Robby = click_pos(1) > sp(1)-0.5 && click_pos(1) < sp(1)+0.5...
            && click_pos(2) > sp(2)-0.5 && click_pos(2) < sp(2)+0.5;

        %find if target_pos was clicked
        clicked_targ = click_pos(1) > tp(1)-0.5 && click_pos(1) < tp(1)+0.5...
            && click_pos(2) > tp(2)-0.5 && click_pos(2) < tp(2)+0.5;
    end
end

function move(~,~)
%callback for moving mouse (in editing interface)
    
    %find position of cursor
    pos = get(gca,'CurrentPoint'); 
    curs_pos = pos(1,1:2);
    
    suc = in_map(curs_pos,nm.barriers); %determine whether mouse inside axes/over bars
    p = round(curs_pos); %map position to cell
    suc1 = in_map(curs_pos); %determine whether mouse inside axes
    
    if get(add_button,'Value') 
    %if add barriers toggle button is pressed
        if ~suc1 && ~clicked_barrier
        %clear 'cursor' with bar segment if cursor is no longer over map
                set(I,'cdata',true_map)
                drawnow
        elseif suc && ~all(p==nm.start_pos) && ~all(p==nm.target_pos)
        %if mouse over map but not over start/target position
            if ~clicked_barrier
            %add 'cursor' with a bar segment while mouse clicker is up 
                temp = true_map;
                temp(p(2),p(1)) = 2;
                set(I,'cdata',temp)
                drawnow
            else
            %if mouse clicker is down while adding barriers
                nb = {p(1),p(2)};
                if isempty(new_bar)
                %initialize new bar if not initialized during windowbuttondown
                    new_bar = nb; 
                else
                    if ~isequal(new_bar(end,:),nb) %if not last bar unit added 
                        new_bar = [new_bar;nb]; %add bar unit
                        %visualize change temporarily
                        true_map(p(2),p(1)) = 2;
                        set(I,'cdata',true_map)
                        drawnow
                    end
                end
            end
        end
    elseif get(remove_button,'Value')
    %if remove barriers toggle button is pressed
            if ~suc1 && ~clicked_barrier
            %clear 'cursor' with bar segment if cursor is no longer over map
                set(I,'cdata',true_map)
                drawnow
            elseif suc1 && ~suc && ~all(p==nm.start_pos) && ~all(p==nm.target_pos)
            %if mouse over barriers and on map but not over start/target position
                if ~clicked_barrier
                %add 'cursor' with a blank segment while mouse clicker is up 
                    temp = true_map;
                    temp(p(2),p(1)) = 5;
                    set(I,'cdata',temp)
                    drawnow   
                else
                %if mouse clicker is down while removing barriers
                    bar = {p(1),p(2)}; %bar to be removed
                    barriers = nm.barriers;
                    rows = find_row(barriers,bar);
                    for i = size(rows,2):-1:1
                        barriers(rows(i),:) = [];
                    end
                    nm.barriers = barriers;
                    init(nm)                    
                end
            end
    elseif clicked_Robby && suc %only if add/remove barriers not clicked
    %if clicking Robby 
        set(Robby,'xdata',[-0.5+p(1),0.5+p(1)],... 
            'ydata',[-0.5+p(2),0.5+p(2)]) 
        drawnow
    elseif clicked_targ && suc %only if add/remove barriers not clicked
    %if clicking target
        plot_map = true_map;
        plot_map(plot_map==3) = 5;
        plot_map(p(2),p(1)) = 3;
        set(I,'cdata',plot_map)
        drawnow
    end
end

function release(~,~)
%callback for releasing mouse (in editing interface)
    
    %find position where click was released
    new_pos = get(gca,'CurrentPoint'); 
    rel_pos = new_pos(1,1:2);
    
    if get(add_button,'Value')
    
        %add bars that were drawn to new map
        nm.barriers = [nm.barriers;new_bar];
        init(nm) %initialize visualization and maps
        clicked_barrier = 0; %mouse no longer clicked down
        new_bar = {}; %new empty set for barriers being drawn
        
    elseif get(remove_button,'Value')
        clicked_barrier = 0; %mouse no longer clicked down

    elseif clicked_targ || clicked_Robby
        
        %find if click released inside axes or over any barriers
        suc = in_map(rel_pos,nm.barriers);

        if clicked_targ
            if suc %if inside axes
                nm.target_pos = round(rel_pos); %initialize new target_pos
                init(nm) %initialize visualization and maps
            else %otherwise, replot target_pos
                set(I,'cdata',true_map)
            end
        else %if clicked_Robby
            if suc
                nm.start_pos = round(rel_pos); %initialize new start_pos
                init(nm) %initialize visualization and maps
            else %otherwise, replot Robby
                sp = nm.start_pos; %get old start_pos
                set(Robby,'xdata',[-0.5+sp(1),0.5+sp(1)],... 
                    'ydata',[-0.5+sp(2),0.5+sp(2)]) %plot Robby at start_pos
            end 
        end
        clicked_targ = 0; clicked_Robby = 0; %no longer clicking Robby/target
    end
end

function add_barriers(source,~)
    %set barrier button values
    unpress(remove_button) %remove_button can't be depressed at same time
    if source.Value %if button is turned on
        set(add_button,'BackgroundColor',depressed_color) 
    else %if button is turned off
        set(add_button,'BackgroundColor',ui_color)
    end    
end

function remove_barriers(source,~)
    %set barrier button values
    unpress(add_button) %add_button can't be depressed at same time
    if source.Value %if button is turned on
        set(remove_button,'BackgroundColor',depressed_color)
    else %if button is turned off
        set(remove_button,'BackgroundColor',ui_color)
    end    
end

function cancel(~,~)
    setappdata(I,'CurrentMap',m) %forget about nm (new map being created)
    go2runner()
end

function done(~,~)
    %finish editing/creating map (name and save map in drop-down menu)

    j = length(all_names) + 1; %map number

    %initialize the figure/gui window
    name_fig = figure('Visible','off','Position',popup_size,'Color',fig_color,...
        'menubar','none','CloseRequestFcn',@close_req);
    set(name_fig,'name','Save As','numbertitle','off')
    movegui(name_fig,'center')
    axis off

    %ui control for text box (enter name of map being saved)
    name_box = uicontrol('Style','edit','Position',[0.2,0.3,0.6,0.2],...
    'String',['Map ',num2str(j)],'Callback',{@name,name_fig});
    uicontrol('Style','text','Position',[0.2,0.6,0.3,0.2],...
        'BackgroundColor',fig_color,'String','Save as:');
    uicontrol(name_box) %place cursor in name_box

    %set current name to initial option of name if map already in drop-down
    for i = 1:length(all_maps) 
    %check whether each map is the same as the new map
        if isequal(all_maps{i},nm) 
            set(name_box,'String',all_names{i}) 
            j = i; %if they're the same, set the new value to that value
                       %(only official after finished naming map in @name)
            break
        end
    end
    name_fig.Visible = 'on'; %make figure visible;
    set(all_handles,'Enable','off') %don't allow other interactions
end

function clear(~,~)
    i = value; %current map number
    %delete map and set new map number as old value 
    all_names(i) = [];
    all_maps(i) = [];
    if old_value >= i; %if old_value > current value
        value = old_value - 1; %go to map number that is one less than current
    else
        value = old_value; %otherwise, go back to old value
    end
    drop_down.Value = value; %set value
    set(drop_down,'String',all_names) %set drop-down values

    m = all_maps{value}; %find old map in drop-down menu
    init(m); %initialize old visualization and maps
    old_value = value; %set new old_value as current value
    
    check_clear_button() %enable clear button accordingly (if not a default map)
end

%% UI Callbacks for Pop-Up Windows

function set_dim(~,event)
%KeyPressFcn for dim1_box and dim2_box, works with what has been entered
    if strcmp(event.Key,'return') %ONLY if return key has been pressed
        
        pause(0.1) %allow edit box time to register string
        
        %retrieve dimensions as strings
        dim1_str = get(dim1_box,'String');
        dim2_str = get(dim2_box,'String');
        
        %convert dimensions to numbers, if possible
        [dim1_num,suc1] = str2num(dim1_str);
        [dim2_num,suc2] = str2num(dim2_str);
        
        %if either dimension conversion unsuccessful
        if ~suc1 || ~suc2 
            if ~suc1
                set(dim2_box,'String',10) %reset dim1 as 10, don't close
                uicontrol(dim2_box)
            end
            if ~suc2
                set(dim1_box,'String',10) %reset dim2 as 10, don't close 
                uicontrol(dim1_box)
            end
        else
            close(gcf) %close dim_figure when successful
           
            %initialize new map information (field)
            nm.dim1 = dim1_num; 
            nm.dim2 = dim2_num;
  
            %initial guesses for location of start/target positions
            nm.start_pos = [1,1];
            nm.target_pos = [dim1_num,dim2_num];
            nm.barriers = {};
            setappdata(I,'CurrentMap',nm) %set as current map
           
            %initialize visualization of editor, showing full map view 
                %(only start_pos and target_pos)
            go2editor()
        end 
    end
end

function name(source,~,name_fig)
%function called by done button uicallback when name for map is entered
%into text box in popup window
    
    %make nm the new current map, m
    setappdata(I,'CurrentMap',nm)
    m = nm;

    %go back to running window, with new plot initialized
    go2runner()
        
    %index name into drop-down
    m_name = source.String;
    delete(name_fig)
    all_maps{j} = nm;
    all_names{j} = m_name;
    set(drop_down,'String',all_names)
    drop_down.Value = j; %view that new map number
    value = j; %set j as new view
     
    %allow UI buttons to be pushed
    set(all_handles,'Enable','on')
    check_clear_button() %enable clear button according to value
end   

%% Helper Functions

function suc = in_map(pos,varargin)
%find if mouse position is inside axes and (optional) not over any barriers
    pos = pos - 0.5; %reallign axes points with plot points
%find whether mouse position (pos) is inside axes
    suc = (pos(1) > 0) && (pos(1) < nm.dim1)...
        && (pos(2) > 0) && (pos(2) < nm.dim2);
    if nargin == 2
    %find whether mouse position is over any barriers
        bars = varargin{1}; total_bars = size(bars,1);
        pass = zeros(1,total_bars); %1 or 0 for each barrier in 'bars'         
        for n = 1:total_bars %for each barrier
            b = bars(n,:); %1x2 cell of 1 barrier
            pass(n) = ~((pos(1) > min(b{1})-1) && (pos(1) < max(b{1})))...
                || ~((pos(2) > min(b{2})-1) && (pos(2) < max(b{2})));
        end
    %success if mouse isn't over any barrier and is over map
    suc = all(pass)*suc; 
    end
end

function go2editor() %switch from runner to editor window
    new_bar = {}; %set new bar to be added to map as empty cell
    %change button from reset to start if necessary
    set(start_button,'String','Start','Callback',@release_robot)
    %change visibility of uicontrols
    [true_map,known_map] = runner2editor(running_handles,...
        editing_handles,I,Robby,radio_button);
    %activate mouse callbacks
    set(fig,'WindowButtonMotionFcn',@move,...
        'WindowButtonDownFcn',@click,'WindowButtonUpFcn',@release)
end

function go2runner() %switch from editor to runner window
    %reset all initializing variables for editor
    clicked_Robby = 0;
    clicked_targ = 0;
    clicked_barrier = 0;
    unpress(remove_button)
    unpress(add_button)
    new_bar = {};
    
    %change button from reset to start if necessary
    set(start_button,'String','Start','Callback',@release_robot)
    %change visbibility of uicontrols
    [true_map,known_map] = editor2runner(editing_handles,...
        running_handles,I,Robby,radio_button,dark);
    %deactivate mouse callbacks
    set(fig,'WindowButtonMotionFcn',[],...
        'WindowButtonDownFcn',[],'WindowButtonUpFcn',[])
end

function init(m)
    %change button from reset to start if necessary
    set(start_button,'String','Start','Callback',@release_robot)
    %set given map to appdata and initialize plot
    setappdata(I,'CurrentMap',m)
    [true_map,known_map] = initialize_plot(I,Robby);
end

function unpress(button_handle)
    %unpress a toggle button (add_barriers or remove_barriers)
    set(button_handle,'Value',0)
    set(button_handle,'BackgroundColor',ui_color)
end

function check_clear_button()
    %check whether clear button should be enabled, and act accordingly
    if value <= n_default %if currently viewing default map
        set(clear_button,'Enable','off') %disable clear button
    else
        set(clear_button,'Enable','on') %otherwise, enable clear button
    end
end

function close_req(source,~)
%close request for popup windows
    delete(source) %delete popup window
    %enable all handles if main window if still open
    if all(ishandle(all_handles)) 
        set(all_handles,'Enable','on')
        check_clear_button() %enable clear button accordingly
    end
end

function close_main(source,~)
%close request for main figure window
    %save maps and current map number (map that was viewed last)
    save(save_name,'all_maps','all_names','value') 
    delete(source) 
end

end
