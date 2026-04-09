package events
;
   import flash.events.Event;
   
    class RequestEntryFailedEvent extends Event
   {
      
      public static inline final EVENT_NAME= "REQUEST_ENTRY_FAILED";
      
      var mErrorCode:UInt = 0;
      
      public function new(param1:UInt, param2:Bool = false, param3:Bool = false)
      {
         super("REQUEST_ENTRY_FAILED",param2,param3);
         mErrorCode = param1;
      }
      
      @:isVar public var errorCode(get,never):UInt;
public function  get_errorCode() : UInt
      {
         return mErrorCode;
      }
   }


