package actor;

import brain.assetRepository.AssetLoadingComponent;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.sound.SoundAsset;
import brain.starling.swfConverter.BakeScheduler;
import brain.utils.ColorMatrix;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.PreRenderWorkComponent;
import combat.weapon.WeaponView;
import dBGlobals.DBGlobal;
import distributedObjects.HeroGameObject;
import distributedObjects.NPCGameObject;
import effects.EffectGameObject;
import effects.EffectView;
import facade.DBFacade;
import dr_floor.FloorObject;
import dr_floor.FloorView;
import gameMasterDictionary.GMActor;
import gameMasterDictionary.GMAttack;
import generatedCode.CombatResult;
import sound.DBSoundComponent;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

class ActorView extends FloorView {
	public static var BODY_Y_OFFSET:Float = -45;

	static inline final DEBUG_HEADING = false;

	static var mMouseOverEffect:GlowFilter = new GlowFilter((16633879 : UInt), 1, 16, 16, 5);

	static var mMouseSelectedEffect:GlowFilter = new GlowFilter((16711680 : UInt), 1, 16, 16, 5);

	var mBody:Sprite;

	var mEffect:Sprite;

	var mParentActorObject:ActorGameObject;

	var mEventComponent:EventComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mPreRenderWorkComponent:PreRenderWorkComponent;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mSoundComponent:DBSoundComponent;

	var mVelocity:Vector3D;

	var mBodyAnimRenderer:ActorRenderer;

	var mAnimName:String = "idle";

	var mHeading:Float = 0;

	var mWantNametag:Bool = false;

	var mNametag:ActorNametag;

	var mCurrentWeaponView:WeaponView;

	var mCurrentWeaponAnimRenderer:ActorRenderer;

	var mBodyFilters:Array<ASAny>;

	var mStatusTintColor:UInt = 0;

	var mStatusTintAmount:Float = 0;

	var mStatusTintAttachments:Vector<EffectView>;

	var mDeathSoundEffect:SoundAsset;

	var mDeathSoundVolume:Float = Math.NaN;

	var mMouseHitRect:Rectangle;

	var mMouseHitRectFixed:Bool = false;

	var mMousePickable:Bool = true;

	public var mousePickedCentrally:Bool = false;

	var specialVFXObject_Back:EffectGameObject;

