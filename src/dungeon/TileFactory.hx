package dungeon;

import brain.logger.Logger;
import brain.utils.MemoryTracker;
import distributedObjects.DistributedDungeonFloor;
import events.LEClientEvent;
import facade.DBFacade;
import generatedCode.DungeonTileUsage;
import flash.geom.Vector3D;
import org.as3commons.collections.Map;

class TileFactory {
	var mDBFacade:DBFacade;

	var mFactoriesReady:ASFunction;

	var mPropFactoryReady:Bool = false;

	var mTileFactoryReady:Bool = false;

	var mPropFactory:PropFactory;

	var mTileMap:Map = new Map();

	public var mFillerTiles:Array<ASAny> = [];

	var mLocalProximityTriggers:Array<ASAny>;

	var mTileLibraryJson:ASObject;

	public function new(facade:DBFacade, libraryJson:Array<ASAny>, tileLibraryJson:ASObject) {
		mDBFacade = facade;
		mTileLibraryJson = tileLibraryJson;
		loadTileLibrary();
		loadTileTriggersAndTriggerables();
		mPropFactory = new PropFactory(mDBFacade, libraryJson);
		MemoryTracker.track(mPropFactory, "PropFactory - created in TileFactory.constructor()");
	}

	public function destroy() {
		mDBFacade = null;
		mPropFactory.destroy();
		mPropFactory = null;
		mFactoriesReady = null;
	}

	@:isVar public var propFactory(get, never):PropFactory;

	public function get_propFactory():PropFactory {
		return mPropFactory;
	}

	function propFactoryReady() {
		mPropFactoryReady = true;
		checkIfReady();
	}

	function checkIfReady() {
		if (mPropFactoryReady && mTileFactoryReady) {
			mFactoriesReady();
		}
	}

	function loadTileLibrary() {
		var _loc2_ = 0;
		var _loc3_:Array<ASAny> = ASCompat.dynamicAs(mTileLibraryJson.LETiles, Array);
		var _loc1_ = (_loc3_.length : UInt);
		while ((_loc2_ : UInt) < _loc1_) {
			mTileMap.add(_loc3_[_loc2_].id, _loc3_[_loc2_]);
			if (_loc3_[_loc2_].category == "FILLER_TILE") {
				mFillerTiles.push(_loc3_[_loc2_]);
			}
			_loc2_++;
		}
		mTileFactoryReady = true;
		checkIfReady();
	}

	function loadTileTriggersAndTriggerables() {
		var _loc2_ = 0;
		var _loc3_:Array<ASAny> = ASCompat.dynamicAs(mTileLibraryJson.LETriggers, Array);
		var _loc1_ = (_loc3_.length : UInt);
		while ((_loc2_ : UInt) < _loc1_) {
			mDBFacade.gameMaster.triggerToTriggerable.add(_loc3_[_loc2_].triggerId, _loc3_[_loc2_].triggerableId);
			_loc2_++;
		}
	}

	public function buildTile(tileNetworkComponent:DungeonTileUsage, addToGrid:ASFunction, tileInitialized:ASFunction,
			distributedDungeonFloor:DistributedDungeonFloor) {
		var _loc5_:ASAny = null;
		mLocalProximityTriggers = [];
		var _loc6_:ASObject = mTileMap.itemFor(tileNetworkComponent.tileId);
		if (_loc6_ == null) {
			Logger.warn("Could not find tileId: " + tileNetworkComponent.tileId + " in mTileMap");
			return;
		}
		var _loc7_ = new Tile(mDBFacade, (ASCompat.toInt(_loc6_.LEObjects.length) : UInt), _loc6_.category == "FILLER_TILE");
		MemoryTracker.track(_loc7_, "Tile - created in TileFactory.buildTile()");
		_loc7_.position = new Vector3D(tileNetworkComponent.x, tileNetworkComponent.y);
		addToGrid(_loc7_);
		tileInitialized(_loc7_);
		buildBackground(_loc6_.LEBackground, _loc7_, distributedDungeonFloor);
		final __ax4_iter_145:Array<ASAny> = _loc6_.LEObjects;
		if (checkNullIteratee(__ax4_iter_145))
			for (_tmp_ in __ax4_iter_145) {
				_loc5_ = _tmp_;
				buildingProp(_loc5_, _loc7_, distributedDungeonFloor);
			}
		final __ax4_iter_146:Array<ASAny> = _loc6_.LETriggers;
		if (checkNullIteratee(__ax4_iter_146))
			for (_tmp_ in __ax4_iter_146) {
				_loc5_ = _tmp_;
				buildingProp(_loc5_, _loc7_, distributedDungeonFloor);
			}
		final __ax4_iter_147 = mLocalProximityTriggers;
		if (checkNullIteratee(__ax4_iter_147))
			for (_tmp_ in __ax4_iter_147) {
				_loc5_ = _tmp_;
				analyzeLocalProximityTrigger(_loc5_, _loc7_, distributedDungeonFloor);
			}
	}

