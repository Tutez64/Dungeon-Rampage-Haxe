package distributedObjects;

import actor.ActorGameObject;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphComponent;
import events.CacheLoadRequestNpcEvent;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import generatedCode.DistributedDungionAreaNetworkComponent;
import generatedCode.IDistributedDungionArea;
import generatedCode.InfiniteRewardData;
import generatedCode.WeaponDetails;
import generatedCode.Swrapper;

class DistributedDungionArea extends Area implements IDistributedDungionArea {
	var mNetworkComponent:DistributedDungionAreaNetworkComponent;

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
		var _loc2_ = 0;
		mCacheSfc = new Vector<String>();
		_loc2_ = 0;
		while (_loc2_ < val.length) {
			mCacheSfc.push(DBFacade.buildFullDownloadPath(val[_loc2_].fileName));
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
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
		var _loc2_ = 0;
		mTileLibrary = new Vector<String>();
		_loc2_ = 0;
		while (_loc2_ < val.length) {
			mTileLibrary.push(val[_loc2_].fileName);
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
	}

	public function calculateNetAttackDamage(attacker:ActorGameObject, target:ActorGameObject, attack:GMAttack, weapon:WeaponDetails):Float {
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc5_:Float = 0;
		if (attack.StatOffsets != null) {
			_loc6_ = ASCompat.toNumber((weapon.power * mDBFacade.gameMaster.stat_BonusMultiplier.values[Std.int(attack.StatOffsets.offence)]
				+
				attacker.stats.values[Std.int(attack.StatOffsets.offence)]) * ASCompat.toNumber((attacker.buffHandler.multiplier : ASAny)[attack.StatOffsets.offence]));
			_loc6_ = _loc6_ * attack.DamageMod;
			_loc7_ = ASCompat.toNumber(target.stats.values[Std.int(attack.StatOffsets.defence)] * ASCompat.toNumber((target.buffHandler.multiplier : ASAny)[attack.StatOffsets.defence]));
			_loc5_ = _loc6_ + _loc7_;
		} else {
			_loc5_ = weapon.power * attack.DamageMod;
		}
		return _loc5_;
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
