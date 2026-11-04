package actor.stateMachine;

import actor.ActorGameObject;
import actor.ActorRenderer;
import actor.ActorView;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import distributedObjects.NPCGameObject;
import facade.DBFacade;
import gameMasterDictionary.GMActor;

class ActorDeadState extends ActorState {
	static inline final ROT_ON_FLOOR_TIME:Float = 8;

	static inline final ROT_ON_FLOOR_ALPHA:Float = 0.7;

	public static inline final NAME = "ActorDeadState";

	var mWorkComponent:LogicalWorkComponent;

	var mFinishedDeathCallback:Task;

	var mPendingDeathCallback:ASFunction;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView) {
		super(dbFacade, actorGameObject, actorView, "ActorDeadState");
		mWorkComponent = new LogicalWorkComponent(mDBFacade, "ActorDeadState");
	}

	override public function destroy() {
		mDBFacade.mTween.killTweensOf(mActorGameObject.view);
		mDBFacade.mTween.killTweensOf(mActorGameObject.view.root);
		if (mFinishedDeathCallback != null) {
			mFinishedDeathCallback.destroy();
			mFinishedDeathCallback = null;
		}
		clearPendingDeathCallback();
		mWorkComponent.destroy();
		mWorkComponent = null;
		super.destroy();
	}

	override public function enterState() {
		super.enterState();
		if (this.mActorGameObject.actorData.gMActor.CharType == GMActor.CHAR_TYPE_PROP) {
			propDeath();
		} else {
			enemyDeath();
		}
	}

	function setupDeadActorCommon() {
		mActorView.removeFromStage();
		mActorView.layer = 10;
		mActorView.root.alpha = 0.7;
		mActorView.addToStage();
		mActorView.actionsForDeadState();
		if (mActorView.currentWeapon != null && mActorView.currentWeapon.weaponRenderer != null) {
			mActorView.currentWeapon.weaponRenderer.stop();
		}
		mActorGameObject.removeNavColliders();
		if (mActorGameObject.isPet && mActorGameObject.usePetUI) {
			mDBFacade.hud.unregisterPet(ASCompat.reinterpretAs(mActorGameObject, NPCGameObject));
		}
	}

	function clearPendingDeathCallback() {
		if (mPendingDeathCallback == null) {
			return;
		}
		var _loc1_ = mActorView.bodyAnimRenderer;
		if (_loc1_ != null) {
			_loc1_.removeLoadCompleteCallback(mPendingDeathCallback);
		}
		mPendingDeathCallback = null;
	}

	function enemyDeath() {
		mActorView.root.visible = true;
		setupDeadActorCommon();
		mWorkComponent.doLater(8 * 0.8, function(param1:brain.clock.GameClock) {
			mDBFacade.mTween.tweenMaxTo(mActorView.root, 8 * 0.2, {"alpha": 0});
		});
		tryScheduleEnemyDeathOrFallback();
	}

	function tryScheduleEnemyDeathOrFallback() {
		var deathAnimDuration:Float;
		var bodyRenderer:ActorRenderer;
		var angle:Float;
		var actorView = ASCompat.reinterpretAs(mActorGameObject.view, ActorView);
		if (actorView.hasAnim("death")) {
			deathAnimDuration = actorView.getAnimDurationInSeconds("death") + 8;
			mFinishedDeathCallback = mWorkComponent.doLater(deathAnimDuration, mFinishedCallback);
			actorView.playAnim("death", 0, false, false);
			return;
		}
		bodyRenderer = actorView.bodyAnimRenderer;
		if (bodyRenderer != null && bodyRenderer.isStarlingLoading) {
			clearPendingDeathCallback();
			mPendingDeathCallback = function() {
				mPendingDeathCallback = null;
				tryScheduleEnemyDeathOrFallback();
			};
			bodyRenderer.addLoadCompleteCallback(mPendingDeathCallback);
			return;
		}
		switch (mActorGameObject.actorData.gMActor.DefaultDestruct) {
			case(_ == GMActor.DESTRUCTION_TIPOVER => true):
				angle = Math.random() < 0.5 ? -90 : 90;
				mDBFacade.mTween.tweenMaxTo(actorView, 0.3, {"rotation": angle});

			default:
				actorView.root.visible = false;
				if (actorView.bodyAnimRenderer != null) {
					actorView.bodyAnimRenderer.visible = false;
				}
		}
		mFinishedDeathCallback = mWorkComponent.doLater(8, mFinishedCallback);
	}

	function propDeath() {
		setupDeadActorCommon();
		trySchedulePropDeathOrFallback();
	}

	function trySchedulePropDeathOrFallback() {
		var corpseAngle:Float;
		var propDeathDuration:Float;
		var fadeStart:Float;
		var bodyRenderer:ActorRenderer;
		var angle:Float;
		var actorView = ASCompat.reinterpretAs(mActorGameObject.view, ActorView);
		if (actorView.hasAnim("death")) {
			corpseAngle = Math.random() < 0.5 ? -20 : 20;
			corpseAngle *= Math.random();
			mDBFacade.mTween.tweenMaxTo(actorView, 0.3, {"rotation": corpseAngle});
			propDeathDuration = actorView.getAnimDurationInSeconds("death") + 8;
			mFinishedDeathCallback = mWorkComponent.doLater(propDeathDuration, mFinishedCallback);
			actorView.playAnim("death", 0, false, false);
			fadeStart = propDeathDuration - 8 * 0.2;
			if (fadeStart < 0) {
				fadeStart = 0;
			}
			mWorkComponent.doLater(fadeStart, function(param1:brain.clock.GameClock) {
				mDBFacade.mTween.tweenMaxTo(actorView.root, 8 * 0.2, {"alpha": 0});
			});
			return;
		}
		bodyRenderer = actorView.bodyAnimRenderer;
		if (bodyRenderer != null && bodyRenderer.isStarlingLoading) {
			clearPendingDeathCallback();
			mPendingDeathCallback = function() {
				mPendingDeathCallback = null;
				trySchedulePropDeathOrFallback();
			};
			bodyRenderer.addLoadCompleteCallback(mPendingDeathCallback);
			return;
		}
		switch (mActorGameObject.actorData.gMActor.DefaultDestruct) {
			case(_ == GMActor.DESTRUCTION_TIPOVER => true):
				angle = Math.random() < 0.5 ? -90 : 90;
				mDBFacade.mTween.tweenMaxTo(actorView, 0.3, {"rotation": angle});

			default:
				actorView.root.visible = false;
				if (actorView.bodyAnimRenderer != null) {
					actorView.bodyAnimRenderer.visible = false;
				}
		}
		mFinishedDeathCallback = mWorkComponent.doLater(8, mFinishedCallback);
		if (actorView.root.visible) {
			mWorkComponent.doLater(8 * 0.8, function(param1:brain.clock.GameClock) {
				mDBFacade.mTween.tweenMaxTo(actorView.root, 8 * 0.2, {"alpha": 0});
			});
		}
	}

	override public function exitState() {
		super.exitState();
		if (mFinishedDeathCallback != null) {
			mFinishedDeathCallback.destroy();
			mFinishedDeathCallback = null;
		}
		clearPendingDeathCallback();
	}
}
