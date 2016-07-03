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
    %    uiGridLayout.m
    %
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
   
    properties (Access = private, Hidden = true)
        
        %%% --- input properties --- %%%
        
        dilation	% mask dilation size
        nhood       % linking relatives nhood distance 
        
        image       % image CData
        mask        % binary mask
        patch       % color pathch
        
        height      % image height
        width       % image width
        
        path        % current file path
        name        % current file name
        
    end
    
    properties (SetObservable)
        
        sm_event % current event in state machine
        
    end
    
    properties (Access = private, Hidden = true)
        
        sm_table % state transition table
        sm_state % current state in state machine
        sm_lh    % state machine listener handle
        tree
        
        keychar
        point
        indexBranch
        indexNode
        
        editPoint
        editIndexBranch
        editIndexNode
        
        hoverHandle
        
        %%% --- image figure handlers --- %%%
        ih_figure
        ih_axes
        ih_image
        ih_patch
        
        %%% --- UI components --- %%%
        ui_parent
        ui_grid
        ui_panel
        
        ui_toggleButton_segment
        ui_pushButton_load
        ui_toggleButton_mask
        ui_pushButton_export
        
        ui_edit_dilation
        ui_edit_nhood
        
        ui_text_status
        
    end
    
    properties (Constant, Hidden)
        
        %%% --- UI properties --- %%%
        GUI_WINDOW_POSITION = [1, 1, 250, 130];
        VERTICAL_GAP = [12, 2, 8];
        HORIZONTAL_GAP = [5, 2, 5];
        PUSHBUTTON_POSITION = [1, 1, 90, 26];
        CHECKBOX_POSITION = [1, 1, 90, 26];
        EDITBOX_POSITION = [1, 1, 45, 20];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE COLOR
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY COLOR
        FONT_SIZE = 8;
        
        PATCHALPHA_OFF = 0;
        PATCHALPHA_ON = 0.2;
        
        %%% --- Tree Settings --- %%%
        RANGE_DILATION = [10,30];
        RANGE_NHOOD = [20, 50];
        
        %%% --- States --- %%%
        STATE_IDLE = 1;
        STATE_OVER_BRANCH = 2;
        STATE_OVER_NODE = 3;
        STATE_DRAWING = 4;
        STATE_REPOSITION_BRANCH = 5;
        STATE_REPOSITION_NODE = 6;
        STATE_SELECTED_BRANCH = 7;
        STATE_COUNT = 8;
        
        %%% --- Events --- %%%
        EVENT_NULL = 1;
        EVENT_KEY_DIGIT = 2;
        EVENT_KEY_DEL = 3;
        EVENT_CLICK_DOWN = 4;
        EVENT_CLICK_UP = 5;
        EVENT_CLICK_DOUBLE = 6;
        EVENT_MOUSE_MOVE = 7;
        EVENT_OVER_BRANCH = 8;
        EVENT_OVER_NODE = 9;
        EVENT_OVER_IMAGE = 10;
        EVENT_COUNT = 11;
        
    end
    
    events (NotifyAccess = protected)
        
        event_NeuroTree_GetImage
        
    end
    
    %%% --- constructor / destructor --- %%%
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
                    'Tag', 'hNeuroTree',...
                    'Name', 'NeuroTree',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Color', obj.BACKGROUND_COLOR,...
                    'Resize', 'off',...
                    'Units', 'pixels', ...
                    'Position', obj.GUI_WINDOW_POSITION,...
                    'CloseRequestFcn', @obj.fcnCallback_close);
                movegui(obj.ui_parent, 'northwest');
                
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            
            % set default properties
            obj.default();
            
            % render user interface
            obj.render();
            
        end
        
        function obj = default(obj)
            %DEFAULT set class properties default values
            
            obj.dilation = 10;
            obj.nhood = 20;
            
            obj.mask = zeros(obj.height, obj.width);
            obj.patch = zeros(obj.height, obj.width, 3, 'uint8');
            
            obj.tree = [];
            
            obj.keychar = [];
            obj.point = [];
            obj.indexBranch = 0;
            obj.indexNode = 0;
            
            obj.editPoint = [];
            obj.editIndexBranch = 0;
            obj.editIndexNode = 0;
            
            obj.hoverHandle = [];
            
        end
        
        function obj = dispose(obj)
            %DISPOSE WidgetNeuroTree class destructor
            
            if isgraphics(obj.ui_parent, 'figure')
                delete(obj.ui_parent);
            end
            
            delete(obj);
        end
        
    end % constructor / destructor
    
    
    %%% --- user interface methods --- %%%
    methods
        
        function obj = render(obj)
            %RENDER render user interface
            
            %%% --- create widget panel --- %%%
            ui_parent_grid = uiGridLayout(...
                'Parent', obj.ui_parent,...
                'VGrid', 1,...
                'HGrid', 1,...
                'VGap', [4, 2, 4],...
                'HGap', [4, 2, 4]);
            
            obj.ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Neuro Tree',...
                'TitlePosition', 'lefttop',...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', ui_parent_grid.getGrid('VIndex', 1, 'HIndex', 1));
            
            %%% --- create grid object --- %%%
            obj.ui_grid = uiGridLayout(...
                'Parent', obj.ui_panel,...
                'VGrid', 4,...
                'HGrid', 4,...
                'VGap', obj.VERTICAL_GAP,...
                'HGap', obj.HORIZONTAL_GAP);
            
            %%% --- render pushButtons --- %%%
            obj.ui_toggleButton_segment = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Segment',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_segment,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_toggleButton_segment,...
                'VIndex', 1,...
                'HIndex', 1:2,...
                'Anchor', 'center');
                                     
            obj.ui_pushButton_load = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Load',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_load,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_pushButton_load,...
                'VIndex', 1,...
                'HIndex', 3:4,...
                'Anchor', 'center');
            
            obj.ui_toggleButton_mask = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'ToggleButton',...
                'String', 'View Mask',...
                'Enable', 'off',...
                'Value', 0,...
                'Callback', @obj.fcnCallback_mask,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_toggleButton_mask,...
                'VIndex', 2,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_export = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Export',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_export,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_pushButton_export,...
                'VIndex', 2,...
                'HIndex', 3:4,...
                'Anchor', 'center');
            
            %%% --- render status information --- %%%
            obj.ui_text_status = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'Text',...
                'String', 'choose image to segment',...
                'FontSize', obj.FONT_SIZE,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 3, 'HIndex', 1:4));
            obj.ui_grid.align(obj.ui_text_status,...
                'VIndex', 3,...
                'HIndex', 1:4,...
                'Anchor', 'center');
                                   
            %%% --- user input --- %%%
            ui_text_label = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'Text',...
                'String', 'dilation[px]',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 4, 'HIndex', 1));
            obj.ui_grid.align(ui_text_label,...
                'VIndex', 4,...
                'HIndex', 1,...
                'Anchor', 'east');
            
            obj.ui_edit_dilation = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'Edit',...
                'String', '10',...
                'Enable', 'off',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Callback', @obj.fcnCallback_parse,...
                'Units', 'pixels',...
                'Position', obj.EDITBOX_POSITION);
            obj.ui_grid.align(obj.ui_edit_dilation,...
                'VIndex', 4,...
                'HIndex', 2,...
                'Anchor', 'west');
            
            ui_text_label = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'Text',...
                'String', 'nhood[px]',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 4, 'HIndex', 3));
            obj.ui_grid.align(ui_text_label,...
                'VIndex', 4,...
                'HIndex', 3,...
                'Anchor', 'east');
            
            obj.ui_edit_nhood = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'edit',...
                'String', '20',...
                'Enable', 'off',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Callback', @obj.fcnCallback_parse,...
                'Units', 'pixels',...
                'Position', obj.EDITBOX_POSITION);
            obj.ui_grid.align(obj.ui_edit_nhood,...
                'VIndex', 4,...
                'HIndex', 4,...
                'Anchor', 'west');
                
        end
        
        
        function obj = enable(obj, varindex, varchar)
            %ENABLE toggles user interface handles enable property
            % VARINDEX index of handles that need to be toggled
            % VARCHAR a char specifying the state
            
            handles = [obj.ui_toggleButton_segment;...
                       obj.ui_pushButton_load;...
                       obj.ui_toggleButton_mask;...
                       obj.ui_pushButton_export;...
                       obj.ui_edit_dilation;...
                       obj.ui_edit_nhood];
            
            % empty varindex will take all handles       
            if isempty(varindex)
                varindex = 1:size(handles,1);
            end
            
            set(handles(varindex), 'Enable', varchar);       
                   
        end
        
        %%% --- UI Callbacks --- %%%
        function obj = fcnCallback_close(obj, ~, ~)
            %FCNCALLBACK_CLOSEUIWINDOW user interface callback function
            % calls class DISPOSE method
            
            obj.dispose();
            
        end
        
        function obj = fcnCallback_segment(obj, ~, ~)
            %FCNCALLBACK_SEGMENT user interface callback function
            % calls class SEGMENT method
            
            if strcmp('Segment', get(obj.ui_toggleButton_segment, 'String'))
                
                set(obj.ui_toggleButton_segment, 'String', 'Clear');
                set(obj.ui_toggleButton_segment, 'Value', 1);
                obj.segment();
                
            else
                
                set(obj.ui_toggleButton_segment, 'String', 'Segment');
                set(obj.ui_toggleButton_segment, 'Value', 0);
                obj.clear();
                
            end
            
        end
        
        function obj = fcnCallback_load(obj, ~, ~)
            %FCNCALLBACK_LOAD user interface callback function
            % calls class LOAD method
            
            obj.load();
            
        end
        
        function obj = fcnCallback_export(obj, ~, ~)
            %FCNCALLBACK_EXPORT user interface callback function
            % calls class EXPORT method
            
            obj.export();
            
        end
        
        function obj = fcnCallback_mask(obj, ~, ~)
            %FCNCALLBACK_MASK user interface callback function
            % calls class VIEW/HIDE mask methods
            
            if strcmp('View Mask', get(obj.ui_toggleButton_mask, 'String'))
                
                set(obj.ui_toggleButton_mask, 'String', 'Hide Mask');
                set(obj.ui_toggleButton_mask, 'Value', 1);
                obj.view();
                
            else
                
                set(obj.ui_toggleButton_mask, 'String', 'View Mask');
                set(obj.ui_toggleButton_mask, 'Value', 0);
                obj.hide();
                
            end
            
        end
        
        function obj = fcnCallback_parse(obj, hSrc, ~)
            %FCNCALLBACK_PARSE user interface callback function
            % parses edit boxes input
            % assign value to property
            % calls class DILATE/LINK methods
            
            varchar = get(hSrc, 'String');
            varchar = regexp(varchar, '[\d]+', 'match');
            value = str2double(varchar);
            
            % avoid empty value
            if isnan(value)
                return;
            end
            
            % choose by used edint box
            switch hSrc
                case obj.ui_edit_dilation
                        
                    if (obj.RANGE_DILATION(1) <= value) && (value <= obj.RANGE_DILATION(2))
                            
                    	obj.dilation = value;
                        obj.dilate();
                       
                    end
                    set(obj.ui_edit_dilation, 'String', sprintf('%d',obj.dilation));
                    
                case obj.ui_edit_nhood
                        
                    if (obj.RANGE_NHOOD(1) <= value) && (value <= obj.RANGE_NHOOD(2))
                        
                        obj.nhood = value;
                        obj.link();
                            
                    end
                    set(obj.ui_edit_nhood, 'String', sprintf('%d',obj.nhood));
                        
            end
               
        end
        
    end % user interface methods
    
    
    %%% --- user interface respond methods --- %%%
    methods
        
        function obj = start(obj, varargin)
            %START initialize class image handlers
            
            % use parser
            parserObj = inputParser;
            addParameter(parserObj, 'FileName', [], @ischar);
            addParameter(parserObj, 'Figure', [], @isgraphics);
            addParameter(parserObj, 'Axes', [], @isgraphics);
            addParameter(parserObj, 'Image', [], @isgraphics);
            
            parse(parserObj, varargin{:});
            
            % assign input variables
            [obj.path, obj.name] = fileparts(parserObj.Results.FileName);
            
            obj.ih_figure = parserObj.Results.Figure;
            obj.ih_axes = parserObj.Results.Axes;
            obj.ih_image = parserObj.Results.Image;
            
            obj.image = get(obj.ih_image, 'CData');
            [obj.height, obj.width] = size(obj.image);
            obj.mask = false(obj.height, obj.width);
            obj.patch = zeros(obj.height, obj.width, 3, 'uint8');
            
            % create patch
            hold(obj.ih_axes, 'on');
            obj.ih_patch = imshow(obj.patch,[],...
                                  'Parent', obj.ih_axes,...
                                  'Border', 'tight',...
                                  'InitialMagnification', 'fit');
            hold(obj.ih_axes, 'off');
            set(obj.ih_patch, 'AlphaData', obj.PATCHALPHA_OFF);
            
            
        end
        
        function obj = segment(obj)
            %SEGMENT initialize tree segmentation
            
            % fire get image exent
            notify(obj, 'event_NeuroTree_GetImage');
            
            % initiate drawing
            obj.drawing('on');
            
            % make image figure main
            figure(obj.ih_figure);
            
            % update user message
            obj.status();
            
        end
        
        
        function obj = clear(obj)
            %CLEAR clean tree and drawing
            
            % switch off drawing callbacks
            obj.drawing('off');
            
        end
        
        
        function obj = load(obj)
            %LOAD load tree file
            
            % fire get image exent
            notify(obj, 'event_NeuroTree_GetImage');
        end
        
        
        function obj = export(obj)
            %EXPORT exports current tree
            
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
               obj.tree(b).export(fpWrite);
           end
           fclose(fpWrite);
           
        end
        
        
        function obj = view(obj)
            %VIEW set on visibility of current patch
            
            set(obj.ih_patch, 'CData', obj.patch);
            set(obj.ih_patch, 'AlphaData', (obj.mask > 0) .* obj.PATCHALPHA_ON);
            
        end
        
        
        function obj = hide(obj)
            %HIDE set off visibility of current patch
            
            set(obj.ih_patch, 'AlphaData', obj.PATCHALPHA_OFF);
            
        end
        
        
        function obj = dilate(obj)
            %DILATE dilates the tree mask with current DILATION size
            
            % get current tree size
            treeSize = size(obj.tree, 1);
            
            % sort tree by depth and index
            treeDepth = cat(1, obj.tree.depth);
            treeIndex = cat(1, obj.tree.index);
            [~, sortIndex] = sortrows([treeDepth, treeIndex], [1, 2]);
            
            for b = 1 : treeSize
                
                % current branch
                bIdx = sortIndex(b);
                pixels = obj.tree(bIdx).pixels;
                index = obj.tree(bIdx).index;
                color = obj.tree(bIdx).color;
                
                % mask update will reset and re-index
                obj.fcnMask_update(pixels, index, color);
                
            end
            
        end
        
        
        function obj = link(obj)
            %LINK re-links tree with current NHOOD size
            
            % get current tree size
            treeSize = size(obj.tree, 1);
            
            % sort tree by depth and index
            treeDepth = cat(1, obj.tree.depth);
            treeIndex = cat(1, obj.tree.index);
            [~, sortIndex] = sortrows([treeDepth, treeIndex], [1, 2]);
            
            % sort tree
            obj.tree = obj.tree(sortIndex);
            
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
            
            
            for b = 1 : treeSize
                
                % re-index
                obj.tree(b).reindex(b);
                
                % link
                obj.tree(b).link(listNodes,...
                                 depthPerNode,...
                                 min(depthPerBranch),...
                                 max(depthPerBranch),...
                                 indexBranchPerNode);
                
            end
            
        end
        
        
        function obj = status(obj)
            %STATUS updates status message
            
            if isa(obj.tree, 'NeuroTreeBranch')
                
                msg = sprintf('branch %d, node %d, depth %d, span[px] %d',...
                          obj.indexBranch,...
                          obj.indexNode,...
                          obj.tree(obj.indexBranch).depth,...
                          obj.tree(obj.indexBranch).span);
                      
            else
                
                msg = 'segment by pressing 0 - 9 for branch depth';
                
            end
            
                      
            set(obj.ui_text_status, 'String', msg);
            obj.ui_grid.align(obj.ui_text_status,...
                'VIndex', 3,...
                'HIndex', 1:4,...
                'Anchor', 'center');
            
        end
        
    end % user interface respond methods
    
    
    %%% --- user drawing interaction callbacks --- %%%
    methods
        
        function obj = sminit(obj)
            %SMINIT initialize state machine
            
            obj.sm_state = obj.STATE_IDLE;
            obj.sm_event = obj.EVENT_NULL;
            
            % allocate state/event table
            obj.sm_table = cell(obj.STATE_COUNT - 1,...
                                obj.EVENT_COUNT - 1);
            
            % fill up state machine table
            obj.sm_table(obj.STATE_IDLE,...
                         obj.EVENT_KEY_DIGIT) = {@obj.fcnBranch_create};
                     
            obj.sm_table(obj.STATE_DRAWING,...
                         obj.EVENT_MOUSE_MOVE) = {@obj.fcnBranch_stretch};
                     
            obj.sm_table(obj.STATE_DRAWING,...
                         obj.EVENT_CLICK_DOWN) = {@obj.fcnBranch_extend};
                     
            obj.sm_table(obj.STATE_DRAWING,...
                         obj.EVENT_CLICK_DOUBLE) = {@obj.fcnBranch_complete};
                     
            obj.sm_table(obj.STATE_OVER_BRANCH,...
                         obj.EVENT_CLICK_DOWN) = {@obj.fcnBranch_pickUp};
                     
            obj.sm_table(obj.STATE_REPOSITION_BRANCH,...
                         obj.EVENT_MOUSE_MOVE) = {@obj.fcnBranch_move};
                     
            obj.sm_table(obj.STATE_IDLE,...
                         obj.EVENT_OVER_BRANCH) = {@obj.fcnBranch_overBranch};
                     
            obj.sm_table(obj.STATE_OVER_NODE,...
                         obj.EVENT_OVER_BRANCH) = {@obj.fcnBranch_overBranch};
                     
            obj.sm_table(obj.STATE_OVER_BRANCH,...
                         obj.EVENT_OVER_IMAGE) = {@obj.fcnBranch_overImage};
                     
            obj.sm_table(obj.STATE_REPOSITION_BRANCH,...
                         obj.EVENT_CLICK_UP) = {@obj.fcnBranch_putDown};
                     
            obj.sm_table(obj.STATE_OVER_BRANCH,...
                         obj.EVENT_CLICK_DOUBLE) = {@obj.fcnBranch_select};
                     
            obj.sm_table(obj.STATE_SELECTED_BRANCH,...
                         obj.EVENT_CLICK_DOWN) = {@obj.fcnBranch_deselect};
                     
            obj.sm_table(obj.STATE_SELECTED_BRANCH,...
                         obj.EVENT_KEY_DEL) = {@obj.fcnBranch_delete};
                     
                     
            obj.sm_table(obj.STATE_DRAWING,...
                         obj.EVENT_KEY_DEL) = {@obj.fcnNode_delete};
                     
            obj.sm_table(obj.STATE_OVER_NODE,...
                         obj.EVENT_CLICK_DOWN) = {@obj.fcnNode_pickUp};
                     
            obj.sm_table(obj.STATE_REPOSITION_NODE,...
                         obj.EVENT_MOUSE_MOVE) = {@obj.fcnNode_move};
                     
            obj.sm_table(obj.STATE_IDLE,...
                         obj.EVENT_OVER_NODE) = {@obj.fcnNode_overNode};
                     
            obj.sm_table(obj.STATE_OVER_BRANCH,...
                         obj.EVENT_OVER_NODE) = {@obj.fcnNode_overNode};
                     
            obj.sm_table(obj.STATE_OVER_NODE,...
                         obj.EVENT_OVER_IMAGE) = {@obj.fcnNode_overImage};
                     
            obj.sm_table(obj.STATE_REPOSITION_NODE,...
                         obj.EVENT_CLICK_UP) = {@obj.fcnNode_putDown};
            
        end
        
        function obj = drawing(obj, interact)
            %DRAWING toggle drawing on/off state
            % assign drawing callback functions to image figure
            
            if strcmp('on', interact)
                
                % set figure callbacks
                set(obj.ih_figure,...
                        'WindowButtonMotionFcn', @obj.fcnDrawing_moveMouse,...
                        'WindowButtonDownFcn', @obj.fcnDrawing_clickDown,...
                        'WindowButtonUpFcn', @obj.fcnDrawing_clickUp,...
                        'WindowKeyPressFcn', @obj.fcnDrawing_pressKey);
                
                % initialize state machine    
                obj.sminit();
                
                % add event listener
                obj.sm_lh = addlistener(obj, 'sm_event', 'PostSet', @obj.fcnStateMachine_transition);
                
            elseif strcmp('off', interact)
                
                % remove figure callbacks
                set(obj.ih_figure,...
                        'WindowButtonMotionFcn', [],...
                        'WindowButtonDownFcn', [],...
                        'WindowButtonUpFcn', [],...
                        'WindowKeyPressFcn', []);
                 
               % remove event listener
               delete(obj.sm_lh);
               
            end
        end
        
        
        function obj = click(obj)
            %CLICK returns current mouse click point
            
            % read click point
            obj.point = get(obj.ih_axes, 'CurrentPoint');
            obj.point = round(obj.point(1, 1:2));
            
        end
        
        
        function obj = press(obj)
            
            obj.keychar = get(obj.ih_figure, 'CurrentCharacter');
            
        end
        
        
        function obj = hover(obj)
            %HOVER finds handle of graphic object under mouse pointer
            % set current state based on graphic object type
            
            % undocumented matlab HITTEST function
            % returns the handle of object that is under the mouse
            hobj = hittest(obj.ih_figure);
            
            % update curren hover handle
            obj.hoverHandle = hobj;
            
            
            if isgraphics(hobj, 'image')
                
                obj.sm_event = obj.EVENT_OVER_IMAGE;
                
            elseif isgraphics(hobj, 'line')
            
                % decide between line and point
                if strcmp(hobj.LineStyle, 'none')
                    
                    obj.sm_event = obj.EVENT_OVER_NODE;
                    
                elseif strcmp(hobj.LineStyle,'-')
                    
                    obj.sm_event = obj.EVENT_OVER_BRANCH;
                    
                end
                
            end
            
        end
        
        
        function obj = fcnDrawing_pressKey(obj, ~, ~)
            %FCNDRAWING_PRESSKEY drawing callback function
            % defines state action on key press
            
            obj.press();
            
            if (obj.keychar >= '0') && (obj.keychar <= '9')
                
                obj.sm_event = obj.EVENT_KEY_DIGIT;
                
            elseif uint8(obj.keychar) == 8 %(DEL)
                
                obj.sm_event = obj.EVENT_KEY_DEL;
                
            end
            
        end
        
        
        function obj = fcnDrawing_moveMouse(obj, ~, ~)
            %FCNDRAWING_MOVEMOUSE drawing callback function
            % defines state action on mouse move
            
            obj.hover();
            obj.click();
            obj.sm_event = obj.EVENT_MOUSE_MOVE;
            
        end
        
        
        function obj = fcnDrawing_clickDown(obj, ~, ~)
            %FCNDRAWING_CLICKDOWN drawing callback function
            % defines state action on mouse right click down
            
            obj.click();
            
            clickSelection = get(obj.ih_figure, 'SelectionType');
            
            if strcmp(clickSelection, 'normal')
                
                obj.sm_event = obj.EVENT_CLICK_DOWN;
                
            elseif strcmp(clickSelection, 'open')
                
                obj.sm_event = obj.EVENT_CLICK_DOUBLE;
                
            end
            
        end
        
        
        function obj = fcnDrawing_clickUp(obj, ~, ~)
            %FCNDRAWING_CLICKUP drawing callback function
            % defines state action on mouse right click up
            
            obj.click();
            obj.sm_event = obj.EVENT_CLICK_UP;
            
        end
        
        
        function obj = fcnStateMachine_transition(obj, ~, ~)
            %FCNSTATEMACHINE_TRANSITION execute transition callback
            
            fcnDrawingCallback = obj.sm_table{obj.sm_state, obj.sm_event};
            if isa(fcnDrawingCallback, 'function_handle')
                fcnDrawingCallback();
            end
            
            % add granularity (20 ms delay)
            drawnow limitrate;
            
        end
        
        
    end % user drawing interaction callbacks
    
    %%% --- branch callback functions --- %%%
    methods
        
        function obj = fcnBranch_create(obj)
            %FCNBRNACH_CREATE allocates new branch in tree
            
            % update state transition
            obj.sm_state = obj.STATE_DRAWING;
            
            % update mouse cursor
            set(obj.ih_figure, 'Pointer', 'cross');
            
            % update branch index
            obj.indexBranch = size(obj.tree, 1) + 1;
            
            % reset node index
            obj.indexNode = 0;
            
            % reset edit index
            obj.editIndexBranch = obj.indexBranch;
            obj.editIndexNode = obj.indexNode;
            
            % append new branch object
            obj.tree = cat(1, obj.tree,...
                              NeuroTreeBranch('Index', obj.indexBranch,...
                                              'Depth', obj.keychar,...
                                              'Height', obj.height,...
                                              'Width', obj.width,...
                                              'Parent', obj.ih_axes));
            
           % update status
           obj.status();
                                         
        end
        
        
        function obj = fcnBranch_stretch(obj)
            %FCNBRANCH_STRETCH extend branch without appending node
            
            % update state transition
            obj.sm_state = obj.STATE_DRAWING;
            
            % update mouse cursor
            set(obj.ih_figure, 'Pointer', 'cross');
            
            % update last node in current branch
            obj.tree(obj.indexBranch).stretch(obj.indexNode + 1, obj.point);
            
        end
        
        
        function obj = fcnBranch_extend(obj)
            %FCNBRANCH_EXTEND append node to current branch
            
            % update state transition
            obj.sm_state = obj.STATE_DRAWING;
            
            % update node index
            obj.indexNode = obj.indexNode + 1;
            
            % append node in current branch
            obj.tree(obj.indexBranch).extend(obj.indexNode, obj.point);
            
            % measure branch length
            obj.tree(obj.indexBranch).measure();
            
            % update status
            obj.status();
            
        end
        
        
        function obj = fcnBranch_complete(obj)
            %FCNBRANCH_COMPLETE complete branch drawing
            tic
            % update state transition
            obj.sm_state = obj.STATE_OVER_NODE;
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'circle');
            
            % complete branch process
            obj.tree(obj.indexBranch).complete();
            
            % update branch properties
            obj.tree(obj.indexBranch).properties();
            
            % mask branch
            %{
            obj.fcnMask_index(obj.tree(obj.indexBranch).pixels,...
                              obj.tree(obj.indexBranch).index,...
                              obj.tree(obj.indexBranch).color);
            %}
            
            % activate full UI 
            if obj.indexBranch > 0
                obj.enable([], 'on');
            end
            
            % check if mask view is active
            if get(obj.ui_toggleButton_mask, 'Value') == 1
                obj.view();
            end
            
            % update status
            obj.status();
            
            fprintf('complete %.2f\n',toc);
        end
        
        
        function obj = fcnBranch_pickUp(obj)
            %FCNBRANCH_PICKUP pick up last branch position before move
            
            % update state transition
            obj.sm_state = obj.STATE_REPOSITION_BRANCH;
            
            % set edit point
            obj.editPoint = obj.point;
            
            % set edit branch index
            % user data hides branch index (check NeuroTreeBranch
            % constructor)
            obj.editIndexBranch = obj.hoverHandle.UserData; 
            
        end
        
        
        function obj = fcnBranch_move(obj)
            %FCNBRANCH_MOVE shift branch with edit click displacement
            
            % update state transition
            obj.sm_state = obj.STATE_REPOSITION_BRANCH;
            
            % displacement from pickUp click
            deltaClick = obj.point - obj.editPoint;
            
            % move branch position
            obj.tree(obj.editIndexBranch).move(deltaClick);
            
            % update pickUp click
            obj.editPoint = obj.point;
            
        end
        
        
        function obj = fcnBranch_putDown(obj)
            %FCNBRANCH_PUTDOWN release branch after moving
            
            %update state transition
            obj.sm_state = obj.STATE_OVER_BRANCH;
            
            % complete branch
            obj.tree(obj.editIndexBranch).complete();
            
            % update branch properties
            obj.tree(obj.editIndexBranch).properties();
            %{
            % update mask
            obj.fcnMask_update(obj.tree(obj.editIndexBranch).pixels,...
                              obj.tree(obj.editIndexBranch).index,...
                              obj.tree(obj.editIndexBranch).color);
            %}
            
            % is view mask active
            if get(obj.ui_toggleButton_mask, 'Value') == 1
                obj.view();
            end
            
            % update status
            obj.status();
                         
        end
        
        
        function obj = fcnBranch_overBranch(obj)
            %FCNBRANCH_OVERBRANCH update mouse pointer 
            % if hoovering over branch
            
            % update state transition
            obj.sm_state = obj.STATE_OVER_BRANCH;
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'hand');
            
        end
        
        
        function obj = fcnBranch_overImage(obj)
            % FCNBRNACH_OVERIMAGE update mouse pointer
            % if hoovering over image
            
            % update state transition
            obj.sm_state = obj.STATE_IDLE;
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'arrow');
            
        end
        
        
        
        function obj = fcnBranch_select(obj)
            %FCNBRANCH_SELECT add highlight to current branch
            
            % update state transition
            obj.sm_state = obj.STATE_SELECTED_BRANCH;
            set(obj.ih_figure, 'Pointer', 'arrow');
            
            obj.tree(obj.editIndexBranch).select();
            
        end
        
        
        function obj = fcnBranch_deselect(obj)
            %FCNBRANCH_DESELECT remove highlight from current branch
            
            % update state transition
            obj.sm_state = obj.STATE_IDLE;
            
            obj.tree(obj.editIndexBranch).deselect();
            
        end
        
        
        function obj = fcnBranch_delete(obj)
            %FCNBRANCH_DELETE remove current branch from tree
            
            % update state transition
            obj.sm_state = obj.STATE_IDLE;
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'arrow');
            
            % reset mask
            obj.fcnMask_reset(obj.tree(obj.editIndexBranch).index);
                          
            % delete given branch from tree
            obj.tree(obj.editIndexBranch).dispose();
            obj.tree(obj.editIndexBranch) = [];
            
            % update current branch index
            obj.indexBranch = numel(obj.tree);
            
            % check if tree is empty else reindex
            if obj.indexBranch == 0
                obj.default();
            else
                for b = 1 : obj.indexBranch
                    obj.tree(b).reindex(b);
                end
            end
            
            % update status
            obj.status();
            
        end
        
    end % branch callback functions
    
    
    %%% --- nodes callback functions --- %%%
    methods
        
        function obj = fcnNode_pickUp(obj)
            %FCNNODE_PICKUP last node position before move
            
            % update state transition
            obj.sm_state = obj.STATE_REPOSITION_NODE;
            
            % set edit branch index
            % user data hides branch index (check NeuroTreeBranch
            % constructor)
            obj.editIndexBranch = obj.hoverHandle.UserData;
            
            % set index of nodex
            dist = sqrt(sum(bsxfun(@minus, [obj.hoverHandle.XData', obj.hoverHandle.YData'], obj.point) .^ 2, 2));
            [~, obj.editIndexNode] = min(dist);
            
        end
        
        
        function obj = fcnNode_move(obj)
            %FCNNODE_MOVE shift node with edit click displacement
            
            % update state transition
            obj.sm_state = obj.STATE_REPOSITION_NODE;
            
            % update branch node
            obj.tree(obj.editIndexBranch).replace(obj.editIndexNode, obj.point);
            
        end
        
        
        function obj = fcnNode_putDown(obj)
            %FCNNODE_PUTDOWN release node after moving
            
            % update state transition
            obj.sm_state = obj.STATE_OVER_NODE;
            
            % complete branch
            obj.tree(obj.editIndexBranch).replace(obj.editIndexNode, obj.point);
            
            
            % branch properties
            obj.tree(obj.editIndexBranch).properties();
            
            %{
            % update mask
            obj.fcnMask_update(obj.tree(obj.editIndexBranch).pixels,...
                              obj.tree(obj.editIndexBranch).index,...
                              obj.tree(obj.editIndexBranch).color);
            %}
            
            % is view mask active
            if get(obj.ui_toggleButton_mask, 'Value') == 1
                obj.view();
            end
            
            % update status
            obj.status();
            
        end
        
        
        function obj = fcnNode_overNode(obj)
            %FCNNODE_OVERNODE update mouse pointer 
            % if hoovering over node
            
            % update state transition
            obj.sm_state = obj.STATE_OVER_NODE;
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'circle');
            
        end
        
        function obj = fcnNode_overImage(obj)
            % FCNNODE_OVERIMAGE update mouse pointer
            % if hoovering over image
            
            % update state transition
            obj.sm_state = obj.STATE_IDLE;
            
            % update mouse pointer
            set(obj.ih_figure, 'Pointer', 'arrow');
            
        end
        
        
        
        
        function obj = fcnNode_delete(obj)
            %FCNNODE_DELETE remove nodes in current branch
            
            if obj.indexNode > 1
            
                % update sate transition
                obj.sm_state = obj.STATE_DRAWING;
                
                % remove node
                obj.tree(obj.indexBranch).remove(obj.indexNode);
            
                % update node index
                obj.indexNode = obj.indexNode - 1;
            
                % update status
                obj.status();
                
            else
                
                % remove branch
                obj.editIndexBranch = obj.indexBranch;
                obj.fcnBranch_delete();
                
            end
            
            
        end
        
    end % nodes callback functions
    
    
    %%% --- mask/patch operations --- %%%
    methods
        
        function obj = fcnMask_index(obj, pixels, index, color)
            %FCNMASK_INDEX adds current index to mask
            
            % binary mask
            bry = false(obj.height, obj.width);
            bry(pixels) = true;
            
            % complete closed polygons
            bry = imfill(bry, 'holes');
            
            % dilate binary is faster
            bry = imdilate(bry, strel('disk', obj.dilation));
            
            % set index for mask
            obj.mask(bry) = index;
            
            % cast branch color type
            color = cast(color, 'like', obj.patch);
            
            % format patch to 2D
            obj.patch = reshape(obj.patch, obj.height * obj.width, 3);
            bry = bry(:);
            
            % fill up color palette
            for c = 1 : 3
                obj.patch(bry,c) = color(c);
            end
            
            % reformat to 3D
            obj.patch = reshape(obj.patch, obj.height, obj.width, 3);
            
        end
        
        
        function obj = fcnMask_reset(obj, index)
            %FCNMASK_RESET resets current index in mask
            
            % decrease dimensions
            obj.mask = obj.mask(:);
            obj.patch = reshape(obj.patch, obj.height * obj.width, 3);
            
            % reset index
            obj.patch(obj.mask == index, 1) = 0;
            obj.patch(obj.mask == index, 2) = 0;
            obj.patch(obj.mask == index, 3) = 0;
            
            obj.mask(obj.mask == index) = 0;
            
            % re-transform
            obj.mask = reshape(obj.mask, obj.height, obj.width);
            obj.patch = reshape(obj.patch, obj.height, obj.width, 3);
            
        end
        
        
        function obj = fcnMask_update(obj, pixels, index, color)
            %FCNMASK_MOVE rest & re-index mask
            
            obj.fcnMask_reset(index);
            obj.fcnMask_index(pixels, index, color);
            
        end
        
        
    end % mask/patch operations
    
end % class end