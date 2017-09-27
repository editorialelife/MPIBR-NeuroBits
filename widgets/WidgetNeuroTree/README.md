# WidgetNeuroTree
user guided tree segmentation

# required

# WidgetNeuroTreeUI

### status
text_status

### tab pushButtons
pushButton_segment
pushButton_load
pushButton_mask
pushButton_export

### tab edit
editBox_dilation
editBox_nhood
checkBox_autoNhood

### methods
* requestEditDilation
* requestEditNhood
* requestEditAuto


# WidgetNeuroTreeViewer (hFigure)
(Public Properties)
click_down
click_up
click_move
click_double
press_key

(Events)
event_clickDown
event_clickUp
event_clickMove
event_clickDouble
event_pressDigit
event_pressBackspace
event_pressEsc

(Request Methods)
changeCursor()

# WidgetNeuroTreeModel

### 
filePath
fileName

dilation
nhood
mask
patch

### Methods
create(click, digit)
extend(click)
stretch(move)
complete(click)
pickup(click, handle)
putdown(click, handle)
select(handle)
deselect(handle)
reposition(click)
remove(handle)
erase(handle)
hover(handle)








### Event/State diagram

event_click_down @ state_drawing -> state_drawing :: obj.model.addnode() # cross
event_click_down @ state_hover -> state_reposition :: obj.model.pickup() # circle, hand
event_click_down @ state_selected -> state_idle :: obj.model.deselect() # arrow

event_click_up @ state_reposition -> state_hover :: obj.model.putdown() # circle, hand

event_click_double @ state_drawing -> state_hover :: obj.model.complete() # circle, hand
event_click_double @ state_hover -> state_selected :: obj.model.select() # arrow

event_mouse_move @ state_drawing -> state_drawing :: obj.model.stretch() # cross
event_mouse_move @ state_reposition -> state_reposition :: obj.model.reposition() # circle, hand

event_press_digit @ state_idle -> state_drawing :: obj.model.create() # cross

event_press_esc @ state_selected -> state_idle :: obj.model.deselect() # arrow
event_press_esc @ state_drawing -> state_idle :: obj.model.complete() # circle, hand

event_press_del @ state_drawing -> state_drawing :: obj.model.remove() # cross
event_press_del @ state_selected -> state_idle :: obj.model.erase() # arrow

event_hover_handle @ state_idle -> state_hover :: obj.model.hover() # circle, hand
event_hover_handle @ state_hover -> state_hover :: obj.model.hover() # circle, hand
