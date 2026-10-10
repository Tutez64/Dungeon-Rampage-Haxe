package distributedObjects;

import facade.DBFacade;
import generatedCode.GeneratedDcSocket;

class DistributedObjectManager {
	var mDBfacade:DBFacade;

	var mGeneratedDcSocket:GeneratedDcSocket;

	public var mMatchMaker:MatchMaker;

	public var mPresenceManager:PresenceManager;

	public function new(facade:DBFacade) {
		mDBfacade = facade;
	}

	public function Initialize(host:String, port:Int, playtoken:String, demographics:String, account:UInt, networkid:UInt, noderules:UInt):Bool {
		if (mGeneratedDcSocket != null) {
			mGeneratedDcSocket.destroy();
		}
		mGeneratedDcSocket = null;
		mGeneratedDcSocket = new GeneratedDcSocket(mDBfacade, host, port, playtoken, demographics, account);
		mGeneratedDcSocket.pass2Init(networkid, noderules);
		return true;
	}

	public function destroy() {
		if (mGeneratedDcSocket != null) {
			mGeneratedDcSocket.destroy();
		}
		mGeneratedDcSocket = null;
	}

	public function isAllOk():Bool {
		var _loc1_ = mGeneratedDcSocket != null && mGeneratedDcSocket.connected && mMatchMaker != null;
		trace("------------>isAllOk ", _loc1_);
		return _loc1_;
	}

	function SocketIsLeaving() {
		if (mGeneratedDcSocket != null) {
			mGeneratedDcSocket.destroy();
		}
		mGeneratedDcSocket = null;
	}

	public function enterSocketErrorState(errorCode:UInt, errorText:String = "") {
		mDBfacade.mainStateMachine.enterSocketErrorState(errorCode, errorText);
		mDBfacade.mDistributedObjectManager.SocketIsLeaving();
	}
}
