package effects;

import actor.ActorGameObject;
import brain.assetRepository.AssetLoadingComponent;
import brain.sceneGraph.SceneGraphComponent;
import brain.sceneGraph.SceneGraphManager;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import facade.DBFacade;
import dr_floor.FloorObject;
import sound.DBSoundComponent;
import flash.geom.Vector3D;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

class EffectManager {
	static inline final OUT_OF_MANA_DISPLAY_TIME:Float = 2;

	var mDBFacade:DBFacade;

	var mManagedEffects:Map;

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

	public function playLerpedEffect(swfPath:String, className:String, positionOffset:Vector3D, parentObject:FloorObject = null,
			lerpToActor:ActorGameObject = null, lerpSpeed:Float = 1, lerpGlowColor:UInt = (13369344 : UInt), behindAvatar:Bool = false, scale:Float = 1,
			rotation:Float = 0, rotationX:Float = 0, rotationY:Float = 0, rotationZ:Float = 0, loop:Bool = false, layerName:String = "sorted",
			isManaged:Bool = false, playRate:Float = 1, assetLoadedCallback:ASFunction = null) {
		var _loc19_ = new LerpEffectGameObject(mDBFacade, swfPath, className, playRate, (0 : UInt), assetLoadedCallback, lerpToActor, lerpSpeed, lerpGlowColor);
		MemoryTracker.track(_loc19_, "LerpEffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playLerpedEffect()", "pool");
		_loc19_.view.root.scaleX = _loc19_.view.root.scaleY = _loc19_.view.root.scaleZ = scale;
		_loc19_.position = parentObject.position.add(positionOffset);
		_loc19_.layer = SceneGraphManager.getLayerFromName(layerName);
		_loc19_.view.addToStage();
	}

	public function playEffect(swfPath:String, className:String, position:Vector3D, parentObject:FloorObject = null, behindAvatar:Bool = false,
			scale:Float = 1, rotation:Float = 0, rotationX:Float = 0, rotationY:Float = 0, rotationZ:Float = 0, loop:Bool = false,
			layerName:String = "sorted", isManaged:Bool = false, playRate:Float = 1, assetLoadedCallback:ASFunction = null):UInt {
		var effectGameObject:EffectGameObject;
		var pool:EffectPool;
		if (isManaged) {
			effectGameObject = new EffectGameObject(mDBFacade, swfPath, className, playRate, (0 : UInt), assetLoadedCallback);
			MemoryTracker.track(effectGameObject, "EffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playEffect()", "pool");
		} else {
			effectGameObject = ASCompat.reinterpretAs(mDBFacade.effectPool.checkout(mDBFacade, swfPath, className, assetLoadedCallback), EffectGameObject);
		}
		effectGameObject.view.root.scaleX = effectGameObject.view.root.scaleY = effectGameObject.view.root.scaleZ = scale;
		effectGameObject.rotation = rotation;
		effectGameObject.view.rotationX = rotationX;
		effectGameObject.view.rotationY = rotationY;
		effectGameObject.view.rotationZ = rotationZ;
		effectGameObject.position = position;
		if (parentObject != null) {
			if (behindAvatar) {
				parentObject.view.root.addChildAt(effectGameObject.view.root, 0);
			} else {
				parentObject.view.root.addChild(effectGameObject.view.root);
			}
		} else {
			effectGameObject.layer = SceneGraphManager.getLayerFromName(layerName);
			effectGameObject.view.addToStage();
		}
		pool = mDBFacade.effectPool;
		cast(effectGameObject.view, EffectView).play(loop, function() {
			if (!isManaged) {
				pool.checkin(effectGameObject);
			}
		});
		if (isManaged) {
			mManagedEffects.add(effectGameObject.id, effectGameObject);
		}
		return effectGameObject.id;
	}

	public function playSoundEffect(soundSwfPath:String, soundName:String) {
		mAssetLoadingComponent.getSoundAsset(soundSwfPath, soundName, function(param1:brain.sound.SoundAsset) {
			mSoundComponent.playSfxOneShot(param1, null);
		});
	}

	public function endManagedEffect(effectID:UInt) {
		var _loc2_ = ASCompat.dynamicAs(mManagedEffects.itemFor(effectID), effects.EffectGameObject);
		if (_loc2_ != null) {
			mManagedEffects.remove(_loc2_);
			_loc2_.destroy();
		}
	}

	public function playNotEnoughManaEffects() {
		if (mNotEnoughManaDisplayTask == null) {
			playSoundEffect(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"), "OutOfMana");
			mDBFacade.hud.showNotEnoughMana();
			mNotEnoughManaDisplayTask = mLogicalWorkComponent.doLater(2, function(param1:brain.clock.GameClock) {
				mNotEnoughManaDisplayTask = null;
				mDBFacade.hud.hideNotEnoughMana();
			});
		}
	}

	public function destroy() {
		var _loc2_:IMapIterator = null;
		var _loc1_:EffectGameObject = null;
		mDBFacade = null;
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mSoundComponent.destroy();
		mSoundComponent = null;
		if (mManagedEffects != null) {
			_loc2_ = ASCompat.reinterpretAs(mManagedEffects.iterator(), IMapIterator);
			while (_loc2_.hasNext()) {
				_loc1_ = ASCompat.dynamicAs(_loc2_.next(), effects.EffectGameObject);
				_loc1_.destroy();
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
