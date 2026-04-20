package steamInput
;
   import flash.events.Event;
   
    class OnSteamInputButtonPressedEvent extends Event
   {
      
      public static inline final TYPE= "OnSteamInputButtonPressedEvent";
      
      public var actionName:String;
      
      public function new(param1:String)
      {
         this.actionName = param1;
         super("OnSteamInputButtonPressedEvent");
      }
   }


