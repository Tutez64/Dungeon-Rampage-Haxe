package projectile;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.StarlingAssetMapper;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.utils.ColorMatrix;
import brain.workLoop.LayerWorkComponent;
import brain.workLoop.LogicalWorkComponent;
import facade.DBFacade;
import dr_floor.FloorView;
import starling.SwfFallbackDebug;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import starling.extensions.animate.Animation;

class ProjectileView extends FloorView {
	var mLogicalWorkComponent:LogicalWorkComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mBody:MovieClip;

	var mEffect:MovieClip;

	var mProjectileGameObject:ProjectileGameObject;

	var mEffectRenderer:MovieClipRenderController;

	var mProjectileRenderer:MovieClipRenderController;

	var mStarlingRenderer:StarlingProjectileRenderer;

	var mStarlingSyncComponent:LayerWorkComponent;

	var mOnStage:Bool = false;

	var mBodyRotation:Float = 0;

	var mBodyScaleX:Float = 1;

	var mBodyScaleY:Float = 1;

	var mEffectRotation:Float = 0;

	var mCreationGameTime:Float = Math.NaN;

	public function new(facade:DBFacade, gameObject:ProjectileGameObject) {
		super(facade, gameObject);
		mProjectileGameObject = gameObject;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "ProjectileView");
		mBodyRotation = 0;
		mBodyScaleX = 1;
		mBodyScaleY = 1;
		mEffectRotation = 0;
	}

	override public function init() {
		super.init();
		if (mLogicalWorkComponent.gameClock != null) {
			mCreationGameTime = mLogicalWorkComponent.gameClock.gameTime;
		}
		loadProjectileAssets();
	}

	function effectDelayRemaining():Float {
		if (Math.isNaN(mCreationGameTime) || mLogicalWorkComponent.gameClock == null) {
			return mProjectileGameObject.effectTimeOffset;
		}
		var _loc1_ = mLogicalWorkComponent.gameClock.gameTime - mCreationGameTime;
		return Math.max(0, mProjectileGameObject.effectTimeOffset - _loc1_ / 1000);
	}

	function createEffect(gameClock:GameClock = null) {
		if (mProjectileGameObject.effectName == null) {
			return;
		}
		if (mStarlingRenderer != null) {
			showStarlingEffect();
		} else {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mProjectileGameObject.effectPath), setupEffect);
		}
	}

	public function setupEffect(swfAsset:SwfAsset) {
		mEffectRenderer = ASCompat.reinterpretAs(mDBFacade.movieClipPool.checkout(mDBFacade, swfAsset, mProjectileGameObject.effectName),
			MovieClipRenderController);
		mEffect = mEffectRenderer.clip;
		var _loc3_ = mProjectileGameObject.weapon != null ? mProjectileGameObject.weapon.collisionScale() : 1;
		mEffect.scaleX;
		mEffect.scaleY;
		var _loc4_ = mProjectileGameObject.gmProjectile.TrailTint;
		var _loc2_ = mProjectileGameObject.gmProjectile.TrailSaturation;
		applyColor(_loc4_, _loc2_, mEffect);
		SwfFallbackDebug.applyOutline(mDBFacade, mEffect, "PROJECTILE");
		mEffectRenderer.play((0 : UInt), true);
		mRoot.addChildAt(mEffect, 0);
		mEffect.rotation = Math.atan2(mProjectileGameObject.velocity.y, mProjectileGameObject.velocity.x) * 180 / 3.141592653589793;
	}

	function loadProjectileAssets() {
		var atlasKey:String;
		var swfPath = DBFacade.buildFullDownloadPath(mProjectileGameObject.gmProjectile.SwfFilepath);
		if (!ASCompat.stringAsBool(mProjectileGameObject.gmProjectile.ProjModel)
			|| mDBFacade.assetLoadingComponent == null
			|| mDBFacade.starlingLayerManager == null
			|| mDBFacade.starlingLayerManager.getLayer(mProjectileGameObject.layer) == null) {
			reportSwfFallback(swfPath,
				!ASCompat.stringAsBool(mProjectileGameObject.gmProjectile.ProjModel) ? "no ProjModel in GameMaster data" : (mDBFacade.assetLoadingComponent == null ? "no asset loading component" : (mDBFacade.starlingLayerManager == null ? "no Starling layer manager (Stage3D not up)" : "no Starling layer for projectile layer "
					+ mProjectileGameObject.layer)));
			mAssetLoadingComponent.getSwfAsset(swfPath, setupArt);
			return;
		}
		atlasKey = StarlingAssetMapper.getActorAtlasKeyFromPath(swfPath);
		if (atlasKey == null) {
			reportSwfFallback(swfPath, "no Starling atlas key mapped for the projectile SWF path");
			mAssetLoadingComponent.getSwfAsset(swfPath, setupArt);
			return;
		}
		mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(swfPath, function() {
			if (mProjectileGameObject == null) {
				return;
			}
			onBodyAtlasLoaded(swfPath);
		}, false, mProjectileGameObject.belongsToRemotePlayer,
			mProjectileGameObject.backgroundLoadTier);
	}

	function onBodyAtlasLoaded(swfPath:String) {
		var effectSwfPath:String;
		var effectAtlasKey:String;
		var bodyClassName = mProjectileGameObject.gmProjectile.ProjModel;
		bodyClassName = mDBFacade.customSkinVisualsOverrideHandler.customSkinProjectileVisualOverrider(bodyClassName, mProjectileGameObject.parentActorSkinId);
		var atlasKey = StarlingAssetMapper.getActorAtlasKeyFromPath(swfPath);
		var bodyAnimation = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(atlasKey, bodyClassName);
		var bodyLabel:String = null;
		if (bodyAnimation == null) {
			bodyAnimation = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(atlasKey);
			if (bodyAnimation != null && bodyAnimation.getFrame(bodyClassName) >= 0) {
				bodyLabel = bodyClassName;
			} else if (bodyAnimation != null) {
				bodyAnimation.dispose();
				bodyAnimation = null;
			}
		}
		if (bodyAnimation == null) {
			fallBackToSwf(swfPath, "no Starling animation for \'" + bodyClassName + "\' in atlas \'" + atlasKey + "\'");
			return;
		}
		if (mProjectileGameObject.effectName == null) {
			createStarlingRenderer(bodyAnimation, bodyLabel, null, null);
			return;
		}
		effectSwfPath = DBFacade.buildFullDownloadPath(mProjectileGameObject.effectPath);
		effectAtlasKey = StarlingAssetMapper.getActorAtlasKeyFromPath(effectSwfPath);
		if (effectAtlasKey == null) {
			Logger.warn("ProjectileView: no Starling atlas for trail " + effectSwfPath + ", rendering body only");
			createStarlingRenderer(bodyAnimation, bodyLabel, null, null);
			return;
		}
		if (effectAtlasKey == atlasKey) {
			onEffectAtlasLoaded(swfPath, bodyAnimation, bodyLabel, effectAtlasKey);
			return;
		}
		createStarlingRenderer(bodyAnimation, bodyLabel, null, null);
		mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(effectSwfPath, function() {
			onLateEffectAtlasLoaded(swfPath, effectAtlasKey);
		}, false, mProjectileGameObject.belongsToRemotePlayer,
			mProjectileGameObject.backgroundLoadTier);
	}

	function onEffectAtlasLoaded(swfPath:String, bodyAnimation:Animation, bodyLabel:String, effectAtlasKey:String) {
		var _loc7_ = mProjectileGameObject.effectName;
		var _loc6_ = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(effectAtlasKey, _loc7_);
		var _loc5_:String = null;
		if (_loc6_ == null) {
			_loc6_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(effectAtlasKey);
			if (_loc6_ != null && _loc6_.getFrame(_loc7_) >= 0) {
				_loc5_ = _loc7_;
			} else if (_loc6_ != null) {
				_loc6_.dispose();
				_loc6_ = null;
			}
		}
		if (_loc6_ == null) {
			Logger.warn("ProjectileView: no Starling trail " + _loc7_ + " in " + effectAtlasKey + ", rendering body only");
			createStarlingRenderer(bodyAnimation, bodyLabel, null, null);
			return;
		}
		createStarlingRenderer(bodyAnimation, bodyLabel, _loc6_, _loc5_);
	}

	function onLateEffectAtlasLoaded(swfPath:String, effectAtlasKey:String) {
		if (mProjectileGameObject == null || mStarlingRenderer == null) {
			return;
		}
		var _loc5_ = mProjectileGameObject.effectName;
		var _loc4_ = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(effectAtlasKey, _loc5_);
		var _loc3_:String = null;
		if (_loc4_ == null) {
			_loc4_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(effectAtlasKey);
			if (_loc4_ != null && _loc4_.getFrame(_loc5_) >= 0) {
				_loc3_ = _loc5_;
			} else if (_loc4_ != null) {
				_loc4_.dispose();
				_loc4_ = null;
			}
		}
		if (_loc4_ == null) {
			Logger.warn("ProjectileView: no Starling trail " + _loc5_ + " in " + effectAtlasKey + ", rendering body only");
			return;
		}
		if (!mStarlingRenderer.attachEffect(_loc4_, _loc3_)) {
			_loc4_.dispose();
			return;
		}
		startStarlingEffect();
	}

	function tearDownStarlingRenderer() {
		if (mStarlingSyncComponent != null) {
			mStarlingSyncComponent.destroy();
			mStarlingSyncComponent = null;
		}
		if (mStarlingRenderer != null) {
			mStarlingRenderer.destroy();
			mStarlingRenderer = null;
		}
	}

	function fallBackToSwf(swfPath:String, reason:String = "unknown") {
		reportSwfFallback(swfPath, reason);
		mAssetLoadingComponent.getSwfAsset(swfPath, setupArt);
	}

	function reportSwfFallback(swfPath:String, reason:String) {
		var _loc3_ = mProjectileGameObject != null
			&& mProjectileGameObject.gmProjectile != null ? mProjectileGameObject.gmProjectile.ProjModel : "?";
		SwfFallbackDebug.report(mDBFacade, "PROJECTILE", _loc3_, swfPath, reason);
	}

	function createStarlingRenderer(bodyAnimation:Animation, bodyLabel:String, effectAnimation:Animation, effectLabel:String) {
		var _loc6_ = Math.NaN;
		mStarlingRenderer = new StarlingProjectileRenderer(mDBFacade, mProjectileGameObject.gmProjectile.ProjModel + "_" + mProjectileGameObject.id,
			this.layer, bodyAnimation, bodyLabel, effectAnimation, effectLabel);
		if (mOnStage) {
			mStarlingRenderer.setLayer(this.layer);
			mStarlingRenderer.visible = mRoot.visible;
		} else {
			mStarlingRenderer.setLayer(0);
			mStarlingRenderer.visible = false;
		}
		var _loc7_ = mProjectileGameObject.gmProjectile.Tint;
		var _loc5_ = mProjectileGameObject.gmProjectile.Saturation;
		applyStarlingColor(_loc7_, _loc5_, true);
		if (effectAnimation != null) {
			startStarlingEffect();
		}
		if (mProjectileGameObject.weapon != null) {
			applyStarlingWeaponAesthetic();
		}
		if (mProjectileGameObject.rotationSpeed == 0) {
			if (mProjectileGameObject.shouldRotate) {
				mStarlingRenderer.setBodyRotation(mBodyRotation = Math.atan2(mProjectileGameObject.velocity.y,
					mProjectileGameObject.velocity.x) * 180 / 3.141592653589793);
			}
		} else {
			mLogicalWorkComponent.doEveryFrame(updateRotation);
		}
		syncStarlingTransform();
		mStarlingRenderer.play();
		mStarlingSyncComponent = new LayerWorkComponent(mDBFacade, "ProjectileView");
		mStarlingSyncComponent.doEveryFrame(onStarlingSyncFrame);
	}

	function startStarlingEffect() {
		var _loc2_ = mProjectileGameObject.gmProjectile.TrailTint;
		var _loc3_ = mProjectileGameObject.gmProjectile.TrailSaturation;
		applyStarlingColor(_loc2_, _loc3_, false);
		var _loc1_ = effectDelayRemaining();
		if (_loc1_ > 0) {
			mStarlingRenderer.setEffectVisible(false);
			mLogicalWorkComponent.doLater(_loc1_, showStarlingEffect);
		} else {
			showStarlingEffect();
		}
	}

	function applyStarlingColor(tint:Float, saturation:Float, isBody:Bool) {
		if (mStarlingRenderer == null) {
			return;
		}
		if (tint == 0 && saturation == 1) {
			if (isBody) {
				mStarlingRenderer.clearBodyColorFilter();
			} else {
				mStarlingRenderer.clearEffectColorFilter();
			}
			return;
		}
		var _loc4_ = new ColorMatrix();
		_loc4_.adjustHue(tint);
		_loc4_.adjustSaturation(saturation);
		if (isBody) {
			mStarlingRenderer.setBodyColorFilter(_loc4_.matrix);
		} else {
			mStarlingRenderer.setEffectColorFilter(_loc4_.matrix);
		}
	}

	function applyStarlingWeaponAesthetic() {
		var _loc1_:Array<ASAny> = null;
		if (mStarlingRenderer == null || mProjectileGameObject.weapon == null) {
			return;
		}
		var _loc4_ = mProjectileGameObject.weapon.weaponAesthetic;
		var _loc7_ = mProjectileGameObject.weapon.collisionScale();
		mBodyScaleX = 1;
		mBodyScaleY = 1;
		if (_loc4_.HasColor) {
			_loc1_ = [
				_loc4_.ItemR,
				0,
				0,
				0,
				_loc4_.ItemRAdd,
				0,
				_loc4_.ItemG,
				0,
				0,
				_loc4_.ItemGAdd,
				0,
				0,
				_loc4_.ItemB,
				0,
				_loc4_.ItemBAdd,
				0,
				0,
				0,
				1,
				0
			];
			mStarlingRenderer.setBodyColorFilter(_loc1_);
		}
		var _loc6_ = (0 : UInt);
		var _loc2_:Float = 1;
		var _loc5_:Float = 0;
		var _loc3_ = false;
		if (mProjectileGameObject.weapon.gmRarity.HasGlow) {
			_loc6_ = mProjectileGameObject.weapon.gmRarity.GlowColor;
			_loc2_ = 0.5 * mProjectileGameObject.weapon.gmRarity.GlowStr * _loc7_;
			_loc5_ = mProjectileGameObject.weapon.gmRarity.GlowDist * _loc7_;
			_loc3_ = true;
		} else if (_loc4_.HasGlow) {
			_loc6_ = _loc4_.GlowColor;
			_loc2_ = _loc4_.GlowStr;
			_loc5_ = _loc4_.GlowDist;
			_loc3_ = true;
		}
		if (_loc3_ && _loc5_ > 0) {
			mStarlingRenderer.setBodyGlowFilter(_loc6_, _loc2_, _loc5_, 1);
		}
	}

	function showStarlingEffect(gameClock:GameClock = null) {
		if (mStarlingRenderer == null) {
			return;
		}
		mEffectRotation = Math.atan2(mProjectileGameObject.velocity.y, mProjectileGameObject.velocity.x) * 180 / 3.141592653589793;
		mStarlingRenderer.setEffectRotation(mEffectRotation);
		mStarlingRenderer.setEffectVisible(true);
	}

	function onStarlingSyncFrame(clock:GameClock) {
		syncStarlingTransform();
	}

	function syncStarlingTransform() {
		if (mStarlingRenderer == null || mProjectileGameObject == null) {
			return;
		}
		var _loc1_ = mProjectileGameObject.weapon != null ? mProjectileGameObject.weapon.collisionScale() : 1;
		mStarlingRenderer.setTransform(mRoot.x, mRoot.y, mBodyScaleX * _loc1_, mBodyScaleY * _loc1_, mRoot.alpha);
		mStarlingRenderer.setBodyRotation(mBodyRotation);
		if (mStarlingRenderer.visible != (mOnStage && mRoot.visible)) {
			mStarlingRenderer.visible = mOnStage && mRoot.visible;
		}
	}

	function setupArt(swfAsset:SwfAsset) {
		var _loc4_ = mProjectileGameObject.gmProjectile.ProjModel;
		_loc4_ = mDBFacade.customSkinVisualsOverrideHandler.customSkinProjectileVisualOverrider(_loc4_, mProjectileGameObject.parentActorSkinId);
		mProjectileRenderer = ASCompat.reinterpretAs(mDBFacade.movieClipPool.checkout(mDBFacade, swfAsset, _loc4_), MovieClipRenderController);
		mBody = mProjectileRenderer.clip;
		mProjectileRenderer.play((0 : UInt), true);
		mRoot.addChild(mBody);
		var _loc5_ = mProjectileGameObject.gmProjectile.Tint;
		var _loc2_ = mProjectileGameObject.gmProjectile.Saturation;
		applyColor(_loc5_, _loc2_, mBody);
		if (mProjectileGameObject.rotationSpeed == 0) {
			if (mProjectileGameObject.shouldRotate) {
				mBody.rotation = Math.atan2(mProjectileGameObject.velocity.y, mProjectileGameObject.velocity.x) * 180 / 3.141592653589793;
			}
		} else {
			mLogicalWorkComponent.doEveryFrame(updateRotation);
		}
		if (mProjectileGameObject.weapon != null) {
			applyColorAndGlow(mBody);
			mBody.scaleX *= mProjectileGameObject.weapon.collisionScale();
			mBody.scaleY *= mProjectileGameObject.weapon.collisionScale();
		}
		SwfFallbackDebug.applyOutline(mDBFacade, mBody, "PROJECTILE");
		mBodyScaleX = mBody.scaleX;
		mBodyScaleY = mBody.scaleY;
		var _loc3_ = effectDelayRemaining();
		if (_loc3_ > 0) {
			mLogicalWorkComponent.doLater(_loc3_, createEffect);
		} else {
			createEffect();
		}
	}

	function applyColorAndGlow(node:DisplayObject) {
		var _loc2_ = mProjectileGameObject.weapon.weaponAesthetic;
		if (_loc2_.HasColor) {
			node.transform.colorTransform = new ColorTransform(_loc2_.ItemR, _loc2_.ItemG, _loc2_.ItemB, 1, _loc2_.ItemRAdd, _loc2_.ItemGAdd, _loc2_.ItemBAdd,
				0);
		}
		if (_loc2_.HasGlow) {
			node.filters = cast([
				new GlowFilter(_loc2_.GlowColor, 1, _loc2_.GlowDist, _loc2_.GlowDist, _loc2_.GlowStr)
			]);
		}
		if (mProjectileGameObject.weapon.gmRarity.HasGlow) {
			node.filters = cast([
				new GlowFilter(mProjectileGameObject.weapon.gmRarity.GlowColor, 0.5,
					mProjectileGameObject.weapon.gmRarity.GlowDist * mProjectileGameObject.weapon.collisionScale(),
					mProjectileGameObject.weapon.gmRarity.GlowDist * mProjectileGameObject.weapon.collisionScale(),
					mProjectileGameObject.weapon.gmRarity.GlowStr * mProjectileGameObject.weapon.collisionScale())
			]);
		}
	}

	function applyColor(tint:Float, saturation:Float, node:DisplayObject) {
		var _loc4_:ColorMatrix = null;
		if (tint != 0 || saturation != 1) {
			_loc4_ = new ColorMatrix();
			_loc4_.adjustHue(tint);
			_loc4_.adjustSaturation(saturation);
			node.filters = cast([_loc4_.filter]);
		} else {
			node.filters = cast([]);
		}
	}

	function updateRotation(gameClock:GameClock) {
		if (mBody != null) {
			mBody.rotation += mProjectileGameObject.rotationSpeed * mLogicalWorkComponent.gameClock.tickLength;
		}
		mBodyRotation += mProjectileGameObject.rotationSpeed * mLogicalWorkComponent.gameClock.tickLength;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setBodyRotation(mBodyRotation);
		}
	}

	public function setRotation(newRotation:Float) {
		if (mBody != null) {
			mBody.rotation = newRotation;
		}
		mBodyRotation = newRotation;
		if (mStarlingRenderer != null) {
			mStarlingRenderer.setBodyRotation(newRotation);
		}
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

	override public function destroy() {
		tearDownStarlingRenderer();
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mBody = null;
		mEffect = null;
		if (mEffectRenderer != null) {
			mDBFacade.movieClipPool.checkin(mEffectRenderer);
			mEffectRenderer = null;
		}
		if (mProjectileRenderer != null) {
			mDBFacade.movieClipPool.checkin(mProjectileRenderer);
			mProjectileRenderer = null;
		}
		mProjectileGameObject = null;
		super.destroy();
	}
}
