classdef (ConstructOnLoad) UserEventData < event.EventData
   properties
       userdata
   end
   
   methods
      function data = UserEventData(userdata)
         data.userdata = userdata;
      end
   end
end