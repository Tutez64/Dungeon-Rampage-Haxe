package networkCode;

import brain.clock.GameClock;
import brain.gameObject.GameObject;
import brain.logger.Logger;
import brain.workLoop.LogicalWorkComponent;
import facade.DBFacade;
import generatedCode.*;
import flash.errors.*;
import flash.events.*;
import flash.net.Socket;
import flash.utils.ByteArray;

class DcSocket extends Socket {
	static inline final PING_INTERVAL:Float = 10;

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

	var mDisconnecttext:String = "NotSet";

	public function new(facade:DBFacade, host:String, port:Int, validationToken:String, demographics:String, accountid:UInt) {
		Logger.debug("Creating new Socket " + host + " " + port + " " + validationToken + " " + accountid);
		super();
		mValidationToken = validationToken;
		mDemographics = demographics;
		mAccountid = accountid;
		this.endian = "littleEndian";
		input_double_buffer = new DcNetworkPacket();
		mDBFacade = facade;
		Doid_NetInterfaces = {};
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "DcSocket");
		configureListeners();
		Logger.debug("Starting Conection ");
		mDBFacade.metrics.log("DcSocketCreate");
		mDBFacade.loadingBarTick();
		this.connect(host, port);
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
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
		return _loc3_;
	}

	static function sorter(x:DcNetworkClass, y:DcNetworkClass):Float {
		return y.creationOrder - x.creationOrder;
	}

	public function pass2Init(networkid:UInt, noderules:UInt) {
		mNetworkID = networkid;
		mNodeRules = noderules;
	}

	@:isVar public var facade(get, never):DBFacade;

	public function get_facade():DBFacade {
		return mDBFacade;
	}

	function configureListeners() {
		addEventListener("close", closeHandler);
		addEventListener("connect", connectHandler);
		addEventListener("ioError", ioErrorHandler);
		addEventListener("securityError", securityErrorHandler);
		addEventListener("socketData", socketDataHandler);
	}

	function unconfigureListeners() {
		removeEventListener("connect", connectHandler);
		removeEventListener("close", closeHandler);
		removeEventListener("ioError", ioErrorHandler);
		removeEventListener("securityError", securityErrorHandler);
		removeEventListener("socketData", socketDataHandler);
	}

	function closeHandler(event:Event) {
		var _loc2_ = (601 : UInt);
		if (mDisconnectCode == 60 || mDisconnectCode == 61) {
			_loc2_ = (mDisconnectCode : UInt);
		}
		Logger.warn("DcSocket closeHandler: " + event.toString());
		mDBFacade.metrics.log("DcSocketClose", {
			"errorCode": Std.string(_loc2_),
			"subcode": Std.string(mDisconnectCode),
			"subtext": mDisconnecttext
		});
		mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc2_, mDisconnecttext);
	}

	function connectHandler(event:Event) {
		Logger.debug("connectHandler: " + event);
		mDBFacade.loadingBarTick();
		mDBFacade.metrics.log("DcSocketConnect");
		mLogicalWorkComponent.doEverySeconds(10, StartPingFunction);
		SendLogin();
	}

	public function StartPingFunction(gameClock:GameClock) {
		SendHeartBeat();
	}

	function ioErrorHandler(event:IOErrorEvent) {
		var _loc2_ = (602 : UInt);
		Logger.warn("DcSocket ioErrorHandler: " + event.toString());
		mDBFacade.metrics.log("DcSocketClose", {"errorCode": Std.string(_loc2_)});
		mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc2_, event.text);
	}

	function securityErrorHandler(event:SecurityErrorEvent) {
		var _loc2_ = (603 : UInt);
		Logger.warn("DcSocket securityErrorHandler: " + event.toString());
		mDBFacade.metrics.log("DcSocketClose", {"errorCode": Std.string(_loc2_)});
		mDBFacade.mDistributedObjectManager.enterSocketErrorState(_loc2_, event.text);
	}

	function socketDataHandler(event:ProgressEvent) {
		ProcessMoreSocketData();
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
		writeShort((pck.length : Int));
		writeBytes(pck);
		flush();
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
		var _loc4_ = ASCompat.dynamicAs(Doid_NetInterfaces[Std.string(_loc3_)], networkCode.DcNetworkInterface);
		if (_loc4_ == null) {
			Logger.warn("Process_CLIENT_OBJECT_UPDATE_FIELD DcNetworkInterface is null " + _loc4_ + " " + _loc3_ + " " + _loc2_);
		} else {
			_loc4_.recvById(game_packet, _loc2_);
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

	function ProcessMoreSocketData() {
		var _loc4_ = 0;
		var _loc2_:DcNetworkPacket = null;
		var _loc1_ = input_double_buffer.length;
		readBytes(input_double_buffer, input_double_buffer.length);
		var _loc3_ = input_double_buffer.length;
		while (input_double_buffer.bytesAvailable >= 2) {
			_loc4_ = (input_double_buffer.readUnsignedShort() : Int);
			if ((_loc4_ : UInt) > input_double_buffer.bytesAvailable) {
				input_double_buffer.position -= (2 : UInt);
				break;
			}
			_loc2_ = new DcNetworkPacket();
			input_double_buffer.readBytes(_loc2_, (0 : UInt), (_loc4_ : UInt));
			ProcessPacketFromWire(_loc2_);
		}
		input_double_buffer.do_slide();
	}

	function Process_CLIENT_OBJECT_DISABLE_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc3_ = ASCompat.dynamicAs(Doid_NetInterfaces[Std.string(_loc2_)], networkCode.DcNetworkInterface);
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
			mDBFacade.dbAccountInfo.SocketPingMilsecs = Std.int(_loc3_ - _loc4_);
		}
	}

	function Process_CLIENT_OBJECT_DISABLE_OWNER_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc3_ = ASCompat.dynamicAs(Doid_NetInterfaces[Std.string(_loc2_)], networkCode.DcNetworkInterface);
		if (_loc3_ == null) {
			Logger.warn("Process_CLIENT_OBJECT_DISABLE_OWNER_RESP: Received Remove ID for object not in memory " + _loc2_);
		} else {
			_loc3_.destroy();
			ASCompat.deleteProperty(Doid_NetInterfaces, Std.string(_loc2_));
		}
	}

	function Process_CLIENT_OBJECT_DELETE_RESP(game_packet:DcNetworkPacket) {
		var _loc2_ = game_packet.readUnsignedInt();
		var _loc3_ = ASCompat.dynamicAs(Doid_NetInterfaces[Std.string(_loc2_)], networkCode.DcNetworkInterface);
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
			unconfigureListeners();
			mDBFacade.mDistributedObjectManager.enterSocketErrorState((mDisconnectCode : UInt), mDisconnecttext);
		} else {
			Logger.info("Process_CLIENT_LOGOUT_RESP[" + mDisconnectCode + "] Server Text[" + mDisconnecttext + "]");
			mDBFacade.metrics.log("ClientLogoutResp", {
				"code": Std.string(mDisconnectCode),
				"text": mDisconnecttext
			});
		}
	}

	public function destroy() {
		var _loc1_:ASObject = null;
		var _loc2_ = 0;
		Logger.debug("DcSocket destroy");
		if (mDBFacade.metrics != null) {
			mDBFacade.metrics.log("DcSocketDestroy");
		}
		this.close();
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		if (mDBFacade.dbAccountInfo != null) {
			mDBFacade.dbAccountInfo.SocketPingMilsecs = -1;
		}
		var _loc4_ = new Vector<DcNetworkClass>();
		var _loc3_:String;
		final __ax4_iter_158:ASObject = Doid_NetInterfaces;
		if (checkNullIteratee(__ax4_iter_158))
			for (_tmp_ in __ax4_iter_158.___keys()) {
				_loc3_ = _tmp_;
				_loc1_ = Doid_NetInterfaces[_loc3_];
				if (Std.isOfType(_loc1_, DcNetworkClass)) {
					_loc4_.push(ASCompat.dynamicAs(Doid_NetInterfaces[_loc3_], networkCode.DcNetworkClass));
				} else {
					_loc1_.destroy();
				}
			}
		ASCompat.ASVector.sort(_loc4_, sorter);
		_loc2_ = 0;
		while (_loc2_ < _loc4_.length) {
			_loc4_[_loc2_].destroy();
			_loc2_ = ASCompat.toInt(_loc2_) + 1;
		}
		Doid_NetInterfaces = null;
		unconfigureListeners();
		input_double_buffer.clear();
		mDBFacade = null;
		mValidationToken = null;
	}

	function Process_CLIENT_LOGIN_DUNGEONBUSTER(game_packet:DcNetworkPacket) {}

	public function getDcHash():UInt {
		return (Std.int(4294967295) : UInt);
	}
}
