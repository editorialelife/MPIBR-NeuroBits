# WidgetImageBrowser

widget to navigate in multi-channel and/or multi-stack images.
stack projection can be requested.
adjust bit depth to limit viewer scale.


# Requirements

[GUI Layout Toolbox](https://de.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox)

[ImageIO](https://software.scic.brain.mpg.de/projects/MPIBR/ImageIO)


## Model-view-controller paradigm

the widget uses MVC design.


### Model

updateFile
updateIndexStack
updateIndexChannel
updateCData
updateProjection
requestSizeStack
requestSizeChannel
requestResolution
requestCLimit

### UI

user actions:
* event_changeChannel
* event_changeStack
* event_requestProjection
* event_changeCLimits

viewer responds:
* updateStatus
* updateLabelChannel
* updateLabelStack
* requestProjectionType
* requestProjectionIsKeep
* requestCLimitValues
* requestStepChannel
* requestStepStack
* requestEnableChannel
* requestEnableStack

### VIEWER
* updateCLimit
* updatePreview

