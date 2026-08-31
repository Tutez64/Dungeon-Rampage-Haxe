package actor.player;

import actor.ActorView;
import actor.stateMachine.ActorMacroStateMachine;
import actor.stateMachine.ActorReviveState;
import brain.utils.MemoryTracker;
import distributedObjects.HeroGameObject;
import facade.DBFacade;

class HeroStateMachine extends ActorMacroStateMachine {
	var mReviveState:ActorReviveState;

	public function new(dbFacade:DBFacade, heroGameObject:HeroGameObject, actorView:ActorView) {
		super(dbFacade, heroGameObject, actorView);
		mReviveState = new ActorReviveState(mDBFacade, heroGameObject, mActorView);
		MemoryTracker.track(mReviveState, "ActorReviveState - created in HeroStateMachine.HeroStateMachine()");
	}

	override public function destroy() {
		mReviveState.destroy();
		super.destroy();
	}

	public function enterReviveState() {
		this.transitionToState(mReviveState);
	}
}
