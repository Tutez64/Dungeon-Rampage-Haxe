package events
;
   import flash.events.Event;
   
    class UIHudChangeEvent extends Event
   {
      
      public static inline final UI_HUD_CHANGE_EVENT= "UI_HUD_CHANGE_EVENT";
      
      public static inline final DEFAULT_UI_HUD_TYPE= (0 : UInt);
      
      public static inline final CONDENSED_UI_HUD_TYPE= (1 : UInt);
      
      var mHudType:UInt = 0;
      
      public function new(param1:UInt, param2:Bool = false, param3:Bool = false)
      {
         super("UI_HUD_CHANGE_EVENT",param2,param3);
         mHudType = param1;
      }
      
      @:isVar public var hudType(get,never):UInt;
public function  get_hudType() : UInt
      {
         return mHudType;
      }
   }


