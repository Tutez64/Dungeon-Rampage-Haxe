package com.wildtangent
;
   import flash.events.Event;
   
    final class Stats extends Core
   {
      
      public function new()
      {
         super();
      }
      
      public function getStats(param1:ASObject) 
      {
         var obj:ASObject = param1;
         if(vexReady)
         {
            if(!ASCompat.toBool(myVex.hasEventListener(Event.COMPLETE)))
            {
               myVex.addEventListener(Event.COMPLETE,function(param1:Event)
               {
                  dispatchEvent(new StatsEvent(StatsEvent.STATS_COMPLETE,param1.target.statsData));
               });
            }
            myVex.getStats(obj);
         }
         else
         {
            storeMethod(getStats,obj);
         }
      }
      
      public function submit(param1:ASObject) : Bool
      {
         if(vexReady)
         {
            return ASCompat.toBool(myVex.submitStats(param1));
         }
         storeMethod(submit,param1);
         return true;
      }
      
      public function sendExistingParameters() 
      {
         if(_error != null)
         {
            ASCompat.setProperty(myVex, "error", _error);
         }
      }
      
      @:isVar public var error(never,set):ASFunction;
public function  set_error(param1:ASFunction) :ASFunction      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "error", param1);
         }
         else
         {
            _error = param1;
         }
return param1;
      }
   }


