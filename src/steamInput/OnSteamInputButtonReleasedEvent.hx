package steamInput
;
   import flash.events.Event;
   
    class OnSteamInputButtonReleasedEvent extends Event
   {
      
      public static inline final TYPE= "OnSteamInputButtonReleasedEvent";
      
      public var actionName:String;
      
      public function new(param1:String)
      {
         this.actionName = param1;
         super("OnSteamInputButtonReleasedEvent");
      }
   }


