package effects;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.StarlingAssetMapper;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.Layer;
import brain.render.MovieClipRenderController;
import brain.workLoop.LayerWorkComponent;
import facade.DBFacade;
import dr_floor.FloorView;
import starling.SwfFallbackDebug;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;
import starling.utils.Pool;

class EffectView extends FloorView {
	var mAssetLoadingComponent:AssetLoadingComponent;

	var mEffect:MovieClip;

	var mEffectClassName:String;

	var mSwfPath:String;

	var mLoop:Bool = false;

	var mShouldBePlaying:ShouldBePlaying;

	var mAssetLoadedCallback:ASFunction;

	var mPlayRate:Float = 1;

	var mIconInsert:EffectIconInsert;

	var mUseStarling:Bool = false;

	var mStarlingRenderer:StarlingEffectRenderer;

	var mStarlingSyncComponent:LayerWorkComponent;

	var mAnchor:DisplayObject;

	var mSortAnchor:DisplayObject;

	var mBehindAnchor:Bool = false;

	var mOnStage:Bool = false;

	var mFlipX:Bool = false;

	var mRotationX:Float = 0;

	var mStarlingPurgeStamp:Int = -1;

	var mStatusTintColor:UInt = 0;

	var mStatusTintAmount:Float = 0;

	var mIsPlaying:Bool = false;

	var mLastPlayLoop:Bool = false;

	var mLastPlayFinishedCallback:ASFunction;

	var mSwfFallbackReason:String = "effect did not attempt the Starling path";

	public var artResolvedCallback:ASFunction;

	public function new(facade:DBFacade, effectGameObject:EffectGameObject, assetLoadedCallback:ASFunction = null) {
		super(facade, effectGameObject, "pool");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mEffectClassName = effectGameObject.className;
		mSwfPath = effectGameObject.swfPath;
		mAssetLoadedCallback = assetLoadedCallback;
		mIconInsert = effectGameObject.iconInsert;
		var _loc4_ = starlingUnavailableReason(mSwfPath);
		if (_loc4_ == null) {
			mUseStarling = true;
			queueStarlingEffectAssets();
		} else {
			mSwfFallbackReason = _loc4_;
			mAssetLoadingComponent.getSwfAsset(mSwfPath, assetLoaded);
		}
	}

	static function computeLayerSpaceMatrix(node:DisplayObject):Matrix {
		var _loc5_:Matrix = null;
		var _loc4_:Matrix = null;
		var _loc2_ = node.transform.matrix;
		if (_loc2_ == null) {
			_loc2_ = compose2DMatrix(node);
		} else {
			_loc5_ = Pool.getMatrix();
			_loc5_.copyFrom(_loc2_);
			_loc2_ = _loc5_;
		}
		var _loc3_:DisplayObject = node.parent;
		while (_loc3_ != null && !Std.isOfType(_loc3_, Layer)) {
			_loc4_ = _loc3_.transform.matrix;
			if (_loc4_ == null) {
				_loc4_ = compose2DMatrix(_loc3_);
			}
			_loc2_.concat(_loc4_);
			_loc3_ = _loc3_.parent;
		}
		return _loc2_;
	}

	static function compose2DMatrix(node:DisplayObject):Matrix {
		var _loc2_ = Pool.getMatrix();
		_loc2_.createBox(node.scaleX, node.scaleY, node.rotation * 3.141592653589793 / 180, node.x, node.y);
		return _loc2_;
	}

	static function computeLayerSpaceAlpha(node:DisplayObject):Float {
		var _loc3_:Float = 1;
		var _loc2_ = node;
		while (_loc2_ != null && !Std.isOfType(_loc2_, Layer)) {
			_loc3_ *= _loc2_.alpha;
			_loc2_ = _loc2_.parent;
		}
		return _loc3_;
	}

