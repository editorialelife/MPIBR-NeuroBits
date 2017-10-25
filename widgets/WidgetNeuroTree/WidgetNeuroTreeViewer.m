classdef WidgetNeuroTreeViewer < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        
        click_down
        click_up
        click_double
        move_mouse
        press_key
        hover_handle
        
        handle_figure
        handle_axes
        handle_image
        
    end
    
    properties (Access = private, Constant = true, Hidden = true)
        
        VIEWER_AXES_PADDING = 5
        
    end
    
    events
        
        event_clickDown
        event_clickUp
        event_clickDouble
        event_moveMouse
        event_pressDigit
        event_pressDel
        event_pressEsc
        event_hoverIdle
        event_hoverLine
        event_hoverPoint
        
    end
    
    methods
        
        function obj = WidgetNeuroTreeViewer(varargin)
            
            %%% parse figure parent
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], ...
                @(varhandle) isgraphics(varhandle, 'figure'));
            parse(parserObj, varargin{:});
            
            %%% assign figure
            obj.handle_figure = parserObj.Results.Parent;
            if isempty(obj.handle_figure)
                
                screenSize = get(0, 'ScreenSize');
                screenSize = floor(0.8 * min(screenSize(3:4)));
                
                obj.handle_figure = figure(...
                        'Visible', 'on',...
                        'Tag', 'hViewerFigureHandle',...
                        'Name', '',...
                        'MenuBar', 'none',...
                        'ToolBar', 'none',...
                        'NumberTitle', 'off',...
                        'Position', [1, 1, screenSize + obj.VIEWER_AXES_PADDING, screenSize + obj.VIEWER_AXES_PADDING]);
                movegui(obj.handle_figure, 'north');
                
                handle_layout = uiextras.HBoxFlex(...
                        'Parent', obj.handle_figure,...
                        'Padding', obj.VIEWER_AXES_PADDING);

                obj.handle_axes = axes(...
                        'Parent', handle_layout,...
                        'ActivePositionProperty', 'position',...
                        'XTick', [],...
                        'YTick', [],...
                        'XColor', 'none',...
                        'YColor', 'none');

                obj.handle_image = imshow(...
                        zeros(screenSize, screenSize, 'uint8'),...
                        [],...
                        'Parent', obj.handle_axes,...
                        'XData', [0, 1],...
                        'YData', [0, 1]);
                
            else
                
                handle_list = findall(obj.handle_figure);
                obj.handle_axes = handle_list(isgraphics(handle_list, 'axes'));
                obj.handle_image = handle_list(isgraphics(handle_list, 'image'));
                
            end
            
            %%% initialize callbacks
            obj.uicallbacks();
            
        end
        
        function obj = uicallbacks(obj)
            
            set(obj.handle_figure,...
                'WindowButtonMotionFcn', @obj.fcnCallback_moveMouse,...
                'WindowButtonDownFcn', @obj.fcnCallback_clickDown,...
                'WindowButtonUpFcn', @obj.fcnCallback_clickUp,...
                'WindowKeyPressFcn', @obj.fcnCallback_pressKey);
            
        end
        
    end
    
    %% --- UI Callbacks --- %%
    methods
        
        function varpoint = click(obj)
            
            varpoint = get(obj.handle_axes, 'CurrentPoint');
            varpoint = varpoint(1, 1:2);
            
        end
        
        function varkey = press(obj)
            
            varkey = get(obj.handle_figure, 'CurrentCharacter');
            if isempty(varkey)
                varkey = 0;
            end
            
        end
        
        
        function obj = fcnCallback_moveMouse(obj, ~, ~)
            
            %%% return current move position
            obj.move_mouse = obj.click();
            notify(obj, 'event_moveMouse');
            
            %%% set hover handle
            obj.hover_handle = hittest(obj.handle_figure);
            
            %%% check type of handle
            if isgraphics(obj.hover_handle, 'line')
                
                % devide between line and point
                if obj.hover_handle.LineStyle(1) == 'n' % line style property is none for point
                    notify(obj, 'event_hoverPoint');
                    
                elseif obj.hover_handle.LineStyle(1) == '-' % line style property is '-' for line
                    notify(obj, 'event_hoverLine');
                    
                end
            else
                
                notify(obj, 'event_hoverIdle');
                
            end
            
        end
        
        function obj = fcnCallback_clickDown(obj, ~, ~)
            
            obj.click_down = obj.click();
            
            clickSelection = get(obj.handle_figure, 'Selection');
            if strcmp(clickSelection, 'normal')
                
                notify(obj, 'event_clickDown');
                
            elseif strcmp(clickSelection, 'open')
                
                notify(obj, 'event_clickDouble');
                
            end
            
            
        end
        
        function obj = fcnCallback_clickUp(obj, ~, ~)
            
            obj.click_up = obj.click();
            notify(obj, 'event_clickUp');
            
        end
        
        function obj = fcnCallback_pressKey(obj, ~, ~)
            
            obj.press_key = obj.press();
            
            if (obj.press_key >= '0') && (obj.press_key <= '9')
                
                notify(obj, 'event_pressDigit');
                
            elseif uint8(obj.press_key) == 8 %(DEL)
                
                notify(obj, 'event_pressDel');
                
            elseif uint8(obj.press_key) == 27 %(ESC)
                
                notify(obj, 'event_pressEsc');
                
            end
            
        end
        
    end
    
    %% --- external request --- %%
    methods
        
        function obj = changeMousePointer(obj, vartype)
            
            set(obj.handle_figure, 'Pointer', vartype);
            
        end
    end
    
end

