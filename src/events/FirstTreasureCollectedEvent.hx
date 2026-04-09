package events
;
   import flash.events.Event;
   
    class FirstTreasureCollectedEvent extends Event
   {
      
      public static inline final EVENT_NAME= "FirstTreasureCollected";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("FirstTreasureCollected",param1,param2);
      }
   }


