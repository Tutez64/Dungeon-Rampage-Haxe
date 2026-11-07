package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.compat.ConsoleLib;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.StatusEvent;
import flash.net.LocalConnection;
import flash.net.Socket;
import flash.system.Security;
import flash.utils.ByteArray;
import haxe.Exception;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class Remoting extends ConsoleCore {
	public static var NONE:UInt = (0 : UInt);

	public static var SENDER:UInt = (1 : UInt);

	public static var RECIEVER:UInt = (2 : UInt);

	public var _socket:Socket;

	public var _senders:ASDictionary<ASAny, ASAny>;

	public var _sendID:String;

	public var _sendBuffer:ByteArray;

	public var _recBuffers:IMap<ASAny, ASAny>;

	public var _mode:UInt = 0;

	public var _loggedIn:Bool = false;

	public var _local:ASAny;

	public var _lastReciever:String;

	public var _lastLogin:String;

	public var _callbacks:IMap<ASAny, ASAny>;

	public function new(m:Console = /*undefined*/ null) {
		var _gthis:Remoting;
		_lastLogin = "";
		_senders = new ASDictionary<ASAny, ASAny>();
		_recBuffers = new StringMap<ASAny>();
		_sendBuffer = new ByteArray();
		_callbacks = new StringMap<ASAny>();
		_gthis = this;
		super(m);
		registerCallback("login", function(bytes:ByteArray) {
			_gthis.login(bytes.readUTF());
		});
		registerCallback("requestLogin", requestLogin);
		registerCallback("loginFail", loginFail);
		registerCallback("loginSuccess", loginSuccess);
	}

	public function update() {
		var _loc1_ = (null : ByteArray);
		var _loc2_ = (null : ByteArray);
		var _loc3_:ASAny = ASCompat.asString(null);
		var _loc13_:ASAny = null;
		var _loc14_ = 0;
		var _loc15_ = false;
		var _loc16_:ASAny = ASCompat.asString(null);
		if (_sendBuffer.length != 0) {
			if (_socket != null && _socket.connected) {
				_socket.writeBytes(_sendBuffer);
				_sendBuffer = new ByteArray();
			} else if (_local != null) {
				_sendBuffer.position = (0 : UInt);
				if (_sendBuffer.bytesAvailable < 38000) {
					_loc1_ = _sendBuffer;
					_sendBuffer = new ByteArray();
				} else {
					_loc1_ = new ByteArray();
					_sendBuffer.readBytes(_loc1_, (0 : UInt), (ASCompat.floatToInt(Math.min(38000, _sendBuffer.bytesAvailable)) : UInt));
					_loc2_ = new ByteArray();
					_sendBuffer.readBytes(_loc2_);
					_sendBuffer = _loc2_;
				}
				_loc3_ = config.remotingConnectionName + Std.string(get_remoting() == 2 ? 1 : 2);
				_local.send(_loc3_, "synchronize", _sendID, _loc1_);
			} else {
				_sendBuffer = new ByteArray();
			}
		}
		var _loc4_ = cast(_recBuffers, StringMap<Dynamic>);
		var _loc5_:ASAny = ASCompat.haxeMapStorage(_loc4_);
		var _loc6_:ASAny = null;
		var _loc7_ = 0;
		var _loc8_ = false;
		var _loc9_:ASAny = _loc5_;
		var _loc10_ = _loc7_;
		var _loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		if (!_loc11_ && _loc6_ != null) {
			_loc9_ = _loc5_ = _loc6_;
			_loc10_ = _loc7_ = 0;
			_loc6_ = null;
			_loc8_ = true;
			_loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		}
		var _loc12_ = _loc10_;
		while (true) {
			_loc13_ = _loc5_;
			_loc14_ = _loc7_;
			_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			if (!_loc15_ && _loc6_ != null) {
				_loc13_ = _loc5_ = _loc6_;
				_loc14_ = _loc7_ = 0;
				_loc6_ = null;
				_loc8_ = true;
				_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			}
			_loc12_ = _loc14_;
			if (!_loc15_) {
				break;
			}
			_loc3_ = ASCompat.nextName(_loc5_, _loc12_);
			_loc7_ = _loc12_;
			if (_loc8_) {
				_loc3_ = Std.string(_loc3_).substr(1);
			}
			_loc16_ = _loc3_;
			processRecBuffer(_loc16_);
		}
	}

	public function synchronize(id:String, obj:ASAny) {
		var _loc6_ = ASCompat.dynamicAs(null, StringMap);
		if (!ASCompat.isByteArray(obj)) {
			report("Remoting sync error. Recieved non-ByteArray:" + Std.string(obj), 9);
			return;
		}
		var _loc3_ = ASCompat.asByteArray(obj);
		var _loc4_ = cast(_recBuffers, StringMap<Dynamic>);
		var _loc5_ = ASCompat.asByteArray(_loc4_.get(id));
		if (_loc5_ != null) {
			_loc5_.position = _loc5_.length;
			_loc5_.writeBytes(_loc3_);
		} else {
			_loc6_ = cast(_recBuffers, StringMap<Dynamic>);
			{
				_loc6_.set(id, _loc3_);
			}
		}
	}

	public function startSharedConnection(targetmode:UInt):Bool {
		var _loc3_:ASAny = null;
		close();
		_mode = targetmode;
		_local = new LocalConnection();
		ASCompat.setProperty(_local, "client", {"synchronize": synchronize});
		if (config.allowedRemoteDomain != null && config.allowedRemoteDomain != "") {
			_local.allowDomain(config.allowedRemoteDomain);
			_local.allowInsecureDomain(config.allowedRemoteDomain);
		}
		_local.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRemotingSecurityError, false, 0, true);
		try {
			_local.connect(config.remotingConnectionName + Std.string(_mode));
		} catch (_loc_e_:ASAny) {
			_loc3_ = _loc_e_;
			null;
			return false;
		}
		return true;
	}

	public function socketSecurityErrorHandler(e:Event) {
		report("Remoting security error." + Std.string(e), 9);
		remotingSocket(null);
	}

	public function socketIOErrorHandler(e:Event) {
		report("Remoting socket error." + Std.string(e), 9);
		remotingSocket(null);
	}

	public function socketDataHandler(e:Event) {
		handleSocket(cast(e.currentTarget, Socket));
	}

	public function socketConnectHandler(e:Event) {
		report("Remoting socket connected.", -1);
		_sendBuffer = new ByteArray();
		if (_loggedIn || checkLogin("")) {
			sendLoginSuccess();
		} else {
			send("requestLogin");
		}
	}

	public function socketCloseHandler(e:Event) {
		if (e.currentTarget == _socket) {
			_socket = null;
		}
	}

	@:isVar public var remoting(get, set):UInt;

	public function set_remoting(newMode:UInt):UInt {
		var _loc2_ = ASCompat.asString(null);
		if (newMode == _mode) {
			return newMode;
		}
		_sendID = generateId();
		if (newMode == 1) {
			if (!startSharedConnection((1 : UInt))) {
				report("Could not create remoting client service. You will not be able to control this console with remote.", 10);
			}
			_sendBuffer = new ByteArray();
			_local.addEventListener(StatusEvent.STATUS, onSenderStatus, false, 0, true);
			report("<b>Remoting started.</b> " + getInfo(), -1);
			_loggedIn = checkLogin("");
			if (_loggedIn) {
				sendLoginSuccess();
			} else {
				send("requestLogin");
			}
		} else if (newMode == 2) {
			if (startSharedConnection((2 : UInt))) {
				_sendBuffer = new ByteArray();
				_local.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onRemoteAsyncError, false, 0, true);
				_local.addEventListener(StatusEvent.STATUS, onRecieverStatus, false, 0, true);
				report("<b>Remote started.</b> " + getInfo(), -1);
				_loc2_ = Security.sandboxType;
				if (_loc2_ == Security.LOCAL_WITH_FILE || _loc2_ == Security.LOCAL_WITH_NETWORK) {
					report("Untrusted local sandbox. You may not be able to listen for logs properly.", 10);
					printHowToGlobalSetting();
				}
				login(_lastLogin);
			} else {
				report("Could not create remote service. You might have a console remote already running.", 10);
			}
		} else {
			close();
		}
		console.get_panels().updateMenu();
		return newMode;
	}

	public function sendLoginSuccess() {
		_loggedIn = true;
		send("loginSuccess");
		dispatchEvent(new Event(Event.CONNECT));
	}

	public function send(command:String, arg:ByteArray = /*undefined*/ null):Bool {
		if (_mode == 0) {
			return false;
		}
		_sendBuffer.position = _sendBuffer.length;
		_sendBuffer.writeUTF(command);
		if (arg != null) {
			_sendBuffer.writeBoolean(true);
			_sendBuffer.writeUnsignedInt(arg.length);
			_sendBuffer.writeBytes(arg);
		} else {
			_sendBuffer.writeBoolean(false);
		}
		return true;
	}

	public function requestLogin() {
		if (get_remoting() != 2) {
			return;
		}
		_sendBuffer = new ByteArray();
		if (_lastLogin != null && _lastLogin != "") {
			login(_lastLogin);
		} else {
			console.get_panels().get_mainPanel().requestLogin();
		}
	}

	public function remotingSocket(host:String, port:Int = 0) {
		if (_socket != null && _socket.connected) {
			_socket.close();
			_socket = null;
		}
		if (host != null && host != "" && port != 0) {
			set_remoting((1 : UInt));
			report("Connecting to socket " + host + ":" + port);
			_socket = new Socket();
			_socket.addEventListener(Event.CLOSE, socketCloseHandler);
			_socket.addEventListener(Event.CONNECT, socketConnectHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, socketIOErrorHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketSecurityErrorHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			_socket.connect(host, port);
		}
	}

	public function registerCallback(key:String, fun:ASAny, latestOnly:Bool = false) {
		var _loc4_:ASObject = {
			"fun": fun,
			"latest": latestOnly
		};
		var _loc5_ = cast(_callbacks, StringMap<Dynamic>);
		var _loc6_:ASObject = _loc4_;
		{
			_loc5_.set(key, _loc6_);
		}
	}

	public function processRecBuffer(id:String) {
		var _loc5_ = (0 : UInt);
		var _loc6_ = (0 : UInt);
		var _loc7_ = ASCompat.asString(null);
		var _loc8_:ASAny = (null : ByteArray);
		var _loc9_ = ASCompat.dynamicAs(null, StringMap);
		var _loc10_:ASAny = null;
		var _loc11_ = (null : ByteArray);
		var _loc12_ = ASCompat.dynamicAs(null, Exception);
		if (!ConsoleLib.truthy(ASDictionary.getString(_senders, id))) {
			_senders[id] = true;
			if (_lastReciever != null) {
				report("Remote switched to new sender [" + id + "] as primary.", -2);
			}
			_lastReciever = id;
		}
		var _loc3_ = cast(_recBuffers, StringMap<Dynamic>);
		var _loc4_ = ASCompat.asByteArray(_loc3_.get(id));
		try {
			_loc5_ = _loc4_.position = (0 : UInt);
			while (_loc4_.bytesAvailable != 0) {
				_loc7_ = _loc4_.readUTF();
				_loc8_ = null;
				if (_loc4_.bytesAvailable == 0) {
					break;
				}
				if (_loc4_.readBoolean()) {
					if (_loc4_.bytesAvailable == 0) {
						break;
					}
					_loc6_ = _loc4_.readUnsignedInt();
					if (_loc4_.bytesAvailable < _loc6_) {
						break;
					}
					_loc8_ = new ByteArray();
					_loc4_.readBytes(ASCompat.asByteArray(_loc8_), (0 : UInt), _loc6_);
				}
				_loc9_ = cast(_callbacks, StringMap<Dynamic>);
				_loc10_ = _loc9_.get(_loc7_);
				if (!ASCompat.toBool(_loc10_.latest) || id == _lastReciever) {
					if (_loc8_ != null) {
						_loc10_.fun(_loc8_);
					} else {
						_loc10_.fun();
					}
				}
				_loc5_ = _loc4_.position;
			}
			if (_loc5_ < _loc4_.length) {
				_loc8_ = new ByteArray();
				_loc8_.writeBytes(_loc4_, _loc5_);
				_loc11_ = _loc4_ = ASCompat.asByteArray(_loc8_);
				_loc9_ = cast(_recBuffers, StringMap<Dynamic>);
				{
					_loc9_.set(id, _loc11_);
				}
			} else {
				cast(_recBuffers, StringMap<Dynamic>).remove(id);
			}
		} catch (_loc_e_:ASAny) {
			_loc10_ = _loc_e_;
			_loc12_ = ASCompat.haxeCaught(_loc10_);
			report("Remoting sync error: " + Std.string(_loc12_), 9);
		}
	}

	public function printHowToGlobalSetting() {
		report("Make sure your flash file is \'trusted\' in Global Security Settings.", -2);
		report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\' (on left) &gt; add the location of the local flash (swf) file.",
			-2);
	}

	public function onSenderStatus(e:StatusEvent) {
		if (e.level == "error" && !(_socket != null && _socket.connected)) {
			_loggedIn = false;
		}
	}

	public function onRemotingSecurityError(e:SecurityErrorEvent) {
		report("Remoting security error.", 9);
		printHowToGlobalSetting();
	}

	public function onRemoteAsyncError(e:AsyncErrorEvent) {
		report("Problem with remote sync. [<a href=\'event:remote\'>Click here</a>] to restart.", 10);
		set_remoting((0 : UInt));
	}

	public function onRecieverStatus(e:StatusEvent) {
		if (get_remoting() == 2 && e.level == "error") {
			report("Problem communicating to client.", 10);
		}
	}

	public function loginSuccess() {
		if ([].length == 0) {
			console.setViewingChannels();
		} else if ([].length == 1) {
			console.setViewingChannels([][0]);
		} else if ([].length == 2) {
			console.setViewingChannels([][0], [][1]);
		} else if ([].length == 3) {
			console.setViewingChannels([][0], [][1], [][2]);
		} else if ([].length == 4) {
			console.setViewingChannels([][0], [][1], [][2], [][3]);
		} else if ([].length == 5) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4]);
		} else if ([].length == 6) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5]);
		} else if ([].length == 7) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6]);
		} else if ([].length == 8) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7]);
		} else if ([].length == 9) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8]);
		} else if ([].length == 10) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9]);
		} else if ([].length == 11) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10]);
		} else if ([].length == 12) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11]);
		} else if ([].length == 13) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12]);
		} else if ([].length == 14) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12], [][13]);
		} else if ([].length == 15) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12], [][13], [][14]);
		} else if ([].length == 16) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12], [][13], [][14], [][15]);
		} else if ([].length == 17) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12], [][13], [][14], [][15],
				[][16]);
		} else if ([].length == 18) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12], [][13], [][14], [][15],
				[][16], [][17]);
		} else if ([].length == 19) {
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12], [][13], [][14], [][15],
				[][16], [][17], [][18]);
		} else {
			if ([].length != 20) {
				throw "Too many rest arguments";
			}
			console.setViewingChannels([][0], [][1], [][2], [][3], [][4], [][5], [][6], [][7], [][8], [][9], [][10], [][11], [][12], [][13], [][14], [][15],
				[][16], [][17], [][18], [][19]);
		}
		report("Login Successful", -1);
	}

	public function loginFail() {
		if (get_remoting() != 2) {
			return;
		}
		report("Login Failed", 10);
		console.get_panels().get_mainPanel().requestLogin();
	}

	public function login(pass:String = /*undefined*/ null) {
		var _loc2_ = (null : ByteArray);
		if (pass == null) {
			pass = "";
		}
		if (get_remoting() == 2) {
			_lastLogin = pass;
			report("Attempting to login...", -1);
			_loc2_ = new ByteArray();
			_loc2_.writeUTF(pass);
			send("login", _loc2_);
		} else if (_loggedIn || checkLogin(pass)) {
			sendLoginSuccess();
		} else {
			send("loginFail");
		}
	}

	public function handleSocket(socket:Socket) {
		if (!ConsoleLib.truthy(_senders[socket])) {
			_senders[socket] = generateId();
			_socket = socket;
		}
		var _loc2_ = new ByteArray();
		socket.readBytes(_loc2_);
		synchronize(_senders[socket], _loc2_);
	}

	public function get_remoting():UInt {
		return _mode;
	}

	@:isVar public var canSend(get, never):Bool;

	public function get_canSend():Bool {
		if (_mode == 1) {
			return _loggedIn;
		}
		return false;
	}

	public function getInfo():String {
		return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
	}

	public function generateId():String {
		return ConsoleLib.now().getTime() + "." + ASCompat.floatToInt(Math.ffloor(Math.random() * 100000));
	}

	public function close() {
		var _loc2_:ASAny = null;
		var _loc3_:ASAny = null;
		if (_local != null) {
			try {
				_local.close();
			} catch (_loc_e_:ASAny) {
				_loc2_ = _loc_e_;
				null;
				_loc3_ = ASCompat.haxeUnwrap(ASCompat.haxeCaught(_loc2_));
				report("Remote.close: " + Std.string(_loc3_), 10);
			}
		}
		_mode = (0 : UInt);
		_sendBuffer = new ByteArray();
		_local = null;
	}

	public function checkLogin(pass:String):Bool {
		if (!(config.remotingPassword == null && config.keystrokePassword == pass || config.remotingPassword == "")) {
			return config.remotingPassword == pass;
		}
		return true;
	}
}
