package events
;
   import flash.display.MovieClip;
   import flash.events.Event;
   
    class FriendSummaryNewsFeedEvent extends Event
   {
      
      public static inline final NAME= "FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT";
      
      public static var FRIEND_NAME_HIGHLIGHT_COLOR:UInt = (65280 : UInt);
      
      var mFriendName:String;
      
      var mIsFriendNameInFront:Bool = false;
      
      var mMessage:String;
      
      var mPic:MovieClip;
      
      public function new(param1:String, param2:String, param3:MovieClip, param4:String, param5:Bool = false, param6:Bool = false, param7:Bool = false)
      {
         mFriendName = param4;
         mIsFriendNameInFront = param5;
         mMessage = param2;
         mPic = param3;
         super(param1,param6,param7);
      }
      
      @:isVar public var friendName(get,never):String;
public function  get_friendName() : String
      {
         return mFriendName;
      }
      
      @:isVar public var message(get,never):String;
public function  get_message() : String
      {
         return mMessage;
      }
      
      @:isVar public var isFriendNameInFront(get,never):Bool;
public function  get_isFriendNameInFront() : Bool
      {
         return mIsFriendNameInFront;
      }
      
      @:isVar public var pic(get,never):MovieClip;
public function  get_pic() : MovieClip
      {
         return mPic;
      }
   }


