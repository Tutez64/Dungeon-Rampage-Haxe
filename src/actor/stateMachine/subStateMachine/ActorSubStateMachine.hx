package actor.stateMachine.subStateMachine;

import actor.ActorGameObject;
import actor.ActorView;
import actor.stateMachine.ActorNavigationState;
import actor.stateMachine.ActorState;
import actor.stateMachine.ActorStateMachine;
import brain.utils.MemoryTracker;
import combat.attack.ScriptTimeline;
import facade.DBFacade;

class ActorSubStateMachine extends ActorStateMachine {
	var mActorNavigationState:ActorNavigationState;

	var mActorChoreographyState:ActorChoreographySubState;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView) {
		super(dbFacade, actorGameObject, actorView);
		buildStates();
	}

	public function exit() {
		ASCompat.dynamicAs(this.currentState, ActorState).exitState();
		this.currentState = null;
	}

	function buildStates() {
		mActorNavigationState = new ActorNavigationState(mDBFacade, mActorGameObject, mActorView);
		MemoryTracker.track(mActorNavigationState, "ActorNavigationState - created in ActorSubStateMachine.buildStates()");
		mActorChoreographyState = new ActorChoreographySubState(mDBFacade, mActorGameObject, mActorView);
		MemoryTracker.track(mActorChoreographyState, "ActorChoreographySubState - created in ActorSubStateMachine.buildStates()");
	}

	public function enterNavigationState() {
		this.transitionToState(mActorNavigationState);
	}

	public function enterChoreographyState(playSpeed:Float, targetActor:ActorGameObject, script:ScriptTimeline, finishedCallback:ASFunction = null,
			stopCallback:ASFunction = null, loop:Bool = false) {
		var enterNavigationAndCallFinishedCallback:ASFunction = function() {
			enterNavigationState();
			if (finishedCallback != null) {
				finishedCallback();
			}
		};
		mActorChoreographyState.setChoreography(playSpeed, targetActor, script, enterNavigationAndCallFinishedCallback, stopCallback, loop);
		this.transitionToState(mActorChoreographyState);
	}

	override public function destroy() {
		if (this.currentState != null) {
			this.currentState.exitState();
		}
		this.currentState = null;
		mActorNavigationState.destroy();
		mActorNavigationState = null;
		mActorChoreographyState.destroy();
		mActorChoreographyState = null;
		super.destroy();
	}
}