	var specialVFXObject_Front:EffectGameObject;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject) {
		super(dbFacade, actorGameObject);
		mParentActorObject = actorGameObject;
		mBodyFilters = [];
		mVelocity = new Vector3D(0, 0, 0);
		mEventComponent = new EventComponent(mDBFacade);
		mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade, "ActorView");
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "ActorView");
		mSoundComponent = new DBSoundComponent(dbFacade);
		mRoot.name = "ActorView.mRoot_" + actorGameObject.id;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mBody = new Sprite();
		mBody.name = "ActorView.mBody";
		mRoot.addChild(mBody);
		mEffect = new Sprite();
		mEffect.name = "ActorView.mEffect";
		mRoot.addChild(mEffect);
	}

	function applyColor(node:DisplayObject) {
		var _loc3_ = mParentActorObject.actorData.brightness;
		var _loc5_ = mParentActorObject.actorData.hue;
		var _loc2_ = mParentActorObject.actorData.saturation;
		if (_loc3_ == 0 && _loc5_ == 0 && _loc2_ == 0) {
			return;
		}
		var _loc4_ = new ColorMatrix();
		if (_loc3_ != 0) {
			_loc4_.adjustBrightness(_loc3_);
		}
		if (_loc5_ != 0) {
			_loc4_.adjustHue(_loc5_);
		}
		if (_loc2_ != 0) {
			_loc4_.adjustSaturation(_loc2_);
		}
		node.filters = cast([_loc4_.filter]);
		if (Std.isOfType(node, ActorRenderer)) {
			cast(node, ActorRenderer).applyColorFilter(_loc4_.matrix);
		}
	}

	@:isVar public var bodyAnimRenderer(get, never):ActorRenderer;

	public function get_bodyAnimRenderer():ActorRenderer {
		return mBodyAnimRenderer;
	}

	@:isVar public var currentWeapon(get, set):WeaponView;

	public function get_currentWeapon():WeaponView {
		return mCurrentWeaponView;
	}

	function set_currentWeapon(value:WeaponView):WeaponView {
		if (mCurrentWeaponView == value) {
			return value;
		}
		mCurrentWeaponView = value;
		if (mCurrentWeaponAnimRenderer != null) {
			mCurrentWeaponAnimRenderer.stop();
		}
		mCurrentWeaponAnimRenderer = mCurrentWeaponView.weaponRenderer;
		if (mCurrentWeaponAnimRenderer != null) {
			if (mCurrentWeaponAnimRenderer.hasAnim(mAnimName)) {
				this.bodyAnimRenderer.forceFrame(0);
				mCurrentWeaponAnimRenderer.heading = this.heading;
				mCurrentWeaponAnimRenderer.play(mAnimName, this.bodyAnimRenderer.currentFrame, true, this.bodyAnimRenderer.loop);
			} else {
				mCurrentWeaponAnimRenderer.stop();
			}
			mBody.addChild(mCurrentWeaponAnimRenderer);
			if (this.root.parent != null) {
				mCurrentWeaponAnimRenderer.setLayer(this.layer);
				mCurrentWeaponAnimRenderer.visible = this.root.visible;
			}
			if (mBodyFilters.length > 0) {
				mCurrentWeaponAnimRenderer.setHighlightFilter(getDominantFilterColor());
			}
			if (mStatusTintAmount > 0) {
				mCurrentWeaponAnimRenderer.applyStatusTint(mStatusTintColor, mStatusTintAmount);
			} else {
				mCurrentWeaponAnimRenderer.clearStatusTint();
			}
		}
		return value;
	}

	@:isVar public var nametag(get, never):ActorNametag;

	public function get_nametag():ActorNametag {
		return mNametag;
	}

	public function disableMouse() {
		mMousePickable = false;
		mRoot.mouseChildren = false;
		mRoot.mouseEnabled = false;
	}

	public function enableMouse() {
		mMousePickable = true;
		if (mousePickedCentrally) {
			return;
		}
		mRoot.mouseChildren = true;
		mRoot.mouseEnabled = true;
	}

	@:isVar public var mousePickable(get, never):Bool;

	public function get_mousePickable():Bool {
		return mMousePickable;
	}

	@:isVar public var mouseHitRect(get, never):Rectangle;

	public function get_mouseHitRect():Rectangle {
		if (mMouseHitRect != null) {
			return mMouseHitRect;
		}
		return ASCompat.coerce(mBody != null && mBody.width > 0 ? mBody.getBounds(mRoot) : null, flash.geom.Rectangle);
	}

	@:isVar public var fixedMouseHitRect(get, never):Rectangle;

	public function get_fixedMouseHitRect():Rectangle {
		return mMouseHitRect;
	}

	function setMouseHitRect(x:Float, y:Float, width:Float, height:Float) {
		if (mMouseHitRect == null) {
			mMouseHitRect = new Rectangle();
		}
		mMouseHitRect.setTo(x, y, width, height);
	}

	function setFixedMouseHitRect(x:Float, y:Float, width:Float, height:Float) {
		setMouseHitRect(x, y, width, height);
		mMouseHitRectFixed = true;
	}

	public function actionsForDeadState() {
		this.mouseOverUnhighlight();
		this.mouseSelectedUnhighlight();
		disableMouse();
		if (mDeathSoundEffect != null) {
			mSoundComponent.playSfxOneShot(mDeathSoundEffect, worldCenter, 0, mDeathSoundVolume);
		}
		velocity = new Vector3D(0, 0);
		hideSpecialEffect();
	}

	public function actionsForExitDeadState() {
		enableMouse();
		showSpecialEffect();
	}

	function buildNametag() {
		if (mWantNametag) {
			mNametag = new ActorNametag(mDBFacade, mAssetLoadingComponent, mLogicalWorkComponent, mParentActorObject.actorData.gMActor.NametagY);
			mNametag.cacheAsBitmap = true;
			mNametag.hpBar.scaleX = mParentActorObject.actorData.gMActor.HealthbarScale / root.scaleX;
			mNametag.hpBar.scaleY = mParentActorObject.actorData.gMActor.HealthbarScale / root.scaleY;
			mRoot.addChild(mNametag);
			mNametag.AFK = this.mParentActorObject.AFK;
			mNametag.screenName = this.mParentActorObject.screenName;
			mNametag.setHp(mParentActorObject.hitPoints, (ASCompat.floatToInt(mParentActorObject.maxHitPoints) : UInt));
		}
	}

	@:isVar public var body(get, set):Sprite;

	public function get_body():Sprite {
		return mBody;
	}

	public function applyStatusTint(color:UInt, amount:Float) {
		var _loc3_:EffectView;
		var __ax4_iter_17:Vector<EffectView>;
		mStatusTintColor = color;
		mStatusTintAmount = amount;
		if (amount <= 0) {
			clearStatusTint();
			return;
		}
		if (mBodyAnimRenderer != null) {
			mBodyAnimRenderer.applyStatusTint(color, amount);
		}
		if (mCurrentWeaponAnimRenderer != null) {
			mCurrentWeaponAnimRenderer.applyStatusTint(color, amount);
		}
		if (mStatusTintAttachments != null) {
			__ax4_iter_17 = mStatusTintAttachments;
			if (checkNullIteratee(__ax4_iter_17))
				for (_tmp_ in __ax4_iter_17) {
					_loc3_ = _tmp_;
					_loc3_.applyStatusTint(color, amount);
				}
		}
	}

	public function clearStatusTint() {
		var _loc1_:EffectView;
		var __ax4_iter_18:Vector<EffectView>;
		mStatusTintAmount = 0;
		if (mBodyAnimRenderer != null) {
			mBodyAnimRenderer.clearStatusTint();
		}
		if (mCurrentWeaponAnimRenderer != null) {
			mCurrentWeaponAnimRenderer.clearStatusTint();
		}
		if (mStatusTintAttachments != null) {
			__ax4_iter_18 = mStatusTintAttachments;
			if (checkNullIteratee(__ax4_iter_18))
				for (_tmp_ in __ax4_iter_18) {
					_loc1_ = _tmp_;
					_loc1_.clearStatusTint();
				}
		}
	}

	public function registerStatusTintAttachment(effectView:EffectView) {
		if (effectView == null) {
			return;
		}
		if (mStatusTintAttachments == null) {
			mStatusTintAttachments = new Vector<EffectView>();
		}
		if (mStatusTintAttachments.indexOf(effectView) == -1) {
			mStatusTintAttachments.push(effectView);
			if (mStatusTintAmount > 0) {
				effectView.applyStatusTint(mStatusTintColor, mStatusTintAmount);
			}
		}
	}

	public function unregisterStatusTintAttachment(effectView:EffectView) {
		if (mStatusTintAttachments == null || effectView == null) {
			return;
		}
		var _loc2_ = mStatusTintAttachments.indexOf(effectView);
		if (_loc2_ != -1) {
			effectView.clearStatusTint();
			mStatusTintAttachments.splice(_loc2_, (1 : UInt));
		}
	}

	public function buildBuff(buff:MovieClip, sortLayer:String) {
		if (buff == null) {
			return;
		}
		if (mRoot.contains(buff)) {
			Logger.warn("buff already is a child of mRoot");
			return;
		}
		if (sortLayer == "foreground") {
			mRoot.addChild(buff);
		} else {
			mRoot.addChildAt(buff, 0);
		}
	}

	public function destroyBuff(buff:MovieClip) {
		if (buff == null) {
			return;
		}
		if (mRoot.contains(buff)) {
			mRoot.removeChild(buff);
		}
	}

	override public function init() {
		super.init();
		mBodyAnimRenderer = new ActorRenderer(mDBFacade, mParentActorObject, true);
		mBodyAnimRenderer.loadAssets();
		mBody.addChild(mBodyAnimRenderer);
		applyColor(mBodyAnimRenderer);
		buildNametag();
		if (ASCompat.stringAsBool(mParentActorObject.actorData.deathSound)) {
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), mParentActorObject.actorData.deathSound,
				function(param1:SoundAsset) {
					mDeathSoundEffect = param1;
					mDeathSoundVolume = mParentActorObject.actorData.deathVolume;
				});
		}
		if (mParentActorObject.gmSkin != null && mParentActorObject.gmSkin.doesSpecialFXBackExist()) {
			addSpecialBackEffect(mParentActorObject.gmSkin.specialFXSwfPath_Back, mParentActorObject.gmSkin.specialFXName_Back);
		}
		if (mParentActorObject.gmSkin != null && mParentActorObject.gmSkin.doesSpecialFXFrontExist()) {
			addSpecialFrontEffect(mParentActorObject.gmSkin.specialFXSwfPath_Front, mParentActorObject.gmSkin.specialFXName_Front);
		}
	}

	public function addSpecialBackEffect(swfPath:String, className:String) {
		specialVFXObject_Back = new EffectGameObject(mDBFacade, DBFacade.buildFullDownloadPath(swfPath), className, 1);
		MemoryTracker.track(specialVFXObject_Back, "EffectGameObject \'"
			+ swfPath
			+ ":"
			+ className
			+ "\' - created in ActorView.addSpecialBackEffect()");
		cast(specialVFXObject_Back.view, EffectView).attachToParent(root, true);
		cast(specialVFXObject_Back.view, EffectView).play(true, function() {});
	}

	public function addSpecialFrontEffect(swfPath:String, className:String) {
		specialVFXObject_Front = new EffectGameObject(mDBFacade, DBFacade.buildFullDownloadPath(swfPath), className, 1);
		MemoryTracker.track(specialVFXObject_Front, "EffectGameObject \'"
			+ swfPath
			+ ":"
			+ className
			+ "\' - created in ActorView.addSpecialFrontEffect()");
		cast(specialVFXObject_Front.view, EffectView).attachToParent(root, false);
		cast(specialVFXObject_Front.view, EffectView).play(true, function() {});
	}

	public function showSpecialEffect() {
		if (specialVFXObject_Back != null) {
			specialVFXObject_Back.view.root.visible = true;
		}
		if (specialVFXObject_Front != null) {
			specialVFXObject_Front.view.root.visible = true;
		}
	}

	public function hideSpecialEffect() {
		if (specialVFXObject_Back != null) {
			specialVFXObject_Back.view.root.visible = false;
		}
		if (specialVFXObject_Front != null) {
			specialVFXObject_Front.view.root.visible = false;
		}
	}

	public function hasAnim(animName:String):Bool {
		return this.bodyAnimRenderer.hasAnim(animName);
	}

	public function getAnimDurationInSeconds(animName:String):Float {
		return this.bodyAnimRenderer.getAnimDurationInSeconds(animName);
	}

	public function playAnim(animName:String, startingFrame:Int = 0, restart:Bool = false, loop:Bool = true, playRate:Float = 1):Bool {
		mAnimName = animName;
		if (this.bodyAnimRenderer != null) {
			this.bodyAnimRenderer.heading = this.heading;
			this.bodyAnimRenderer.play(animName, startingFrame, restart, loop, playRate);
		}
		if (mCurrentWeaponAnimRenderer != null) {
			if (mCurrentWeaponAnimRenderer.hasAnim(animName)) {
				mCurrentWeaponAnimRenderer.heading = this.heading;
				mCurrentWeaponAnimRenderer.play(animName, startingFrame, restart, loop, playRate);
			} else {
				mCurrentWeaponAnimRenderer.stop();
			}
		}
		return true;
	}

	@:isVar public var currentAnim(get, never):String;

	public function get_currentAnim():String {
		return mAnimName;
	}

	public function setAnimAt(animName:String, frameNumber:UInt):Bool {
		this.bodyAnimRenderer.heading = this.heading;
		this.bodyAnimRenderer.setFrame(animName, (frameNumber : Int));
		if (mCurrentWeaponAnimRenderer != null) {
			if (mCurrentWeaponAnimRenderer.hasAnim(animName)) {
				mCurrentWeaponAnimRenderer.heading = this.heading;
				mCurrentWeaponAnimRenderer.setFrame(animName, (frameNumber : Int));
			} else {
				mCurrentWeaponAnimRenderer.stop();
			}
		}
		return true;
	}

	public function stopAnim() {
		this.bodyAnimRenderer.stop();
		if (mCurrentWeaponAnimRenderer != null) {
			mCurrentWeaponAnimRenderer.stop();
		}
	}

	public function setHp(hp:UInt, maxHp:UInt) {
		if (mNametag != null) {
			mNametag.setHp(hp, maxHp);
		}
	}

	@:isVar public var screenName(never, set):String;

	public function set_screenName(value:String):String {
		if (mNametag != null) {
			mNametag.screenName = value;
		}
		return value;
	}

	public function setChat(message:String) {
		if (mNametag != null) {
			mNametag.setChat(message);
		}
	}

	@:isVar public var velocity(get, set):Vector3D;

	public function get_velocity():Vector3D {
		return mVelocity;
	}

	function set_velocity(vel:Vector3D):Vector3D {
		return mVelocity = vel;
	}

	@:isVar public var heading(get, set):Float;

	public function set_heading(angle:Float):Float {
		mHeading = angle;
		if (false && Std.isOfType(mParentActorObject, NPCGameObject)) {
			Logger.debugch("heading",
				"ActorView set heading id="
				+ mParentActorObject.id
				+ " const="
				+ (mParentActorObject.actorData != null ? mParentActorObject.actorData.constant : "?")
				+ " heading="
				+ mHeading
				+ " anim="
				+ mAnimName);
		}
		if (this.bodyAnimRenderer != null) {
			this.bodyAnimRenderer.heading = angle;
		}
		if (mCurrentWeaponAnimRenderer != null) {
			mCurrentWeaponAnimRenderer.heading = angle;
		}
		return angle;
	}

	function get_heading():Float {
		return mHeading;
	}

	override public function addToStage() {
		super.addToStage();
		var _loc1_ = this.bodyAnimRenderer;
		if (_loc1_ != null) {
			_loc1_.setLayer(this.layer);
			_loc1_.visible = this.root.visible;
		}
		if (mCurrentWeaponAnimRenderer != null) {
			mCurrentWeaponAnimRenderer.setLayer(this.layer);
			mCurrentWeaponAnimRenderer.visible = this.root.visible;
		}
	}

	override public function removeFromStage() {
		var _loc1_ = this.bodyAnimRenderer;
		if (_loc1_ != null) {
			_loc1_.setLayer(0);
			_loc1_.visible = false;
		}
		if (mCurrentWeaponAnimRenderer != null) {
			mCurrentWeaponAnimRenderer.setLayer(0);
			mCurrentWeaponAnimRenderer.visible = false;
		}
		super.removeFromStage();
	}

	override public function destroy() {
		if (mNametag != null) {
			mNametag.destroy();
			mNametag = null;
		}
		if (mDeathSoundEffect != null) {
			mDeathSoundEffect = null;
		}
		if (specialVFXObject_Back != null) {
			specialVFXObject_Back.destroy();
			specialVFXObject_Back = null;
		}
		if (specialVFXObject_Front != null) {
			specialVFXObject_Front.destroy();
			specialVFXObject_Front = null;
		}
		mEventComponent.destroy();
		mEventComponent = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mPreRenderWorkComponent.destroy();
		mPreRenderWorkComponent = null;
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mSoundComponent.destroy();
		mSoundComponent = null;
		if (mBodyAnimRenderer != null) {
			mBodyAnimRenderer.destroy();
			mBodyAnimRenderer = null;
		}
		mCurrentWeaponView = null;
		mCurrentWeaponAnimRenderer = null;
		mBodyFilters = null;
		mStatusTintAttachments = null;
		mBody = null;
		mEffect = null;
		mParentActorObject = null;
		super.destroy();
	}

	function set_body(value:Sprite):Sprite {
		if (mBody != null && mBody.parent != null) {
			mBody.parent.removeChild(mBody);
		}
		mBody = value;
		mRoot.addChild(mBody);
		return value;
	}

	public function mouseOverHighlight() {
		addEffect(mMouseOverEffect);
	}

	public function mouseOverUnhighlight() {
		removeEffect(mMouseOverEffect);
	}

	public function mouseSelectedHighlight() {
		addEffect(mMouseSelectedEffect);
	}

	public function mouseSelectedUnhighlight() {
		removeEffect(mMouseSelectedEffect);
	}

	public function setStarlingHitArea(bounds:Rectangle) {
		if (mMouseHitRectFixed || bounds == null || bounds.width <= 0 || bounds.height <= 0) {
			return;
		}
		setMouseHitRect(bounds.x, bounds.y, bounds.width, bounds.height);
	}

	public function reviveHighlight() {
		var _loc1_ = new ColorTransform();
		_loc1_.color = (16777215 : UInt);
		mBody.transform.colorTransform = _loc1_;
	}

	public function reviveUnhighlight() {
		mBody.transform.colorTransform = new ColorTransform();
	}

	function addEffect(effect:GlowFilter) {
		if (mBodyFilters.indexOf(effect) < 0) {
			mBodyFilters.push(effect);
			mBody.filters = cast(mBodyFilters);
			if (mBodyAnimRenderer != null) {
				mBodyAnimRenderer.setHighlightFilter(getDominantFilterColor());
			}
			if (mCurrentWeaponAnimRenderer != null) {
				mCurrentWeaponAnimRenderer.setHighlightFilter(getDominantFilterColor());
			}
		}
	}

	function removeEffect(effect:GlowFilter) {
		var _loc2_ = mBodyFilters.indexOf(effect);
		if (_loc2_ >= 0) {
			mBodyFilters.splice(_loc2_, (1 : UInt));
			mBody.filters = cast(mBodyFilters);
			if (mBodyAnimRenderer != null) {
				if (mBodyFilters.length > 0) {
					mBodyAnimRenderer.setHighlightFilter(getDominantFilterColor());
				} else {
					mBodyAnimRenderer.clearHighlightFilter();
				}
			}
			if (mCurrentWeaponAnimRenderer != null) {
				if (mBodyFilters.length > 0) {
					mCurrentWeaponAnimRenderer.setHighlightFilter(getDominantFilterColor());
				} else {
					mCurrentWeaponAnimRenderer.clearHighlightFilter();
				}
			}
		}
	}

	function getDominantFilterColor():UInt {
		if (mBodyFilters.indexOf(mMouseSelectedEffect) >= 0) {
			return mMouseSelectedEffect.color;
		}
		if (mBodyFilters.indexOf(mMouseOverEffect) >= 0) {
			return mMouseOverEffect.color;
		}
		return ASCompat.dynamicAs(mBodyFilters[mBodyFilters.length - 1], GlowFilter).color;
	}

	function playHitEffect(gmAttack:GMAttack, isAttackeeHero:Bool) {
		var _loc5_ = DBFacade.buildFullDownloadPath(gmAttack.HitEffectFilepath);
		var _loc3_ = Std.isOfType(mParentActorObject, HeroGameObject) ? "db_fx_hitRed" : gmAttack.HitEffect;
		if (isAttackeeHero) {
			_loc3_ = gmAttack.HitEffect;
		}
		var _loc4_ = new Vector3D(0, mParentActorObject.actorData.gMActor.ProjEmitOffset);
		var _loc6_ = 1 / mRoot.scaleX;
		var _loc7_ = gmAttack.HitEffectStopRotation ? 0 : Math.random() * 360;
		if (ASCompat.stringAsBool(_loc3_)) {
			mParentActorObject.distributedDungeonFloor.effectManager.playEffect(_loc5_, _loc3_, _loc4_, mParentActorObject, gmAttack.HitEffectBehindAvatar,
				_loc6_, _loc7_);
		}
	}

	function playHitEffectToLerpToAttacker(gmAttack:GMAttack, lerpActor:ActorGameObject) {
		var swfPath:String;
		var hitEffectName:String;
		var lerpedFunc:ASFunction;
		var i:Int;
		if (ASCompat.stringAsBool(gmAttack.HitEffectToLerpToAttacker)) {
			swfPath = DBFacade.buildFullDownloadPath(gmAttack.HitEffectLerpFilepath);
			hitEffectName = gmAttack.HitEffectToLerpToAttacker;
			if (ASCompat.stringAsBool(hitEffectName)) {
				lerpedFunc = function() {
					playLerpedEffect(swfPath, hitEffectName, mParentActorObject, lerpActor, gmAttack.HitEffectToLerpSpeed, gmAttack.HitEffectToLerpGlowColor);
				};
				i = 0;
				while (i < 5) {
					mLogicalWorkComponent.doLater(Math.random() / 100 * i, lerpedFunc);
					i = i + 1;
				}
			}
		}
	}

	function playHitEffectToLerpFromAttacker(gmAttack:GMAttack, lerpActor:ActorGameObject) {
		var swfPath:String;
		var hitEffectName:String;
		var lerpedFunc:ASFunction;
		var i:Int;
		if (ASCompat.stringAsBool(gmAttack.HitEffectToLerpFromAttacker)) {
			swfPath = DBFacade.buildFullDownloadPath(gmAttack.HitEffectLerpFilepath);
			hitEffectName = gmAttack.HitEffectToLerpFromAttacker;
			if (ASCompat.stringAsBool(hitEffectName)) {
				lerpedFunc = function() {
					playLerpedEffect(swfPath, hitEffectName, lerpActor, mParentActorObject, gmAttack.HitEffectToLerpSpeed, gmAttack.HitEffectToLerpGlowColor);
				};
				i = 0;
				while (i < 5) {
					mLogicalWorkComponent.doLater(Math.random() / 100 * i, lerpedFunc);
					i = i + 1;
				}
			}
		}
	}

	function playLerpedEffect(swfPath:String, className:String, parentObject:FloorObject = null, lerpToActor:ActorGameObject = null, lerpSpeed:Float = 1,
			lerpGlowColor:UInt = (13369344 : UInt)) {
		var _loc7_ = new Vector3D(0, 0);
		var _loc8_ = 0.5 + Math.random();
		mParentActorObject.distributedDungeonFloor.effectManager.playLerpedEffect(swfPath, className, _loc7_, parentObject, lerpToActor, lerpSpeed,
			lerpGlowColor, false, _loc8_);
	}

	function playHealEffect() {
		var _loc2_ = DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
		var _loc5_ = "db_fx_heal";
		var _loc1_ = mParentActorObject.projectileLaunchOffset;
		var _loc3_ = 1 / mRoot.scaleX;
		var _loc4_:Float = 0;
		mParentActorObject.distributedDungeonFloor.effectManager.playEffect(_loc2_, _loc5_, _loc1_, mParentActorObject, false, _loc3_, _loc4_);
	}

	function isThisIdTheOwner(id:UInt):Bool {
		var _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(id), ActorGameObject);
		return _loc2_.isOwner;
	}

	function isThisIdAnOwnersPet(id:UInt):Bool {
		var _loc3_:NPCGameObject = null;
		var _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(id), ActorGameObject);
		if (_loc2_ != null) {
			_loc3_ = ASCompat.reinterpretAs(_loc2_, NPCGameObject);
			if (_loc3_ == null) {
				return false;
			}
			if (_loc3_.masterIsUser()) {
				return true;
			}
		}
		return false;
	}

	function isThisAProp(id:UInt):Bool {
		var _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(id), ActorGameObject);
		return _loc2_ != null && _loc2_.actorData.gMActor.CharType == GMActor.CHAR_TYPE_PROP;
	}

	function doesCombatResultInvolveUserOrPetOfUser(combatResult:CombatResult):Bool {
		return isThisIdUserOrPetOfUser(combatResult.attacker) || isThisIdUserOrPetOfUser(combatResult.attackee);
	}

	function doesCombatResultHaveShowHealFlag(combatResult:CombatResult):Bool {
		var _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(combatResult.attackee), ActorGameObject);
		return _loc2_.hasShowHealNumbers;
	}

	function isThisIdUserOrPetOfUser(id:UInt):Bool {
		if (isThisIdTheOwner(id)) {
			return true;
		}
		return isThisIdAnOwnersPet(id);
	}

	public function localCombatHit(combatResult:CombatResult) {
		var _loc2_:GMAttack = null;
		var _loc3_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(combatResult.attacker), ActorGameObject);
		if (_loc3_ == null) {
			return;
		}
		if (_loc3_.isOwner) {
			_loc2_ = ASCompat.coerce(mDBFacade.gameMaster.attackById.itemFor(combatResult.attack.attackType), gameMasterDictionary.GMAttack);
			playHitEffect(_loc2_, _loc3_.isHeroType);
			playHitEffectToLerpToAttacker(_loc2_, _loc3_);
			playHitEffectToLerpFromAttacker(_loc2_, _loc3_);
		}
	}

	public function receiveDamage(combatResult:CombatResult, gmAttack:GMAttack) {
		var attackerGameObject:ActorGameObject;
		var impactSound:String;
		if (combatResult.damage != 0) {
			BakeScheduler.noteCombat();
		}
		attackerGameObject = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(combatResult.attacker), ActorGameObject);
		if (attackerGameObject != null) {
			if (!attackerGameObject.isOwner) {
				playHitEffect(gmAttack, attackerGameObject.isHeroType);
			}
			if (combatResult.damage != 0) {
				if (doesCombatResultInvolveUserOrPetOfUser(combatResult) && !isThisAProp(combatResult.attackee)) {
					spawnDamageFloater(combatResult.criticalHit != 0, combatResult.damage, isThisIdTheOwner(combatResult.attacker),
						isThisIdTheOwner(combatResult.attackee), combatResult.effectiveness);
				}
			}
			if (ASCompat.stringAsBool(mParentActorObject.actorData.hitSound)) {
				this.mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), mParentActorObject.actorData.hitSound,
					function(param1:SoundAsset) {
						mSoundComponent.playSfxOneShot(param1, worldCenter, 0, mParentActorObject.actorData.hitVolume);
					});
			}
		}
		if (gmAttack != null && ASCompat.stringAsBool(gmAttack.ImpactSound)) {
			impactSound = gmAttack.ImpactSound;
			if (combatResult.effectiveness < 0) {
				impactSound = "WeakAttack";
			} else if (combatResult.effectiveness > 0) {
				impactSound = "StrongHit";
			}
			this.mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), impactSound, function(param1:SoundAsset) {
				mSoundComponent.playSfxOneShot(param1, worldCenter, 0, gmAttack.ImpactVolume);
			});
		}
	}

	public function receiveHeal(combatResult:CombatResult, gmAttack:GMAttack) {
		var _loc3_ = false;
		if (combatResult.damage != 0) {
			if (doesCombatResultInvolveUserOrPetOfUser(combatResult) || doesCombatResultHaveShowHealFlag(combatResult)) {
				_loc3_ = isThisIdTheOwner(combatResult.attacker) || isThisIdTheOwner(combatResult.attackee);
				spawnHealFloater(combatResult.damage, isThisIdTheOwner(combatResult.attacker), isThisIdTheOwner(combatResult.attackee),
					combatResult.effectiveness);
			}
		}
	}

	@:isVar var wantDamageFloaters(get, never):Bool;

	function get_wantDamageFloaters():Bool {
		return mDBFacade.featureFlags.getFlagValue("want-damage-floaters") && !mDBFacade.uiHideToggle.hidden;
	}

	public function spawnDamageFloater(isCriticalHit:Bool, delta:Int, attackerIsOwner:Bool, attackeeIsOwner:Bool, effectiveness:Int, inType:UInt = (0 : UInt),
			floaterType:String = "DAMAGE_MOVEMENT_TYPE") {
		if (wantDamageFloaters) {
			DamageFloater.spawn(mDBFacade, delta, mParentActorObject, (0 : UInt), (24 : UInt), 0.9, 90, attackerIsOwner, attackeeIsOwner, isCriticalHit,
				effectiveness, inType, floaterType);
		}
	}

	public function spawnHealFloater(delta:Int, attackerIsOwner:Bool, attackeeIsOwner:Bool, effectiveness:Int, inType:UInt = (0 : UInt),
			floaterType:String = "DAMAGE_MOVEMENT_TYPE") {
		if (wantDamageFloaters) {
			DamageFloater.spawn(mDBFacade, delta, mParentActorObject, (4 : UInt), (24 : UInt), 0.9, 90, attackerIsOwner, attackeeIsOwner, false,
				effectiveness, inType, floaterType);
		}
	}

	public function hasAnimationRenderer():Bool {
		if (bodyAnimRenderer != null) {
			return true;
		}
		return false;
	}

	@:isVar public var AFK(never, set):Bool;

	public function set_AFK(value:Bool):Bool {
		if (mNametag != null) {
			mNametag.AFK = value;
		}
		return value;
	}
}
