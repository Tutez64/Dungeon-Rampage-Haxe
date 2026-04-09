package events
;
   import flash.events.Event;
   
    class FirstTreasureNearbyEvent extends Event
   {
      
      public static inline final EVENT_NAME= "FirstTreasureNearby";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("FirstTreasureNearby",param1,param2);
      }
   }


