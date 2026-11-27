package actor.stateMachine;

import actor.ActorGameObject;
import actor.ActorView;
import brain.workLoop.Task;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class ActorNavigationState extends ActorState {
	public static inline final NAME = "ActorNavigationState";

	var mUpdateTask:Task;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, finishedCallback:ASFunction = null) {
		super(dbFacade, actorGameObject, actorView, "ActorNavigationState", finishedCallback);
	}

	override public function enterState() {
		var _loc1_:HeroGameObjectOwner = null;
		super.enterState();
		mActorGameObject.startRunIdleMonitoring();
		if (mActorGameObject.isOwner) {
			_loc1_ = ASCompat.reinterpretAs(mActorGameObject, HeroGameObjectOwner);
			_loc1_.inputController.inputType = "free";
		}
		mActorGameObject.movementControllerType = "normal";
	}

	override public function exitState() {
		mActorGameObject.stopRunIdleMonitoring();
		super.exitState();
	}
}
