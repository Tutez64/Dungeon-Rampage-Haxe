package networkCode;

import brain.clock.GameClock;
import brain.gameObject.GameObject;
import brain.logger.Logger;
import brain.workLoop.LogicalWorkComponent;
import facade.DBFacade;
import generatedCode.*;
import networkCode.transport.ConnectDiagnostics;
import networkCode.transport.GameEndpoints;
import networkCode.transport.GameTransportEvent;
import networkCode.transport.IGameTransport;
import networkCode.transport.SessionCredential;
import networkCode.transport.TransportFailureText;
import networkCode.transport.TransportSelector;
import networkCode.transport.TransportSettings;
import flash.errors.*;
import flash.events.*;
import flash.utils.ByteArray;

class DcSocket {
	static inline final RETRY_PASS_DELAY_MS = 1500;

	var input_double_buffer:DcNetworkPacket;

	var Doid_NetInterfaces:ASObject;

	var mDBFacade:DBFacade;

	var mValidationToken:String;

	var mAccountid:UInt = 0;

	var mNetworkID:UInt = 0;

	var mNodeRules:UInt = 0;

	var mDemographics:String;

	public var CLIENT_HEART_BEAT:UInt = (52 : UInt);

	public var CLIENT_LOGIN_DUNGEONBUSTER:UInt = (118 : UInt);

	public var CLIENT_OBJECT_UPDATE_FIELD:UInt = (124 : UInt);

	public var CLIENT_OBJECT_DISABLE_RESP:UInt = (125 : UInt);

	public var CLIENT_OBJECT_DISABLE_OWNER_RESP:UInt = (126 : UInt);

	public var CLIENT_OBJECT_DELETE_RESP:UInt = (127 : UInt);

	public var CLIENT_CREATE_OBJECT_REQUIRED_RESP:UInt = (134 : UInt);

	public var CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP:UInt = (135 : UInt);

	public var CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP:UInt = (136 : UInt);

	public var CLIENT_LOGOUT:UInt = (137 : UInt);

	public var CLIENT_LOGOUT_RESP:UInt = (140 : UInt);

	public var CLIENT_INTEREST_CONTEXT:UInt = (148 : UInt);

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mDisconnectCode:Int = 0;

	var mDisconnecttext:String;

	var mEndpoints:GameEndpoints;

	var mSelector:TransportSelector;

	var mTransport:IGameTransport;

	var mCandidateIndex:Int = -1;

	var mHasConnected:Bool = false;

	var mFailureReported:Bool = false;

	var mAttemptStartedAt:Int = 0;

	var mAttempts:Array<ASAny> = [];

	var mDiagnosticsLogged:Bool = false;

	var mReconnecting:Bool = false;

	var mRetriedPass:Bool = false;

