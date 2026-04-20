package steamInput
;
   import flash.events.Event;
   
    class SteamInputGlyphsChangedEvent extends Event
   {
      
      public static inline final TYPE= "OnSteamInputGlyphsChanged";
      
      public function new()
      {
         super("OnSteamInputGlyphsChanged");
      }
   }


