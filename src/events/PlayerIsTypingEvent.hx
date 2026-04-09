package events
;
    class PlayerIsTypingEvent extends GameObjectEvent
   {
      
      public static inline final PLAYER_IS_TYPING= "PLAYER_IS_TYPING";
      
      public static inline final PLAYER_CHAT_FOCUS_IN= "CHAT_BOX_FOCUS_IN";
      
      public static inline final PLAYER_CHAT_FOCUS_OUT= "CHAT_BOX_FOCUS_OUT";
      
      public var subtype:String;
      
      public function new(param1:String, param2:UInt, param3:String, param4:Bool = false, param5:Bool = false)
      {
         subtype = param3;
         super(param1,param2,param4,param5);
      }
   }


