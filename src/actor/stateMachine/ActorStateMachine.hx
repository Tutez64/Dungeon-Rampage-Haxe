package actor.stateMachine;

import actor.ActorGameObject;
import actor.ActorView;
import brain.stateMachine.StateMachine;
import facade.DBFacade;

class ActorStateMachine extends StateMachine {
	var mDBFacade:DBFacade;

	var mActorGameObject:ActorGameObject;

	var mActorView:ActorView;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView) {
		super();
		mDBFacade = dbFacade;
		mActorGameObject = actorGameObject;
		mActorView = actorView;
	}

	override public function destroy() {
		mActorView = null;
		mActorGameObject = null;
		mDBFacade = null;
		super.destroy();
	}
}
