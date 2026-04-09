package brain.utils
;
   import flash.events.HTTPStatusEvent;
   import flash.net.URLRequestHeader;
   
    class HttpStatusEventUtils
   {
      
      public function new()
      {
         
      }
      
      public static function getTraceId(param1:HTTPStatusEvent) : String
      {
         if(param1 == null || param1.responseHeaders == null)
         {
            return null;
         }
         var _loc2_:URLRequestHeader;
         final __ax4_iter_59 = param1.responseHeaders;
         if (checkNullIteratee(__ax4_iter_59)) for (_tmp_ in __ax4_iter_59)
         {
            _loc2_ = _tmp_;
            if(_loc2_.name.toLowerCase() == "x-trace-id")
            {
               return _loc2_.value;
            }
         }
         return null;
      }
   }


