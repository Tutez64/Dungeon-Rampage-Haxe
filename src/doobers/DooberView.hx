package doobers;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.StarlingAssetMapper;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.render.tweens.Quad;
import brain.render.tweens.TweenHandle;
import brain.sound.SoundAsset;
import brain.workLoop.LayerWorkComponent;
import collections.Map;
import dBGlobals.DBGlobal;
import distributedObjects.HeroGameObject;
import facade.DBFacade;
import dr_floor.FloorView;
import sound.DBSoundComponent;
import starling.SwfFallbackDebug;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Vector3D;
import starling.extensions.animate.Animation;

class DooberView extends FloorView {
	static inline final LOOP_HEIGHT = 270;

	static inline final LOOP_DURATION:Float = 0.9;

	static inline final LOOP_DURATION_RAND:Float = 0.3;

	static inline final LOOP1_TIME = 60;

	static inline final LOOP2_TIME = 40;

	static inline final LOOP1_HEIGHT = 75;

	static inline final LOOP2_HEIGHT = 25;

	static inline final TWEEN_TO_UI_TIME:Float = 0.5;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mDoober:MovieClip;

	var mBody:Sprite;

	var mDooberGameObject:DooberGameObject;

	var mBounceTimeline:TweenHandle;

	var mMoveToUITween:TweenHandle;

	var mEndPos:Vector3D;

	var mSoundComponent:DBSoundComponent;

	var mPickupSound:SoundAsset;

	var mDooberRenderer:MovieClipRenderController;

	var mDooberSwfAsset:SwfAsset;

	var mStarlingRenderer:StarlingDooberRenderer;

	var mStarlingSyncComponent:LayerWorkComponent;

	var mOnStage:Bool = false;

	public function new(facade:DBFacade, dooberGameObject:DooberGameObject) {
		super(facade, dooberGameObject);
		mDooberGameObject = dooberGameObject;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSoundComponent = new DBSoundComponent(facade);
		mRoot.name = "DooberView_" + mDooberGameObject.id;
		mBody = new Sprite();
		mBody.name = "mBody";
		mRoot.addChild(mBody);
	}

