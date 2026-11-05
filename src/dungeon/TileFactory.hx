package dungeon;

import brain.logger.Logger;
import brain.utils.MemoryTracker;
import collections.Map;
import distributedObjects.DistributedDungeonFloor;
import events.LEClientEvent;
import facade.DBFacade;
import generatedCode.DungeonTileUsage;
import starling.StarlingViewFactory;
import starling.SwfFallbackDebug;
import flash.geom.Vector3D;

class TileFactory {
	var mDBFacade:DBFacade;

	var mFactoriesReady:ASFunction;

	var mPropFactoryReady:Bool = false;

	var mTileFactoryReady:Bool = false;

	var mPropFactory:PropFactory;

	var mStarlingViewFactory:StarlingViewFactory;

	var mTileMap:Map = new Map();

	public var mFillerTiles:Array<ASAny> = [];

	var mLocalProximityTriggers:Array<ASAny>;

	var mTriggerToTriggerable:Map = new Map();

	var mTriggerableEventsById:Map = new Map();

	var mTileLibraryJson:ASObject;

	var mNpcForceFlashByTilePosition:Map;

	public function new(facade:DBFacade, libraryJson:Array<ASAny>, tileLibraryJson:ASObject) {
		mDBFacade = facade;
		mTileLibraryJson = tileLibraryJson;
		mNpcForceFlashByTilePosition = new Map();
		loadTileLibrary();
		loadTileTriggersAndTriggerables();
		mPropFactory = new PropFactory(mDBFacade, libraryJson);
		mStarlingViewFactory = new StarlingViewFactory(mDBFacade);
		MemoryTracker.track(mPropFactory, "PropFactory - created in TileFactory.constructor()");
	}

	public function destroy() {
		mDBFacade = null;
		mPropFactory.destroy();
		mPropFactory = null;
		mStarlingViewFactory.destroy();
		mStarlingViewFactory = null;
		mFactoriesReady = null;
		mNpcForceFlashByTilePosition = null;
		mTriggerToTriggerable.clear();
		mTriggerToTriggerable = null;
		mTriggerableEventsById.clear();
		mTriggerableEventsById = null;
	}

	@:isVar public var propFactory(get, never):PropFactory;

	public function get_propFactory():PropFactory {
		return mPropFactory;
	}

	@:isVar public var starlingViewFactory(get, never):StarlingViewFactory;

