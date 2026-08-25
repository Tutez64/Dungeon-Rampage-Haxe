package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import combat.weapon.WeaponGameObject;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import gameMasterDictionary.GMWeaponAesthetic;
import flash.geom.Vector3D;

class PlayEffectAttackTimelineAction extends PlayEffectTimelineAction {
	public static inline final TYPE = "attackEffect";

	public static inline final SWING_RIGHT = "attack_swingRight";

	public static inline final SWING_LEFT = "attack_swingLeft";

	public static inline final SWORD_TRAIL_DEFAULT_PREFIX = "db_fx_attack";

	var mActorPos:Vector3D;

	var mChargeTime:Float = Math.NaN;

	var mWeapon:WeaponGameObject;

	var mRegisterChargeEffectCallback:ASFunction;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor,
			weapon:WeaponGameObject, registerChargeEffectCallback:ASFunction, effectName:String, effectPath:String, xOffset:Float = 0, yOffset:Float = 0,
			headingOffset:Float = 0, headingOffsetAngle:Float = 0, playAtTarget:Bool = false, parentToActor:Bool = false, behindAvatar:Bool = false,
			scale:Float = 1, autoAdjustHeading:Bool = false, loop:Bool = false, layer:String = "sorted", managed:Bool = false, useTimelineSpeed:Bool = false,
			invertAngles:Bool = false, insertParentName:String = "", insertIconPath:String = "", insertIconName:String = "") {
		super(actorGameObject, actorView, dbFacade, effectName, effectPath, xOffset, yOffset, headingOffset, headingOffsetAngle, playAtTarget, parentToActor,
			behindAvatar, scale, autoAdjustHeading, loop, layer, managed, useTimelineSpeed, invertAngles, insertParentName, insertIconPath, insertIconName);
		mDistributedDungeonFloor = distributedDungeonFloor;
		mWeapon = weapon;
		var _loc26_ = mWeapon != null ? mWeapon.collisionScale() : 1;
		mScale *= _loc26_;
		mXOffset *= _loc26_;
		mYOffset *= _loc26_;
		mRegisterChargeEffectCallback = registerChargeEffectCallback;
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			distributedDungeonFloor:DistributedDungeonFloor, actionObj:ASObject, weapon:WeaponGameObject,
			registerChargeEffectCallback:ASFunction):PlayEffectAttackTimelineAction {
		return new PlayEffectAttackTimelineAction(actorGameObject, actorView, dbFacade, distributedDungeonFloor, weapon, registerChargeEffectCallback,
			actionObj.name, actionObj.path, ASCompat.toNumberField(actionObj, "xOffset"), ASCompat.toNumberField(actionObj, "yOffset"),
			ASCompat.toNumberField(actionObj, "headingOffset"), ASCompat.toNumberField(actionObj, "headingOffsetAngle"),
			ASCompat.toBool(actionObj.playAtTarget), ASCompat.toBool(actionObj.parentToActor), ASCompat.toBool(actionObj.behindAvatar),
			ASCompat.toNumberField(actionObj, "scale"), ASCompat.toBool(actionObj.autoAdjustHeading), ASCompat.toBool(actionObj.loop), actionObj.layer,
			ASCompat.toBool(actionObj.managed), ASCompat.toBool(actionObj.useTimelineSpeed), ASCompat.toBool(actionObj.invertAngles),
			actionObj.insertParentName, actionObj.insertIconPath, actionObj.insertIconName);
	}

	override public function execute(timeline:ScriptTimeline) {
		var _loc5_:GMWeaponAesthetic = null;
		if (mPlayAtTarget && timeline.targetActor == null) {
			return;
		}
		if (useTimelineSpeed) {
			mPlayRate = timeline.playSpeed;
		}
		var _loc3_:ActorGameObject = null;
		if (mParentToActor) {
			_loc3_ = mActorGameObject;
		}
		var _loc4_ = calculatePositionBasedOnOffsets(timeline.targetActor);
		var _loc10_ = mEffectName.substring(0);
		var _loc7_ = mActorGameObject.heading;
		var _loc2_:Float = 0;
		var _loc9_:Float = 0;
		if (mAutoAdjustHeading) {
			_loc2_ = _loc7_;
		}
		var _loc6_:ASObject = {};
		if (mInvertAngles) {
			_loc7_ += 180;
		}
		if (mEffectName.indexOf("_angle") >= 0) {
			if (mActorGameObject.currentWeapon != null) {
				_loc5_ = mActorGameObject.currentWeapon.weaponAesthetic;
			}
			if (_loc5_ != null && ASCompat.stringAsBool(_loc5_.SwordTrailOverride)) {
				_loc10_ = StringTools.replace(_loc10_, "db_fx_attack", _loc5_.SwordTrailOverride);
			}
			_loc6_ = convertAngleForEffectName(Std.int(_loc7_));
			_loc10_ += _loc6_.string;
			if (_loc10_.indexOf("swing_angle") >= 0) {
				if (mActorGameObject.actorView.currentAnim == "attack_swingRight") {
					_loc10_ += "_right";
				} else {
					_loc10_ += "_left";
				}
			}
		}
		if (ASCompat.toBool(_loc6_.flip)) {
			_loc9_ = 180;
		}
		var _loc8_ = (0 : UInt);
		_loc10_ = mDBFacade.customSkinVisualsOverrideHandler.customSkinBusterVisualOverrider(_loc10_, mActorGameObject);
		_loc8_ = mActorGameObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mEffectPath), _loc10_, _loc4_, _loc3_,
			mBehindAvatar, mScale, 0, 0, _loc9_, _loc2_, mLoop, mLayer, mManaged, mPlayRate,
			ASCompat.asFunction(mDoIconInsert ? assetLoadedCallback(this) : null));
		if (mManaged) {
			timeline.mManagedEffects.add(_loc8_);
		}
	}

	public function convertAngleForEffectName(angle:Int):ASObject {
		var _loc3_:ASObject = {
			"string": "",
			"flip": true
		};
		if (angle < 0) {
			angle = 360 + angle;
		}
		var _loc2_ = angle % 45;
		if (_loc2_ > 22) {
			angle += 45 - _loc2_;
		} else {
			angle -= _loc2_;
		}
		if (angle == 0 || angle == 360) {
			ASCompat.setProperty(_loc3_, "string", "180");
		} else if (angle == 45) {
			ASCompat.setProperty(_loc3_, "string", "135");
		} else if (angle == 315) {
			ASCompat.setProperty(_loc3_, "string", "225");
		} else {
			ASCompat.setProperty(_loc3_, "flip", false);
			ASCompat.setProperty(_loc3_, "string", Std.string(angle));
		}
		return _loc3_;
	}

	override public function destroy() {
		mRegisterChargeEffectCallback = null;
		mWeapon = null;
		super.destroy();
	}
}
