package distributedObjects;

import brain.event.EventComponent;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphComponent;
import events.CacheLoadRequestNpcEvent;
import facade.DBFacade;
import generatedCode.DistributedDungionAreaNetworkComponent;
import generatedCode.IDistributedDungionArea;
import generatedCode.InfiniteRewardData;
import generatedCode.Swrapper;

class DistributedDungionArea extends Area implements IDistributedDungionArea {
	var mNetworkComponent:DistributedDungionAreaNetworkComponent;

	var mTeammateRevivesThisDungeon:Int = 0;

	var mTileLibrary:Vector<String>;

	var mSceneGraphComponent:SceneGraphComponent;

	var mEventComponent:EventComponent;

	public var mCacheNpc:Vector<UInt>;

	public var mCacheSfc:Vector<String>;

	public function new(facade:DBFacade, remoteId:UInt = (0 : UInt)) {
		Logger.debug("New  DistributedDungionArea******************************");
		super(facade, remoteId);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "DistributedDungionArea");
		mCacheNpc = new Vector<UInt>();
		mCacheSfc = new Vector<String>();
		mEventComponent = new EventComponent(facade);
	}

	@:isVar public var cacheNpc(never, set):Vector<UInt>;

	public function set_cacheNpc(val:Vector<UInt>):Vector<UInt> {
		return mCacheNpc = val;
	}

	@:isVar public var cacheSWC(never, set):Vector<Swrapper>;

	public function set_cacheSWC(val:Vector<Swrapper>):Vector<Swrapper> {
		var _loc2_ = (0 : UInt);
		mCacheSfc = new Vector<String>();
		_loc2_ = (0 : UInt);
		while (_loc2_ < (val.length:UInt)) {
			mCacheSfc.push(DBFacade.buildFullDownloadPath(val[(_loc2_ : Int)].fileName));
			_loc2_++;
		}
		return val;
	}

	public function setNetworkComponentDistributedDungionArea(iface:DistributedDungionAreaNetworkComponent) {
		mNetworkComponent = iface;
	}

	public function postGenerate() {
		mEventComponent.dispatchEvent(new CacheLoadRequestNpcEvent(mCacheNpc, mCacheSfc, mTileLibrary));
	}

	public function tileLibrary(val:Vector<Swrapper>) {
		var _loc2_ = (0 : UInt);
		mTileLibrary = new Vector<String>();
		_loc2_ = (0 : UInt);
		while (_loc2_ < (val.length:UInt)) {
			mTileLibrary.push(val[(_loc2_ : Int)].fileName);
			_loc2_++;
		}
	}

	public function countTeammateRevive():Int {
		return ++mTeammateRevivesThisDungeon;
	}

	public function floorReward(mapReward:UInt) {}

	public function floorEnding(timeUntilTransition:UInt) {
		if (mActiveFloor == null) {
			return;
		}
		mActiveFloor.floorEnding(timeUntilTransition);
	}

	public function floorfailing(timeUntilTransition:UInt) {
		if (mActiveFloor == null) {
			return;
		}
		mActiveFloor.floorFailing(timeUntilTransition);
	}

	public function tellClientInfiniteRewardData(avId:UInt, avScore:UInt, goldReward:UInt, infiniteRewards:Vector<InfiniteRewardData>) {
		if (mDBFacade.dbAccountInfo.activeAvatarId != avId) {
			return;
		}
		mInfiniteStartScore = (avScore : Int);
		mInfiniteFloorGold = (goldReward : Int);
		mInfiniteRewardData = infiniteRewards;
		var _loc5_:InfiniteRewardData;
		if (checkNullIteratee(infiniteRewards))
			for (_tmp_ in infiniteRewards) {
				_loc5_ = _tmp_;
			}
	}

	public function dungeonEnding(timeUntilTransition:UInt, victory:UInt) {
		if (mActiveFloor == null) {
			return;
		}
		if (victory != 0) {
			mActiveFloor.victory();
		} else {
			mActiveFloor.defeat();
		}
	}

	override public function destroy() {
		mEventComponent.destroy();
		mEventComponent = null;
		mCacheNpc = null;
		super.destroy();
	}
}
