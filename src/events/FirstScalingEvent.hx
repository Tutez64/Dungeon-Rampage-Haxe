package events
;
   import flash.events.Event;
   
    class FirstScalingEvent extends Event
   {
      
      public static inline final EVENT_NAME= "FirstScaling";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("FirstScaling",param1,param2);
      }
   }