	static function computeLayerSpaceVisible(node:DisplayObject):Bool {
		var _loc2_ = node;
		while (_loc2_ != null && !Std.isOfType(_loc2_, Layer)) {
			if (!_loc2_.visible) {
				return false;
			}
			_loc2_ = _loc2_.parent;
		}
		return true;
	}

	function starlingUnavailableReason(swfPath:String):String {
		if (mDBFacade.assetLoadingComponent == null) {
			return "no asset loading component";
		}
		if (mDBFacade.starlingLayerManager == null) {
			return "no Starling layer manager (Stage3D not up)";
		}
		var _loc2_ = StarlingAssetMapper.isKnownBiome(StarlingAssetMapper.getBiomeKeyFromPath(swfPath));
		if (!_loc2_ && StarlingAssetMapper.getActorAtlasFile(swfPath, true) == null) {
			return "no atlas folder or biome key mapped for the effect SWF path";
		}
		return null;
	}

	function queueStarlingEffectAssets() {
		var _loc1_ = StarlingAssetMapper.getActorAtlasFile(mSwfPath, true);
		if (_loc1_ != null) {
			mDBFacade.assetLoadingComponent.queueStarlingAssets(StarlingAssetMapper.getActorAtlasKeyFromPath(mSwfPath), onStarlingAtlasLoaded, false, [_loc1_]);
		} else if (StarlingAssetMapper.isPropLibraryPath(mSwfPath)) {
			mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(mSwfPath, [mEffectClassName], onStarlingAtlasLoaded);
		} else {
			mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(mSwfPath, onStarlingAtlasLoaded);
		}
	}

	public function prewarmRenderer():StarlingEffectRenderer {
		revalidateStarlingRenderer();
		return mStarlingRenderer;
	}

	@:isVar public var isArtLoaded(get, never):Bool;

	public function get_isArtLoaded():Bool {
		return mMovieClipRenderer != null || mStarlingRenderer != null;
	}

	@:isVar var fallbackCategory(get, never):String;

	function get_fallbackCategory():String {
		var _loc1_ = ASCompat.reinterpretAs(mParentFloorObject, EffectGameObject);
		return _loc1_ != null && _loc1_.fallbackCategory != null ? _loc1_.fallbackCategory : "EFFECT";
	}

	@:isVar public var artDurationInSeconds(get, never):Float;

	public function get_artDurationInSeconds():Float {
		if (mStarlingRenderer != null) {
			return mStarlingRenderer.artDurationInSeconds;
		}
		if (mMovieClipRenderer != null) {
			return mMovieClipRenderer.durationInSeconds;
		}
		return 0;
	}

