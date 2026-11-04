package town;

import brain.event.EventComponent;
import facade.DBFacade;
import uI.skills.UISkills;

class SkillsTownSubState extends TownSubState {
	public static inline final NAME = "SkillsTownSubState";

	var mUISkills:UISkills;

	var mEventComponent:EventComponent;

	public function new(dbFacade:DBFacade, townStateMachine:TownStateMachine) {
		super(dbFacade, townStateMachine, "SkillsTownSubState");
		mEventComponent = new EventComponent(mDBFacade);
	}

	override public function destroy() {
		if (mUISkills != null) {
			mUISkills.destroy();
			mUISkills = null;
		}
		mEventComponent.destroy();
		super.destroy();
	}

	override function setupState() {
		super.setupState();
		mUISkills = new UISkills(mDBFacade, mRootMovieClip, mTownStateMachine.townHeader);
	}

	override function setupHeaderLinks() {
		super.setupHeaderLinks();
		mUISkills.setupHeaderLinks();
	}

	override public function enterState() {
		super.enterState();
		mUISkills.activate();
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", function(param1:events.DBAccountResponseEvent) {
			mUISkills.refresh(false);
		});
		mTownStateMachine.townHeader.showCloseButton(true);
		super.resetHeaderLinks();
		setupHeaderLinks();
		mDBFacade.menuNavigationController.pushNewLayer("SKILLS_MENU", mTownStateMachine.townHeader.determineCallback,
			mTownStateMachine.townHeader.closeButton, mTownStateMachine.townHeader.closeButton, mUISkills.selectPreviousHero, mUISkills.selectNextHero);
		mUISkills.refresh();
	}

	override public function exitState() {
		mUISkills.processChosenAvatar();
		mUISkills.deactivate();
		mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
		mDBFacade.menuNavigationController.popLayer("SKILLS_MENU");
		super.exitState();
	}
}
