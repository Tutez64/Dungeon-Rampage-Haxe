package events
;
   import flash.events.Event;
   
    class TrophiesUpdatedAccountEvent extends Event
   {
      
      public static inline final EVENT_NAME= "TrophiesUpdatedAccountEvent";
      
      public var trophyCount:UInt = 0;
      
      public function new(param1:UInt, param2:Bool = false, param3:Bool = false)
      {
         super("TrophiesUpdatedAccountEvent",param2,param3);
         trophyCount = param1;
      }
   }


