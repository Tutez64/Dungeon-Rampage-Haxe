package events
;
   import flash.events.Event;
   
    class II_FloorCompleteEvent extends Event
   {
      
      public static inline final TYPE= "II_FLOOR_COMPLETE";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("II_FLOOR_COMPLETE",param1,param2);
      }
   }


