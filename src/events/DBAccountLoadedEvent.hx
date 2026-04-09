package events
;
   import account.DBAccountInfo;
   import flash.events.Event;
   
    class DBAccountLoadedEvent extends Event
   {
      
      public static inline final EVENT_NAME= "DB_ACCOUNT_INFO_LOADED";
      
      var mDBAccountInfo:DBAccountInfo;
      
      public function new(param1:DBAccountInfo, param2:Bool = false, param3:Bool = false)
      {
         super("DB_ACCOUNT_INFO_LOADED",param2,param3);
         mDBAccountInfo = param1;
      }
      
      @:isVar public var dbAccountInfo(get,never):DBAccountInfo;
public function  get_dbAccountInfo() : DBAccountInfo
      {
         return mDBAccountInfo;
      }
   }


