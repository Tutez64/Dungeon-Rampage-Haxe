package actor.stateMachine.subStateMachine;

import actor.ActorGameObject;
import actor.ActorView;
import actor.stateMachine.ActorState;
import brain.event.EventComponent;
import brain.logger.Logger;
import combat.attack.ScriptTimeline;
import events.HeroOwnerEndedAttackStateEvent;
import facade.DBFacade;

class ActorChoreographySubState extends ActorState {
	public static inline final NAME = "ActorChoreographySubState";

	var mCurrentScript:ScriptTimeline;

	var mQueuedScript:ScriptTimeline;

	var mQueuedPlaySpeed:Float = 1;

	var mQueuedFinishedCallback:ASFunction;

	var mQueuedStopCallback:ASFunction;

	var mQueuedLoop:Bool = false;

	var mQueuedTargetActor:ActorGameObject;

	var mEventComponent:EventComponent;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, finishedCallback:ASFunction = null) {
		super(dbFacade, actorGameObject, actorView, "ActorChoreographySubState", finishedCallback);
		mEventComponent = new EventComponent(mDBFacade);
	}

	public function setChoreography(playSpeed:Float, target:ActorGameObject, script:ScriptTimeline, finishedCallback:ASFunction = null,
			stopCallback:ASFunction = null, loop:Bool = false) {
		mQueuedScript = script;
		mQueuedPlaySpeed = playSpeed;
		mQueuedFinishedCallback = finishedCallback;
		mQueuedStopCallback = stopCallback;
		mQueuedLoop = loop;
		mQueuedTargetActor = target;
	}

	override public function enterState() {
		super.enterState();
		if (mQueuedScript != null) {
			if (mCurrentScript != null) {
				mCurrentScript.stop();
			}
			mCurrentScript = mQueuedScript;
			mQueuedScript = null;
			mCurrentScript.play(mQueuedPlaySpeed, mQueuedTargetActor, mQueuedFinishedCallback, mQueuedStopCallback, mQueuedLoop);
		} else {
			Logger.error("No script in choreography!");
			mQueuedFinishedCallback();
		}
	}

	override public function exitState() {
		if (mActorGameObject.isOwner) {
			mEventComponent.dispatchEvent(new HeroOwnerEndedAttackStateEvent("PLAYER_ENDED_ATTACK_STATE"));
		}
		if (mCurrentScript != null) {
			if (mCurrentScript.isPlaying) {
				mCurrentScript.stop();
			}
			mCurrentScript = null;
		}
		super.exitState();
	}

	override public function destroy() {
		exitState();
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
		super.destroy();
	}
}
