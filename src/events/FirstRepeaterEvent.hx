package events
;
   import flash.events.Event;
   
    class FirstRepeaterEvent extends Event
   {
      
      public static inline final EVENT_NAME= "FirstRepeater";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("FirstRepeater",param1,param2);
      }
   }


