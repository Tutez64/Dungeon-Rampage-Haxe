package com.junkbyte.console.core;

import com.junkbyte.console.Console;
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

class Remoting extends ConsoleCore {
	public static inline final NONE = (0 : UInt);

	public static inline final SENDER = (1 : UInt);

	public static inline final RECIEVER = (2 : UInt);

	var _callbacks:ASObject;

	var _mode:UInt = 0;

	var _local:LocalConnection;

	var _socket:Socket;

	var _sendBuffer:ByteArray;

	var _recBuffers:ASObject;

	var _senders:ASDictionary<ASAny, ASAny>;

	var _lastLogin:String = "";

	var _loggedIn:Bool = false;

	var _sendID:String;

	var _lastReciever:String;

	public function new(m:Console) {
		this._callbacks = new ASObject();
		this._sendBuffer = new ByteArray();
		this._recBuffers = new ASObject();
		this._senders = new ASDictionary<ASAny, ASAny>();
		super(m);
		this.registerCallback("login", function(bytes:ByteArray) {
			login(bytes.readUTF());
		});
		this.registerCallback("requestLogin", this.requestLogin);
		this.registerCallback("loginFail", this.loginFail);
		this.registerCallback("loginSuccess", this.loginSuccess);
	}

	public function update() {
		var _loc1_:String = null;
		var _loc2_:ByteArray = null;
		var _loc3_:String = null;
		var _loc4_:ByteArray = null;
		if (this._sendBuffer.length != 0) {
			if (this._socket != null && this._socket.connected) {
				this._socket.writeBytes(this._sendBuffer);
				this._sendBuffer = new ByteArray();
			} else if (this._local != null) {
				this._sendBuffer.position = (0 : UInt);
				if (this._sendBuffer.bytesAvailable < 38000) {
					_loc2_ = this._sendBuffer;
					this._sendBuffer = new ByteArray();
				} else {
					_loc2_ = new ByteArray();
					this._sendBuffer.readBytes(_loc2_, (0 : UInt), (Std.int(Math.min(38000, this._sendBuffer.bytesAvailable)) : UInt));
					_loc4_ = new ByteArray();
					this._sendBuffer.readBytes(_loc4_);
					this._sendBuffer = _loc4_;
				}
				_loc3_ = config.remotingConnectionName + (this.remoting == Remoting.RECIEVER ? SENDER : RECIEVER);
				this._local.send(_loc3_, "synchronize", this._sendID, _loc2_);
			} else {
				this._sendBuffer = new ByteArray();
			}
		}
		final __ax4_iter_117:ASObject = this._recBuffers;
		if (checkNullIteratee(__ax4_iter_117))
			for (_tmp_ in __ax4_iter_117.___keys()) {
				_loc1_ = _tmp_;
				this.processRecBuffer(_loc1_);
			}
	}

	function processRecBuffer(id:String) {
		var buffer:ByteArray;
		var pointer = (0 : UInt);
		var cmd:String = null;
		var arg:ByteArray = null;
		var callbackData:ASObject = null;
		var blen = (0 : UInt);
		var recbuffer:ByteArray = null;
		if (!ASCompat.toBool(this._senders[id])) {
			this._senders[id] = true;
			if (ASCompat.stringAsBool(this._lastReciever)) {
				report("Remote switched to new sender [" + id + "] as primary.", -2);
			}
			this._lastReciever = id;
		}
		buffer = ASCompat.asByteArray(this._recBuffers[id]);
		try {
			pointer = buffer.position = (0 : UInt);
			while (buffer.bytesAvailable != 0) {
				cmd = buffer.readUTF();
				arg = null;
				if (buffer.bytesAvailable == 0) {
					break;
				}
				if (buffer.readBoolean()) {
					if (buffer.bytesAvailable == 0) {
						break;
					}
					blen = buffer.readUnsignedInt();
					if (buffer.bytesAvailable < blen) {
						break;
					}
					arg = new ByteArray();
					buffer.readBytes(arg, (0 : UInt), blen);
				}
				callbackData = this._callbacks[cmd];
				if (!ASCompat.toBool(callbackData.latest) || id == this._lastReciever) {
					if (arg != null) {
						callbackData.fun(arg);
					} else {
						callbackData.fun();
					}
				}
				pointer = buffer.position;
			}
			if (pointer < buffer.length) {
				recbuffer = new ByteArray();
				recbuffer.writeBytes(buffer, pointer);
				this._recBuffers[id] = buffer = recbuffer;
			} else {
				ASCompat.deleteProperty(this._recBuffers, id);
			}
		} catch (err:Dynamic) {
			report("Remoting sync error: " + err, 9);
		}
	}

