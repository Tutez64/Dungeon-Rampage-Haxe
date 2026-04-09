package events
;
   import flash.events.Event;
   
    class PlayerExitEvent extends Event
   {
      
      public static inline final EVENT_STRING= "PlayerExitEvent_str";
      
      public var id:UInt = 0;
      
      public function new(param1:UInt, param2:Bool = false, param3:Bool = false)
      {
         id = param1;
         super("PlayerExitEvent_str",param2,param3);
      }
   }


