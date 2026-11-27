package actor.stateMachine;

import actor.ActorGameObject;
import actor.ActorView;
import brain.stateMachine.State;
import facade.DBFacade;

class ActorState extends State {
	var mDBFacade:DBFacade;

	var mActorGameObject:ActorGameObject;

	var mActorView:ActorView;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, stateName:String, finishedCallback:ASFunction = null) {
		super(stateName, finishedCallback);
		mDBFacade = dbFacade;
		mActorGameObject = actorGameObject;
		mActorView = actorView;
	}

	override public function destroy() {
		mDBFacade = null;
		mActorGameObject = null;
		mActorView = null;
		super.destroy();
	}
}