	function synchronize(id:String, obj:ASObject) {
		if (!ASCompat.isByteArray(obj)) {
			report("Remoting sync error. Recieved non-ByteArray:" + Std.string(obj), 9);
			return;
		}
		var _loc3_ = (obj : ByteArray);
		var _loc4_ = ASCompat.asByteArray(this._recBuffers[id]);
		if (_loc4_ != null) {
			_loc4_.position = _loc4_.length;
			_loc4_.writeBytes(_loc3_);
		} else {
			this._recBuffers[id] = _loc3_;
		}
	}

	public function send(command:String, arg:ByteArray = null):Bool {
		if (this._mode == NONE) {
			return false;
		}
		this._sendBuffer.position = this._sendBuffer.length;
		this._sendBuffer.writeUTF(command);
		if (arg != null) {
			this._sendBuffer.writeBoolean(true);
			this._sendBuffer.writeUnsignedInt(arg.length);
			this._sendBuffer.writeBytes(arg);
		} else {
			this._sendBuffer.writeBoolean(false);
		}
		return true;
	}

	@:isVar public var remoting(get, set):UInt;

	public function get_remoting():UInt {
		return this._mode;
	}

	@:isVar public var canSend(get, never):Bool;

	public function get_canSend():Bool {
		return this._mode == SENDER && this._loggedIn;
	}