	public function new(facade:DBFacade, host:String, port:Int, validationToken:String, demographics:String, accountid:UInt) {
		mDisconnectCode = 0;
		mDisconnecttext = "NotSet";
		Logger.debugch("WS", "Creating new Socket " + host + " " + port + " " + accountid);
		mValidationToken = validationToken;
		mDemographics = demographics;
		mAccountid = accountid;
		input_double_buffer = new DcNetworkPacket();
		mDBFacade = facade;
		Doid_NetInterfaces = {};
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "DcSocket");
		mEndpoints = new GameEndpoints(host, port);
		mDBFacade.metrics.log("DcSocketCreate");
		mDBFacade.loadingBarTick();
	}

	static function fromArray(array:ByteArray, colons:Bool = false):String {
		var _loc4_ = 0;
		var _loc3_ = "";
		_loc4_ = 0;
		while ((_loc4_ : UInt) < array.length) {
			_loc3_ += ("0" + ASCompat.toRadix(array[_loc4_], (16 : UInt))).substr(-2, 2);
			if (colons) {
				if ((_loc4_ : UInt) < array.length - 1) {
					_loc3_ += ":";
				}
			}
			_loc4_++;
		}
		return _loc3_;
	}

	static function sorter(x:DcNetworkClass, y:DcNetworkClass):Float {
		return y.creationOrder - x.creationOrder;
	}

	public function beginConnect(endpoints:GameEndpoints, experimentalWebSocketReconnects:Bool) {
		if (endpoints != null) {
			mEndpoints = endpoints;
		}
		mSelector = new TransportSelector(mEndpoints, experimentalWebSocketReconnects, currentCredential);
		mFailureReported = false;
		mCandidateIndex = -1;
		mHasConnected = false;
		mAttempts = [];
		mDiagnosticsLogged = false;
		mRetriedPass = false;
		Logger.infoch("WS", "DcSocket connecting, candidates: " + mSelector.describe());
		tryNextCandidate();
	}

	function currentCredential():SessionCredential {
		var _loc1_ = mValidationToken;
		if (mDBFacade != null && mDBFacade.validationToken != null && mDBFacade.validationToken != "") {
			_loc1_ = mDBFacade.validationToken;
		}
		return new SessionCredential(Std.string(mAccountid), _loc1_, mDBFacade?.initialLoginTraceId);
	}

	public function pass2Init(networkid:UInt, noderules:UInt) {
		mNetworkID = networkid;
		mNodeRules = noderules;
	}

	@:isVar public var facade(get, never):DBFacade;

	public function get_facade():DBFacade {
		return mDBFacade;
	}

	@:isVar public var connected(get, never):Bool;

	public function get_connected():Bool {
		return mTransport != null && mTransport.connected;
	}

	@:isVar public var transport(get, never):IGameTransport;

	public function get_transport():IGameTransport {
		return mTransport;
	}

	function tryNextCandidateIfAny():Bool {
		if (!mHasConnected && mCandidateIndex + 1 < mSelector.count) {
			tryNextCandidate();
			return true;
		}
		return false;
	}

	function retryPassIfStalled():Bool {
		if (mHasConnected || mRetriedPass || !ConnectDiagnostics.looksLikeStall(mAttempts)) {
			return false;
		}
		mRetriedPass = true;
		mCandidateIndex = -1;
		ASCompat.setTimeout(retryPass, 1500);
		return true;
	}

	function retryPass() {
		if (mDBFacade == null) {
			return;
		}
		tryNextCandidate();
	}

	function tryNextCandidate() {
		detachTransport(true);
		mCandidateIndex = mCandidateIndex + 1;
		var _loc1_ = mSelector.candidateAt(mCandidateIndex);
		if (_loc1_ == null) {
			reportFailure((602 : UInt), "No usable WorldServer endpoint: " + mEndpoints);
			return;
		}
		logTransport("attempt", _loc1_.name, null);
		mTransport = mSelector.createTransport(mCandidateIndex);
		configureListeners();
		mAttemptStartedAt = flash.Lib.getTimer();
		mTransport.connect();
	}

	function attemptElapsedMs():Int {
		return flash.Lib.getTimer() - mAttemptStartedAt;
	}

	function recordAttempt(elapsedMs:Int, code:Int, text:String, cert:String, certDetail:String, closed:Bool) {
		mAttempts.push({
			"name": transportName(),
			"elapsedMs": elapsedMs,
			"code": code,
			"text": text,
			"cert": cert,
			"certDetail": certDetail,
			"closed": closed
		});
	}

	function logConnectFailureDiagnostics() {
		if (mHasConnected || mDiagnosticsLogged) {
			return;
		}
		mDiagnosticsLogged = true;
		ConnectDiagnostics.run(mAttempts, mEndpoints, mDBFacade?.webServicesUrl);
	}

	function configureListeners() {
		mTransport.addEventListener("gameTransportConnected", connectHandler);
		mTransport.addEventListener("gameTransportData", socketDataHandler);
		mTransport.addEventListener("gameTransportClosed", closeHandler);
		mTransport.addEventListener("gameTransportFailed", failedHandler);
		mTransport.addEventListener("gameTransportReconnecting", reconnectingHandler);
		mTransport.addEventListener("gameTransportReconnectAttempt", reconnectAttemptHandler);
		mTransport.addEventListener("gameTransportResumed", resumedHandler);
	}

	function detachTransport(closeIt:Bool) {
		if (mTransport == null) {
			return;
		}
		mTransport.removeEventListener("gameTransportConnected", connectHandler);
		mTransport.removeEventListener("gameTransportData", socketDataHandler);
		mTransport.removeEventListener("gameTransportClosed", closeHandler);
		mTransport.removeEventListener("gameTransportFailed", failedHandler);
		mTransport.removeEventListener("gameTransportReconnecting", reconnectingHandler);
		mTransport.removeEventListener("gameTransportReconnectAttempt", reconnectAttemptHandler);
		mTransport.removeEventListener("gameTransportResumed", resumedHandler);
		if (closeIt) {
			mTransport.close();
		}
		mTransport = null;
		clearReconnectIndicator();
	}

	function clearReconnectIndicator() {
		if (!mReconnecting) {
			return;
		}
		mReconnecting = false;
		if (mDBFacade != null) {
			mDBFacade.onConnectionReconnectFailed();
		}
	}

	function logTransport(phase:String, transportName:String, closeEvent:GameTransportEvent, elapsedMs:Int = -1) {
		if (mDBFacade == null || mDBFacade.metrics == null) {
			return;
		}
		var _loc5_:ASObject = {
			"phase": phase,
			"transport": transportName,
			"candidate": Std.string(mCandidateIndex)
		};
		if (elapsedMs >= 0) {
			_loc5_["elapsedMs"] = Std.string(elapsedMs);
		}
		if (closeEvent != null) {
			_loc5_["wsCode"] = Std.string(closeEvent.code);
			_loc5_["wsReason"] = closeEvent.reason;
			_loc5_["initiator"] = closeEvent.initiator;
		}
		mDBFacade.metrics.log("DcSocketTransport", _loc5_);
	}

	function closeHandler(event:GameTransportEvent) {
		var _loc5_ = attemptElapsedMs();
		Logger.warnch("WS", "DcSocket closeHandler: " + event.toString() + (mHasConnected ? "" : " after " + _loc5_ + "ms"));
		if (!mHasConnected) {
			recordAttempt(_loc5_, event.code, event.reason, "", "", true);
		}
		logTransport("closed", transportName(), event, mHasConnected ? -1 : _loc5_);
		endReconnect(event);
		if (!event.terminal && tryNextCandidateIfAny()) {
			return;
		}
		var _loc2_ = wellKnownDisconnectCode();
		var _loc3_ = _loc2_ != 0 ? _loc2_ : (601 : UInt);
		if (mDBFacade.metrics != null) {
			mDBFacade.metrics.log("DcSocketClose", {
				"errorCode": Std.string(_loc3_),
				"subcode": Std.string(mDisconnectCode),
				"subtext": mDisconnecttext
			});
		}
		detachTransport(false);
		logConnectFailureDiagnostics();
		var _loc4_ = event.gaveUp ? TransportFailureText.forGiveUp(event) : TransportFailureText.forClose(event);
		mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc3_, TransportFailureText.withServerText(mDisconnecttext, _loc4_));
	}

	function connectHandler(event:GameTransportEvent) {
		Logger.infoch("WS", "DcSocket connected [" + transportName() + "]");
		mHasConnected = true;
		logTransport("connected", transportName(), null);
		mDBFacade.loadingBarTick();
		mDBFacade.metrics.log("DcSocketConnect", {"transport": transportName()});
		mLogicalWorkComponent.doEverySeconds(TransportSettings.heartbeatSeconds, StartPingFunction);
		SendLogin();
	}

	public function StartPingFunction(gameClock:GameClock) {
		SendHeartBeat();
	}

	function reconnectingHandler(event:GameTransportEvent) {
		Logger.warnch("WS", "DcSocket reconnecting [" + transportName() + "]: " + event.code + " " + event.reason);
		mReconnecting = true;
		logTransport("reconnecting", transportName(), event);
		mDBFacade.onConnectionReconnecting(event.reason);
	}

	function reconnectAttemptHandler(event:GameTransportEvent) {
		mDBFacade.onConnectionReconnectAttempt(event.attempts, event.elapsedMilliseconds, event.graceMilliseconds);
	}

	function resumedHandler(event:GameTransportEvent) {
		Logger.infoch("WS", "DcSocket resumed ["
			+ transportName()
			+ "] after "
			+ event.elapsedMilliseconds
			+ "ms and "
			+ event.attempts
			+ " attempt(s)");
		mReconnecting = false;
		logResume("resumed", event.attempts, event.elapsedMilliseconds);
		mDBFacade.onConnectionResumed();
	}

	function endReconnect(event:GameTransportEvent) {
		if (!mReconnecting) {
			return;
		}
		logResume("gaveUp", event.attempts, event.elapsedMilliseconds);
		clearReconnectIndicator();
	}

	function logResume(outcome:String, attempts:Int, elapsedMilliseconds:Int) {
		if (mDBFacade == null || mDBFacade.metrics == null) {
			return;
		}
		mDBFacade.metrics.log("DcSocketResume", {
			"outcome": outcome,
			"attempts": Std.string(attempts),
			"elapsedMs": Std.string(elapsedMilliseconds),
			"stateChanged": Std.string(mDBFacade.reconnectChangedMainState)
		});
	}

	function failedHandler(event:GameTransportEvent) {
		var _loc3_ = attemptElapsedMs();
		Logger.warnch("WS",
			"DcSocket transport failed ["
			+ transportName()
			+ "]: "
			+ event.errorCode
			+ " "
			+ event.text
			+ (mHasConnected ? "" : " after " + _loc3_ + "ms")
			+ (event.certificateStatus == "" ? "" : " cert=" + event.certificateStatus)
			+ (event.certificateDetail == "" ? "" : " [" + event.certificateDetail + "]"));
		if (!mHasConnected) {
			recordAttempt(_loc3_, (event.errorCode : Int), event.text, event.certificateStatus, event.certificateDetail, false);
		}
		logTransport("failed", transportName(), null, mHasConnected ? -1 : _loc3_);
		endReconnect(event);
		if (tryNextCandidateIfAny()) {
			return;
		}
		detachTransport(false);
		var _loc2_ = wellKnownDisconnectCode();
		if (_loc2_ != 0) {
			reportFailure(_loc2_, mDisconnecttext);
			return;
		}
		if (retryPassIfStalled()) {
			return;
		}
		logConnectFailureDiagnostics();
		reportFailure(event.errorCode, TransportFailureText.forFailure(event));
	}

	function wellKnownDisconnectCode():UInt {
		if (mDisconnectCode == 60 || mDisconnectCode == 61) {
			return (mDisconnectCode : UInt);
		}
		return (0 : UInt);
	}

	function reportFailure(errorCode:UInt, text:String) {
		if (mFailureReported) {
			return;
		}
		mFailureReported = true;
		ASCompat.setTimeout(deliverFailure, 0, errorCode, text);
	}

	function deliverFailure(errorCode:UInt, text:String) {
		if (mDBFacade == null) {
			return;
		}
		mDBFacade.metrics.log("DcSocketClose", {"errorCode": Std.string(errorCode)});
		mDBFacade.mDistributedObjectManager.enterSocketErrorState(errorCode, text);
	}

	function transportName():String {
		return mTransport != null ? mTransport.name : "none";
	}

	function socketDataHandler(event:GameTransportEvent) {
		ProcessMoreSocketData(event.bytes);
	}

	public function BuildPacketHeartBeat():DcNetworkPacket {
		var _loc2_ = new DcNetworkPacket();
		_loc2_.writeShort((CLIENT_HEART_BEAT : Int));
		var _loc3_ = Date.now();
		var _loc1_ = Std.string(_loc3_.getTime());
		_loc2_.writeUTF(_loc1_);
		return _loc2_;
	}

	function BuildPacketLogin():DcNetworkPacket {
		var _loc2_ = new DcNetworkPacket();
		_loc2_.writeShort((CLIENT_LOGIN_DUNGEONBUSTER : Int));
		_loc2_.writeUTF(mValidationToken);
		var _loc3_ = "development";
		_loc2_.writeUTF(_loc3_);
		var _loc1_ = getDcHash();
		_loc2_.writeUnsignedInt(_loc1_);
		_loc2_.writeUnsignedInt((4 : UInt));
		_loc2_.writeUnsignedInt(mAccountid);
		_loc2_.writeUnsignedInt(mNetworkID);
		_loc2_.writeUnsignedInt(mNodeRules);
		return _loc2_;
	}

	public function sendpacket(pck:DcNetworkPacket) {
		if (mTransport == null) {
			return;
		}
		var _loc2_ = new ByteArray();
		_loc2_.endian = "littleEndian";
		_loc2_.writeShort((pck.length : Int));
		_loc2_.writeBytes(pck, (0 : UInt), pck.length);
		_loc2_.position = (0 : UInt);
		mTransport.send(_loc2_);
	}

	public function SendLogout() {
		mDBFacade.metrics.log("DcSocketSendLogout");
		Logger.debug("SendLogout");
		var _loc1_ = new DcNetworkPacket();
		_loc1_.writeShort((CLIENT_LOGOUT : Int));
		sendpacket(_loc1_);
	}

	function SendLogin() {
		mDBFacade.metrics.log("DcSocketSendLogin");
		Logger.debug("SendLogin");
		sendpacket(BuildPacketLogin());
		SendHeartBeat();
	}

	function SendHeartBeat() {
		sendpacket(BuildPacketHeartBeat());
	}

	function ProcessPacketFromWire(game_packet:DcNetworkPacket) {
		var _loc2_:Int = game_packet.readUnsignedShort();
		switch (_loc2_) {
			case(_ == ASCompat.toInt(CLIENT_HEART_BEAT) => true):
				Process_CLIENT_HEART_BEAT(game_packet);

			case(_ == ASCompat.toInt(CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP) => true):
				Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP(game_packet);

			case(_ == ASCompat.toInt(CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP) => true):
				Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP(game_packet);

			case(_ == ASCompat.toInt(CLIENT_CREATE_OBJECT_REQUIRED_RESP) => true):
				Process_CLIENT_CREATE_OBJECT_REQUIRED_RESP(game_packet);

			case(_ == ASCompat.toInt(CLIENT_OBJECT_UPDATE_FIELD) => true):
				Process_CLIENT_OBJECT_UPDATE_FIELD(game_packet);

			case(_ == ASCompat.toInt(CLIENT_OBJECT_DISABLE_RESP) => true):
				Process_CLIENT_OBJECT_DISABLE_RESP(game_packet);

			case(_ == ASCompat.toInt(CLIENT_OBJECT_DISABLE_OWNER_RESP) => true):
				Process_CLIENT_OBJECT_DISABLE_OWNER_RESP(game_packet);

			case(_ == ASCompat.toInt(CLIENT_OBJECT_DELETE_RESP) => true):
				Process_CLIENT_OBJECT_DELETE_RESP(game_packet);

			case(_ == ASCompat.toInt(CLIENT_LOGIN_DUNGEONBUSTER) => true):
				Process_CLIENT_LOGIN_DUNGEONBUSTER(game_packet);

			case(_ == ASCompat.toInt(CLIENT_INTEREST_CONTEXT) => true):
				Process_CLIENT_INTEREST_CONTEXT(game_packet);

			case(_ == ASCompat.toInt(CLIENT_LOGOUT_RESP) => true):
				Process_CLIENT_LOGOUT_RESP(game_packet);

			default:
				Logger.error("-------------------------------------Weird not processing function code=" + _loc2_);
		}
	}

	function Process_CLIENT_OBJECT_UPDATE_FIELD(game_packet:DcNetworkPacket) {
		var _loc3_ = game_packet.readUnsignedInt();
		var _loc2_ = game_packet.readUnsignedShort();
		var _loc4_ = ASCompat.coerce(Doid_NetInterfaces[Std.string(_loc3_)], networkCode.DcNetworkInterface);
		if (_loc4_ == null) {
			Logger.warn("Process_CLIENT_OBJECT_UPDATE_FIELD DcNetworkInterface is null " + _loc4_ + " " + _loc3_ + " " + _loc2_);
		} else {
			_loc4_.recvById(game_packet, _loc2_);
			#if cpp
			modding.Host.fieldReceived(_loc4_, _loc2_);
			#end
		}
	}

	function InformParentOfNewObject(parent_do_id:UInt, child_do_id:UInt) {
		var _loc3_:GameObject = null;
		var _loc4_ = mDBFacade.gameObjectManager.getReferenceFromId(child_do_id);
		if (_loc4_ == null) {
			Logger.warn("InformParentOfNewObject: newObject does not exist " + child_do_id);
		} else if (parent_do_id != 0) {
			_loc3_ = mDBFacade.gameObjectManager.getReferenceFromId(parent_do_id);
			if (_loc3_ != null) {
				_loc3_.newNetworkChild(_loc4_.getTrueObject());
			}
		}
		#if cpp
		modding.Host.objectCreated(Doid_NetInterfaces[Std.string(child_do_id)]);
		#end
	}

	function Process_CLIENT_CREATE_OBJECT_REQUIRED_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc4_ = game_packet.readUnsignedInt();
		var _loc3_ = game_packet.readUnsignedShort();
		var _loc6_ = game_packet.readUnsignedInt();
		ASCompat.reinterpretAs(this, DcSocketGenerate).ObjectFactoryVisible(_loc3_, _loc6_, game_packet);
		var _loc5_ = mDBFacade.gameObjectManager.getReferenceFromId(_loc6_);
		InformParentOfNewObject(_loc2_, _loc6_);
	}

	function Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc4_ = game_packet.readUnsignedInt();
		var _loc3_ = game_packet.readUnsignedShort();
		var _loc5_ = game_packet.readUnsignedInt();
		ASCompat.reinterpretAs(this, DcSocketGenerate).ObjectFactoryVisible(_loc3_, _loc5_, game_packet);
		InformParentOfNewObject(_loc2_, _loc5_);
	}

	function Process_CLIENT_CREATE_OBJECT_REQUIRED_OTHER_OWNER_RESP(game_packet:DcNetworkPacket) {
		var _loc3_ = game_packet.readUnsignedShort();
		var _loc5_ = game_packet.readUnsignedInt();
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc4_ = game_packet.readUnsignedInt();
		ASCompat.reinterpretAs(this, DcSocketGenerate).ObjectFactoryOwner(_loc3_, _loc5_, game_packet);
		InformParentOfNewObject(_loc2_, _loc5_);
	}

	function ProcessMoreSocketData(chunk:ByteArray) {
		var _loc3_ = 0;
		var _loc2_:DcNetworkPacket = null;
		if (chunk == null || chunk.length == 0) {
			return;
		}
		var _loc4_ = input_double_buffer.position;
		input_double_buffer.position = input_double_buffer.length;
		input_double_buffer.writeBytes(chunk, (0 : UInt), chunk.length);
		input_double_buffer.position = _loc4_;
		while (input_double_buffer.bytesAvailable >= 2) {
			_loc3_ = (input_double_buffer.readUnsignedShort() : Int);
			if (_loc3_ == 0) {
				Logger.warn("DcSocket discarding a zero-length packet from the wire");
			} else {
				if ((_loc3_ : UInt) > input_double_buffer.bytesAvailable) {
					input_double_buffer.position -= (2 : UInt);
					break;
				}
				_loc2_ = new DcNetworkPacket();
				input_double_buffer.readBytes(_loc2_, (0 : UInt), (_loc3_ : UInt));
				ProcessPacketFromWire(_loc2_);
			}
		}
		input_double_buffer.do_slide();
	}

	function Process_CLIENT_OBJECT_DISABLE_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc3_ = ASCompat.coerce(Doid_NetInterfaces[Std.string(_loc2_)], networkCode.DcNetworkInterface);
		if (_loc3_ == null) {
			Logger.warn("Process_CLIENT_OBJECT_DISABLE_RESP: Received Remove ID for object not in memory " + _loc2_);
		} else {
			_loc3_.destroy();
			ASCompat.deleteProperty(Doid_NetInterfaces, Std.string(_loc2_));
		}
	}

	function Process_CLIENT_HEART_BEAT(game_packet:DcNetworkPacket) {
		var _loc2_:String = null;
		var _loc4_ = Math.NaN;
		var _loc5_:Date = null;
		var _loc3_ = Math.NaN;
		if (mDBFacade.dbAccountInfo != null) {
			_loc2_ = game_packet.readUTF();
			_loc4_ = ASCompat.toNumber(_loc2_);
			_loc5_ = Date.now();
			_loc3_ = _loc5_.getTime();
			mDBFacade.dbAccountInfo.SocketPingMilsecs = ASCompat.floatToInt(_loc3_ - _loc4_);
		}
	}

	function Process_CLIENT_OBJECT_DISABLE_OWNER_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc3_ = ASCompat.coerce(Doid_NetInterfaces[Std.string(_loc2_)], networkCode.DcNetworkInterface);
		if (_loc3_ == null) {
			Logger.warn("Process_CLIENT_OBJECT_DISABLE_OWNER_RESP: Received Remove ID for object not in memory " + _loc2_);
		} else {
			_loc3_.destroy();
			ASCompat.deleteProperty(Doid_NetInterfaces, Std.string(_loc2_));
		}
	}

	function Process_CLIENT_OBJECT_DELETE_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc3_ = ASCompat.coerce(Doid_NetInterfaces[Std.string(_loc2_)], networkCode.DcNetworkInterface);
		if (_loc3_ == null) {
			Logger.warn("Process_CLIENT_OBJECT_DISABLE_OWNER_RESP: Received Remove ID for object not in memory " + _loc2_);
		} else {
			_loc3_.destroy();
			ASCompat.deleteProperty(Doid_NetInterfaces, Std.string(_loc2_));
		}
	}

	function Process_CLIENT_INTEREST_CONTEXT(game_packet:DcNetworkPacket) {
		var _loc4_ = game_packet.readUnsignedShort();
		var _loc3_ = game_packet.readUnsignedInt();
		var _loc2_ = mDBFacade.gameObjectManager.getReferenceFromId(_loc3_);
		if (_loc2_ == null) {
			Logger.warn("Process_CLIENT_INTEREST_CONTEXT: Object does not exist - should never see this id=" + _loc3_);
		} else {
			_loc2_.InterestClosure();
		}
	}

	function Process_CLIENT_LOGOUT_RESP(game_packet:DcNetworkPacket) {
		mDisconnectCode = game_packet.readShort();
		mDisconnecttext = game_packet.readUTF();
		if (mDisconnectCode == 60) {
			detachTransport(true);
			mDBFacade.mDistributedObjectManager.enterSocketErrorState((mDisconnectCode : UInt), mDisconnecttext);
		} else {
			Logger.infoch("WS", "Process_CLIENT_LOGOUT_RESP[" + mDisconnectCode + "] Server Text[" + mDisconnecttext + "]");
			mDBFacade.metrics.log("ClientLogoutResp", {
				"code": Std.string(mDisconnectCode),
				"text": mDisconnecttext
			});
		}
	}

	public function destroy() {
		var _loc1_:ASObject = null;
		var _loc2_ = 0;
		Logger.debugch("WS", "DcSocket destroy");
		if (mDBFacade.metrics != null) {
			mDBFacade.metrics.log("DcSocketDestroy");
		}
		detachTransport(true);
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		if (mDBFacade.dbAccountInfo != null) {
			mDBFacade.dbAccountInfo.SocketPingMilsecs = -1;
		}
		var _loc4_ = new Vector<DcNetworkClass>();
		var _loc3_:String;
		final __ax4_iter_162:ASObject = Doid_NetInterfaces;
		if (checkNullIteratee(__ax4_iter_162))
			for (_tmp_ in __ax4_iter_162.___keys()) {
				_loc3_ = _tmp_;
				_loc1_ = Doid_NetInterfaces[_loc3_];
				if (Std.isOfType(_loc1_, DcNetworkClass)) {
					_loc4_.push(ASCompat.coerce(Doid_NetInterfaces[_loc3_], networkCode.DcNetworkClass));
				} else {
					_loc1_.destroy();
				}
			}
		ASCompat.ASVector.sort(_loc4_, sorter);
		_loc2_ = 0;
		while (_loc2_ < _loc4_.length) {
			_loc4_[_loc2_].destroy();
			_loc2_++;
		}
		Doid_NetInterfaces = null;
		input_double_buffer.clear();
		mDBFacade = null;
		mValidationToken = null;
	}

	function Process_CLIENT_LOGIN_DUNGEONBUSTER(game_packet:DcNetworkPacket) {}

	public function getDcHash():UInt {
		return (ASCompat.floatToInt(4294967295) : UInt);
	}
}
