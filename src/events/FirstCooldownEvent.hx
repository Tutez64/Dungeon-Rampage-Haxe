package events
;
   import flash.events.Event;
   
    class FirstCooldownEvent extends Event
   {
      
      public static inline final EVENT_NAME= "FirstCooldown";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("FirstCooldown",param1,param2);
      }
   }


