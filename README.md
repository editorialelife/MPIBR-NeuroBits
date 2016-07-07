## NeuroBits
> NeuroBits is an assembly of MatLab GUI widgets providing the functionality of user guided segmentation for neuronal morphology.

##Usage
> Start NeuroBits and use the *Folder Browser* panel to choose file or folder input.  Browse through available LSM images to choose one of interest. First plane in a stacked file is shown on the way. Use the *Image Browser* panel to choose desired channel or stack position in current image. One can also visualise diverse projections of the image stack. The segmentation process is initialised by the *Neuro Tree* panel. Here the user starts interactive window which allows hand-drawn segmentation of neuronal morphology. ROI is initialised by pressing a number between 0 and 9, where the digit correspond to neuronal tree depth. 0 depth defines a closed polygon region design to describe cell soma. Single mouse click will introduce new node in each branch and double mouse click will complete the branch. ROIs position can be edit by moving around the whole branch or desired nodes. To remove a ROI from the scene, double click on it to select and press DEL button. View/Hide UI buttons activate colour mask overlay of the current tree. Load/Export UI buttons use defined text format to store and reuse tree properties. *Neuro Puncta* panel should be used over channel with a puncta-like signal. The segmentation algorithm will locate each puncta object and visualise its centre of mass. The field of view is automatically divided in a concentric circular sectors spaced equally from a given central point. Each puncta will be clustered to single sector fulfilling the criteria for Sholl analysis. *Batch processing* panel is designed to merge results from the previous two segmentation steps. Table-like export format summarise overall results and provide enough information for further statistical analysis. Some plots will be generated on those steps too. Batch job facilitates fast information extraction for all segmented regions in the current folder.

## Widget Description
>###Folder Browser
>> Class *WidgetFolderBrowser* implements an interactive tool to choose folder or image of interest. One can easy navigate through folder content and choose file of interest. Class event is notified every time a new image is chosen from the list of available files, facilitating communication with other classes. The widget is designed as a general purpose folder browser, where the desired file extension should be provided. In the case of *NeuroBits* it is *.lsm files.

>###Image Browser
>> Class *WidgetImageBrowser* reads and visualise stacked images in either TIF or LSM format. The class uses *readLSMInfo.m* and *readLSMImage.m* routines to do image IO access. The routines are adapted only for non-compressed images as one would normally get using Zeiss microscopes. The reading operations are fast low level byte reading defined by header offset. No external library is needed. The widget will create an image figure window, containing the image axes and CData property. Visualising range can be set by the user. Event notifications are triggered on altering the open and close requests of the image figure window. 

>###Neuro Tree
>> Class *WidgetNeuroTree* adds interactive properties to the image figure window provided by *WidgetImageBrowser*. A user-guided segmentation for neuronal morphology is  available through an event-driven state machine, that simplifies user-action logic. New event-state pairs can be added to a list of available combinations and easily extend class functionality and features. Regions of interest are referred to as branches and are being composed of nodes (distinct mouse click position over neuronal morphology). The hierarchy and connectivity of the branches is maintained by user defined order (tree depth) and automatic linking in a given neighbourhood distance. Additional property for each branch is its interpolated length in pixels (or units provided in the resolution header of the image file). 

>###Neuro Puncta
>> Class *WidgetNeuroPuncta* identifies puncta-like signal in an image. The algorithm behind identifies 2D local maxima in a restricted neighbourhood. A second input parameter defines a minimum intensity threshold to avoid background signal. Sholl analysis are also implemented. The field of view is automatically split in concentric circular sectors with equally spaced distance. The centre of the Sholl mask is either specified by the user or is interpolated from the mask provided by *WidgetNeuroTree*.

>### Batch Processing
>> Class *WidgetBatchProcessing* correlate the segmentation done by *WidgetNeuroTree* and *WidgetNeuroPuncta*. Neuronal morphology and puncta overlay statistics are being exported to tab delimited text files, appropriate for any further statistical programs input. Plots depicting average branch length and puncta density per branch order are visualised.

## Collaborators
> Anne-Sophie Hafner [email](mailto:anne-sophie.hafner@brain.mpg.de)

> Lisa Kochen [email](mailto:lisa.kochen@brain.mpg.de)

## Bugs
Please report all bugs [here](mailto:sciclist@brain.mpg.de)
