package events
;
   import flash.events.Event;
   
    class ClientExitCompleteEvent extends Event
   {
      
      public static inline final EVENT_NAME= "CLIENT_EXIT_COMPLETE";
      
      public function new(param1:Bool = false, param2:Bool = false)
      {
         super("CLIENT_EXIT_COMPLETE",param1,param2);
      }
   }


