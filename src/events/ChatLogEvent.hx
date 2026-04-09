package events
;
   import flash.events.Event;
   
    class ChatLogEvent extends Event
   {
      
      public static inline final NAME= "CHAT_LOG_EVENT";
      
      var mMessage:String;
      
      var mChatLogType:String;
      
      var mPlayerName:String;
      
      public function new(param1:String, param2:String, param3:String, param4:String = "", param5:Bool = false, param6:Bool = false)
      {
         super(param1,param5,param6);
         mMessage = param2;
         mChatLogType = param3;
         mPlayerName = param4;
      }
      
      @:isVar public var chat(get,never):String;
public function  get_chat() : String
      {
         return mMessage;
      }
      
      @:isVar public var chatLogType(get,never):String;
public function  get_chatLogType() : String
      {
         return mChatLogType;
      }
      
      @:isVar public var playerName(get,never):String;
public function  get_playerName() : String
      {
         return mPlayerName;
      }
   }