	public function setIconInsert(iconInsert:EffectIconInsert) {
		mIconInsert = iconInsert;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.clearMarkerContent();
			if (mIconInsert != null) {
				loadStarlingIcon();
			}
		}
	}

	public function setPlayRate(val:Float) {
		mPlayRate = val;
		if (mMovieClipRenderer != null) {
			mMovieClipRenderer.playRate = val;
		}
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setPlayRate(val);
		}
	}

	public function attachToParent(parentRoot:Sprite, behind:Bool, sortAnchor:DisplayObject = null) {
		var _loc4_ = 0;
		mAnchor = parentRoot;
		mSortAnchor = ASCompat.coerce(sortAnchor ?? parentRoot, flash.display.DisplayObject);
		mBehindAnchor = behind;
		if (behind) {
			parentRoot.addChildAt(mRoot, 0);
		} else {
			parentRoot.addChild(mRoot);
		}
		if (mStarlingRenderer != null) {
			_loc4_ = resolveStarlingLayer();
			if (_loc4_ != 0) {
				mStarlingRenderer.setLayer(_loc4_);
			}
			syncStarlingTransform();
		}
	}

	public function play(loop:Bool, finishedCallback:ASFunction) {
		mIsPlaying = true;
		mLastPlayLoop = loop;
		mLastPlayFinishedCallback = finishedCallback;
		revalidateStarlingRenderer();
		if (mStarlingRenderer != null) {
			mStarlingRenderer.play(loop, finishedCallback);
			if (mIsPlaying) {
				startStarlingSync();
			}
		} else if (mMovieClipRenderer != null) {
			mMovieClipRenderer.play((0 : UInt), loop, finishedCallback);
		} else {
			mShouldBePlaying = new ShouldBePlaying(loop, finishedCallback);
		}
	}

	public function stop() {
		mShouldBePlaying = null;
		mAssetLoadedCallback = null;
		mIsPlaying = false;
		mLastPlayFinishedCallback = null;
		stopStarlingSync();
		if (mStarlingRenderer != null) {
			mStarlingRenderer.stop();
			mStarlingRenderer.setLayer(0);
		}
		if (mMovieClipRenderer != null) {
			mMovieClipRenderer.stop();
			mMovieClipRenderer.finishedCallback = null;
		}
		this.removeFromStage();
		if (mRoot.parent != null) {
			mRoot.parent.removeChild(mRoot);
		}
		mAnchor = null;
		mSortAnchor = null;
	}

	override public function addToStage() {
		if (mUseStarling && mDBFacade.starlingLayerManager.getLayer(this.layer) == null) {
			fallbackToSwf("no Starling layer for layer index " + this.layer);
		}
		mOnStage = true;
		super.addToStage();
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setLayer(this.layer);
			syncStarlingTransform();
		}
	}

	override public function removeFromStage() {
		mOnStage = false;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setLayer(0);
		}
		super.removeFromStage();
	}

	override public function set_rotationY(rot:Float):Float {
		if (mUseStarling) {
			mFlipX = rot != 0;
		} else {
			super.rotationY = rot;
		}
		return rot;
	}

	override public function get_rotationY():Float {
		return mUseStarling ? (mFlipX ? 180 : 0) : super.rotationY;
	}

	override public function set_rotationX(rot:Float):Float {
		if (mUseStarling) {
			mRotationX = rot;
		} else {
			super.rotationX = rot;
		}
		return rot;
	}

	override public function get_rotationX():Float {
		return mUseStarling ? mRotationX : super.rotationX;
	}

	function onStarlingAtlasLoaded() {
		var _loc5_:String = null;
		var _loc1_:ShouldBePlaying = null;
		if (!mUseStarling || mDBFacade == null) {
			return;
		}
		var _loc2_ = StarlingAssetMapper.getActorAtlasKeyFromPath(mSwfPath);
		var _loc4_ = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(_loc2_, mEffectClassName);
		var _loc3_:String = null;
		if (_loc4_ == null) {
			_loc5_ = StarlingAssetMapper.isPropLibraryPath(mSwfPath) ? StarlingAssetMapper.getBiomeKeyFromPath(mSwfPath) : null;
			_loc4_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(mEffectClassName, _loc5_);
		}
		if (_loc4_ == null) {
			_loc4_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(_loc2_);
			if (_loc4_ != null && _loc4_.getFrame(mEffectClassName) >= 0) {
				_loc3_ = mEffectClassName;
			} else if (_loc4_ != null) {
				_loc4_.dispose();
				_loc4_ = null;
			}
		}
		if (_loc4_ == null) {
			Logger.warnch("Starling", "EffectView: no Starling effect \'" + mEffectClassName + "\' in atlas \'" + _loc2_ + "\', using SWF");
			mSwfFallbackReason = "no Starling animation for effect class in atlas \'" + _loc2_ + "\'";
			mUseStarling = false;
			mAssetLoadingComponent.getSwfAsset(mSwfPath, assetLoaded);
			return;
		}
		var _loc6_ = resolveStarlingLayer();
		if (_loc6_ != 0 && mDBFacade.starlingLayerManager.getLayer(_loc6_) == null) {
			_loc4_.dispose();
			fallbackToSwf("anchor\'s layer " + _loc6_ + " has no Starling counterpart");
			return;
		}
		mStarlingRenderer = new StarlingEffectRenderer(mDBFacade, mEffectClassName, _loc6_, _loc4_, _loc3_);
		mStarlingPurgeStamp = mDBFacade.assetLoadingComponent.starlingPurgeCount;
		mStarlingRenderer.setPlayRate(mPlayRate);
		if (mStatusTintAmount > 0) {
			mStarlingRenderer.setStatusTint(mStatusTintColor, mStatusTintAmount);
		}
		if (mIconInsert != null) {
			loadStarlingIcon();
		}
		if (mShouldBePlaying != null) {
			_loc1_ = mShouldBePlaying;
			mShouldBePlaying = null;
			play(_loc1_.loop, _loc1_.finishedCallback);
		} else {
			syncStarlingTransform();
		}
		if (artResolvedCallback != null) {
			artResolvedCallback();
		}
	}

	public function applyStatusTint(color:UInt, amount:Float) {
		mStatusTintColor = color;
		mStatusTintAmount = amount;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setStatusTint(color, amount);
		}
	}

	public function clearStatusTint() {
		mStatusTintAmount = 0;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.clearStatusTint();
		}
	}

	function loadStarlingIcon() {
		var iconInsert = mIconInsert;
		var fullPath = DBFacade.buildFullDownloadPath(iconInsert.iconPath);
		mAssetLoadingComponent.getSwfAsset(fullPath, function(param1:SwfAsset) {
			if (mStarlingRenderer == null || mIconInsert != iconInsert) {
				return;
			}
			var _loc3_ = param1.getClass(iconInsert.iconName);
			if (_loc3_ == null) {
				Logger.error("Unable to find icon class: " + iconInsert.iconName);
				return;
			}
			var _loc2_ = StarlingEffectRenderer.createIconImage(fullPath + ":" + iconInsert.iconName,
				ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.DisplayObject));
			mStarlingRenderer.attachMarkerContent(iconInsert.markerName, _loc2_);
		});
	}

	function startStarlingSync() {
		if (mStarlingSyncComponent == null) {
			mStarlingSyncComponent = new LayerWorkComponent(mDBFacade, "EffectView");
		}
		mStarlingSyncComponent.doEveryFrame(onStarlingSyncFrame);
		syncStarlingTransform();
	}

	function stopStarlingSync() {
		if (mStarlingSyncComponent != null) {
			mStarlingSyncComponent.destroy();
			mStarlingSyncComponent = null;
		}
	}

	function onStarlingSyncFrame(clock:GameClock) {
		syncStarlingTransform();
	}

	function revalidateStarlingRenderer() {
		if (mStarlingRenderer == null || mDBFacade == null || mDBFacade.assetLoadingComponent == null) {
			return;
		}
		if (mStarlingPurgeStamp == mDBFacade.assetLoadingComponent.starlingPurgeCount) {
			return;
		}
		mStarlingRenderer.destroy();
		mStarlingRenderer = null;
		if (mIsPlaying && mShouldBePlaying == null) {
			mShouldBePlaying = new ShouldBePlaying(mLastPlayLoop, mLastPlayFinishedCallback);
		}
		queueStarlingEffectAssets();
	}

	function syncStarlingTransform() {
		var _loc5_ = 0;
		var _loc4_:Matrix = null;
		revalidateStarlingRenderer();
		if (mStarlingRenderer == null || mRoot == null || mDBFacade == null) {
			return;
		}
		if (mAnchor != null) {
			_loc5_ = resolveStarlingLayer();
			if (_loc5_ == 0) {
				mStarlingRenderer.visible = false;
				return;
			}
			if (_loc5_ != mStarlingRenderer.layerIndex) {
				if (mDBFacade.starlingLayerManager.getLayer(_loc5_) == null) {
					fallbackToSwf("anchor\'s layer " + _loc5_ + " has no Starling counterpart");
					return;
				}
				mStarlingRenderer.setLayer(_loc5_);
			}
		}
		var _loc1_ = computeLayerSpaceMatrix(mRoot);
		var _loc2_ = _loc1_.tx;
		var _loc3_ = _loc1_.ty;
		if (mAnchor != null) {
			_loc4_ = computeLayerSpaceMatrix(mSortAnchor ?? mAnchor);
			_loc2_ = _loc4_.tx;
			_loc3_ = _loc4_.ty + (mBehindAnchor ? -0.2 : 0.2);
			Pool.putMatrix(_loc4_);
		}
		if (mFlipX) {
			_loc1_.a = -_loc1_.a;
			_loc1_.c = -_loc1_.c;
		}
		mStarlingRenderer.setWorldTransform(_loc1_, _loc2_, _loc3_, computeLayerSpaceAlpha(mRoot));
		Pool.putMatrix(_loc1_);
		mStarlingRenderer.visible = computeLayerSpaceVisible(mRoot) && (mOnStage || mAnchor != null);
	}

	function resolveStarlingLayer():Int {
		if (mOnStage) {
			return this.layer;
		}
		var _loc1_ = mAnchor;
		while (_loc1_ != null && !Std.isOfType(_loc1_, Layer)) {
			_loc1_ = _loc1_.parent;
		}
		return Std.isOfType(_loc1_, Layer) ? cast(_loc1_, Layer).sortIndex : 0;
	}

	function fallbackToSwf(reason:String = null) {
		if (reason != null) {
			mSwfFallbackReason = reason;
		}
		mUseStarling = false;
		stopStarlingSync();
		if (mStarlingRenderer != null) {
			mStarlingRenderer.destroy();
			mStarlingRenderer = null;
		}
		if (mIsPlaying) {
			mShouldBePlaying = new ShouldBePlaying(mLastPlayLoop, mLastPlayFinishedCallback);
		}
		mAssetLoadingComponent.getSwfAsset(mSwfPath, assetLoaded);
	}

	function assetLoaded(swfAsset:SwfAsset) {
		var _loc2_:ShouldBePlaying = null;
		var _loc3_ = swfAsset.getClass(mEffectClassName);
		if (_loc3_ == null) {
			Logger.error("Unable to find class: " + mEffectClassName);
			return;
		}
		mEffect = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
		mMovieClipRenderer = new MovieClipRenderController(mDBFacade, mEffect);
		mMovieClipRenderer.playRate = mPlayRate;
		if (mShouldBePlaying != null) {
			_loc2_ = mShouldBePlaying;
			mShouldBePlaying = null;
			mMovieClipRenderer.play((0 : UInt), _loc2_.loop, _loc2_.finishedCallback);
		}
		SwfFallbackDebug.report(mDBFacade, fallbackCategory, mEffectClassName, mSwfPath, mSwfFallbackReason);
		SwfFallbackDebug.applyOutline(mDBFacade, mEffect, fallbackCategory);
		mRoot.mouseChildren = false;
		mRoot.mouseEnabled = false;
		mRoot.addChild(mEffect);
		if (mAssetLoadedCallback != null) {
			mAssetLoadedCallback(mEffect);
		}
		if (artResolvedCallback != null) {
			artResolvedCallback();
		}
	}

	override public function destroy() {
		mShouldBePlaying = null;
		mAssetLoadedCallback = null;
		artResolvedCallback = null;
		mIconInsert = null;
		mAnchor = null;
		mSortAnchor = null;
		mEffect = null;
		stopStarlingSync();
		if (mStarlingRenderer != null) {
			mStarlingRenderer.destroy();
			mStarlingRenderer = null;
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		super.destroy();
	}
}

private class ShouldBePlaying {
	public var loop:Bool = false;

	public var finishedCallback:ASFunction;

	public function new(l:Bool, f:ASFunction) {
		loop = l;
		finishedCallback = f;
	}
}
