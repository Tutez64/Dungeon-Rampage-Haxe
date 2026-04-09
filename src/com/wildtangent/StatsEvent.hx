package com.wildtangent
;
   import flash.events.Event;
   
    class StatsEvent extends Event
   {
      
      public static inline final STATS_COMPLETE= "statsLoaded";
      
      public var StatsData:ASObject;
      
      public function new(param1:String, param2:ASObject)
      {
         super(param1);
         StatsData = param2;
      }
   }


