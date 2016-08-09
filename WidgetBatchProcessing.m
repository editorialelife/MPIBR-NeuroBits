classdef WidgetBatchProcessing < handle
    %
    % WidgetBatchProcessing
    %
    % GUI Widget for 
    % batch processing
    %
    % requires:
    %    uiGridLayout.m
    %
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties (Access = private, Hidden = true)
        
        ui_parent
        ui_panel
        ui_grid
        
    end
    
    properties (Constant, Hidden)
        
        %%% --- UI properties --- %%%
        UIWINDOW_SIZE = [1, 1, 256, 130];
        GRID_VGAP = [15, 2, 5];
        GRID_HGAP = [5, 2, 5];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE COLOR
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY COLOR
        PUSHBUTTON_SIZE = [1, 1, 90, 26];
        EDITBOX_SIZE = [1, 1, 45, 20];
        
    end
    
    methods
        
        function obj = WidgetBatchProcessing(varargin)
            %WIDGETNEUROPUNCTA
            
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
                    'Tag', 'hNeuroPuncta',...
                    'Name', 'NeuroPuncta',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Color', obj.BACKGROUND_COLOR,...
                    'Resize', 'off',...
                    'Units', 'pixels',...
                    'Position', obj.UIWINDOW_SIZE,...
                    'CloseRequestFcn', @obj.fcnCallback_closeUserInterface);
                movegui(obj.ui_parent, 'northwest');
                
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            
            % render User Interface
            obj.renderUserInterface();
            
        end
        
        
        function obj = dispose(obj)
            %DISPOSE
            
            % remove grid
            if isa(obj.ui_grid, 'uiGridLayout')
                delete(obj.ui_grid);
            end
            
            % check if parent is figure or was inherit
            if isgraphics(obj.ui_parent,'figure')
                delete(obj.ui_parent);
            end
            
            delete(obj);
            
        end
        
        
        function obj = renderUserInterface(obj)
            %RENDERUSERINTERFACE
            
            %%% --- create widget panel --- %%%
            obj.ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Batch Processing',...
                'TitlePosition', 'lefttop',...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'normalized',...
                'Position', [0, 0, 1, 1],...
                'Units', 'pixels');
            
            %%% --- create grid object --- %%%
            obj.ui_grid = uiGridLayout(...
                'Parent', obj.ui_parent,...
                'VGrid', 4,...
                'HGrid', 4,...
                'VGap', obj.GRID_VGAP,...
                'HGap', obj.GRID_HGAP);
            
        end
        
    end
    
    %% --- user interface callbacks --- %%
    methods
        
        function obj = fcnCallback_closeUserInterface(obj, ~, ~)
            %FCNCALLBACK_CLOSEUSERINTERFACE
            
            obj.dispose();
            
        end
    end
    
    
end

