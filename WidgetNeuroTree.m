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
        patch
        tree
        
        width
        height
        
    end
    
    properties (Access = public, Hidden = true)
        
        %%% --- image figure handlers --- %%%
        ih_figure
        ih_axes
        ih_image
        ih_patch
        
    end
    
    properties (Access = private, Hidden = true)
        
        %%% --- State Machine --- %%%
        state
        key
        click
        dilate
        linked
        indexBranch
        indexNode
        
        %%% --- Edint components --- %%%
        edit_click
        edit_indexBranch
        edit_indexNode
        edit_handle
        
        %%% --- UI components --- %%%
        ui_parent
        ui_panel
        
        ui_pushButton_SegmentTree
        ui_pushButton_SaveTree
        ui_pushButton_LoadTree
        ui_pushButton_LinkTree
        
        ui_text_StatusBranch
        ui_text_StatusNode
        ui_text_StatusDepth
        ui_text_StatusSpan
        
        ui_text_DilationHeader
        ui_edit_DilationSize
        ui_checkBox_ViewMask
        
    end
    
    properties (Constant, Hidden)
        
        %%% --- UI properties --- %%%
        GUI_WINDOW_POSITION = [0, 0.455, 0.15, 0.40];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY
        GRID_MARGIN_H = 0.015;
        GRID_MARGIN_W = 0.015;
        FONT_SIZE = 8;
        PATCH_ALPHA_OFF = 0;
        PATCH_ALPHA_ON = 0.2;
        
        %%% --- Tree Settings --- %%%
        MIN_DILATE_SIZE = 10;
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
            
            % set default properties
            obj.setDefaultProperties();
            
            % render UI
            obj.renderUI();
            
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
            
            %%% --- render pushButtons --- %%% 
            obj.ui_pushButton_SegmentTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Segment',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_SegmentTree,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         1, 1));
                                     
            obj.ui_pushButton_SaveTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Save Tree',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_SaveTree,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 1));
            
            obj.ui_pushButton_LoadTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Load Tree',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_LoadTree,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         3, 1));                         
                                     
            obj.ui_pushButton_LinkTree = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Link 0 / 0',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_LinkTree,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 1));
            
            
            %%% --- render status information --- %%%
            obj.ui_text_StatusBranch = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'branch 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         1, 2));
            
            obj.ui_text_StatusNode = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'node 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 2));
            
            obj.ui_text_StatusDepth = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'depth 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         3, 2));
            
            obj.ui_text_StatusSpan = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'span[px] 0',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([8,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 2));
                                    
            %%% --- mask properties --- %%%
            obj.ui_checkBox_ViewMask = uicontrol(...
                'Parent', hPanel,...
                'Style', 'CheckBox',...
                'String', 'view mask',...
                'Value', 0,...
                'Enable', 'off',...
                'BackgroundColor', obj.getParentColor(),...
                'FontSize', obj.FONT_SIZE,...
                'Callback', @obj.fcnCallback_ViewMask,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         3, 2));
            
            obj.ui_text_DilationHeader = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'dilation size [px]',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,4],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 3));
                                     
            obj.ui_edit_DilationSize = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Edit',...
                'String', '21',...
                'Enable', 'off',...
                'BackgroundColor', obj.getParentColor(),...
                'FontSize', obj.FONT_SIZE,...
                'Callback', @obj.fcnCallback_DilationSize,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,4],...
                                         [obj.GRID_MARGIN_H *5, obj.GRID_MARGIN_W *5],...
                                         4, 4));
            
        end
        
        % method :: setDefaultProperties
        %  input :: class object
        % action :: set hidden properties default values
        function obj = setDefaultProperties(obj)
            
            % set defaults
            obj.tree = [];
            obj.state = obj.STATE_IDLE;
            obj.key = [];
            obj.click = [];
            obj.dilate = 21;
            obj.linked = 0;
            obj.indexBranch = 0;
            obj.indexNode = 0;
            obj.mask = zeros(obj.height, obj.width);
            obj.patch = zeros(obj.height, obj.width, 3, 'like', obj.image);
            
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
           
           % create empty mask
           obj.mask = zeros(obj.height, obj.width);
           
           % create patch
           obj.patch = zeros(obj.height, obj.width, 3, 'like', obj.image);
           hold(obj.ih_axes, 'on');
           obj.ih_patch = imshow(obj.patch, [],...
                                 'Border', 'tight',...
                                 'InitialMagnification', 'fit',...
                                 'Parent', obj.ih_axes);
           set(obj.ih_patch, 'AlphaData', obj.PATCH_ALPHA_OFF);                  
           hold(obj.ih_axes, 'off');
           
           % set current figure
           figure(obj.ih_figure);
           
        end
        
        % method :: saveTree
        %  input :: class object
        % action :: saves current tree to file
        function obj = saveTree(obj)
            
            % create output file
            fileOut = [obj.path,...
                       filesep,...
                       obj.name,...
                       '_neuroTree_',...
                       datestr(now,'ddmmmyyyy'),...
                       '.txt'];
           fpWrite = fopen(fileOut, 'w');
           
           % loop over each branch
           treeSize = size(obj.tree, 1);
           for b = 1 : treeSize
               obj.tree(b).exportBranch(fpWrite);
           end
           fclose(fpWrite);
            
        end
        
        % method :: loadTree
        %  input :: class object
        % action :: load current tree from file
        function obj = loadTree(obj)
            
            % get tree file
            [name, path] = uigetfile('*_neuroTree_*.txt', 'Pick Neuro Tree Branch file');
            
            % open file to read
            fileIn = [path, filesep, name];
            fpRead = fopen(fileIn, 'r');
            txt = textscan(fpRead, '%s', 'delimiter', '\t');
            fclose(fpRead);
            txt = txt{:};
            
            % find branch index
            branchDataIndex = strncmp(txt, '[', 1);
            branchDataIndex = cumsum(branchDataIndex);
            for b = 1 : branchDataIndex(end)
                
                % branch data
                branchData = txt(branchDataIndex == b);
                
                % parse branch info
                
            end
            
        end
        
        
        % method :: linkTree
        %  input :: class object
        % action :: automatic linking of branch hierarchy
        function obj = linkTree(obj)
            
            % get ree size
            treeSize = length(obj.tree);
                
            % count nodes per branch
            countNodesPerBranch = zeros(treeSize, 1);
            for b = 1 : treeSize
            	countNodesPerBranch(b) = size(obj.tree(b).nodes, 1);
            end
                
            % build branch index per node
            indexBranchPerNode = zeros(sum(countNodesPerBranch), 1);
            indexBranchPerNode(cumsum([1;countNodesPerBranch(1:end-1)])) = 1;
            indexBranchPerNode = cumsum(indexBranchPerNode);
                
            % build node list
            listNodes = cat(1, obj.tree.nodes);
                
            % build depth per node
            depthPerBranch = cat(1, obj.tree.depth);
            depthPerNode = depthPerBranch(indexBranchPerNode);
                
            % link relatives per branch
            obj.linked = 0;
            for b = 1 : treeSize
                    
            	% link parent
                obj.tree(b).linkParent(listNodes,...
                                       depthPerNode,...
                                       min(depthPerBranch),...
                                       indexBranchPerNode);
                    
                % link children
                obj.tree(b).linkChildren(listNodes,...
                                         depthPerNode,...
                                         max(depthPerBranch),...
                                         indexBranchPerNode);
                   
                % check if linking works
                if ~(isempty(obj.tree(b).parent) && isempty(obj.tree(b).children))
                       
                	obj.linked = obj.linked + 1;
                       
                end
                   
            end
                
            % update status
            obj.updateStatus();
            
        end
        
        % method :: showMask
        %  input :: class object
        % action :: makes patch visible
        function obj = showMask(obj)
            
            set(obj.ih_patch, 'CData', obj.patch);
            set(obj.ih_patch, 'AlphaData', (obj.mask > 0) .* obj.PATCH_ALPHA_ON);
            
        end
        
        % method :: hideMask
        %  input :: class object
        % action :: makes patch unvisible
        function obj = hideMask(obj)
            
            set(obj.ih_patch, 'AlphaData', obj.PATCH_ALPHA_OFF);
            
        end
        
        % method :: clearTree
        %  input :: class object
        % action :: clear current tree and figure callbacks
        function obj = clearTree(obj)
            
            % remove callback functions
            obj.setFigureCallbacks('off');
            
            % clear tree
            if size(obj.tree, 1) > 0
                
                % dispose each branch
                while ~isempty(obj.tree)
                    obj.tree(1).disposeBranch();
                    obj.tree(1) = [];
                end
                
                % set default properties
                obj.setDefaultProperties();
                
                % update default status
                obj.updateStatus();
                
            end
            
        end
        
        
        % method :: enableButtonGroup
        %  input :: class object, enable
        % action :: change operational state of button group
        function obj = enableButtonGroup(obj, enable)
            buttonGroup = cat(1,...
                obj.ui_pushButton_SaveTree,...
                obj.ui_pushButton_LoadTree,...
                obj.ui_pushButton_LinkTree,...
                obj.ui_edit_DilationSize,...
                obj.ui_checkBox_ViewMask);
            
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
        
        
        % callback :: LinkTree
        %    event :: on link tree button
        %   action :: automatic linking of branch hierarchy
        function obj = fcnCallback_LinkTree(obj, ~, ~)
            obj.linkTree();
        end
        
        % callback :: ViewMask
        %    event :: on view mask button
        %   action :: show/hide mask
        function obj = fcnCallback_ViewMask(obj, ~, ~)
            
            if obj.ui_checkBox_ViewMask.Value == 1        
                obj.showMask();
            else
                obj.hideMask();
            end
            
        end
        
        % callback :: DilationSize
        %    event :: on edit dilation size field
        %   action :: update current dilation value
        function obj = fcnCallback_DilationSize(obj, ~, ~)
            
            % extract value
            value = regexp(obj.ui_edit_DilationSize.String, '[\d]+','match');
            
            % check if value is empty
            if isempty(value)
                value = 0;
            else
                value = str2double(value(1));
            end
            
            % check value span
            if value < obj.MIN_DILATE_SIZE
                obj.dilate = obj.MIN_DILATE_SIZE;
            elseif value > obj.MAX_DILATE_SIZE
                obj.dilate = obj.MAX_DILATE_SIZE;
            else
                obj.dilate = value;
            end
            
            % update edit box string
            set(obj.ui_edit_DilationSize, 'String', sprintf('%d', obj.dilate));
            
            % update mask dilation
            obj.updateMaskDilation();
            
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
                
                obj.fcnRespond_KeyDigit();
                
            elseif uint8(obj.key) == 8 %(DEL)
                
                obj.fcnRespond_KeyDel();
                
            end
            
        end
        
        % callback :: MoveMouse
        %    event :: on mouse move
        %   action :: track mouse position
        function obj = fcnCallback_MoveMouse(obj, ~, ~)
            
            % get current click position
            obj.click = obj.getClick();
            
            % call respond function
            obj.fcnRespond_MouseMove();
            
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
                
                obj.fcnRespond_ClickDown();
                
            elseif strcmp(clickSelection, 'open')
                
                obj.fcnRespond_ClickDouble();
                
            end
        end
        
        % callback :: ClickUp
        %    event :: on mouse click up
        %   action :: get mouse release position
        function obj = fcnCallback_ClickUp(obj, ~, ~)
            
            % get current click position
            obj.click = obj.getClick();
            
            obj.fcnRespond_ClickUp();
            
        end
        
        
        %%% -------------------------------- %%%
        %%% --- EVENTS RESPOND FUNCTIONS --- %%%
        %%% -------------------------------- %%%
        
        % respond :: KeyDigit
        %   event :: EVENT_KEY_DIGIT
        %  action :: update states
        function obj = fcnRespond_KeyDigit(obj)
            
            if obj.state == obj.STATE_IDLE
                
                obj.createBranch();
                
                obj.state = obj.STATE_DRAWING;
                
            end
            
        end
            
        % respond :: KeyDel
        %   event :: EVENT_KEY_DEL
        %  action :: update states
        function obj = fcnRespond_KeyDel(obj)
            
            if obj.state == obj.STATE_DRAWING
                
                obj.deleteNode();
                
                if obj.indexNode > 1
                    
                    obj.state = obj.STATE_DRAWING;
                    
                else
                    
                    % last node deleted, dispose branch
                    obj.edit_indexBranch = obj.indexBranch;
                    obj.deleteBranch();
                    obj.state = obj.STATE_IDLE;
                    set(obj.ih_figure, 'Pointer', 'arrow');
                    
                end
                
            elseif obj.state == obj.STATE_SELECTED_BRANCH
                
                obj.deleteBranch();
                
                obj.state = obj.STATE_IDLE;
                
            end
            
        end
        
        % respond :: ClickDown
        %   event :: EVENT_CLICK_DOWN
        %  action :: update states
        function obj = fcnRespond_ClickDown(obj)
            
            switch obj.state
                
                case obj.STATE_DRAWING
                    
                    obj.extendBranch();
                    
                case obj.STATE_OVER_BRANCH
                    
                    obj.pickUpBranch();
                    
                    obj.state = obj.STATE_REPOSITION_BRANCH;
                    
                case obj.STATE_OVER_NODE
                    
                    obj.pickUpNode();
                    
                    obj.state = obj.STATE_REPOSITION_NODE;
                    
                case obj.STATE_SELECTED_BRANCH
                    
                    obj.deselectBranch();
                    
                    obj.state = obj.STATE_IDLE;
                    
            end
            
        end
        
        % respond :: ClickUp
        %   event :: EVENT_CLICK_UP
        %  action :: update states
        function obj = fcnRespond_ClickUp(obj)
            
            if obj.state == obj.STATE_REPOSITION_BRANCH
                
                obj.releaseBranch();
                obj.state = obj.STATE_OVER_BRANCH;
                
            elseif obj.state == obj.STATE_REPOSITION_NODE
                
                obj.releaseBranch();
                obj.state = obj.STATE_OVER_NODE;
                
            end
            
        end
        
        % respond :: ClickDouble
        %   event :: EVENT_CLICK_DOUBLE
        %  action :: update states
        function obj = fcnRespond_ClickDouble(obj)
            
            if obj.state == obj.STATE_DRAWING
                
                obj.completeBranch();
                
                obj.state = obj.STATE_IDLE;
                
            elseif obj.state == obj.STATE_OVER_BRANCH
                
                obj.selectBranch();
                
                obj.state = obj.STATE_SELECTED_BRANCH;
                
            end
            
        end
        
        
        % respond :: MouseMove
        %   event :: EVENT_MOUSE_MOVE
        %  action :: update states
        function obj = fcnRespond_MouseMove(obj)
            
            switch obj.state
                
                case obj.STATE_DRAWING
                    
                    obj.stretchBranch();
                    
                case obj.STATE_REPOSITION_BRANCH
                    
                    obj.moveBranch();
                    
                case obj.STATE_REPOSITION_NODE
                    
                    obj.moveNode();
                    
                case {obj.STATE_IDLE, obj.STATE_OVER_BRANCH, obj.STATE_OVER_NODE}    
                
                    obj.hoverOverObject();
                    
            end
            
            
        end
        
        %%% ----------------------------- %%%
        %%% --- STATE MACHINE METHODS --- %%%
        %%% ----------------------------- %%%
        
        
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
        
        % method :: hoverOverObject
        %  input :: class object
        % action :: update state if mouse hover over object
        function obj = hoverOverObject(obj)
            
            % undocumented matlab HITTEST function
            % returns the handle of object that the mose is over
            hobj = hittest(obj.ih_figure);
            
            % update curren hover handle
            obj.edit_handle = hobj;
            
            % check the type of graphic object
            if isgraphics(hobj, 'image')
                
                % update state
                obj.state = obj.STATE_IDLE;
                
                % update mouse pointer
                set(obj.ih_figure, 'Pointer', 'arrow');
                
            elseif isgraphics(hobj, 'line')
                
                % decide between line and point
                if strcmp(hobj.LineStyle, 'none')
                    
                    % update state
                    obj.state = obj.STATE_OVER_NODE;
                    
                    % update mouse pointer
                    set(obj.ih_figure, 'Pointer', 'circle');
                    
                elseif strcmp(hobj.LineStyle,'-')
                    
                    % update state
                    obj.state = obj.STATE_OVER_BRANCH;
                    
                    % update mouse pointer
                    set(obj.ih_figure, 'Pointer', 'hand');
                    
                end
                
            end
            
        end
        
        % method :: createBranch
        %  input :: class object
        % action :: creates new branch
        function obj = createBranch(obj)
            
            % update branch index
            obj.indexBranch = size(obj.tree, 1) + 1;
            
            % reset node index
            obj.indexNode = 0;
            
            % creane new branch object
            obj.tree = cat(1, obj.tree,...
                              NeuroTreeBranch('Index', obj.indexBranch,...
                                              'Depth', obj.key,...
                                              'Parent', obj.ih_axes));
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'crosshair');
            
            % update status message
            obj.updateStatus();
            
            
        end
        
        % method :: deleteBranch
        %  input :: class object
        % action :: deletes branch
        function obj = deleteBranch(obj)
            
            % delete given branch
            obj.tree(obj.edit_indexBranch).disposeBranch();
            obj.tree(obj.edit_indexBranch) = [];
            
            % delete branch patch
            obj.deleteBranchPatch(obj.edit_indexBranch);
            obj.deleteBranchMask(obj.edit_indexBranch);
            
            % update current branch index
            obj.indexBranch = numel(obj.tree);
            
            % check if tree is empty else reindex
            if obj.indexBranch == 0
                obj.setDefaultProperties();
            else
                for b = 1 : obj.indexBranch
                    obj.tree(b).reindexBranch(b);
                end
            end
            
            % check if mask viewer is active
            if obj.ui_checkBox_ViewMask.Value == 1
                obj.showMask();
            end
            
            % update status
            obj.linked = 0;
            obj.updateStatus();
            
        end
        
        % method :: deleteNode
        %  input :: class object
        % action :: deletes node in current branch
        function obj = deleteNode(obj)
            
            % dispose node
            obj.tree(obj.indexBranch).disposeNode(obj.indexNode);
            
            % updae node index
            obj.indexNode = obj.indexNode - 1;
            
        end
        
        % method :: extendBranch
        %  input :: class object
        % action :: add new node to curren branch
        function obj = extendBranch(obj)
            
            % update node index
            obj.indexNode = obj.indexNode + 1;
            
            % update node in tree
            obj.tree(obj.indexBranch).extendBranch(obj.indexNode, obj.click);
            
            % update status message
            obj.updateStatus();
            
        end
        
        % method :: pickUpBranch
        %  input :: class object
        % action :: picks up branch to move
        function obj = pickUpBranch(obj)
            
            % get current click
            obj.edit_click = obj.click;
            obj.edit_indexBranch = obj.edit_handle.UserData; % user data keeps branch index
            
        end
        
        % method :: moveBranch
        %  input :: class object
        % action :: shift branch position
        function obj = moveBranch(obj)
            
            % delta click
            deltaClick = obj.click - obj.edit_click;
            
            % update branch
            obj.tree(obj.edit_indexBranch).updateBranch(deltaClick);
            
            % update edit click
            obj.edit_click = obj.click;
            
        end
        
        % method :: releaseBranch
        %  input :: class object
        % action :: update branch after release
        function obj = releaseBranch(obj)
            
            % set branch length
            obj.tree(obj.edit_indexBranch).measureBranch();
            
            % create pixel array
            obj.tree(obj.edit_indexBranch).nodesToPixels(obj.height, obj.width);
            
            % delete old patch and mask
            obj.deleteBranchPatch(obj.edit_indexBranch);
            obj.deleteBranchMask(obj.edit_indexBranch);
            
            % mask branch
            obj.maskBranch(obj.tree(obj.indexBranch).pixels,...
                           obj.tree(obj.indexBranch).index);
            
            % patch branch
            obj.patchBranch(obj.tree(obj.indexBranch).getBranchColor(),...
                            obj.tree(obj.indexBranch).index);
                        
            % check if mask viewer is active
            if obj.ui_checkBox_ViewMask.Value == 1
                obj.showMask();
            end
            
            % update status
            obj.updateStatus();
                        
        end
        
        % method :: pickUpNode
        %  input :: class object
        % action :: picks up node to move
        function obj = pickUpNode(obj)
            
            % get current click
            obj.edit_click = obj.click;
            
            % get edit Branch
            obj.edit_indexBranch = obj.edit_handle.UserData; % user data keeps branch index
            
            % get edit Node
            distEucl = sqrt(sum(bsxfun(@minus, [obj.edit_handle.XData', obj.edit_handle.YData'], obj.edit_click).^2, 2));
            [~, obj.edit_indexNode] = min(distEucl);
            
        end
        
        % method :: moveNode
        %  input :: class object
        % action :: shift node position
        function obj = moveNode(obj)
            
            % update edit click
            obj.edit_click = obj.click;
            
            % update branch
            obj.tree(obj.edit_indexBranch).updateNode(obj.edit_indexNode, obj.edit_click);
            
        end
        
        % method :: completeBranch
        %  input :: class object
        % action :: release branch after move
        function obj = completeBranch(obj)
            
            % update node in tree
            obj.tree(obj.indexBranch).completeBranch(obj.height, obj.width);
            
            % mask branch
            obj.maskBranch(obj.tree(obj.indexBranch).pixels,...
                           obj.tree(obj.indexBranch).index);
            
            % patch branch
            obj.patchBranch(obj.tree(obj.indexBranch).getBranchColor(),...
                            obj.tree(obj.indexBranch).index);
            
            % check tree size and enable button group
            if size(obj.tree, 1) > 0
                obj.enableButtonGroup('on');
            end
            
            % check if mask viewer is active
            if obj.ui_checkBox_ViewMask.Value == 1
                obj.showMask();
            end
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'arrow');
            
            % update status message
            obj.updateStatus();
            
        end
        
        
        % method :: maskBranch
        %  input :: class object, pixels, index
        % action :: update current mask
        function obj = maskBranch(obj, pixels, index)
            
            % create branch binary mask
            bry = false(obj.height, obj.width);
            bry(pixels) = true;
            
            % complete closed polygons
            bry = imfill(bry, 'holes');
            
            % dilate mask
            bry = imdilate(bry, strel('disk', obj.dilate));
            
            % keep index in mask
            obj.mask(bry) = index;
            
        end
        
        % method :: deleteBranchMask
        %  input :: class object, index
        % action :: dispose current mask
        function obj = deleteBranchMask(obj, index)
            
            obj.mask(obj.mask == index) = 0;
            
        end
        
        % method :: patchBranch
        %  input :: class object, branchColor, index
        % action :: update current patch
        function obj = patchBranch(obj, branchColor, index)
            
            % cast branch color type
            branchColor = cast(branchColor, 'like', obj.patch);
            
            % create color patch
            branchColorPatch = repmat(shiftdim(branchColor, -1),...
                                      obj.height,...
                                      obj.width,...
                                      1);
                                  
            % create binary mask
            bry = repmat(obj.mask, 1, 1, 3) == index;
            
            % aplly color patch
            obj.patch(bry) = branchColorPatch(bry);
            
        end
        
        
        % method :: deleteBranchPatch
        %  input :: class object, index
        % action :: dispose branch patch
        function obj = deleteBranchPatch(obj, index)
            
            % create binary mask
            bry = repmat(obj.mask, 1, 1, 3) == index;
            
            % dispose patch
            obj.patch(bry) = cast(0 , 'like', obj.patch);
            
        end
        
        
        % method :: selectBranch
        %  input :: class object
        % action :: select branch
        function obj = selectBranch(obj)
            
            % highlight branch
            obj.tree(obj.edit_indexBranch).selectBranch();
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'arrow');
            
        end
        
        % method :: deselectBranch
        %  input :: class object
        % action :: deselect branch
        function obj = deselectBranch(obj)
            
            % remove highlight
            obj.tree(obj.edit_indexBranch).deselectBranch();
            
        end
        
        % method :: stretchBranch
        %  input :: class object
        % action :: extend branch without adding node
        function obj = stretchBranch(obj)
            
            % update node in tree
            obj.tree(obj.indexBranch).stretchBranch(obj.indexNode + 1, obj.click);
            
            % update status message
            obj.updateStatus();
            
        end
        
        
        % method :: updateMaskDilation
        %  input :: class object
        % action :: update mask dilation size
        function obj = updateMaskDilation(obj)
            tic
            
            % get current tree size
            treeSize = size(obj.tree, 1);
            
            % sort tree by order
            treeOrder = cat(1, obj.tree.depth);
            [~, sortIndex] = sort(treeOrder);
            
            for b = 1 : treeSize
                
                % get tree branch
                branchIndex = sortIndex(b);
                
                % delete previous patch
                obj.deleteBranchPatch(branchIndex);
                
                % delete previous mask
                obj.deleteBranchMask(branchIndex);
                
                % mask branch
                obj.maskBranch(obj.tree(branchIndex).pixels,...
                               obj.tree(branchIndex).index);
            
                % patch branch
                obj.patchBranch(obj.tree(branchIndex).getBranchColor(),...
                                obj.tree(branchIndex).index);
            
            end
            
            % check if mask viewer is active
            if obj.ui_checkBox_ViewMask.Value == 1
                obj.showMask();
            end
            
            fprintf('full mask update %.4f\n', toc);
        end
        
        % method :: updateStatus
        %  input :: class object
        % action :: update UI status
        function obj = updateStatus(obj)
            
            set(obj.ui_text_StatusBranch, 'String', sprintf('branch %d', obj.indexBranch));
            set(obj.ui_text_StatusNode, 'String', sprintf('node %d', obj.indexNode));
            set(obj.ui_pushButton_LinkTree, 'String', sprintf('Link %d / %d',obj.linked, size(obj.tree, 1)));
            if obj.indexBranch > 0
                set(obj.ui_text_StatusDepth, 'String', sprintf('depth %d', obj.tree(obj.indexBranch).depth));
                set(obj.ui_text_StatusSpan, 'String', sprintf('span[px] %d', round(obj.tree(obj.indexBranch).span)));
            else
                set(obj.ui_text_StatusDepth, 'String', 'depth 0');
                set(obj.ui_text_StatusSpan, 'String', 'span[px] 0');
            end
            
        end
        
    end
    
end
