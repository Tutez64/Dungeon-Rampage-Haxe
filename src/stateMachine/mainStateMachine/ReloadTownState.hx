package stateMachine.mainStateMachine;

import brain.event.EventComponent;
import brain.stateMachine.State;
import brain.utils.MemoryTracker;
import brain.utils.MemoryUtil;
import events.DBAccountLoadedEvent;
import facade.DBFacade;
import facade.Locale;
import uI.popup.DBUIPopup;

class ReloadTownState extends State {
	public static inline final NAME = "ReloadTownState";

	var mDBFacade:DBFacade;

	var mPopup:DBUIPopup;

	var mEventComponent:EventComponent;

	public function new(dbFacade:DBFacade, finishedCallback:ASFunction = null) {
		super("ReloadTownState", finishedCallback);
		mDBFacade = dbFacade;
	}

	override public function enterState() {
		super.enterState();
		mPopup = new DBUIPopup(mDBFacade, Locale.getString("RELOAD_TOWN_POPUP_TITLE"), null, false);
		MemoryTracker.track(mPopup, "DBUIPopup - created in ReloadTownState.enterState()");
		mEventComponent = new EventComponent(mDBFacade);
		mEventComponent.addListener("DB_ACCOUNT_INFO_LOADED", accountLoaded);
		mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
		mDBFacade.dbAccountInfo.checkFriendsHash();
		MemoryUtil.pauseForGCWithLogging("ReloadTownState: ");
		mDBFacade.ClearCachedTileLibraryJson();
	}

	override public function exitState() {
		mPopup.destroy();
		mPopup = null;
		mEventComponent.destroy();
		mEventComponent = null;
		super.exitState();
	}

	function accountLoaded(dbAccountLoadedEvent:DBAccountLoadedEvent) {
		if (mFinishedCallback != null) {
			mFinishedCallback();
		}
	}
}
