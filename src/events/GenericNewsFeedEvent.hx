package events
;
   import flash.events.Event;
   
    class GenericNewsFeedEvent extends Event
   {
      
      public static inline final NAME= "GENERIC_NEWS_FEED_MESSAGE_EVENT";
      
      var mMessage:String;
      
      var mPicSwfLocation:String;
      
      var mPicSwfClassName:String;
      
      public function new(param1:String, param2:String, param3:String = "", param4:String = "", param5:Bool = false, param6:Bool = false)
      {
         mMessage = param2;
         mPicSwfLocation = param3;
         mPicSwfClassName = param4;
         super(param1,param5,param6);
      }
      
      @:isVar public var message(get,never):String;
public function  get_message() : String
      {
         return mMessage;
      }
      
      @:isVar public var picLocation(get,never):String;
public function  get_picLocation() : String
      {
         return mPicSwfLocation;
      }
      
      @:isVar public var picClassName(get,never):String;
public function  get_picClassName() : String
      {
         return mPicSwfClassName;
      }
   }


