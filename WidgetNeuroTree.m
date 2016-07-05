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
    
   
    properties (Access = public, Hidden = true)
        
        %%% --- input properties --- %%%
        
        dilation	% mask dilation size
        nhood       % linking relatives nhood distance 
        
        image       % image CData
        mask        % binary mask
        patch       % color pathch
        tree        % current NeuroTreeBranch list
        
        height      % image height
        width       % image width
        
        path        % current file path
        name        % current file name
        
    end
    
    
    properties (Access = private, Hidden = true)
        
        sm_pair % action/state pair keeping index to sm_table
        sm_table % state transition table
        sm_state % current state in state machine
        
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
        MESSAGE_LENGTH = 25;
        
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
        
        %%% --- Events --- %%%
        ACTION_KEY_DIGIT = 1;
        ACTION_KEY_DEL = 2;
        ACTION_CLICK_DOWN = 3;
        ACTION_CLICK_UP = 4;
        ACTION_CLICK_DOUBLE = 5;
        ACTION_MOUSE_MOVE = 6;
        ACTION_OVER_BRANCH = 7;
        ACTION_OVER_NODE = 8;
        ACTION_OVER_IMAGE = 9;
        ACTION_EMPTY_BRANCH = 10;
        
        %%% --- State Machine Constants --- %%%
        SM_NEXT_STATE = 1;
        SM_MOUSE_POINTER = 2;
        SM_CALLBACK_FCN = 3;
        SM_ACTION_NOW = 1;
        SM_STATE_NOW = 2;
        
    end
    
    events (NotifyAccess = protected)
        
        event_NeuroTree_GetImage
        
    end
    
    %% --- constructor / destructor --- %%
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
    
    
    %% --- user interface methods --- %%
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
            
            set(obj.ui_toggleButton_segment, 'String', 'Clear');
            set(obj.ui_toggleButton_segment, 'Value', 1);
                
            obj.segment();
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
    
    
    %% --- user interface respond methods --- %%
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
            %{
            hold(obj.ih_axes, 'on');
            obj.ih_patch = imshow(obj.patch,[],...
                                  'Parent', obj.ih_axes,...
                                  'Border', 'tight',...
                                  'InitialMagnification', 'fit');
            hold(obj.ih_axes, 'off');
            set(obj.ih_patch, 'AlphaData', obj.PATCHALPHA_OFF);
            %}
            
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
            obj.status(obj.indexBranch, obj.indexNode);
            
        end
        
        
        function obj = clear(obj)
        	%CLEAR clean tree and drawing
            
            % evoke automatic export
            %obj.export();
            
            % switch off drawing callbacks
            obj.drawing('off');
            
            % clear tree
            if size(obj.tree, 1) > 0
                
                % dispose each branch
                while ~isempty(obj.tree)
                    obj.tree(1).dispose();
                    obj.tree(1) = [];
                end
                
                % set default properties
                obj.default();
                
            end
        end
        
        
        function obj = load(obj)
            %LOAD load tree file
            
            % choose file to load
            [fileName, filePath] = uigetfile({'*_neuroTree_*.txt', 'WidgetNeuroTree files'},'Pick a file');
            
            % open file to read
            fpRead = fopen([filePath, fileName], 'r');
            txt = textscan(fpRead, '%s', 'delimiter', '\n');
            fclose(fpRead);
            txt = txt{:};
            
            % read dilation
            idx_txt_dilation = strncmp('# dilation[px]:', txt, 15);
            obj.dilation = sscanf(txt{idx_txt_dilation},'# dilation[px]: %d');
            
            % read nhood
            idx_txt_nhood = strncmp('# nhood[px]:', txt, 12);
            obj.nhood = sscanf(txt{idx_txt_nhood},'# nhood[px]: %d');
            
            % read branch info
            idx_txt_branch = strncmp('[', txt, 1);
            idx_txt_branch = cumsum(idx_txt_branch);
            branchCount = max(idx_txt_branch);
            for b = 1 : branchCount
                
                obj.tree = cat(1, obj.tree,...
                              NeuroTreeBranch('Index', b,...
                                              'Depth', '0',...
                                              'Height', obj.height,...
                                              'Width', obj.width,...
                                              'Parent', obj.ih_axes));
                obj.tree(b).load(txt(idx_txt_branch == b));
                
            end
            
            % update user message
            obj.status(obj.indexBranch, obj.indexNode);
            
            
        end
        
        
        function obj = export(obj)
        	%EXPORT exports current tree
            
            % check if tree exists
            if obj.indexBranch == 0
                msg = 'Nothing to export, segment a tree.';
            else
            
                % create output file
                fileOut = [obj.path,...
                           filesep,...
                           obj.name,...
                           '_neuroTree_',...
                           datestr(now,'ddmmmyyyy'),...
                           '.txt'];
                fpWrite = fopen(fileOut, 'w');
                
                % output settings
                fprintf(fpWrite, '# file_path: %s\n', obj.path);
                fprintf(fpWrite, '# file_name: %s\n', obj.name);
                fprintf(fpWrite, '# dilation[px]: %d\n', obj.dilation);
                fprintf(fpWrite, '# nhood[px]: %d\n', obj.nhood);
                fprintf(fpWrite, '\n');
                % loop over each branch
                treeSize = size(obj.tree, 1);
                for b = 1 : treeSize
                    obj.tree(b).export(fpWrite);
                end
                fclose(fpWrite);
           
                % user message
                [~, fileTag] = fileparts(fileOut);
                msgLength = length(fileTag);
                if msgLength > obj.MESSAGE_LENGTH
                    msgLength = obj.MESSAGE_LENGTH;
                    fileTag = fileTag(1:msgLength);
                    fileTag = [fileTag,'...'];
                end
                msg = sprintf('NeuroTree exported to %s', fileTag);
                
            end
            
        	set(obj.ui_text_status, 'String', msg);
            obj.ui_grid.align(obj.ui_text_status,...
                              'VIndex', 3,...
                              'HIndex', 1:4,...
                              'Anchor', 'center');
            
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
        
        
        function obj = status(obj, idxBranch, idxNode)
            %STATUS updates status message
            
            if idxBranch > 0
                
                msg = sprintf('branch %d, node %d, depth %d, span[px] %.2f',...
                          idxBranch,...
                          idxNode,...
                          obj.tree(idxBranch).depth,...
                          obj.tree(idxBranch).span);
                      
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
    
    
    %% --- user drawing interaction callbacks --- %%
    methods
        
        function obj = sminit(obj)
            %SMINIT initialize state machine
            
            obj.sm_pair = [];
            obj.sm_table = {};
            obj.sm_state = obj.STATE_IDLE;
            
            %%% - ACTION / STATE Transition Diagram - %%%
            % sm_pair = [ACTION_NOW, STATE_NOW];
            % sm_table = {STATE_NEXT, MOUSE_POINTER, CALLBACK_FUNCTION};
            
            % ACTION_KEY_DIGIT    x STATE_IDLE              -> STATE_DRAWING, mouse=cross @ fcnBranch_create();
            % ACTION_MOUSE_MOVE   x STATE_DRAWING           -> STATE_DRAWING, mouse=cross @ fcnBranch_stretch();
            % ACTION_CLICK_DOWN   x STATE_DRAWING           -> STATE_DRAWING, mouse=cross @ fcnBranch_extend();
            % ACTION_CLICK_DOUBLE x STATE_DRAWING           -> STATE_OVER_NODE, mouse=circle @ fcnBranch_complete();
            % ACTION_CLICK_DOWN   x STATE_OVER_BRANCH       -> STATE_REPOSITION_BRANCH, mouse=hand @ fcnBranch_pickUp();
            % ACTION_MOUSE_MOVE   x STATE_REPOSITION_BRANCH -> STATE_REPOSITION_BRANCH, mouse=hand @ fcnBranch_move();
            % ACTION_CLICK_UP     x STATE_REPOSITION_BRANCH -> STATE_OVER_BRANCH, mouse=hand @ fcnBranch_putDown();
            % ACTION_CLICK_DOUBLE x STATE_OVER_BRANCH       -> STATE_SELECTED_BRANCH, mouse=arrow @ fcnBranch_select();
            % ACTION_CLICK_DOWN   x STATE_SELECTED_BRANCH   -> STATE_IDLE, mouse=arrow @ fcnBranch_deselect();
            % ACTION_KEY_DEL      x STATE_SELECTED_BRANCH   -> STATE_IDLE, mouse=arrow @ fcnBranch_delete();
            % ACTION_EMPTY_BRANCH x STATE_DRAWING           -> STATE_IDLE, mouse=arrow @ fcnBranch_delete();
            % ACTION_KEY_DEL      x STATE_DRAWING           -> STATE_DRAWING, mouse=cross @ fcnNode_delete();
            % ACTION_CLICK_DOWN   x STATE_OVER_NODE         -> STATE_REPOSITION_NODE, mouse=circle @ fcnNode_pickUp();
            % ACTION_MOUSE_MOVE   x STATE_REPOSITION_NODE   -> STATE_REPOSITION_NODE, mouse=circle @ fcnNode_move();
            % ACTION_CLICK_UP     x STATE_REPOSITION_NODE   -> STATE_OVER_NODE, mouse=circle @ fcnNode_putDown();
            % ACTION_OVER_IMAGE   x STATE_OVER_BRANCH       -> STATE_IDLE, mouse=arrow @ [];
            % ACTION_OVER_IMAGE   x STATE_OVER_NODE         -> STATE_IDLE, mouse=arrow @ [];
            % ACTION_OVER_BRANCH  x STATE_IDLE              -> STATE_OVER_BRANCH, mouse=hand @ [];
            % ACTION_OVER_BRANCH  x STATE_OVER_NODE         -> STATE_OVER_BRANCH, mouse=hand @ [];
            % ACTION_OVER_NODE    x STATE_IDLE              -> STATE_OVER_NODE, mouse=circle @ [];
            % ACTION_OVER_NODE    x STATE_OVER_BRANCH       -> STATE_OVER_NODE, mouse=circle @ [];                
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_KEY_DIGIT, obj.STATE_IDLE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_DRAWING, 'cross', @obj.fcnBranch_create}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_MOUSE_MOVE, obj.STATE_DRAWING]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_DRAWING, 'cross', @obj.fcnBranch_stretch}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_DOWN, obj.STATE_DRAWING]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_DRAWING, 'cross', @obj.fcnBranch_extend}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_DOUBLE, obj.STATE_DRAWING]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_OVER_NODE, 'circle', @obj.fcnBranch_complete}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_DOWN, obj.STATE_OVER_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_REPOSITION_BRANCH, 'hand', @obj.fcnBranch_pickUp}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_MOUSE_MOVE, obj.STATE_REPOSITION_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_REPOSITION_BRANCH, 'hand', @obj.fcnBranch_move}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_UP, obj.STATE_REPOSITION_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_OVER_BRANCH, 'hand', @obj.fcnBranch_putDown}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_DOUBLE, obj.STATE_OVER_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_SELECTED_BRANCH, 'arrow', @obj.fcnBranch_select}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_DOWN, obj.STATE_SELECTED_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_IDLE, 'arrow', @obj.fcnBranch_deselect}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_KEY_DEL, obj.STATE_SELECTED_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_IDLE, 'arrow', @obj.fcnBranch_delete}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_EMPTY_BRANCH, obj.STATE_DRAWING]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_IDLE, 'arrow', @obj.fcnBranch_delete}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_KEY_DEL, obj.STATE_DRAWING]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_DRAWING, 'cross', @obj.fcnNode_delete}};
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_DOWN, obj.STATE_OVER_NODE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_REPOSITION_NODE, 'circle', @obj.fcnNode_pickUp}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_MOUSE_MOVE, obj.STATE_REPOSITION_NODE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_REPOSITION_NODE, 'circle', @obj.fcnNode_move}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_CLICK_UP, obj.STATE_REPOSITION_NODE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_OVER_NODE, 'circle', @obj.fcnNode_putDown}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_OVER_IMAGE, obj.STATE_OVER_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_IDLE, 'arrow', []}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_OVER_IMAGE, obj.STATE_OVER_NODE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_IDLE, 'arrow', []}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_OVER_BRANCH, obj.STATE_IDLE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_OVER_BRANCH, 'hand', []}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_OVER_BRANCH, obj.STATE_OVER_NODE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_OVER_BRANCH, 'hand', []}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_OVER_NODE, obj.STATE_IDLE]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_OVER_NODE, 'circle', []}};
            
            
            obj.sm_pair = cat(1, obj.sm_pair, [obj.ACTION_OVER_NODE, obj.STATE_OVER_BRANCH]);
            obj.sm_table(size(obj.sm_pair, 1)) = {{obj.STATE_OVER_NODE, 'circle', []}};
            
            
            % check for disambiguous action/state pair
            if size(obj.sm_pair, 1) ~= size(unique(obj.sm_pair, 'rows'), 1)
                error('WidgetNeuroTree:SMINIT','action-state pair list is not unique.');
            end
            
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
                
            elseif strcmp('off', interact)
                
                % remove figure callbacks
                set(obj.ih_figure,...
                        'WindowButtonMotionFcn', [],...
                        'WindowButtonDownFcn', [],...
                        'WindowButtonUpFcn', [],...
                        'WindowKeyPressFcn', []);
               
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
            if isempty(obj.keychar)
                obj.keychar = 0;
            end
            
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
                
                obj.fcnStateMachine_transition(obj.ACTION_OVER_IMAGE);
                
            elseif isgraphics(hobj, 'line')
            
                % decide between line and point
                if strcmp(hobj.LineStyle, 'none')
                    
                    obj.fcnStateMachine_transition(obj.ACTION_OVER_NODE);
                    
                elseif strcmp(hobj.LineStyle,'-')
                    
                    obj.fcnStateMachine_transition(obj.ACTION_OVER_BRANCH);
                    
                end
                
            end
            
        end
        
        
        function obj = fcnDrawing_pressKey(obj, ~, ~)
            %FCNDRAWING_PRESSKEY drawing callback function
            % defines state action on key press
            
            obj.press();
            
            if (obj.keychar >= '0') && (obj.keychar <= '9')
                
                obj.fcnStateMachine_transition(obj.ACTION_KEY_DIGIT);
                
            elseif uint8(obj.keychar) == 8 %(DEL)
                
                obj.fcnStateMachine_transition(obj.ACTION_KEY_DEL);
                
            end
            
        end
        
        
        function obj = fcnDrawing_moveMouse(obj, ~, ~)
            %FCNDRAWING_MOVEMOUSE drawing callback function
            % defines state action on mouse move
            
            obj.hover();
            obj.click();
            obj.fcnStateMachine_transition(obj.ACTION_MOUSE_MOVE);
            
        end
        
        
        function obj = fcnDrawing_clickDown(obj, ~, ~)
            %FCNDRAWING_CLICKDOWN drawing callback function
            % defines state action on mouse right click down
            
            obj.click();
            
            clickSelection = get(obj.ih_figure, 'SelectionType');
            
            if strcmp(clickSelection, 'normal')
                
                obj.fcnStateMachine_transition(obj.ACTION_CLICK_DOWN);
                
            elseif strcmp(clickSelection, 'open')
                
                obj.fcnStateMachine_transition(obj.ACTION_CLICK_DOUBLE);
                
            end
            
        end
        
        
        function obj = fcnDrawing_clickUp(obj, ~, ~)
            %FCNDRAWING_CLICKUP drawing callback function
            % defines state action on mouse right click up
            
            obj.click();
            obj.fcnStateMachine_transition(obj.ACTION_CLICK_UP);
            
        end
        
        
        function obj = fcnStateMachine_transition(obj, sm_action)
            %FCNSTATEMACHINE_TRANSITION execute transition callback
            
            sm_index = (obj.sm_pair(:, obj.SM_ACTION_NOW) == sm_action) & ...
                       (obj.sm_pair(:, obj.SM_STATE_NOW) == obj.sm_state);
            
            if any(sm_index)
                
                % get current callbackData
                callbackData = obj.sm_table{sm_index};
                
                % set next state
                obj.sm_state = callbackData{obj.SM_NEXT_STATE};
                
                % set mouse pointer
                set(obj.ih_figure, 'Pointer', callbackData{obj.SM_MOUSE_POINTER});
                
                % execute state machine callback
                callbackData{obj.SM_CALLBACK_FCN}();
                
            end
            
            % add granularity (20 ms delay)
            drawnow;
            
        end
        
        
    end % user drawing interaction callbacks
    
    %% --- branch callback functions --- %%
    methods
        
        function obj = fcnBranch_create(obj)
            %FCNBRNACH_CREATE allocates new branch in tree
            
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
           obj.status(obj.indexBranch, obj.indexNode);
                                         
        end
        
        
        function obj = fcnBranch_stretch(obj)
            %FCNBRANCH_STRETCH extend branch without appending node
            
            % update last node in current branch
            obj.tree(obj.indexBranch).stretch(obj.indexNode + 1, obj.point);
            
        end
        
        
        function obj = fcnBranch_extend(obj)
            %FCNBRANCH_EXTEND append node to current branch
            
            % update node index
            obj.indexNode = obj.indexNode + 1;
            
            % append node in current branch
            obj.tree(obj.indexBranch).extend(obj.indexNode, obj.point);
            
            % measure branch length
            obj.tree(obj.indexBranch).measure();
            
            % update status
            obj.status(obj.indexBranch, obj.indexNode);
            
        end
        
        
        function obj = fcnBranch_complete(obj)
            %FCNBRANCH_COMPLETE complete branch drawing
            
            % complete branch process
            obj.tree(obj.indexBranch).complete();
            
            % update branch properties
            obj.tree(obj.indexBranch).properties();
            
            % activate full UI 
            if obj.indexBranch > 0
                obj.enable([], 'on');
            end
            
            % update status
            obj.status(obj.indexBranch, obj.indexNode);
            
        end
        
        
        function obj = fcnBranch_pickUp(obj)
            %FCNBRANCH_PICKUP pick up last branch position before move
            
            % set edit point
            obj.editPoint = obj.point;
            
            % set edit branch index
            % user data hides branch index (check NeuroTreeBranch
            % constructor)
            obj.editIndexBranch = obj.hoverHandle.UserData;
            obj.editIndexNode = size(obj.tree(obj.editIndexBranch).nodes, 1);
            
            % update status
            obj.status(obj.editIndexBranch, obj.editIndexNode);
            
        end
        
        
        function obj = fcnBranch_move(obj)
            %FCNBRANCH_MOVE shift branch with edit click displacement
            
            % displacement from pickUp click
            deltaClick = obj.point - obj.editPoint;
            
            % move branch position
            obj.tree(obj.editIndexBranch).move(deltaClick);
            
            % update pickUp click
            obj.editPoint = obj.point;
            
        end
        
        
        function obj = fcnBranch_putDown(obj)
            %FCNBRANCH_PUTDOWN release branch after moving
            
            % update branch properties
            obj.tree(obj.editIndexBranch).interpolate();
            
            % update status
            obj.status(obj.editIndexBranch, obj.editIndexNode);
                         
        end
        
        
        function obj = fcnBranch_select(obj)
            %FCNBRANCH_SELECT add highlight to current branch
            
            obj.tree(obj.editIndexBranch).select();
            
            % update user status
            obj.status(obj.editIndexBranch, obj.editIndexNode);
            
        end
        
        
        function obj = fcnBranch_deselect(obj)
            %FCNBRANCH_DESELECT remove highlight from current branch
            
            obj.tree(obj.editIndexBranch).deselect();
            
            % update status
            obj.status(obj.indexBranch, obj.indexNode);
            
        end
        
        
        function obj = fcnBranch_delete(obj)
            %FCNBRANCH_DELETE remove current branch from tree
            
            % reset mask
            %obj.fcnMask_reset(obj.tree(obj.editIndexBranch).index);
                          
            % delete given branch from tree
            obj.tree(obj.editIndexBranch).dispose();
            obj.tree(obj.editIndexBranch) = [];
            
            % update current branch / node index
            obj.indexBranch = numel(obj.tree);
            
            % check if tree is empty else reindex
            if obj.indexBranch == 0
                obj.default();
            else
                for b = 1 : obj.indexBranch
                    obj.tree(b).reindex(b);
                end
                
                obj.indexNode = size(obj.tree(obj.indexBranch).nodes, 1);
            
            end
            
            % update status
            obj.status(obj.indexBranch, obj.indexNode);
            
        end
        
    end % branch callback functions
    
    
    %% --- nodes callback functions --- %%
    methods
        
        function obj = fcnNode_pickUp(obj)
            %FCNNODE_PICKUP last node position before move
            
            % set edit branch index
            % user data hides branch index (check NeuroTreeBranch
            % constructor)
            obj.editIndexBranch = obj.hoverHandle.UserData;
            
            % set index of nodex
            dist = sqrt(sum(bsxfun(@minus, [obj.hoverHandle.XData', obj.hoverHandle.YData'], obj.point) .^ 2, 2));
            [~, obj.editIndexNode] = min(dist);
            
            % update status
            obj.status(obj.editIndexBranch, obj.editIndexNode);
            
        end
        
        
        function obj = fcnNode_move(obj)
            %FCNNODE_MOVE shift node with edit click displacement
            
            % update branch node
            obj.tree(obj.editIndexBranch).replace(obj.editIndexNode, obj.point);
            
        end
        
        
        function obj = fcnNode_putDown(obj)
            %FCNNODE_PUTDOWN release node after moving
            
            % branch properties
            obj.tree(obj.editIndexBranch).properties();
            
            % update status
            obj.status(obj.editIndexBranch, obj.editIndexNode);
            
        end
        
        
        function obj = fcnNode_delete(obj)
            %FCNNODE_DELETE remove nodes in current branch
            
            if obj.indexNode > 1
                
                % remove node
                obj.tree(obj.indexBranch).remove(obj.indexNode);
            
                % update node index
                obj.indexNode = obj.indexNode - 1;
                
                % update status
                obj.status(obj.indexBranch, obj.indexNode);
            
            else
                
                % remove branch
                obj.editIndexBranch = obj.indexBranch;
                obj.fcnStateMachine_transition(obj.ACTION_EMPTY_BRANCH);
                
            end
            
        end
        
    end % nodes callback functions
    
    
    %% --- mask/patch operations --- %%
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