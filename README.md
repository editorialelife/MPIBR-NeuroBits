## NeuroBits
> NeuroBits is an assembly of MatLab GUI widgets providing the functionality of user guided segmentation of neuronal morphology.

##Usage
> Start NeuroBits and use the **Folder Browser** panel to set file or folder input and browse among available LSM images. Once the image file is read use the **Image Browser** panel to choose desired channel or stack position. One can also visualise projection of the image stack. The segmentation process is initialised by the **Neuro Tree** panel. Here the user starts interactive window properties which allow hand-drawn segmentation of neuronal morphology. An automatic linking of branches and order is kept in the background. **Neuro Puncta** panel should be used to identify all puncta-like signal in channel and export those positions. **Batch Processing** panel will correlate results between both procedures and export appropriate table formatted information.

## Widget Description
>###Folder Browser
>> Class *WidgetFolderBrowser* is doing something
>###Image Browser
>> Class *WidgetImageBrowser* implements a 
>###Neuro Tree
>> Class *WidgetNeuroTree* uses an event driven state machine to simplify user action logic. New event-state pairs can be added to a list of available combinations to easily extend class functionality and features. Each region of interest is refer to as a branch and each point determining the line is refer as node.
>###Neuro Puncta
>> Class *WidgetNeuroPuncta* identifies punctate signal in an image. The algorithm behind identifies local maxima in restricted size. A second input parameter is defining a minimum intensity threshold to avoid local maxima in background image.
>### Batch Processing
>> Class *WidgetBatchProcessing* uses segmentation mask from Neuro Tree and correlate it with puncta positions of Neuro Puncta. Different exports are available.


## Bugs
Please report all bugs [here](mailto:sciclist@brain.mpg.de)
