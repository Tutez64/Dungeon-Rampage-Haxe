package distributedObjects;

import facade.DBFacade;
import generatedCode.GeneratedDcSocket;
import networkCode.DcSocket;
import networkCode.transport.GameEndpoints;

class DistributedObjectManager {
	var mDBfacade:DBFacade;

	var mGeneratedDcSocket:GeneratedDcSocket;

	public var mMatchMaker:MatchMaker;

	public var mPresenceManager:PresenceManager;

	public function new(facade:DBFacade) {
		mDBfacade = facade;
	}

	@:isVar public var socket(get, never):DcSocket;

	public function get_socket():DcSocket {
		return mGeneratedDcSocket;
	}

	public function Initialize(endpoints:GameEndpoints, experimentalWebSocketReconnects:Bool, playtoken:String, demographics:String, account:UInt,
			networkid:UInt, noderules:UInt):Bool {
		if (mGeneratedDcSocket != null) {
			mGeneratedDcSocket.destroy();
		}
		mGeneratedDcSocket = null;
		mGeneratedDcSocket = new GeneratedDcSocket(mDBfacade, endpoints.address, endpoints.port, playtoken, demographics, account);
		mGeneratedDcSocket.pass2Init(networkid, noderules);
		mGeneratedDcSocket.beginConnect(endpoints, experimentalWebSocketReconnects);
		return true;
	}

	public function destroy() {
		if (mGeneratedDcSocket != null) {
			mGeneratedDcSocket.destroy();
		}
		mGeneratedDcSocket = null;
	}

	public function isAllOk():Bool {
		return mGeneratedDcSocket != null && mGeneratedDcSocket.connected && mMatchMaker != null;
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