	override public function init() {
		super.init();
		mBody.scaleX = mBody.scaleY = mDooberGameObject.mDooberData.ScaleVisual;
		loadDooberAssets();
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), mDooberGameObject.mDooberData.PickupSound, soundLoaded);
		mRoot.mouseEnabled = false;
		mRoot.mouseChildren = false;
	}

	override public function isViewObjectTweenDriven():Bool {
		return true;
	}

	function soundLoaded(soundAsset:SoundAsset) {
		mPickupSound = soundAsset;
	}

	function loadDooberAssets() {
		var swfPath = mDooberGameObject.swfPath;
		if (!ASCompat.stringAsBool(mDooberGameObject.className)
			|| mDBFacade.assetLoadingComponent == null
			|| mDBFacade.starlingLayerManager == null) {
			reportSwfFallback(!ASCompat.stringAsBool(mDooberGameObject.className) ? "no AssetClassName for doober" : (mDBFacade.assetLoadingComponent == null ? "no asset loading component" : "no Starling layer manager (Stage3D not up)"));
			mAssetLoadingComponent.getSwfAsset(swfPath, assetLoaded);
			return;
		}
		mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(swfPath, function() {
			if (mDooberGameObject == null) {
				return;
			}
			if (!loadStarlingDoober()) {
				reportSwfFallback("no bundle animation, per-class animation, or packed label matches the doober class");
				mAssetLoadingComponent.getSwfAsset(swfPath, assetLoaded);
			}
		});
	}

	function reportSwfFallback(reason:String) {
		SwfFallbackDebug.report(mDBFacade, "DOOBER", mDooberGameObject != null ? mDooberGameObject.className : "?",
			mDooberGameObject != null ? mDooberGameObject.swfPath : null, reason);
	}

	function loadStarlingDoober():Bool {
		var _loc3_:String = null;
		var _loc1_:String = null;
		var _loc4_ = mDooberGameObject.className;
		var _loc7_:Animation = null;
		var _loc5_:String = null;
		var _loc2_ = StarlingAssetMapper.getActorAtlasKeyFromPath(mDooberGameObject.swfPath);
		var _loc6_ = _loc4_.lastIndexOf("_");
		if (_loc6_ > 0) {
			_loc3_ = _loc4_.substring(0, _loc6_);
			_loc1_ = _loc4_.substring(_loc6_ + 1);
			_loc7_ = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(_loc2_, _loc3_);
			if (_loc7_ == null) {
				_loc7_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(_loc3_);
			}
			if (_loc7_ != null) {
				if (_loc7_.getFrame(_loc1_) >= 0) {
					_loc5_ = _loc1_;
				} else {
					Logger.warnch("Starling", "Doober bundle \'" + _loc3_ + "\' has no label \'" + _loc1_ + "\' for " + _loc4_);
					_loc7_.dispose();
					_loc7_ = null;
				}
			}
		}
		if (_loc7_ == null) {
			_loc7_ = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(_loc2_, _loc4_);
			if (_loc7_ == null) {
				_loc7_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(_loc4_);
			}
		}
		if (_loc7_ == null) {
			if (_loc2_ != null) {
				_loc7_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(_loc2_);
				if (_loc7_ != null) {
					if (_loc7_.getFrame(_loc4_) >= 0) {
						_loc5_ = _loc4_;
					} else {
						_loc7_.dispose();
						_loc7_ = null;
					}
				}
			}
		}
		if (_loc7_ == null) {
			Logger.warnch("Starling", "No Starling asset for doober " + _loc4_ + "; falling back to SWF");
			return false;
		}
		mStarlingRenderer = new StarlingDooberRenderer(mDBFacade, _loc4_ + "_" + mDooberGameObject.id, 0, _loc7_, _loc5_);
		this.layer = mDooberGameObject.layer;
		if (mOnStage) {
			mStarlingRenderer.setLayer(this.layer);
		}
		mStarlingRenderer.visible = mOnStage && mRoot.visible;
		syncStarlingTransform();
		mStarlingRenderer.play();
		mStarlingSyncComponent = new LayerWorkComponent(mDBFacade, "DooberView");
		mStarlingSyncComponent.doEveryFrame(onStarlingSyncFrame);
		return true;
	}

	function onStarlingSyncFrame(clock:GameClock) {
		syncStarlingTransform();
	}

	function syncStarlingTransform() {
		if (mStarlingRenderer == null || mRoot == null) {
			return;
		}
		var _loc1_ = mRoot.x;
		var _loc2_ = mRoot.y;
		if (mDooberGameObject.layer == 20) {
			_loc1_ = positionX;
			_loc2_ = positionY;
		}
		mStarlingRenderer.setTransform(mRoot.x + mBody.x * mRoot.scaleX, mRoot.y + mBody.y * mRoot.scaleY, mRoot.scaleX * mBody.scaleX,
			mRoot.scaleY * mBody.scaleY, mRoot.alpha, _loc1_, _loc2_);
		mStarlingRenderer.visible = mOnStage && mRoot.visible;
	}

	override public function addToStage() {
		super.addToStage();
		mOnStage = true;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setLayer(this.layer);
			mStarlingRenderer.visible = mRoot.visible;
		}
	}

	override public function removeFromStage() {
		mOnStage = false;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setLayer(0);
			mStarlingRenderer.visible = false;
		}
		super.removeFromStage();
	}

	function assetLoaded(swfAsset:SwfAsset) {
		mDooberRenderer = ASCompat.reinterpretAs(mDBFacade.movieClipPool.checkout(mDBFacade, swfAsset, mDooberGameObject.className), MovieClipRenderController);
		mDoober = mDooberRenderer.clip;
		if (ASCompat.toBool((mDoober : ASAny).doober_shadow)) {
			ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", true);
		}
		SwfFallbackDebug.applyOutline(mDBFacade, mDoober, "DOOBER");
		mBody.addChild(mDoober);
		mDooberRenderer.play((0 : UInt), true);
		this.layer = mDooberGameObject.layer;
	}

	function checkinDoober() {
		if (mStarlingSyncComponent != null) {
			mStarlingSyncComponent.destroy();
			mStarlingSyncComponent = null;
		}
		if (mStarlingRenderer != null) {
			mStarlingRenderer.destroy();
			mStarlingRenderer = null;
		}
		if (mDooberRenderer != null) {
			mDBFacade.movieClipPool.checkin(mDooberRenderer);
			mDooberRenderer = null;
		}
		mDoober = null;
	}

	public function collectedEffect(isHeroOwner:Bool, playerId:UInt, animationComplete:ASFunction) {
		var localPoint:Point;
		var globalPoint:Point;
		var dooberType:String;
		var dooberId:UInt;
		var callback:ASFunction = function() {
			checkinDoober();
			animationComplete();
		};
		if (mBounceTimeline != null) {
			mDBFacade.mTween.killTween(mBounceTimeline);
			mBounceTimeline = null;
		}
		if (mPickupSound != null) {
			mSoundComponent.playSfxOneShot(mPickupSound, worldCenter, 0, mDooberGameObject != null ? mDooberGameObject.mDooberData.PickupVolume : 1);
		}
		localPoint = new Point(0, 0);
		globalPoint = mDBFacade.designLocalToGlobal(mRoot, localPoint);
		this.removeFromStage();
		mDooberGameObject.layer = 50;
		this.addToStage();
		mRoot.x = globalPoint.x;
		mRoot.y = globalPoint.y;
		mBody.x = mBody.y = 0;
		if (mDooberRenderer != null) {
			mDooberRenderer.stop();
			mDooberRenderer.setFrame((0 : UInt));
		}
		if (mStarlingRenderer != null) {
			mStarlingRenderer.rewindAndStop();
		}
		if (mDoober != null && ASCompat.toBool((mDoober : ASAny).doober_shadow)) {
			ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", false);
		}
		dooberType = mDooberGameObject.mDooberData.DooberType;
		dooberId = mDooberGameObject.mDooberData.ChestId;
		if (mDooberGameObject.mDooberData.InstantReward != "1") {
			mMoveToUITween = moveToTeamUI(callback, dooberId);
		} else if (isHeroOwner) {
			mMoveToUITween = moveToUI(dooberType, callback);
		} else if (mDooberGameObject.mDooberData.SharedReward == "1" && checkPlayerOnScreen(playerId)) {
			mMoveToUITween = moveToUI(dooberType, callback);
		} else {
			callback();
		}
	}

	public function animateDooberBounce(startPos:Vector3D, endPos:Vector3D) {
		if (mDoober == null && mStarlingRenderer == null) {
			return;
		}
		if (mDoober != null && ASCompat.toBool((mDoober : ASAny).doober_shadow)) {
			ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", false);
		}
		mEndPos = endPos;
		this.mRoot.x = startPos.x;
		this.mRoot.y = startPos.y;
		mBounceTimeline = mDBFacade.mTween.createTimeline();
		var _loc6_ = 0.9 + Math.random() * 0.3;
		var _loc3_ = _loc6_ * 60 / (60 + 40);
		var _loc4_ = _loc6_ * 40 / (60 + 40);
		var _loc8_ = Vector3D.distance(startPos, endPos);
		var _loc11_ = Math.atan2(endPos.y - startPos.y, endPos.x - startPos.x);
		var _loc5_ = _loc8_ * 60 / (60 + 40);
		var _loc10_ = new Vector3D(startPos.x + _loc5_ * Math.cos(_loc11_), startPos.y + _loc5_ * Math.sin(_loc11_));
		var _loc9_ = new Vector3D((startPos.x + _loc10_.x) / 2, startPos.y - 270 * 75 / (75 + 25));
		var _loc7_ = new Vector3D((_loc10_.x + endPos.x) / 2, _loc10_.y - 270 * 25 / (75 + 25));
		mDBFacade.mTween.addLabel(mBounceTimeline, "start", 0);
		mDBFacade.mTween.addLabel(mBounceTimeline, "loop1", _loc3_ / 2);
		mDBFacade.mTween.addLabel(mBounceTimeline, "mid", _loc3_);
		mDBFacade.mTween.addLabel(mBounceTimeline, "loop2", _loc3_ + _loc4_ / 2);
		mDBFacade.mTween.addLabel(mBounceTimeline, "end", _loc3_ + _loc4_);
		var _loc12_ = _loc3_ + _loc4_;
		mDBFacade.mTween.appendTween(mBounceTimeline, mDBFacade.mTween.tweenMaxTo(this.mRoot, _loc12_, {"x": endPos.x}));
		mDBFacade.mTween.insertTween(mBounceTimeline, mDBFacade.mTween.tweenMaxTo(this.mBody, _loc3_ / 2, {
			"y": _loc9_.y - startPos.y,
			"ease": Quad.easeOut
		}), "start");
		mDBFacade.mTween.insertTween(mBounceTimeline, mDBFacade.mTween.tweenMaxTo(this.mBody, _loc3_ / 2, {
			"y": _loc10_.y - startPos.y,
			"ease": Quad.easeIn
		}), "loop1");
		mDBFacade.mTween.insertTween(mBounceTimeline, mDBFacade.mTween.tweenMaxTo(this.mBody, _loc4_ / 2, {
			"y": _loc7_.y - startPos.y,
			"ease": Quad.easeOut
		}), "mid");
		mDBFacade.mTween.insertTween(mBounceTimeline, mDBFacade.mTween.tweenMaxTo(this.mBody, _loc4_ / 2, {
			"y": endPos.y - startPos.y,
			"ease": Quad.easeIn,
			"onComplete": timelineComplete
		}), "loop2");
		mDBFacade.mTween.playTween(mBounceTimeline);
	}

	function timelineComplete() {
		mRoot.x = mEndPos.x;
		mRoot.y = mEndPos.y;
		mBody.x = mBody.y = 0;
		if (mDooberRenderer != null) {
			mDooberRenderer.play((0 : UInt), true);
		}
		if (mStarlingRenderer != null) {
			mStarlingRenderer.play();
		}
		if (mDoober != null && ASCompat.toBool((mDoober : ASAny).doober_shadow)) {
			ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", true);
		}
	}

	function moveToUI(dooberType:String, animationComplete:ASFunction):TweenHandle {
		var _loc3_:Vector3D = null;
		switch (dooberType) {
			case "GOLD" | "COIN" | "TREASURE":
				_loc3_ = mDBFacade.hud.coinsDestination;

			case "EXP":
				_loc3_ = mDBFacade.hud.expDestination;

			case "CROWD":
				_loc3_ = mDBFacade.hud.crowdDestination;

			default:
				_loc3_ = mDBFacade.hud.profileDestination;
		}
		return mDBFacade.mTween.tweenMaxTo(this.mRoot, 0.5, {
			"x": _loc3_.x,
			"y": _loc3_.y,
			"onComplete": animationComplete
		});
	}

	function moveToTeamUI(animationComplete:ASFunction, chestId:UInt):TweenHandle {
		var _loc3_ = new Vector3D();
		if (this.mDBFacade.hud != null) {
			_loc3_ = mDBFacade.hud.teamLootDestination;
			this.mDBFacade.hud.openTeamLoot(chestId);
		}
		if (chestId == 60001) {
			return mDBFacade.mTween.tweenMaxTo(this.mRoot, 0.5, {
				"x": _loc3_.x,
				"y": _loc3_.y,
				"scaleX": 0.8,
				"scaleY": 0.8,
				"alpha": 0.2,
				"onComplete": animationComplete
			});
		}
		if (chestId == 60004) {
			return mDBFacade.mTween.tweenMaxTo(this.mRoot, 0.5, {
				"x": _loc3_.x,
				"y": _loc3_.y,
				"scaleX": 0.5,
				"scaleY": 0.5,
				"alpha": 0.2,
				"onComplete": animationComplete
			});
		}
		return mDBFacade.mTween.tweenMaxTo(this.mRoot, 0.5, {
			"x": _loc3_.x,
			"y": _loc3_.y,
			"scaleX": 0.6,
			"scaleY": 0.6,
			"alpha": 0.2,
			"onComplete": animationComplete
		});
	}

	function checkPlayerOnScreen(collectedPlayerId:UInt):Bool {
		var _loc2_:Map = null;
		var _loc3_:HeroGameObject = null;
		if (mDooberGameObject != null
			&& mDooberGameObject.distributedDungeonFloor != null
			&& mDooberGameObject.distributedDungeonFloor.remoteHeroes.size > 0) {
			_loc2_ = mDooberGameObject.distributedDungeonFloor.remoteHeroes;
			_loc3_ = ASCompat.dynamicAs(_loc2_.itemFor(collectedPlayerId), HeroGameObject);
			if (_loc3_ != null) {
				return mDBFacade.camera.isPointOnScreen(_loc3_.view.position);
			}
		}
		return false;
	}

	override public function destroy() {
		if (mDooberRenderer != null || mStarlingRenderer != null) {
			this.checkinDoober();
		}
		if (mStarlingSyncComponent != null) {
			mStarlingSyncComponent.destroy();
			mStarlingSyncComponent = null;
		}
		if (mBounceTimeline != null) {
			mDBFacade.mTween.killTween(mBounceTimeline);
			mBounceTimeline = null;
		}
		if (mMoveToUITween != null) {
			mDBFacade.mTween.killTween(mMoveToUITween);
			mMoveToUITween = null;
		}
		mDBFacade.mTween.killTweensOf(this.mRoot);
		mDBFacade.mTween.killTweensOf(this.mBody);
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mSoundComponent.destroy();
		mSoundComponent = null;
		mPickupSound = null;
		mDoober = null;
		mDooberRenderer = null;
		mBody = null;
		mDooberGameObject = null;
		super.destroy();
	}
}
