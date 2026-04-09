package distributedObjects
;
   import brain.event.EventComponent;
   import brain.gameObject.GameObject;
   import events.FriendStatusEvent;
   import facade.DBFacade;
   import generatedCode.IPresenceManager;
   import generatedCode.PresenceManagerNetworkComponent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.as3commons.collections.Map;
   
    class PresenceManager extends GameObject implements IPresenceManager
   {
      
      static var mInstance:PresenceManager;
      
      var mDBFacade:DBFacade;
      
      var mPresence:Map = new Map();
      
      var mEventComponent:EventComponent;
      
      var mNetworkComponent:PresenceManagerNetworkComponent;
      
      var mAddFriendsTimer:Timer;
      
      var mPendingAccountIds:Vector<UInt>;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         mEventComponent = new EventComponent(param1);
         mDBFacade = param1;
         super(param1,param2);
         mInstance = this;
      }
      
      public static function instance() : PresenceManager
      {
         return mInstance;
      }
      
      public function isOnline(param1:UInt) : Bool
      {
         return mPresence.hasKey(param1);
      }
      
      public function isInDungeon(param1:UInt) : Bool
      {
         return mPresence.hasKey(param1) && ASCompat.toNumber(mPresence.itemFor(param1)) != 0;
      }
      
      public function InDungeonId(param1:UInt) : UInt
      {
         if(mPresence.hasKey(param1))
         {
            return (ASCompat.toInt(mPresence.itemFor(param1)) : UInt);
         }
         return (0 : UInt);
      }
      
      public function setNetworkComponentPresenceManager(param1:PresenceManagerNetworkComponent) 
      {
         mNetworkComponent = param1;
      }
      
      public function postGenerate() 
      {
         mDBFacade.mDistributedObjectManager.mPresenceManager = this;
      }
      
      public function friendState(param1:UInt, param2:UInt, param3:UInt) 
      {
         var _loc4_= 0;
         if(param1 == 0)
         {
            if(mPresence.hasKey(param2))
            {
               mPresence.removeKey(param2);
               mEventComponent.dispatchEvent(new FriendStatusEvent("FRIEND_STATUS_EVENT",param2,false));
            }
         }
         else if(!mPresence.hasKey(param2))
         {
            mPresence.add(param2,param3);
            mEventComponent.dispatchEvent(new FriendStatusEvent("FRIEND_STATUS_EVENT",param2,true));
         }
         else
         {
            _loc4_ = ASCompat.toInt(mPresence.itemFor(param2));
            if((_loc4_ : UInt) != param3)
            {
               mPresence.replaceFor(param2,param3);
            }
         }
         mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
      }
      
      public function addFriends(param1:Vector<UInt>) 
      {
         mPendingAccountIds = param1;
         if(mAddFriendsTimer != null)
         {
            mAddFriendsTimer.stop();
            mAddFriendsTimer.removeEventListener("timer",onAddFriendsTimerComplete);
         }
         mAddFriendsTimer = new Timer(2000,1);
         mAddFriendsTimer.addEventListener("timer",onAddFriendsTimerComplete);
         mAddFriendsTimer.start();
      }
      
      function onAddFriendsTimerComplete(param1:TimerEvent) 
      {
         if(mPendingAccountIds != null && mPendingAccountIds.length > 0)
         {
            mNetworkComponent.send_addFriends(mPendingAccountIds);
            mPendingAccountIds = null;
         }
      }
   }


