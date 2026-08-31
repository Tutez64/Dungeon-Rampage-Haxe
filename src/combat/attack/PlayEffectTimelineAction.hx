package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.geom.Vector3D;

class PlayEffectTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "effect";

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mDistributedDungeonFloor:DistributedDungeonFloor;

	var mEffectName:String;

	var mEffectPath:String;

	var mXOffset:Float = Math.NaN;

	var mYOffset:Float = Math.NaN;

	var mHeadingOffset:Float = Math.NaN;

	var mHeadingOffsetAngle:Float = Math.NaN;

	var mParentToActor:Bool = false;

	var mPlayAtTarget:Bool = false;

	var mBehindAvatar:Bool = false;

	var mScale:Float = Math.NaN;

	var mAutoAdjustHeading:Bool = false;

	var mLoop:Bool = false;

	var mLayer:String;

	var mPlayRate:Float = Math.NaN;

	var mUseTimelineSpeed:Bool = false;

	var mInsertParentName:String;

	var mInsertIconPath:String;

	var mInsertIconName:String;

	var mInsertIconClip:MovieClip;

	var mInsertParentClip:MovieClip;

	var mDoIconInsert:Bool = false;

	public var mManaged:Bool = false;

	var mInvertAngles:Bool = false;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, effectName:String, effectPath:String, xOffset:Float = 0,
			yOffset:Float = 0, headingOffset:Float = 0, headingOffsetAngle:Float = 0, playAtTarget:Bool = false, parentToActor:Bool = false,
			behindAvatar:Bool = false, scale:Float = 1, autoAdjustHeading:Bool = false, loop:Bool = false, layer:String = "sorted", managed:Bool = false,
			useTimelineSpeed:Bool = false, invertAngles:Bool = false, insertParentName:String = "", insertIconPath:String = "", insertIconName:String = "") {
		super(actorGameObject, actorView, dbFacade);
		mEffectName = effectName;
		mEffectPath = effectPath;
		mXOffset = xOffset;
		mYOffset = yOffset;
		mHeadingOffset = headingOffset;
		mHeadingOffsetAngle = headingOffsetAngle;
		mPlayAtTarget = playAtTarget;
		mParentToActor = parentToActor;
		mBehindAvatar = behindAvatar;
		mScale = scale;
		mAutoAdjustHeading = autoAdjustHeading;
		mLoop = loop;
		mLayer = layer != null ? layer : "sorted";
		mManaged = managed;
		if (!ASCompat.floatAsBool(mScale)) {
			mScale = 1;
		}
		mPlayRate = 1;
		mUseTimelineSpeed = false;
		if (useTimelineSpeed) {
			mUseTimelineSpeed = true;
		}
		mInvertAngles = invertAngles;
		mInsertParentName = insertParentName;
		mInsertIconPath = insertIconPath;
		mInsertIconName = insertIconName;
		mDoIconInsert = mInsertParentName != null && mInsertIconPath != null && mInsertIconName != null;
		if (mDoIconInsert) {
			mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mInsertIconPath), iconAssetLoaded(this));
		}
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):PlayEffectTimelineAction {
		return new PlayEffectTimelineAction(actorGameObject, actorView, dbFacade, actionObj.name, actionObj.path,
			ASCompat.toNumberField(actionObj, "xOffset"), ASCompat.toNumberField(actionObj, "yOffset"), ASCompat.toNumberField(actionObj, "headingOffset"),
			ASCompat.toNumberField(actionObj, "headingOffsetAngle"), ASCompat.toBool(actionObj.playAtTarget), ASCompat.toBool(actionObj.parentToActor),
			ASCompat.toBool(actionObj.behindAvatar), ASCompat.toNumberField(actionObj, "scale"), ASCompat.toBool(actionObj.autoAdjustHeading),
			ASCompat.toBool(actionObj.loop), actionObj.layer, ASCompat.toBool(actionObj.managed), ASCompat.toBool(actionObj.useTimelineSpeed),
			ASCompat.toBool(actionObj.invertAngles), actionObj.insertParentName, actionObj.insertIconPath, actionObj.insertIconName);
	}

	override public function destroy() {
		mDistributedDungeonFloor = null;
		mInsertIconClip = null;
		mInsertParentName = "";
		mInsertIconName = "";
		super.destroy();
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
	}

	function TryInsertClipIntoEffect() {
		var _loc1_:MovieClip = null;
		if (mInsertIconClip != null && mInsertParentClip != null) {
			if (mInsertParentClip.getChildByName(mInsertParentName) == null) {
				Logger.warn("mInsertParentClip.getChildByName( " + mInsertParentClip + " ) == null");
				return;
			}
			_loc1_ = cast(mInsertParentClip.getChildByName(mInsertParentName), MovieClip);
			if (_loc1_ == null) {
				Logger.warn("parentNameMovieClip == null");
				return;
			}
			while (_loc1_.numChildren > 0) {
				_loc1_.removeChildAt(0);
			}
			_loc1_.addChild(mInsertIconClip);
		}
	}

	function iconAssetLoaded(timeline_action:PlayEffectTimelineAction):ASFunction {
		return function(param1:brain.assetRepository.SwfAsset) {
			var _loc2_ = param1.getClass(timeline_action.mInsertIconName);
			if (_loc2_ == null) {
				Logger.error("Unable to find class: " + timeline_action.mInsertIconName);
				return;
			}
			timeline_action.mInsertIconClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
			timeline_action.mInsertIconClip.mouseChildren = false;
			timeline_action.mInsertIconClip.mouseEnabled = false;
			timeline_action.TryInsertClipIntoEffect();
		};
	}

	function assetLoadedCallback(timeline_action:PlayEffectTimelineAction):ASFunction {
		return function(param1:MovieClip) {
			timeline_action.mInsertParentClip = param1;
			timeline_action.TryInsertClipIntoEffect();
		};
	}

	public function calculateHeadingOffset(offset:Float, heading:Float, actorPosition:Vector3D, angleAddition:Float = 0):Vector3D {
		heading += angleAddition;
		if (heading < 0) {
			heading = 360 + heading;
		}
		heading = convertToRadians(heading);
		var _loc5_ = new Vector3D(0, 0, 0);
		_loc5_.x = actorPosition.x + offset * Math.cos(heading);
		_loc5_.y = actorPosition.y + offset * Math.sin(heading);
		return _loc5_;
	}

	function convertToRadians(angle:Float):Float {
		return angle * 3.141592653589793 / 180;
	}

	@:isVar public var useTimelineSpeed(get, never):Bool;

	public function get_useTimelineSpeed():Bool {
		return mUseTimelineSpeed;
	}

	public function calculatePositionBasedOnOffsets(targetActor:ActorGameObject):Vector3D {
		var _loc3_:Vector3D = null;
		var _loc2_ = new Vector3D(0, 0, 0);
		if (mPlayAtTarget) {
			_loc2_ = targetActor.position;
		} else {
			_loc3_ = new Vector3D(0, 0, 0);
			if (!mParentToActor) {
				if (ASCompat.floatAsBool(mHeadingOffset)) {
					_loc3_ = mActorGameObject.position;
				} else {
					_loc2_ = mActorGameObject.position;
				}
			}
			if (!ASCompat.floatAsBool(mHeadingOffsetAngle)) {
				mHeadingOffsetAngle = 0;
			}
			if (ASCompat.floatAsBool(mHeadingOffset)) {
				_loc2_ = calculateHeadingOffset(mHeadingOffset, mActorGameObject.heading, _loc3_, mHeadingOffsetAngle);
			}
		}
		if (!ASCompat.floatAsBool(mYOffset)) {
			mYOffset = 0;
		}
		if (!ASCompat.floatAsBool(mXOffset)) {
			mXOffset = 0;
		}
		_loc2_.y += mYOffset;
		_loc2_.x += mXOffset;
		return _loc2_;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		if (mPlayAtTarget && timeline.targetActor == null) {
			return;
		}
		mPlayRate = timeline.playSpeed;
		var _loc2_:ActorGameObject = null;
		if (mParentToActor) {
			_loc2_ = mActorGameObject;
		}
		var _loc3_ = calculatePositionBasedOnOffsets(timeline.targetActor);
		var _loc4_ = mActorGameObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mEffectPath), mEffectName, _loc3_,
			_loc2_, mBehindAvatar, mScale, 0, 0, 0, 0, false, mLayer, mManaged, mPlayRate,
			ASCompat.asFunction(mDoIconInsert ? assetLoadedCallback(this) : null));
		if (mManaged) {
			timeline.mManagedEffects.add(_loc4_);
		}
	}
}
