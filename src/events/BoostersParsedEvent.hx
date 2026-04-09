package events
;
   import flash.events.Event;
   
    class BoostersParsedEvent extends Event
   {
      
      public static inline final BOOSTERS_PARSED_UPDATE= "BoostersParsedEvent_BOOSTERS_PARSED_UPDATE";
      
      public function new(param1:String, param2:Bool = false, param3:Bool = false)
      {
         super(param1,param2,param3);
      }
   }


