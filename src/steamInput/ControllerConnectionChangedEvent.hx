package steamInput
;
   import flash.events.Event;
   
    class ControllerConnectionChangedEvent extends Event
   {
      
      public static inline final TYPE= "ControllerConnectionChangedEvent";
      
      public var isControllerConnected:Bool = false;
      
      public function new(param1:Bool)
      {
         this.isControllerConnected = param1;
         super("ControllerConnectionChangedEvent");
      }
   }


