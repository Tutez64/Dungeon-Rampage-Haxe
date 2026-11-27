package distributedObjects;

import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.gameObject.GameObject;
import brain.utils.Timers;
import collections.Map;
import events.FriendStatusEvent;
import facade.DBFacade;
import generatedCode.IPresenceManager;
import generatedCode.PresenceManagerNetworkComponent;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

class PresenceManager extends GameObject implements IPresenceManager {
	static var mInstance:PresenceManager;

	var mDBFacade:DBFacade;

	var mPresence:Map = new Map();

	var mEventComponent:EventComponent;

	var mNetworkComponent:PresenceManagerNetworkComponent;

	var mAddFriendsTimer:Timer;

	var mPendingAccountIds:Vector<UInt>;

	public function new(facade:DBFacade, remoteId:UInt = (0 : UInt)) {
		mEventComponent = new EventComponent(facade);
		mDBFacade = facade;
		super(facade, remoteId);
		mInstance = this;
	}

	public static function instance():PresenceManager {
		return mInstance;
	}

	public function isOnline(who:UInt):Bool {
		return mPresence.hasKey(who);
	}

	public function isInDungeon(who:UInt):Bool {
		return mPresence.hasKey(who) && ASCompat.toNumber(mPresence.itemFor(who)) != 0;
	}

	public function InDungeonId(who:UInt):UInt {
		if (mPresence.hasKey(who)) {
			return (ASCompat.toInt(mPresence.itemFor(who)) : UInt);
		}
		return (0 : UInt);
	}

	public function setNetworkComponentPresenceManager(iface:PresenceManagerNetworkComponent) {
		mNetworkComponent = iface;
	}

	public function postGenerate() {
		mDBFacade.mDistributedObjectManager.mPresenceManager = this;
	}

	public function friendState(yesno:UInt, who:UInt, state:UInt) {
		var _loc4_ = (0 : UInt);
		if (yesno == 0) {
			if (mPresence.hasKey(who)) {
				mPresence.removeKey(who);
				mEventComponent.dispatchEvent(new FriendStatusEvent("FRIEND_STATUS_EVENT", who, false));
			}
		} else if (!mPresence.hasKey(who)) {
			mPresence.add(who, state);
			mEventComponent.dispatchEvent(new FriendStatusEvent("FRIEND_STATUS_EVENT", who, true));
		} else {
			_loc4_ = (ASCompat.toInt(mPresence.itemFor(who)) : UInt);
			if (_loc4_ != state) {
				mPresence.replaceFor(who, state);
			}
		}
		mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
	}

	public function addFriends(who:Vector<UInt>) {
		mPendingAccountIds = who;
		if (mAddFriendsTimer != null) {
			mAddFriendsTimer.stop();
			EventListeners.remove(mAddFriendsTimer, "timer", onAddFriendsTimerComplete);
		}
		mAddFriendsTimer = Timers.create(2000, 1, "PresenceManager.mAddFriendsTimer");
		EventListeners.add(mAddFriendsTimer, "timer", onAddFriendsTimerComplete);
		mAddFriendsTimer.start();
	}

	function onAddFriendsTimerComplete(event:TimerEvent) {
		if (mPendingAccountIds != null && mPendingAccountIds.length > 0) {
			mNetworkComponent.send_addFriends(mPendingAccountIds);
			mPendingAccountIds = null;
		}
	}
}