	function set_remoting(newMode:UInt):UInt {
		var _loc2_:String = null;
		if (newMode == this._mode) {
			return newMode;
		}
		this._sendID = this.generateId();
		if (newMode == SENDER) {
			if (!this.startSharedConnection(SENDER)) {
				report("Could not create remoting client service. You will not be able to control this console with remote.", 10);
			}
			this._sendBuffer = new ByteArray();
			this._local.addEventListener(StatusEvent.STATUS, this.onSenderStatus, false, 0, true);
			report("<b>Remoting started.</b> " + this.getInfo(), -1);
			this._loggedIn = this.checkLogin("");
			if (this._loggedIn) {
				this.sendLoginSuccess();
			} else {
				this.send("requestLogin");
			}
		} else if (newMode == RECIEVER) {
			if (this.startSharedConnection(RECIEVER)) {
				this._sendBuffer = new ByteArray();
				this._local.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.onRemoteAsyncError, false, 0, true);
				this._local.addEventListener(StatusEvent.STATUS, this.onRecieverStatus, false, 0, true);
				report("<b>Remote started.</b> " + this.getInfo(), -1);
				_loc2_ = Security.sandboxType;
				if (_loc2_ == Security.LOCAL_WITH_FILE || _loc2_ == Security.LOCAL_WITH_NETWORK) {
					report("Untrusted local sandbox. You may not be able to listen for logs properly.", 10);
					this.printHowToGlobalSetting();
				}
				this.login(this._lastLogin);
			} else {
				report("Could not create remote service. You might have a console remote already running.", 10);
			}
		} else {
			this.close();
		}
		console.panels.updateMenu();
		return newMode;
	}

	public function remotingSocket(host:String, port:Int = 0) {
		if (this._socket != null && this._socket.connected) {
			this._socket.close();
			this._socket = null;
		}
		if (ASCompat.stringAsBool(host) && port != 0) {
			this.remoting = SENDER;
			report("Connecting to socket " + host + ":" + port);
			this._socket = new Socket();
			this._socket.addEventListener(Event.CLOSE, this.socketCloseHandler);
			this._socket.addEventListener(Event.CONNECT, this.socketConnectHandler);
			this._socket.addEventListener(IOErrorEvent.IO_ERROR, this.socketIOErrorHandler);
			this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.socketSecurityErrorHandler);
			this._socket.addEventListener(ProgressEvent.SOCKET_DATA, this.socketDataHandler);
			this._socket.connect(host, port);
		}
	}

	function socketCloseHandler(e:Event) {
		if (e.currentTarget == this._socket) {
			this._socket = null;
		}
	}

	function socketConnectHandler(e:Event) {
		report("Remoting socket connected.", -1);
		this._sendBuffer = new ByteArray();
		if (this._loggedIn || this.checkLogin("")) {
			this.sendLoginSuccess();
		} else {
			this.send("requestLogin");
		}
	}

	function socketIOErrorHandler(e:Event) {
		report("Remoting socket error." + e, 9);
		this.remotingSocket(null);
	}

	function socketSecurityErrorHandler(e:Event) {
		report("Remoting security error." + e, 9);
		this.remotingSocket(null);
	}

	function socketDataHandler(e:Event) {
		this.handleSocket(ASCompat.dynamicAs(e.currentTarget, Socket));
	}

	public function handleSocket(socket:Socket) {
		if (!ASCompat.toBool(this._senders[socket])) {
			this._senders[socket] = this.generateId();
			this._socket = socket;
		}
		var _loc2_ = new ByteArray();
		socket.readBytes(_loc2_);
		this.synchronize(this._senders[socket], _loc2_);
	}

	function onSenderStatus(e:StatusEvent) {
		if (e.level == "error" && !(this._socket != null && this._socket.connected)) {
			this._loggedIn = false;
		}
	}

	function onRecieverStatus(e:StatusEvent) {
		if (this.remoting == Remoting.RECIEVER && e.level == "error") {
			report("Problem communicating to client.", 10);
		}
	}

	function onRemotingSecurityError(e:SecurityErrorEvent) {
		report("Remoting security error.", 9);
		this.printHowToGlobalSetting();
	}

	function onRemoteAsyncError(e:AsyncErrorEvent) {
		report("Problem with remote sync. [<a href=\'event:remote\'>Click here</a>] to restart.", 10);
		this.remoting = NONE;
	}

	function getInfo():String {
		return "<p4>channel:" + config.remotingConnectionName + " (" + Security.sandboxType + ")</p4>";
	}

	function printHowToGlobalSetting() {
		report("Make sure your flash file is \'trusted\' in Global Security Settings.", -2);
		report("Go to Settings Manager [<a href=\'event:settings\'>click here</a>] &gt; \'Global Security Settings Panel\' (on left) &gt; add the location of the local flash (swf) file.",
			-2);
	}

	function generateId():String {
		return Date.now().getTime() + "." + Math.ffloor(Math.random() * 100000);
	}

	function startSharedConnection(targetmode:UInt):Bool {
		this.close();
		this._mode = targetmode;
		this._local = new LocalConnection();
		this._local.client = {"synchronize": this.synchronize};
		if (ASCompat.stringAsBool(config.allowedRemoteDomain)) {
			this._local.allowDomain(config.allowedRemoteDomain);
			this._local.allowInsecureDomain(config.allowedRemoteDomain);
		}
		this._local.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onRemotingSecurityError, false, 0, true);
		try {
			this._local.connect(config.remotingConnectionName + this._mode);
		} catch (err:Dynamic) {
			return false;
		}
		return true;
	}

	public function registerCallback(key:String, fun:ASFunction, latestOnly:Bool = false) {
		this._callbacks[key] = {
			"fun": fun,
			"latest": latestOnly
		};
	}

	function loginFail() {
		if (this.remoting != Remoting.RECIEVER) {
			return;
		}
		report("Login Failed", 10);
		console.panels.mainPanel.requestLogin();
	}

	function sendLoginSuccess() {
		this._loggedIn = true;
		this.send("loginSuccess");
		dispatchEvent(new Event(Event.CONNECT));
	}

	function loginSuccess() {
		console.setViewingChannels();
		report("Login Successful", -1);
	}

	function requestLogin() {
		if (this.remoting != Remoting.RECIEVER) {
			return;
		}
		this._sendBuffer = new ByteArray();
		if (ASCompat.stringAsBool(this._lastLogin)) {
			this.login(this._lastLogin);
		} else {
			console.panels.mainPanel.requestLogin();
		}
	}

	public function login(pass:String = "") {
		var _loc2_:ByteArray = null;
		if (this.remoting == Remoting.RECIEVER) {
			this._lastLogin = pass;
			report("Attempting to login...", -1);
			_loc2_ = new ByteArray();
			_loc2_.writeUTF(pass);
			this.send("login", _loc2_);
		} else if (this._loggedIn || this.checkLogin(pass)) {
			this.sendLoginSuccess();
		} else {
			this.send("loginFail");
		}
	}

	function checkLogin(pass:String):Bool {
		return config.remotingPassword == null && config.keystrokePassword == pass || config.remotingPassword == "" || config.remotingPassword == pass;
	}

	public function close() {
		if (this._local != null) {
			try {
				this._local.close();
			} catch (error:Dynamic) {
				report("Remote.close: " + error, 10);
			}
		}
		this._mode = NONE;
		this._sendBuffer = new ByteArray();
		this._local = null;
	}
}
