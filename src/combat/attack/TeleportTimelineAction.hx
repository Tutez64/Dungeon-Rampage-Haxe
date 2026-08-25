package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import brain.workLoop.Task;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;
import flash.geom.Vector3D;

class TeleportTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "teleport";

	var mFramesElapsed:Float = 0;

	var mDuration:UInt = 0;

	var mMovementTask:Task;

	var mStartPos:Vector3D;

	var mEndPos:Vector3D;

	var mOffset:Vector3D;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:UInt) {
		mDuration = duration;
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):TeleportTimelineAction {
		var _loc5_ = ASCompat.toNumber(actionObj.duration);
		return new TeleportTimelineAction(actorGameObject, actorView, dbFacade, (Std.int(_loc5_) : UInt));
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		if (mFramesElapsed != 0) {
			ResetMovement();
		}
		mFramesElapsed = 0;
		if (mMovementTask != null) {
			mMovementTask.destroy();
			mMovementTask = null;
		}
		if (mWorkComponent != null) {
			mMovementTask = mWorkComponent.doEveryFrame(UpdateMovement);
		}
	}

	public function initMovementData() {
		var _loc1_:HeroGameObjectOwner = null;
		if (Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner)) {
			_loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner);
			mStartPos = _loc1_.position;
			mEndPos = _loc1_.mTeleportDestination;
			mOffset = new Vector3D(mEndPos.x - mStartPos.x, mEndPos.y - mStartPos.y);
		}
	}

	public function moveHero() {
		var _loc1_:HeroGameObjectOwner = null;
		if (Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner)) {
			_loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner);
			mStartPos = _loc1_.position;
			_loc1_.moveToTeleDest();
			mEndPos = _loc1_.mTeleportDestination;
			mOffset = new Vector3D(mEndPos.x - mStartPos.x, mEndPos.y - mStartPos.y);
		}
	}

	public function stopHeroMovement() {
		var _loc1_:HeroGameObjectOwner = null;
		if (Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner)) {
			_loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner);
			_loc1_.stopMovement();
		}
	}

	public function easeInOutQuad(t:Float, b:Float, c:Float, d:Float):Float {
		t /= d / 2;
		if (t < 1) {
			return c / 2 * t * t + b;
		}
		t--;
		return -c / 2 * (t * (t - 2) - 1) + b;
	}

	public function updateView() {
		var _loc5_:HeroGameObjectOwner = null;
		var _loc4_ = Math.NaN;
		var _loc1_ = Math.NaN;
		var _loc2_:Vector3D = null;
		var _loc3_:Vector3D = null;
		if (Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner)) {
			_loc5_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner);
			_loc4_ = mFramesElapsed / mDuration;
			_loc4_ = easeInOutQuad(mFramesElapsed, 0, 1, mDuration);
			_loc1_ = 1 - _loc4_;
			_loc2_ = new Vector3D(mStartPos.x * _loc1_ + mEndPos.x * _loc4_, mStartPos.y * _loc1_ + mEndPos.y * _loc4_);
			_loc5_.placeAt(_loc2_);
			_loc3_ = new Vector3D(mOffset.x * _loc1_, mOffset.y * _loc1_);
			_loc5_.moveBodyTo(_loc3_);
		}
	}

	public function UpdateMovement(clock:GameClock) {
		if (mActorView != null && mActorView.body != null) {
			var _loc1_ = clock.tickLength / GameClock.ANIMATION_FRAME_DURATION;
			mFramesElapsed += _loc1_;
			if (mFramesElapsed <= _loc1_) {
				stopHeroMovement();
				initMovementData();
			} else if (mFramesElapsed <= mDuration) {
				updateView();
			} else if (mFramesElapsed > mDuration) {
				ResetMovement();
				return;
			}
			return;
		}
		ResetMovement();
	}

	function ResetMovement() {
		var _loc1_:HeroGameObjectOwner = null;
		mFramesElapsed = 0;
		if (mActorView != null && mActorView.body != null) {}
		if (mMovementTask != null) {
			mMovementTask.destroy();
			mMovementTask = null;
		}
		if (Std.isOfType(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner)) {
			_loc1_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(mActorGameObject.id), HeroGameObjectOwner);
		}
	}

	override public function destroy() {
		if (mMovementTask != null) {
			mMovementTask.destroy();
			mMovementTask = null;
		}
		super.destroy();
	}
}
