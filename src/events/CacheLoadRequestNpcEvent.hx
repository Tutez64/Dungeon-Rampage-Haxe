package events
;
   import flash.events.Event;
   
    class CacheLoadRequestNpcEvent extends Event
   {
      
      public static inline final CACHE_LOAD_REQUEST= "Busterncpccahche_event";
      
      public var cacheNpc:Vector<UInt>;
      
      public var cacheSwf:Vector<String>;
      
      public var tilelibraryname:Vector<String>;
      
      public function new(param1:Vector<UInt>, param2:Vector<String>, param3:Vector<String>, param4:Bool = false, param5:Bool = false)
      {
         cacheSwf = param2;
         cacheNpc = param1;
         tilelibraryname = param3;
         super("Busterncpccahche_event",param4,param5);
      }
   }


