package effects;

import actor.ActorGameObject;
import brain.assetRepository.AssetLoadingComponent;
import brain.sceneGraph.SceneGraphComponent;
import brain.sceneGraph.SceneGraphManager;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import collections.IMapIterator;
import collections.Map;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import dr_floor.FloorObject;
import sound.DBSoundComponent;
import flash.geom.Vector3D;

class EffectManager {
	static inline final OUT_OF_MANA_DISPLAY_TIME:Float = 2;

	var mDBFacade:DBFacade;

	var mManagedEffects:Map;

	var mOutstandingEffects:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mSoundComponent:DBSoundComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mNotEnoughManaDisplayTask:Task;

	public function new(facade:DBFacade) {
		mDBFacade = facade;
		mManagedEffects = new Map();
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "EffectManager");
		mSoundComponent = new DBSoundComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "EffectManager");
	}

	static function createPooledEffectRelease(effect:EffectGameObject, pool:EffectPool, outstanding:ASDictionary<ASAny, ASAny>):ASFunction {
		var release:ASFunction = null;
		release = function() {
			if (outstanding[effect] != release) {
				return;
			}
			outstanding.remove(effect);
			if (!cast(effect.view, EffectView).isArtLoaded) {
				effect.destroy();
			} else {
				pool.checkin(effect);
			}
		};
		outstanding[effect] = release;
		return release;
	}

	public function playLerpedEffect(swfPath:String, className:String, positionOffset:Vector3D, parentObject:FloorObject = null,
			lerpToActor:ActorGameObject = null, lerpSpeed:Float = 1, lerpGlowColor:UInt = (13369344 : UInt), behindAvatar:Bool = false, scale:Float = 1,
			rotation:Float = 0, rotationX:Float = 0, rotationY:Float = 0, rotationZ:Float = 0, loop:Bool = false, layerName:String = "sorted",
			isManaged:Bool = false, playRate:Float = 1, assetLoadedCallback:ASFunction = null) {
		if (parentObject == null || !parentObject.hasPosition) {
			return;
		}
		var _loc19_ = new LerpEffectGameObject(mDBFacade, swfPath, className, playRate, (0 : UInt), assetLoadedCallback, lerpToActor, lerpSpeed, lerpGlowColor);
		MemoryTracker.track(_loc19_, "LerpEffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playLerpedEffect()", "pool");
		_loc19_.view.root.scaleX = _loc19_.view.root.scaleY = _loc19_.view.root.scaleZ = scale;
		_loc19_.position = parentObject.position.add(positionOffset);
		_loc19_.layer = SceneGraphManager.getLayerFromName(layerName);
		_loc19_.view.addToStage();
		cast(_loc19_.view, EffectView).play(true, null);
	}

	public function playEffect(swfPath:String, className:String, position:Vector3D, parentObject:FloorObject = null, behindAvatar:Bool = false,
			scale:Float = 1, rotation:Float = 0, rotationX:Float = 0, rotationY:Float = 0, rotationZ:Float = 0, loop:Bool = false,
			layerName:String = "sorted", isManaged:Bool = false, playRate:Float = 1, assetLoadedCallback:ASFunction = null,
			iconInsert:EffectIconInsert = null, fallbackCategory:String = null):UInt {
		var _loc18_:EffectGameObject = null;
		var _loc19_:ASFunction = null;
		if (isManaged) {
			_loc18_ = new EffectGameObject(mDBFacade, swfPath, className, playRate, (0 : UInt), assetLoadedCallback, iconInsert, fallbackCategory);
			MemoryTracker.track(_loc18_, "EffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playEffect()", "pool");
		} else {
			_loc18_ = ASCompat.reinterpretAs(mDBFacade.effectPool.checkout(mDBFacade, swfPath, className, assetLoadedCallback, iconInsert, playRate),
				EffectGameObject);
			_loc19_ = createPooledEffectRelease(_loc18_, mDBFacade.effectPool, mOutstandingEffects);
		}
		_loc18_.view.root.scaleX = _loc18_.view.root.scaleY = _loc18_.view.root.scaleZ = scale;
		_loc18_.rotation = rotation;
		_loc18_.view.rotationX = rotationX;
		_loc18_.view.rotationY = rotationY;
		_loc18_.view.rotationZ = rotationZ;
		_loc18_.position = position;
		if (parentObject != null) {
			cast(_loc18_.view, EffectView).attachToParent(parentObject.view.root, behindAvatar);
		} else {
			_loc18_.layer = SceneGraphManager.getLayerFromName(layerName);
			_loc18_.view.addToStage();
		}
		cast(_loc18_.view, EffectView).play(loop, _loc19_);
		if (isManaged) {
			mManagedEffects.add(_loc18_.id, _loc18_);
		}
		return _loc18_.id;
	}

	public function playSoundEffect(soundSwfPath:String, soundName:String) {
		mAssetLoadingComponent.getSoundAsset(soundSwfPath, soundName, function(param1:brain.sound.SoundAsset) {
			mSoundComponent.playSfxOneShot(param1, null);
		});
	}

	public function endManagedEffect(effectID:UInt) {
		var _loc2_ = ASCompat.coerce(mManagedEffects.itemFor(effectID), effects.EffectGameObject);
		if (_loc2_ != null) {
			mManagedEffects.remove(_loc2_);
			_loc2_.destroy();
		}
	}

	public function managedEffectView(effectID:UInt):EffectView {
		var _loc2_ = ASCompat.coerce(mManagedEffects != null ? ASCompat.coerce(mManagedEffects.itemFor(effectID), effects.EffectGameObject) : null,
			effects.EffectGameObject);
		return _loc2_ != null ? ASCompat.reinterpretAs(_loc2_.view, EffectView) : null;
	}

	public function playNotEnoughManaEffects() {
		if (mNotEnoughManaDisplayTask == null) {
			playSoundEffect(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "OutOfMana");
			mDBFacade.hud.showNotEnoughMana();
			mNotEnoughManaDisplayTask = mLogicalWorkComponent.doLater(2, function(param1:brain.clock.GameClock) {
				mNotEnoughManaDisplayTask = null;
				mDBFacade.hud.hideNotEnoughMana();
			});
		}
	}

	public function destroy() {
		var _loc2_:ASFunction;
		var __ax4_iter_366:ASDictionary<ASAny, ASAny>;
		var _loc1_:ASFunction;
		var _loc5_:Array<ASAny> = null;
		var _loc4_:IMapIterator = null;
		var _loc3_:EffectGameObject = null;
		if (mOutstandingEffects != null) {
			_loc5_ = [];
			__ax4_iter_366 = mOutstandingEffects;
			if (checkNullIteratee(__ax4_iter_366))
				for (_tmp_ in __ax4_iter_366) {
					_loc2_ = ASCompat.coerceFunction(_tmp_);
					_loc5_.push(_loc2_);
				}
			if (checkNullIteratee(_loc5_))
				for (_tmp_ in _loc5_) {
					_loc1_ = ASCompat.coerceFunction(_tmp_);
					_loc1_();
				}
			mOutstandingEffects = null;
		}
		mDBFacade = null;
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mSoundComponent.destroy();
		mSoundComponent = null;
		if (mManagedEffects != null) {
			_loc4_ = ASCompat.reinterpretAs(mManagedEffects.iterator(), IMapIterator);
			while (_loc4_.hasNext()) {
				_loc3_ = ASCompat.coerce(_loc4_.next(), effects.EffectGameObject);
				_loc3_.destroy();
			}
			mManagedEffects.clear();
			mManagedEffects = null;
		}
		if (mNotEnoughManaDisplayTask != null) {
			mNotEnoughManaDisplayTask.destroy();
			mNotEnoughManaDisplayTask = null;
		}
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
			mSceneGraphComponent = null;
		}
	}
}
