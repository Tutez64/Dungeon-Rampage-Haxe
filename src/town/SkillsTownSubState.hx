package town;

import facade.DBFacade;

class SkillsTownSubState extends TownSubState {
	public static inline final NAME = "SkillsTownSubState";

	public function new(dbFacade:DBFacade, townStateMachine:TownStateMachine) {
		super(dbFacade, townStateMachine, "SkillsTownSubState");
	}

	override function setupState() {
		super.setupState();
	}

	override public function enterState() {
		super.enterState();
		mTownStateMachine.townHeader.showCloseButton(true);
	}
}