	function buildingProp(propJsonObj:ASObject, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) {
		switch (propJsonObj.type) {
			case "LEProp":
				buildProp(propJsonObj, tile, distributedDungeonFloor);

			case "LEHeroSpawnProp" | "LENPC" | "LENPCGenerator" | "LECollectable" | "LETriggerGate" | "LETriggerableCamera" |
				"LENPCGeneratorWithAllSpawnsDeadTrigger":
				tile.ignoredAProp();

			case "LETriggerable":
				if (propJsonObj.constant == "SEND_LOCAL_CLIENT_EVENT") {
					mDBFacade.gameMaster.TriggerableIdToTriggerableEvent.add(ASCompat.toInt(propJsonObj.id),
						new TriggerableEvent((ASCompat.toInt(propJsonObj.id) : UInt), propJsonObj.textKey));
				}

			case "LETrigger":
				if (propJsonObj.constant == "PROXIMITY_LOCAL_HERO") {
					mLocalProximityTriggers.push(propJsonObj);
				}

			default:
				Logger.debug("Do not know how to handle type: " + Std.string(propJsonObj.type) + " Ignoring.");
				tile.ignoredAProp();
		}
	}

	function buildProp(propJsonObj:ASObject, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) {
		var _loc4_ = Prop.validatePropConstant(propJsonObj, mDBFacade);
		if (!_loc4_) {
			Logger.warn("invalid prop constant: " + Std.string(propJsonObj.constant));
			return;
		}
		var _loc5_ = Prop.parseFromTileJson(propJsonObj, tile, mDBFacade);
		_loc5_.distributedDungeonFloor = distributedDungeonFloor;
	}

	function analyzeLocalProximityTrigger(propJsonObj:ASObject, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) {
		var triggerableEvent:TriggerableEvent;
		var triggerableId = (ASCompat.toInt(mDBFacade.gameMaster.triggerToTriggerable.itemFor(propJsonObj.id)) : UInt);
		if (triggerableId != 0) {
			triggerableEvent = ASCompat.dynamicAs(mDBFacade.gameMaster.TriggerableIdToTriggerableEvent.itemFor(triggerableId), dungeon.TriggerableEvent);
			if (triggerableEvent != null) {
				tile.createLocalEventCollision(distributedDungeonFloor, (ASCompat.toInt(propJsonObj.x) : UInt), (ASCompat.toInt(propJsonObj.y) : UInt),
					(ASCompat.toInt(propJsonObj.radius) : UInt), ASCompat.toBool(propJsonObj.triggerOnce), function() {
						mDBFacade.eventManager.dispatchEvent(new LEClientEvent(triggerableEvent.eventName));
				});
			}
		}
	}

	function buildBackground(propJsonObj:ASObject, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) {
		var _loc4_ = Prop.validatePropConstant(propJsonObj, mDBFacade);
		if (!_loc4_) {
			Logger.warn("invalid background constant: " + Std.string(propJsonObj.constant));
			return;
		}
		var _loc5_ = Prop.parseFromTileJson(propJsonObj, tile, mDBFacade);
		_loc5_.view.root.scaleX = _loc5_.view.root.scaleY = 1.0022222222222221;
		_loc5_.layer = 5;
		_loc5_.distributedDungeonFloor = distributedDungeonFloor;
		tile.background = _loc5_;
	}
}