	public function get_starlingViewFactory():StarlingViewFactory {
		return mStarlingViewFactory;
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
			mTriggerToTriggerable.add(_loc3_[_loc2_].triggerId, _loc3_[_loc2_].triggerableId);
			_loc2_++;
		}
	}

	public function buildTile(tileNetworkComponent:DungeonTileUsage, addToGrid:ASFunction, tileInitialized:ASFunction,
			distributedDungeonFloor:DistributedDungeonFloor, isGeneratedFiller:Bool = false) {
		var _loc6_:ASObject = null;
		mLocalProximityTriggers = [];
		var _loc7_:ASObject = mTileMap.itemFor(tileNetworkComponent.tileId);
		if (_loc7_ == null) {
			Logger.warn("Could not find tileId: " + tileNetworkComponent.tileId + " in mTileMap");
			return;
		}
		var _loc8_ = new Tile(mDBFacade, (ASCompat.toInt(_loc7_.LEObjects.length) : UInt), _loc7_.category == "FILLER_TILE");
		MemoryTracker.track(_loc8_, "Tile - created in TileFactory.buildTile()");
		_loc8_.position = new Vector3D(tileNetworkComponent.x, tileNetworkComponent.y);
		_loc8_.isGeneratedFiller = isGeneratedFiller;
		addToGrid(_loc8_);
		tileInitialized(_loc8_);
		buildBackground(_loc7_.LEBackground, _loc8_, distributedDungeonFloor);
		final __ax4_iter_453:ASAny = _loc7_.LEObjects;
		if (checkNullIteratee(__ax4_iter_453))
			for (_tmp_ in __ax4_iter_453) {
				_loc6_ = _tmp_;
				buildingProp(_loc6_, _loc8_, distributedDungeonFloor);
			}
		final __ax4_iter_454:ASAny = _loc7_.LETriggers;
		if (checkNullIteratee(__ax4_iter_454))
			for (_tmp_ in __ax4_iter_454) {
				_loc6_ = _tmp_;
				buildingProp(_loc6_, _loc8_, distributedDungeonFloor);
			}
		final __ax4_iter_455 = mLocalProximityTriggers;
		if (checkNullIteratee(__ax4_iter_455))
			for (_tmp_ in __ax4_iter_455) {
				_loc6_ = _tmp_;
				analyzeLocalProximityTrigger(_loc6_, _loc8_, distributedDungeonFloor);
			}
		_loc8_.addExitBackstops(_loc7_, distributedDungeonFloor.box2DWorld);
	}

	function buildingProp(propJsonObj:ASObject, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) {
		switch (propJsonObj.type) {
			case "LEProp":
				buildProp(propJsonObj, tile, distributedDungeonFloor);

			case "LEHeroSpawnProp" | "LENPCGenerator" | "LECollectable" | "LETriggerGate" | "LETriggerableCamera" | "LENPCGeneratorWithAllSpawnsDeadTrigger":
				tile.ignoredAProp();

			case "LENPC":
				recordNpcForceFlash(propJsonObj, tile.position);
				tile.ignoredAProp();

			case "LETriggerable":
				if (propJsonObj.constant == "SEND_LOCAL_CLIENT_EVENT") {
					mTriggerableEventsById.add(ASCompat.toInt(propJsonObj.id),
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
		var triggerableId = (ASCompat.toInt(mTriggerToTriggerable.itemFor(propJsonObj.id)) : UInt);
		if (triggerableId != 0) {
			triggerableEvent = ASCompat.coerce(mTriggerableEventsById.itemFor(triggerableId), dungeon.TriggerableEvent);
			if (triggerableEvent != null) {
				tile.createLocalEventCollision(distributedDungeonFloor, (ASCompat.toInt(propJsonObj.x) : UInt), (ASCompat.toInt(propJsonObj.y) : UInt),
					(ASCompat.toInt(propJsonObj.radius) : UInt), ASCompat.toBool(propJsonObj.triggerOnce), function() {
						mDBFacade.eventManager.dispatchEvent(new LEClientEvent(triggerableEvent.eventName));
				});
			}
		}
	}

	function recordNpcForceFlash(npcJsonObj:ASObject, tilePosition:Vector3D) {
		var _loc4_ = tilePosition.x + "," + tilePosition.y;
		var _loc3_:Array<ASAny> = ASCompat.dynamicAs(mNpcForceFlashByTilePosition.itemFor(_loc4_), Array);
		if (_loc3_ == null) {
			_loc3_ = [];
			mNpcForceFlashByTilePosition.add(_loc4_, _loc3_);
		}
		_loc3_.push({
			"constant": npcJsonObj.constant,
			"x": npcJsonObj.x,
			"y": npcJsonObj.y,
			"forceFlash": npcJsonObj.forceFlash == true
		});
	}

	public function getForceFlashForNpc(constant:String, tilePosition:Vector3D, localX:Float, localY:Float):Bool {
		var _loc7_ = tilePosition.x + "," + tilePosition.y;
		var _loc6_:Array<ASAny> = ASCompat.dynamicAs(mNpcForceFlashByTilePosition.itemFor(_loc7_), Array);
		if (_loc6_ == null) {
			return false;
		}
		var _loc5_:ASObject;
		if (checkNullIteratee(_loc6_))
			for (_tmp_ in _loc6_) {
				_loc5_ = _tmp_;
				if (_loc5_.constant == constant
					&& Math.abs(ASCompat.toNumberField(_loc5_, "x") - localX) < 0.5
					&& Math.abs(ASCompat.toNumberField(_loc5_, "y") - localY) < 0.5) {
					return _loc5_.forceFlash == true;
				}
			}
		return false;
	}

	function buildBackground(propJsonObj:ASObject, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) {
		var _loc6_:Float;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_:Prop = null;
		var _loc4_ = Prop.validatePropConstant(propJsonObj, mDBFacade);
		if (!_loc4_) {
			Logger.warn("invalid background constant: " + Std.string(propJsonObj.constant));
			return;
		}
		var _loc12_ = mDBFacade.rendererFactorySelector;
		var _loc7_ = _loc12_.getLayerBackend(5);
		if (_loc7_ == "starling" && _loc12_.starlingFactory != null && _loc12_.starlingFactory.backend.isReady) {
			_loc10_ = ASCompat.toNumber(tile.position.x + (propJsonObj.x ?? 0));
			_loc11_ = ASCompat.toNumber(tile.position.y + (propJsonObj.y ?? 0));
			_loc5_ = 1.0022222222222221;
			_loc6_ = 1.0022222222222221;
			_loc8_ = 0;
			if (ASCompat.toBool(propJsonObj.flip)) {
				_loc5_ = -_loc5_;
			}
			if (ASCompat.toBool(propJsonObj.rotation)) {
				_loc8_ = ASCompat.toNumber(propJsonObj.rotation);
			}
			starlingViewFactory.buildViewFromAsset(propJsonObj.constant, _loc10_, _loc11_, _loc5_, _loc6_, _loc8_, tile.isOnStage, tile.isFiller());
			tile.addBackgroundNavCollisions(propJsonObj, mPropFactory.getNavCollisionJson(propJsonObj.constant), distributedDungeonFloor.box2DWorld);
		} else {
			SwfFallbackDebug.report(mDBFacade, "TILE", propJsonObj.constant, null,
				"ground layer backend is \'"
				+ _loc7_
				+ "\'"
				+
				(_loc12_.starlingFactory == null ? " (no Starling factory)" : (!_loc12_.starlingFactory.backend.isReady ? " (Starling backend not ready)" : "")));
			_loc9_ = Prop.parseFromTileJson(propJsonObj, tile, mDBFacade);
			_loc9_.view.root.scaleX = _loc9_.view.root.scaleY = 1.0022222222222221;
			_loc9_.layer = 5;
			_loc9_.distributedDungeonFloor = distributedDungeonFloor;
			tile.background = _loc9_;
		}
	}
}
