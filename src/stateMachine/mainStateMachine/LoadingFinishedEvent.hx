package stateMachine.mainStateMachine
;
   import account.DBAccountInfo;
   import flash.events.Event;
   
    class LoadingFinishedEvent extends Event
   {
      
      public static inline final EVENT_NAME= "LoadingFinishedEvent";
      
      var mDBAccountInfo:DBAccountInfo;
      
      public function new(param1:DBAccountInfo, param2:Bool = false, param3:Bool = false)
      {
         super("LoadingFinishedEvent",param2,param3);
         mDBAccountInfo = param1;
      }
      
      @:isVar public var dbAccountInfo(get,never):DBAccountInfo;
public function  get_dbAccountInfo() : DBAccountInfo
      {
         return mDBAccountInfo;
      }
   }


