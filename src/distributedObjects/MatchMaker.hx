package distributedObjects
;
   import brain.event.EventComponent;
   import brain.gameObject.GameObject;
   import brain.logger.Logger;
   import events.ClientExitCompleteEvent;
   import events.MatchMakerLoadedEvent;
   import events.RequestEntryFailedEvent;
   import facade.DBFacade;
   import generatedCode.GameServerPartyMember;
   import generatedCode.IMatchMaker;
   import generatedCode.InfiniteMapNodeDetail;
   import generatedCode.MatchMakerNetworkComponent;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   
    class MatchMaker extends GameObject implements IMatchMaker
   {
      
      public static var EPOCH_ROLL_OVER_EVENT_NAME:String = "EPOCH_ROLL_OVER_EVENT_NAME";
      
      var netIface:MatchMakerNetworkComponent;
      
      var mDBFacade:DBFacade;
      
      var mEventComponent:EventComponent;
      
      var mInfiniteMapNodeDetails:Vector<InfiniteMapNodeDetail>;
      
      var mInfiniteDungeonDetails:Map;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         mDBFacade = param1;
         super(param1,param2);
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function setNetworkComponentMatchMaker(param1:MatchMakerNetworkComponent) 
      {
         netIface = param1;
      }
      
      public function InfiniteDetails(param1:Vector<InfiniteMapNodeDetail>) 
      {
         mInfiniteMapNodeDetails = param1;
         setInfiniteDungeonDetails();
         mEventComponent.dispatchEvent(new Event(EPOCH_ROLL_OVER_EVENT_NAME));
      }
      
      function setInfiniteDungeonDetails() 
      {
         var _loc1_:InfiniteMapNodeDetail = null;
         mInfiniteDungeonDetails = new Map();
         final __ax4_iter_214 = mInfiniteMapNodeDetails;
         if (checkNullIteratee(__ax4_iter_214)) for (_tmp_ in __ax4_iter_214)
         {
            _loc1_  = _tmp_;
            if(_loc1_ != null)
            {
               mInfiniteDungeonDetails.add(_loc1_.nodeId,_loc1_);
            }
         }
      }
      
      public function ClientInformPartyComposition(param1:Vector<GameServerPartyMember>) 
      {
         trace("ClientInformPartyComposition");
         var _loc2_:GameServerPartyMember;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc2_ = _tmp_;
            trace("Member Id:" + Std.string(_loc2_.id) + " Status:" + Std.string(_loc2_.status));
         }
      }
      
      public function postGenerate() 
      {
         mDBFacade.mDistributedObjectManager.mMatchMaker = this;
         mEventComponent.dispatchEvent(new MatchMakerLoadedEvent(this));
      }
      
      public function RequestExit() 
      {
         Logger.info("MatchMaker:RequestExit");
         netIface.send_RequestExit((0 : UInt));
      }
      
      public function RequestEntry(param1:UInt, param2:UInt, param3:UInt, param4:UInt, param5:String) 
      {
         Logger.info("MatchMaker:RequestEntry");
         netIface.send_ClientRequestEntry(mDBFacade.demographicsJson,(mDBFacade.sCode : UInt),param1,param2,param3,param4,param5);
      }
      
      public function ClientRequestEntryResponce(param1:UInt, param2:UInt) 
      {
         Logger.info("MatchMaker:ClientRequestEntryResponce");
         if(param1 != 0)
         {
            mEventComponent.dispatchEvent(new RequestEntryFailedEvent(param1));
         }
      }
      
      public function RequestPartyMemberInvite(param1:UInt) 
      {
         Logger.info("MatchMaker:RequestPartyMemberInvite");
         netIface.send_ClientRequestPartyMemberInvite(mDBFacade.demographicsJson,param1);
      }
      
      override public function destroy() 
      {
         mDBFacade.mDistributedObjectManager.mMatchMaker = null;
         mInfiniteMapNodeDetails = null;
         mInfiniteDungeonDetails = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         super.destroy();
      }
      
      public function ClientExitComplete(param1:UInt) 
      {
         Logger.info("MatchMaker:ClientExitComplete" + Std.string(param1));
         mEventComponent.dispatchEvent(new ClientExitCompleteEvent());
      }
      
      public function getInfiniteDungeonDetailForNodeId(param1:UInt) : InfiniteMapNodeDetail
      {
         return ASCompat.dynamicAs(mInfiniteDungeonDetails.itemFor(param1), generatedCode.InfiniteMapNodeDetail);
      }
   }


