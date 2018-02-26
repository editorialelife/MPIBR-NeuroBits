classdef WidgetImageBrowser < handle
    
    properties
        
        ui
        viewer
        model
        
    end
    
    %% --- constructor/controller --- %%
    methods
        
        function obj = WidgetImageBrowser(varargin)
            
            % parse input
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @(varin) (isempty(varin) || isgraphics(varin)));
            addParameter(parserObj, 'Axes', [], @(varin) (isempty(varin) || isgraphics(varin)));
            parse(parserObj, varargin{:});
            
            % create MVC
            obj.ui = WidgetImageBrowserUi(parserObj.Results.Parent);
            if ~isa(obj.ui, 'WidgetImageBrowserUi')
                error('WidgetImageBrowser: initializing Ui failed!');
            end
            
            if isempty(parserObj.Results.Axes)
                obj.viewer = WidgetImageBrowserViewer();
            else
                obj.viewer = WidgetImageBrowserViewer(parserObj.Results.Axes);
            end
            if ~isa(obj.viewer, 'WidgetImageBrowserViewer')
                error('WidgetImageBrowser: initializing Viewer failed!');
            end
            
            obj.model = WidgetImageBrowserModel();
            if ~isa(obj.model, 'WidgetImageBrowserModel')
                error('WidgetImageBrowser: initializing Model failed!');
            end
            
            % create controller
            addlistener(obj.ui, 'event_changeStack', @obj.fcnCallback_changeStack);
            addlistener(obj.ui, 'event_changeChannel', @obj.fcnCallback_changeChannel);
            addlistener(obj.ui, 'event_changeCLimit', @obj.fcnCallback_changeCLimit);
            addlistener(obj.ui, 'event_changeProjection', @obj.fcnCallback_changeProjection);
            addlistener(obj.model, 'cdata', 'PostSet', @obj.fcnCallback_changeCData);
            
        end
        
        
        function obj = read(obj, varfile)
            
            obj.model.updateFile(varfile);
            obj.model.updateCData();
            
            
            if obj.model.stack == obj.model.requestSizeStack
                
                obj.ui.requestEnableStack('off');
                
            else
                
                obj.ui.requestEnableStack('on');
                
            end
            
            if obj.model.channel == obj.model.requestSizeChannel
                
                obj.ui.requestEnableChannel('off');
                
            else
                
                obj.ui.requestEnableChannel('on');
                
            end
            
        end
        
        function obj = status(obj)
            
            obj.ui.updateLabelStack(sprintf('stack %d / %d', obj.model.stack, obj.model.requestSizeStack));
            obj.ui.updateLabelChannel(sprintf('channel %d / %d', obj.model.channel, obj.model.requestSizeChannel));
            obj.ui.updateStatus(sprintf('resolution: %d x %d (%.2f x %.2f units)\n%s (%d, %d)',...
                obj.model.requestResolution('Pixels'),...
                obj.model.requestResolution('Units'),...
                obj.model.requestBitDepth(),...
                round(obj.model.requestCLimit())));
            
        end
        
    end
    
    
    
    %% --- Controller Callbacks --- %%
    methods
        
        
        function obj = fcnCallback_changeCData(obj, ~, ~)
            
            obj.viewer.updatePreview(obj.model.cdata);
            obj.viewer.updateCLimit(obj.ui.requestCLimitValues());
            obj.status();
            
        end
        
        function obj = fcnCallback_changeStack(obj, ~, ~)
            
            obj.model.updateIndexStack(obj.ui.requestStepStack);
            obj.model.updateCData();
            obj.status();
            
        end
        
        function obj = fcnCallback_changeChannel(obj, ~, ~)
            obj.model.updateIndexChannel(obj.ui.requestStepChannel);
            if obj.ui.requestProjectionIsKeep
                obj.model.updateProjection(obj.ui.requestProjectionType());
            else
                obj.model.updateCData();
            end
            obj.status();
            
        end
        
        function obj = fcnCallback_changeCLimit(obj, ~, ~)
            
            obj.viewer.updateCLimit(obj.ui.requestCLimitValues());
            
        end
        
        function obj = fcnCallback_changeProjection(obj, ~, ~)
            
            obj.model.updateProjection(obj.ui.requestProjectionType());
            
        end
        
    end
    
end