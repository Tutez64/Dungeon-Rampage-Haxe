package stateMachine.mainStateMachine;

import brain.stateMachine.State;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import facade.Locale;
import uI.popup.DBUIOneButtonPopup;
import flash.desktop.NativeApplication;

class SocketErrorState extends State {
	public static inline final NAME = "SocketErrorState";

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade, finishedCallback:ASFunction = null) {
		mDBFacade = dbFacade;
		super("SocketErrorState", finishedCallback);
	}

	override public function enterState() {
		super.enterState();
	}

	override public function exitState() {
		super.exitState();
	}

	override public function destroy() {
		super.destroy();
	}

	function errorDialogResponce() {
		NativeApplication.nativeApplication.exit();
	}

	public function enterReason(errorCode:UInt, errorText:String = ""):DBUIOneButtonPopup {
		var _loc3_:DBUIOneButtonPopup = null;
		if (errorCode == 60) {
			_loc3_ = new DBUIOneButtonPopup(mDBFacade, Locale.getString("SOCKET_CLOSE_60_HEADER"), Locale.getString("SOCKET_CLOSE_60_TEXT"),
				Locale.getString("EXIT"), errorDialogResponce, false);
		} else if (errorCode == 61) {
			_loc3_ = new DBUIOneButtonPopup(mDBFacade, Locale.getString("SOCKET_CLOSE_61_HEADER"), Locale.getString("SOCKET_CLOSE_61_TEXT"),
				Locale.getString("EXIT"), errorDialogResponce, false);
		} else {
			_loc3_ = new DBUIOneButtonPopup(mDBFacade, Locale.getString("SOCKET_UNEXPECT_CLOSE"), Locale.getError((errorCode : Int)) + "\n" + errorText,
				Locale.getString("CENTER_BUTTON_POPUP_RELOAD_TEXT"), errorDialogResponce, false);
		}
		MemoryTracker.track(_loc3_, "DBUIOneButtonPopup - created in SocketErrorState.enterReason()");
		mDBFacade.enteringSocketError();
		return _loc3_;
	}
}
