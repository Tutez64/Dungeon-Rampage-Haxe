package events
;
    class ChatEvent extends GameObjectEvent
   {
      
      public static inline final INCOMING_CHAT_UPDATE= "ChatEvent_INCOMING_CHAT_UPDATE";
      
      public static inline final OUTGOING_CHAT_UPDATE= "ChatEvent_OUTGOING_CHAT_UPDATE";
      
      public var message:String;
      
      public function new(param1:String, param2:UInt, param3:String, param4:Bool = false, param5:Bool = false)
      {
         this.message = param3;
         super(param1,param2,param4,param5);
      }
   }


