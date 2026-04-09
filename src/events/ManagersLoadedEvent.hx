package events
;
   import flash.events.Event;
   
    class ManagersLoadedEvent extends Event
   {
      
      public static inline final EVENT_NAME= "ManagersLoadedEvent";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("ManagersLoadedEvent",param1,param2);
      }
   }


