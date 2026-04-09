package events
;
   import flash.events.Event;
   
    class FriendStatusEvent extends Event
   {
      
      public static inline final FRIEND_ONLINE_STATUS= "FRIEND_STATUS_EVENT";
      
      public static inline final FRIEND_DUNGEON_STATUS= "FRIEND_DUNGEON_STATUS_EVENT";
      
      var mFriendId:UInt = 0;
      
      var mStatus:Bool = false;
      
      public function new(param1:String, param2:UInt, param3:Bool, param4:Bool = false, param5:Bool = false)
      {
         super(param1,param4,param5);
         mFriendId = param2;
         mStatus = param3;
      }
      
      @:isVar public var friendId(get,never):UInt;
public function  get_friendId() : UInt
      {
         return mFriendId;
      }
      
      @:isVar public var status(get,never):Bool;
public function  get_status() : Bool
      {
         return mStatus;
      }
   }


