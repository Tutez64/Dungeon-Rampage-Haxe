package events
;
   import flash.events.Event;
   
    class LEClientEvent extends Event
   {
      
      public static inline final SEND_EVENT= "SEND_EVENT";
      
      public var eventName:String = "";
      
      public function new(param1:String, param2:Bool = false, param3:Bool = false)
      {
         super("SEND_EVENT",param2,param3);
         eventName = param1;
      }
   }


