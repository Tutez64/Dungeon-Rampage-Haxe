package brain.jsonRPC
;
   import flash.events.ErrorEvent;
   
    class FaultEvent extends ErrorEvent
   {
      
      public static inline final Fault= "fault";
      
      public var fault:Error;
      
      public function new(param1:Error)
      {
         this.fault = param1;
         super("fault",true,true,param1.message);
      }
   }


