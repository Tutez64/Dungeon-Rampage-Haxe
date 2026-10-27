package actor.stateMachine;

import actor.ActorGameObject;
import actor.ActorView;
import actor.stateMachine.subStateMachine.ActorSubStateMachine;
import combat.attack.ScriptTimeline;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class ActorDefaultState extends ActorState {
	public static inline final NAME = "ActorDefaultState";

	var mSubStateMachine:ActorSubStateMachine;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, finishedCallback:ASFunction = null) {
		super(dbFacade, actorGameObject, actorView, "ActorDefaultState", finishedCallback);
		mSubStateMachine = new ActorSubStateMachine(dbFacade, actorGameObject, actorView);
	}

	override public function enterState() {
		var _loc1_:HeroGameObjectOwner = null;
		super.enterState();
		if (mActorGameObject.isOwner) {
			_loc1_ = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
			_loc1_.startUserInput();
		}
		mSubStateMachine.enterNavigationState();
	}

	override public function exitState() {
		var _loc1_:HeroGameObjectOwner = null;
		mSubStateMachine.exit();
		if (mActorGameObject.isOwner) {
			_loc1_ = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
			_loc1_.stopUserInput();
		}
		super.exitState();
	}

	public function enterChoreographyState(playSpeed:Float, targetActor:ActorGameObject, scriptTimeline:ScriptTimeline, finishedCallback:ASFunction = null,
			stopCallback:ASFunction = null, loop:Bool = false) {
		mSubStateMachine.enterChoreographyState(playSpeed, targetActor, scriptTimeline, finishedCallback, stopCallback, loop);
	}

	public function enterNavigationState() {
		mSubStateMachine.enterNavigationState();
	}

	@:isVar public var currentSubState(get, never):ActorState;

	public function get_currentSubState():ActorState {
		return ASCompat.dynamicAs(mSubStateMachine.currentState, ActorState);
	}

	override public function destroy() {
		mSubStateMachine.destroy();
		mSubStateMachine = null;
		super.destroy();
	}
}
