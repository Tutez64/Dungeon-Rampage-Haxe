package actor;

import brain.clock.GameClock;
import brain.workLoop.PreRenderWorkComponent;
import brain.workLoop.Task;
import brain.workLoop.WorkComponent;
import facade.DBFacade;
import flash.geom.Point;
import flash.geom.Vector3D;

class MovementController {
	public static inline final IDLE_VELOCITY_THRESHOLD:Float = 1;

	public static inline final MIN_HEADING_SPEED:Float = 2;

	static inline final DEFAULT_SMOOTH_FACTOR:Float = 0.8;

	public static inline final LOCKED_HERO_MOVEMENT_TYPE = "locked_hero";

	public static inline final LOCKED_XY_MOVEMENT_TYPE = "locked_xy";

	public static inline final LOCKED_R_MOVEMENT_TYPE = "locked_r";

	public static inline final LOCKED_MOVEMENT_TYPE = "locked";

	public static inline final NORMAL_MOVEMENT_TYPE = "normal";

	public static final ZERO_VECTOR:Vector3D = new Vector3D();

	static final sNewPos:Vector3D = new Vector3D();

	static final sActorPos:Vector3D = new Vector3D();

	var mTargetPosition:Point = new Point(0, 0);

	var mActorGameObject:ActorGameObject;

	var mView:ActorView;

	var mPositionLerpTask:Task;

	var mLerpResting:Bool = false;

	var mMovementType:String = "normal";

	var mPreRenderWorkComponent:WorkComponent;

	var mWantSmoothTelemetry:Bool = false;

	var mSmoothFactor:Float = 0.8;

	var mDBFacade:DBFacade;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mView = actorView;
		mActorGameObject = actorGameObject;
		mPreRenderWorkComponent = new PreRenderWorkComponent(dbFacade, "MovementController");
		mWantSmoothTelemetry = mDBFacade.dbConfigManager.getConfigBoolean("smooth_telemetry", true);
		mSmoothFactor = mDBFacade.dbConfigManager.getConfigNumber("smooth_telemetry_factor", 0.8);
	}

	@:isVar public var movementType(get, set):String;

	public function set_movementType(moveType:String):String {
		mView.position = mActorGameObject.position;
		mView.heading = mActorGameObject.heading;
		return mMovementType = moveType;
	}

	function get_movementType():String {
		return mMovementType;
	}

	@:isVar public var canMoveHero(get, never):Bool;

	public function get_canMoveHero():Bool {
		return mMovementType != "locked_hero";
	}

	@:isVar public var canMoveXY(get, never):Bool;

	public function get_canMoveXY():Bool {
		return mMovementType != "locked" && mMovementType != "locked_xy";
	}

	@:isVar public var canMoveR(get, never):Bool;

	public function get_canMoveR():Bool {
		return mMovementType != "locked" && mMovementType != "locked_r";
	}

	public function stopLerp() {
		if (mPositionLerpTask != null) {
			mPositionLerpTask.destroy();
			mPositionLerpTask = null;
		}
	}

	public function move(targetPosition:Vector3D, targetHeading:Float) {
		if (!canMoveXY) {
			if (mPositionLerpTask != null) {
				mPositionLerpTask.destroy();
				mPositionLerpTask = null;
			}
		}
		if (mActorGameObject.actorData != null && mActorGameObject.actorData.isMover) {
			if (mPositionLerpTask == null) {
				mPositionLerpTask = mPreRenderWorkComponent.doEveryFrame(positionLerp);
			}
			mLerpResting = false;
		} else {
			mView.position = targetPosition;
			mView.heading = targetHeading;
		}
	}

	public function moveBody(targetPosition:Vector3D, targetHeading:Float) {
		mView.body.x = targetPosition.x;
		mView.body.y = targetPosition.y;
	}

	function positionLerp(gameClock:GameClock) {
		if (mLerpResting) {
			return;
		}
		var _loc3_ = mView.positionX;
		var _loc4_ = mView.positionY;
		var _loc2_ = sActorPos;
		_loc2_.x = mActorGameObject.positionX;
		_loc2_.y = mActorGameObject.positionY;
		_loc2_.z = mActorGameObject.positionZ;
		var _loc6_ = _loc2_;
		var _loc5_ = (1 - mSmoothFactor) * gameClock.timeScale;
		if (mWantSmoothTelemetry) {
			_loc6_ = sNewPos;
			_loc6_.x = _loc3_ * (1 - _loc5_) + _loc2_.x * _loc5_;
			_loc6_.y = _loc4_ * (1 - _loc5_) + _loc2_.y * _loc5_;
		}
		mView.velocity = new Vector3D(_loc6_.x - _loc3_, _loc6_.y - _loc4_, _loc6_.z);
		if (mView.velocity.nearEquals(ZERO_VECTOR, 1)) {
			mLerpResting = true;
			mView.heading = mActorGameObject.heading;
			mView.position = _loc2_;
			mView.velocity.scaleBy(0);
		} else {
			mView.position = _loc6_;
			if (canMoveR && (mView.velocity.length >= 2 || !mDBFacade.featureFlags.getFlagValue("smooth-run-and-direction-states"))) {
				mView.heading = Math.atan2(mView.velocity.y, mView.velocity.x) * 180 / 3.141592653589793;
			}
		}
	}

	public function destroy() {
		if (mPositionLerpTask != null) {
			mPositionLerpTask.destroy();
			mPositionLerpTask = null;
		}
		mPreRenderWorkComponent.destroy();
		mDBFacade = null;
	}
}
