classdef WidgetNeuroTree < handle
    %
    % WidgetNeuroTree
    %
    % GUI Widget for 
    % user guided neuro tree segmentation
    % exporting/loading and modifying segmented ROIs
    % automatic linking of parent/child hierarchy
    % creating a ROI labeled mask
    %
    % requires:
    %    class NeuroTreeBranch
    %    readLSMInfo.m
    %    readLSMImage.m
    %    uiGridLayout.m
    %
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties
        path
        name
        
        image
        mask
        tree
        
        width
        height
        
    end
    
    properties (Access = public, Hidden = true)
        
        %%% --- image figure handlers --- %%%
        ih_figure
        ih_axes
        ih_image
        
    end
    
    properties (Access = private, Hidden = true)
        
        %%% --- State Machine --- %%%
        state
        key
        click
        dilate
        indexBranch
        indexNode
        
        %%% --- UI components --- %%%
        ui_parent
        ui_panel
        
        ui_pushButton_SegmentTree
        ui_pushButton_SaveTree
        ui_pushButton_LoadTree
        ui_pushButton_LinkTree
        ui_pushButton_ViewMask
        ui_pushButton_DownMask
        ui_pushButton_UpMask
        
        ui_text_StatusBranch
        ui_text_StatusNode
        ui_text_StatusDepth
        ui_text_StatusLength
        ui_text_StatusDilate
        ui_text_StatusLinked
        
    end
    
    properties (Constant, Hidden)
        
        %%% --- UI properties --- %%%
        GUI_WINDOW_POSITION = [0, 0.455, 0.15, 0.40];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY
        GRID_MARGIN_H = 0.015;
        GRID_MARGIN_W = 0.015;
        FONT_SIZE = 8;
        
        %%% --- Tree Settings --- %%%
        MIN_DILATE_SIZE = 1;
        MAX_DILATE_SIZE = 30;
        
        %%% --- State --- %%%
        STATE_IDLE = 0;
        STATE_OVER_BRANCH = 1;
        STATE_OVER_NODE = 2;
        STATE_DRAWING = 3;
        STATE_REPOSITION_BRANCH = 4;
        STATE_REPOSITION_NODE = 5;
        STATE_SELECTED_BRANCH = 6;
        
    end
    
    events (NotifyAccess = private, ListenAccess = private)
        
        %%% --- Events --- %%%
        EVENT_KEY_DIGIT
        EVENT_KEY_DEL
        EVENT_CLICK_DOWN
        EVENT_CLICK_UP
        EVENT_CLICK_DOUBLE
        EVENT_OVER_BRANCH
        EVENT_OVER_NODE
        EVENT_MOVE_MOUSE
        
    end
    
    methods
        
        % method :: WidgetNeuroTree
        %  input :: varargin
        % action :: class constructor
        function obj = WidgetNeuroTree(varargin)
            
            % use parser
            parserObj = inputParser;
            
            % define inputs
            addParameter(parserObj, 'Parent', [], @isgraphics);
            
            % parse varargin
            parse(parserObj, varargin{:});
            
            % set UI parent
            if isempty(parserObj.Results.Parent)
                obj.ui_parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hDrawNeuroTreeUI',...
                    'Name', 'Draw Neuro Tree',...
                    'NumberTitle', 'off',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'Color', obj.BACKGROUND_COLOR,...
                    'Units', 'normalized', ...
                    'Position', obj.GUI_WINDOW_POSITION,...
                    'CloseRequestFcn', @obj.fcnCallback_CloseUIWindow);
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            
            % set defaults
            obj.state = obj.STATE_IDLE;
            obj.key = [];
            obj.click = [];
            obj.dilate = 5;
            obj.indexBranch = 0;
            obj.indexNode = 0;
            
            % render UI
            obj.renderUI();
            
            % add event listeners
            obj.addListeners();
            
        end
        
        % method :: renderUI
        %  input :: class object
        % action :: render user interface
        function obj = renderUI(obj)
            
            hPanel = uipanel(...
                'Parent', obj.ui_parent,...
                'BorderType', 'none',...
                'BackgroundColor', obj.getParentColor(),...
                'Units', 'normalized',...
                'Position', [0, 0, 1, 1]);
            
            obj.ui_text_StatusBranch = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'branch 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,3],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         1, 1));
            
            obj.ui_text_StatusNode = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'node 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,3],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 1));
            
            obj.ui_text_StatusDepth = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'depth 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,3],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         1, 2));
            
            obj.ui_text_StatusLinked = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'linked false',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,3],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 2));                         
                                     
            obj.ui_text_StatusLength = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'length[px] 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,3],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         1, 3));
            
            obj.ui_text_StatusDilate = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'dilate[px] 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,3],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 3));
            
            
                                     
            obj.ui_pushButton_SegmentTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Segment',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_SegmentTree,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 1));
                                     
            obj.ui_pushButton_SaveTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Save Tree',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_SaveTree,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         3, 1));
            
            obj.ui_pushButton_LoadTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Load Tree',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_LoadTree,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 1));                         
                                     
            obj.ui_pushButton_LinkTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Link Tree',...
                'Enable', 'off',...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 2));
            
           obj.ui_pushButton_ViewMask = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Show Mask',...
                'Enable', 'off',...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         3, 2));
                                     
           obj.ui_pushButton_DownMask = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', '<<',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_SetMaskSize,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,4],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 3));
            
           obj.ui_pushButton_UpMask = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', '>>',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_SetMaskSize,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,4],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 4));
          
        end
        
        
        % method :: getParentColor
        %  input :: class object
        % action :: returns value of Parent Color/BackgroundColor property
        function value = getParentColor(obj)
            if isgraphics(obj.ui_parent, 'figure')
                value = get(obj.ui_parent, 'Color');
            elseif isgraphics(obj.ui_parent, 'uipanel')
                value = get(obj.ui_parent, 'BackgroundColor');
            end
        end
        
        % mehtod :: unlockUI
        %  input :: class object
        % action :: unlocks user interface
        function obj = unlockUI(obj)
            set(obj.ui_pushButton_SegmentTree, 'Enable', 'on');
        end
        
        
        % method :: setFigureCallbacks
        %  input :: class object, setState
        % action :: switch on/off figure callbacks
        function obj = setFigureCallbacks(obj, setState)
            
            switch setState
                
                case 'on'
                    
                    set(obj.ih_figure,...
                        'WindowButtonMotionFcn', @obj.fcnCallback_MoveMouse,...
                        'WindowButtonDownFcn', @obj.fcnCallback_ClickDown,...
                        'WindowButtonUpFcn', @obj.fcnCallback_ClickUp,...
                        'WindowKeyPressFcn', @obj.fcnCallback_PressKey);
                    
                case 'off'
                    
                    set(obj.ih_figure,...
                        'WindowButtonMotionFcn', [],...
                        'WindowButtonDownFcn', [],...
                        'WindowButtonUpFcn', [],...
                        'WindowKeyPressFcn', []);
                    
            end
            
        end
        
        
        % method :: segmentTree
        %  input :: class object
        % action :: setting current figure callbacks
        function obj = segmentTree(obj)
            
           % set callback functions
           obj.setFigureCallbacks('on');
           
           % read image
           obj.image = obj.ih_image.CData;
           obj.width = size(obj.image, 2);
           obj.height = size(obj.image, 1);
            
        end
        
        
        % method :: clearTree
        %  input :: class object
        % action :: clear current tree and figure callbacks
        function obj = clearTree(obj)
            
            % remove callback functions
            obj.setFigureCallbacks('off');
            
        end
        
        
        % method :: enableButtonGroup
        %  input :: class object, enable
        % action :: change operational state of button group
        function obj = enableButtonGroup(obj, enable)
            buttonGroup = cat(1,...
                obj.ui_pushButton_SaveTree,...
                obj.ui_pushButton_LoadTree,...
                obj.ui_pushButton_LinkTree,...
                obj.ui_pushButton_ViewMask,...
                obj.ui_pushButton_DownMask,...
                obj.ui_pushButton_UpMask);
            
            set(buttonGroup, 'Enable', enable);
        end
        
        
        %%% ----------------------------- %%%
        %%% --- UI CALLBACK FUNCTIONS --- %%%
        %%% ----------------------------- %%%
        
        % callback :: CloseUIWindow
        %    event :: on close request
        %   action :: class destructor
        function obj = fcnCallback_CloseUIWindow(obj, ~, ~)
            
            if isgraphics(obj.ui_parent)
                delete(obj.ui_parent);
            end
            
            delete(obj);
        end
        
        
        % callback :: SegmentTree
        %    event :: on segment button
        %   action :: initialize segmentation with current image
        function obj = fcnCallback_SegmentTree(obj, ~, ~)
            
            switch obj.ui_pushButton_SegmentTree.String
                
                case 'Segment'
                    set(obj.ui_pushButton_SegmentTree, 'String', 'Clear');
                    obj.enableButtonGroup('on');
                    obj.segmentTree();
                    
                case 'Clear'
                    set(obj.ui_pushButton_SegmentTree, 'String', 'Segment');
                    obj.enableButtonGroup('off');
                    obj.clearTree();
                    
            end
            
        end
        
        % callback :: SaveTree
        %    event :: on save tree button
        %   action :: exports current tree in txt format
        function obj = fcnCallback_SaveTree(obj, ~, ~)
            obj.saveTree();
        end

        
        % callback :: LoadTree
        %    event :: on load tree button
        %   action :: load exported neuro tree
        function obj = fcnCallback_LoadTree(obj, ~, ~)
            obj.loadTree();
        end
        
        % callback :: SetMaskSize
        %    event :: on mask Up/Down buttons
        %   action :: adjust mask size
        function obj = fcnCallback_SetMaskSize(obj, hSrc, ~)
            
            % update mask size
            switch hSrc
                case obj.ui_pushButton_DownMask
                    obj.dilate = obj.dilate - 1;
                case obj.ui_pushButton_UpMask
                    obj.dilate = obj.dilate + 1;
            end
            
            % set minimum size
            if (obj.dilate < obj.MIN_DILATE_SIZE + 1)
                set(obj.ui_pushButton_DownMask, 'Enable', 'off');
            else
                set(obj.ui_pushButton_DownMask, 'Enable', 'on');
            end
            
            % set maximum size
            if (obj.dilate > obj.MAX_DILATE_SIZE - 1)
                set(obj.ui_pushButton_UpMask, 'Enable', 'off');
            else
                set(obj.ui_pushButton_UpMask, 'Enable', 'on');
            end
            
            % update status
            set(obj.ui_text_StatusDilate, 'String', sprintf('dilate[px] %d',obj.dilate));
            
        end
        
        
        %%% ---------------------------------- %%%
        %%% --- DRAWING CALLBACK FUNCTIONS --- %%%
        %%% ---------------------------------- %%%
        
        % callback :: PressKey
        %    event :: on keyboard button press
        %   action :: read button id
        function obj = fcnCallback_PressKey(obj, ~, ~)
            
            % get current key pressed
            obj.key = get(obj.ih_figure, 'CurrentCharacter');
            
            % check to fire event
            if (obj.key >= '0') && (obj.key <= '9')
                
                notify(obj, 'EVENT_KEY_DIGIT');
                
            elseif uint8(obj.key) == 8 %(DEL)
                
                notify(obj, 'EVENT_KEY_DEL');
                
            end
            
        end
        
        % callback :: MoveMouse
        %    event :: on mouse move
        %   action :: track mouse position
        function obj = fcnCallback_MoveMouse(obj, ~, ~)
            
            % get current click position
            obj.click = obj.getClick();
            
            % check if over branch
            if obj.isOverBranch()
                
                notify(obj, 'EVENT_OVER_BRANCH');
                
            elseif obj.isOverNode()
                
                notify(obj, 'EVENT_OVER_NODE');
                
            else
                
                notify(obj, 'EVENT_MOVE_MOUSE');
                
            end
            
            % add granularity
            drawnow limitrate;
            
        end
        
        % callback :: ClickDown
        %    event :: on mouse click down
        %   action :: get mouse click position
        function obj = fcnCallback_ClickDown(obj, ~, ~)
            
            % get current click position
            obj.click = obj.getClick();
            
            % get mouse selection
            clickSelection = get(obj.ih_figure, 'SelectionType');
            
            if strcmp(clickSelection, 'normal')
                
                notify(obj, 'EVENT_CLICK_DOWN');
                
            elseif strcmp(clickSelection, 'open')
                
                notify(obj, 'EVENT_DOUBLE_CLICK');
                
            end
        end
        
        % callback :: ClickUp
        %    event :: on mouse click up
        %   action :: get mouse release position
        function obj = fcnCallback_ClickUp(obj, ~, ~)
            
            % get current click position
            obj.click = obj.getClick();
            
            notify(obj, 'EVENT_CLICK_UP');
            
        end
        
        
        %%% -------------------------------- %%%
        %%% --- EVENTS RESPOND FUNCTIONS --- %%%
        %%% -------------------------------- %%%
        
        % respond :: KeyDigit
        %   event :: EVENT_KEY_DIGIT
        %  action :: update states
        function obj = fcnRespond_KeyDigit(obj, ~, ~)
            
            if obj.state == obj.STATE_IDLE
                
                obj.createBranch();
                
                obj.state = obj.STATE_DRAWING;
                
            end
            
        end
            
        % respond :: KeyDel
        %   event :: EVENT_KEY_DEL
        %  action :: update states
        function obj = fcnRespond_KeyDel(obj, ~, ~)
            
            if obj.state == obj.STATE_DRAWING
                
                obj.deleteNode();
                
                if obj.indexNode > 1
                    obj.state = obj.STATE_DRAWING;
                else
                    obj.state = obj.STATE_IDLE;
                end
                
            elseif obj.state == obj.STATE_SELECTED_BRANCH
                
                obj.deleteBranch();
                
                obj.state = obj.STATE_IDLE;
                
            end
            
        end
        
        % respond :: ClickDown
        %   event :: EVENT_CLICK_DOWN
        %  action :: update states
        function obj = fcnRespond_ClickDown(obj, ~, ~)
            
            if obj.state == obj.STATE_DRAWING
                
                obj.addNode();
                
                obj.state = obj.STATE_DRAWING;
                
            elseif obj.state == obj.STATE_OVER_BRANCH
                
                obj.pickUpBranch();
                
                obj.state = obj.STATE_REPOSITION_BRANCH;
                
            elseif obj.state == obj.STATE_OVER_NODE
                
                obj.pickUpNode();
                
                obj.state = obj.STATE_REPOSITION_NODE;
                
            end
            
        end
        
        % respond :: ClickUp
        %   event :: EVENT_CLICK_UP
        %  action :: update states
        function obj = fcnRespond_ClickUp(obj, ~, ~)
            
            if obj.state == obj.STATE_REPOSITION_BRANCH
                
                obj.putDownBranch();
                
                obj.state = obj.STATE_IDLE;
                
            elseif obj.state == obj.STATE_REPOSITION_NODE
                
                obj.putDownNode();
                
                obj.state = obj.STATE_IDLE;
                
            end
            
        end
        
        % respond :: ClickDouble
        %   event :: EVENT_CLICK_DOUBLE
        %  action :: update states
        function obj = fcnRespond_ClickDouble(obj, ~, ~)
            
            if obj.state == obj.STATE_DRAWING
                
                obj.completeBranch();
                
                obj.state = obj.STATE_IDLE;
                
            elseif obj.state == obj.STATE_OVER_BRANCH
                
                obj.selectBranch();
                
                obj.state = obj.STATE_SELECTED_BRANCH;
                
            end
            
        end
        
        % respond :: OverBranch
        %   event :: EVENT_OVER_BRANCH
        %  action :: update states
        function obj = fcnRespond_OverBranch(obj, ~, ~)
            
            if obj.state == obj.STATE_IDLE
                
                obj.state = obj.STATE_OVER_BRANCH;
                
            end
            
        end
        
        % respond :: OverNode
        %   event :: EVENT_OVER_NODE
        %  action :: update states
        function obj = fcnRespond_OverNode(obj, ~, ~)
            
            if obj.state == obj.STATE_IDLE
                
                obj.state = obj.STATE_OVER_NODE;
                
            end
            
        end
        
        % respond :: MouseMove
        %   event :: EVENT_MOUSE_MOVE
        %  action :: update states
        function obj = fcnRespond_MouseMove(obj, ~, ~)
            
            if obj.state == obj.STATE_DRAWING
                
                obj.extendBranch();
                
                obj.state = obj.STATE_DRAWING;
                
            elseif obj.state == obj.STATE_REPOSITION_BRANCH
                
                obj.moveBranch();
                
                obj.state = obj.STATE_REPOSITION_BRANCH;
                
            elseif obj.state == obj.STATE_REPOSITION_NODE
                
                obj.moveNode();
                
                obj.state = obj.STATE_REPOSITION_NODE;
                
            elseif obj.state == obj.STATE_OVER_BRANCH
                
                obj.state = obj.STATE_IDLE;
                
            elseif obj.state == obj.STATE_OVER_NODE
                
                obj.state = obj.STATE_IDLE;
                
            end
            
        end
        
        %%% ----------------------------- %%%
        %%% --- STATE MACHINE METHODS --- %%%
        %%% ----------------------------- %%%
        
        % mathod :: addListeners
        %  input :: class object
        % action :: add listeners for State Machine events
        function obj = addListeners(obj)
            addlistener(obj, 'EVENT_KEY_DIGIT', @fcnRespond_KeyDigit);
            addlistener(obj, 'EVENT_KEY_DEL', @fcnRespond_KeyDel);
            addlistener(obj, 'EVENT_CLICK_DOWN', @fcnRespond_ClickDown);
            addlistener(obj, 'EVENT_CLICK_UP', @fcnRespond_ClickUp);
            addlistener(obj, 'EVENT_CLICK_DOUBLE', @fcnRespond_ClickDouble);
            addlistener(obj, 'EVENT_OVER_BRANCH', @fcnRespond_OverBranch);
            addlistener(obj, 'EVENT_OVER_NODE', @fcnRespond_OverNode);
            addlistener(obj, 'EVENT_MOVE_MOUSE', @fcnRespond_MouseMove);
        end
        
        % method :: getClick
        %  input :: class object
        % action :: get current point
        function clickPoint = getClick(obj)
            
            % read click point
            clickPoint = get(obj.ih_axes, 'CurrentPoint');
            clickPoint = round(clickPoint(1, 1:2));
            
            % check minimum
            clickPoint(clickPoint < 1) = 1;
            
            % check maximum width
            if clickPoint(1) > obj.width
                clickPoint(1) = obj.width;
            end
            
            % check maximum height
            if clickPoint(2) > obj.height;
                clickPoint(2) = obj.height;
            end
            
        end
        
        % method :: isOverBranch
        %  input :: class object
        % action :: returns true if mouse over branch
        function value = isOverBranch(obj)
            value = false;
        end
        
        % method :: isOverNode
        %  input :: class object
        % action :: retunrs true if mouse over node
        function value = isOverNode(obj)
            value = false;
        end
        
        % method :: createBranch
        %  input :: class object
        % action :: creates new branch
        function obj = createBranch(obj)
        end
        
        % method :: deleteBranch
        %  input :: class object
        % action :: deletes branch
        function obj = deleteBranch(obj)
        end
        
        % method :: deleteNode
        %  input :: class object
        % action :: deletes node in current branch
        function obj = deleteNode(obj)
        end
        
        % method :: addNode
        %  input :: class object
        % action :: add new node to curren branch
        function obj = addNode(obj)
        end
        
        % method :: pickUpBranch
        %  input :: class object
        % action :: picks up branch to move
        function obj = pickUpBranch(obj)
        end
        
        % method :: pickUpNode
        %  input :: class object
        % action :: picks up node to move
        function obj = pickUpNode(obj)
        end
        
        % method :: putDownBranch
        %  input :: class object
        % action :: release branch after move
        function obj = putDownBranch(obj)
        end
        
        % method :: putDownNode
        %  input :: class object
        % action :: release node after move
        function obj = putDownNode(obj)
        end
        
        % method :: completeBranch
        %  input :: class object
        % action :: release branch after move
        function obj = completeBranch(obj)
        end
        
        % method :: selectBranch
        %  input :: class object
        % action :: select branch
        function obj = selectBranch(obj)
        end
        
        % method :: extendBranch
        %  input :: class object
        % action :: extend branch without adding node
        function obj = extendBranch(obj)
        end
        
        % method :: moveBranch
        %  input :: class object
        % action :: shift branch position
        function obj = moveBranch(obj)
        end
        
        % method :: moveNode
        %  input :: class object
        % action :: shift node position
        function obj = moveNode(obj)
        end
        
    end
    
end
