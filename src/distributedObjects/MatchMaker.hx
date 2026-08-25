package distributedObjects;

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

class MatchMaker extends GameObject implements IMatchMaker {
	public static var EPOCH_ROLL_OVER_EVENT_NAME:String = "EPOCH_ROLL_OVER_EVENT_NAME";

	var netIface:MatchMakerNetworkComponent;

	var mDBFacade:DBFacade;

	var mEventComponent:EventComponent;

	var mInfiniteMapNodeDetails:Vector<InfiniteMapNodeDetail>;

	var mInfiniteDungeonDetails:Map;

	public function new(facade:DBFacade, remoteId:UInt = (0 : UInt)) {
		mDBFacade = facade;
		super(facade, remoteId);
		mEventComponent = new EventComponent(mDBFacade);
	}

	public function setNetworkComponentMatchMaker(iface:MatchMakerNetworkComponent) {
		netIface = iface;
	}

	public function InfiniteDetails(value_0:Vector<InfiniteMapNodeDetail>) {
		mInfiniteMapNodeDetails = value_0;
		setInfiniteDungeonDetails();
		mEventComponent.dispatchEvent(new Event(EPOCH_ROLL_OVER_EVENT_NAME));
	}

	function setInfiniteDungeonDetails() {
		var _loc1_:InfiniteMapNodeDetail = null;
		mInfiniteDungeonDetails = new Map();
		final __ax4_iter_218 = mInfiniteMapNodeDetails;
		if (checkNullIteratee(__ax4_iter_218))
			for (_tmp_ in __ax4_iter_218) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					mInfiniteDungeonDetails.add(_loc1_.nodeId, _loc1_);
				}
			}
	}

	public function ClientInformPartyComposition(partyMembers:Vector<GameServerPartyMember>) {
		trace("ClientInformPartyComposition");
		var _loc2_:GameServerPartyMember;
		if (checkNullIteratee(partyMembers))
			for (_tmp_ in partyMembers) {
				_loc2_ = _tmp_;
				trace("Member Id:" + _loc2_.id + " Status:" + _loc2_.status);
			}
	}

	public function postGenerate() {
		mDBFacade.mDistributedObjectManager.mMatchMaker = this;
		mEventComponent.dispatchEvent(new MatchMakerLoadedEvent(this));
	}

	public function RequestExit() {
		Logger.info("MatchMaker:RequestExit");
		netIface.send_RequestExit((0 : UInt));
	}

	public function RequestEntry(mapdnodeID:UInt, friendID:UInt, mapID:UInt, onlyfriends:UInt, grouping:String) {
		Logger.info("MatchMaker:RequestEntry");
		netIface.send_ClientRequestEntry(mDBFacade.demographicsJson, (mDBFacade.sCode : UInt), mapdnodeID, friendID, mapID, onlyfriends, grouping);
	}

	public function ClientRequestEntryResponce(ResponceCode:UInt, truenode:UInt) {
		Logger.info("MatchMaker:ClientRequestEntryResponce");
		if (ResponceCode != 0) {
			mEventComponent.dispatchEvent(new RequestEntryFailedEvent(ResponceCode));
		}
	}

	public function RequestPartyMemberInvite(partyInviteId:UInt) {
		Logger.info("MatchMaker:RequestPartyMemberInvite");
		netIface.send_ClientRequestPartyMemberInvite(mDBFacade.demographicsJson, partyInviteId);
	}

	override public function destroy() {
		mDBFacade.mDistributedObjectManager.mMatchMaker = null;
		mInfiniteMapNodeDetails = null;
		mInfiniteDungeonDetails = null;
		if (mEventComponent != null) {
			mEventComponent.destroy();
		}
		super.destroy();
	}

	public function ClientExitComplete(ResponceCode:UInt) {
		Logger.info("MatchMaker:ClientExitComplete" + Std.string(ResponceCode));
		mEventComponent.dispatchEvent(new ClientExitCompleteEvent());
	}

	public function getInfiniteDungeonDetailForNodeId(nodeId:UInt):InfiniteMapNodeDetail {
		return ASCompat.dynamicAs(mInfiniteDungeonDetails.itemFor(nodeId), generatedCode.InfiniteMapNodeDetail);
	}
}
