package networkCode.transport;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.net.SecureSocket;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.utils.ByteArray;
import flash.utils.Timer;

class TlsSocketTransport extends EventDispatcher implements IGameTransport {
	static inline final MAX_WORKERS = 4;

	static var liveWorkers:Int = 0;

	static var reaper:Timer;

	static final WorkerBytes:Dynamic = TlsSocketWorker_swf;

	static final workers:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mHost:String;

	var mPort:Int = 0;

	var mEnforceServerCertificate:Bool = false;

	var mWorker:Worker;

	var mCommands:MessageChannel;

	var mReplies:MessageChannel;

	var mConnected:Bool = false;

	var mFinished:Bool = false;

	var mDrainingReplies:Bool = false;

	public function new(host:String, port:Int, enforceServerCertificate:Bool) {
		super();
		mHost = host;
		mPort = port;
		mEnforceServerCertificate = enforceServerCertificate;
	}

	static function reapWorkers(event:TimerEvent = null) {
		var _loc3_:Worker = null;
		var _loc2_:TlsSocketTransport = null;
		var _loc4_:ASObject;
		final __ax4_iter_81 = workers;
		if (checkNullIteratee(__ax4_iter_81))
			for (_tmp_ in __ax4_iter_81.keys()) {
				_loc4_ = _tmp_;
				_loc3_ = ASCompat.dynamicAs(_loc4_, Worker);
				if (_loc3_.state == "terminated") {
					_loc2_ = ASCompat.dynamicAs(workers[_loc3_], TlsSocketTransport);
					if (_loc2_ != null) {
						_loc2_.onWorkerState(null);
					}
					if (_loc2_ == null || _loc2_.mFinished) {
						releaseWorker(_loc3_);
					}
				}
			}
	}

	static function releaseWorker(worker:Worker) {
		if (ASCompat.toBool(workers[worker])) {
			workers.remove(worker);
			liveWorkers = liveWorkers - 1;
		}
		if (liveWorkers == 0 && reaper != null) {
			reaper.stop();
		}
		var _loc3_ = ASCompat.dynamicAs(worker.getSharedProperty("commands"), MessageChannel);
		var _loc2_ = ASCompat.dynamicAs(worker.getSharedProperty("replies"), MessageChannel);
		if (_loc3_ != null) {
			_loc3_.close();
		}
		if (_loc2_ != null) {
			_loc2_.close();
		}
		worker.setSharedProperty("commands", null);
		worker.setSharedProperty("replies", null);
		worker.setSharedProperty("config", null);
	}

	static function element(reply:Array<ASAny>, index:Int):String {
		return reply.length > index && reply[index] != null ? ASCompat.toString(reply[index]) : "";
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return "tlsSocket " + mHost + ":" + mPort;
	}

	@:isVar public var connected(get, never):Bool;

	public function get_connected():Bool {
		return mConnected && !mFinished;
	}

	@:isVar public var supportsSessions(get, never):Bool;

	public function get_supportsSessions():Bool {
		return false;
	}

	public function sendText(text:String) {
		throw new Error("TlsSocketTransport carries no text frames; it cannot resume a session.");
	}

	public function connect() {
		var _loc1_:Worker = null;
		if (mWorker != null || mFinished) {
			return;
		}
		if (!SecureSocket.isSupported || !Worker.isSupported) {
			fail((603 : UInt), "Secure connections are not supported by this runtime.");
			return;
		}
		reapWorkers();
		if (liveWorkers >= 4) {
			fail((602 : UInt), "Previous connections are still closing; please retry shortly.");
			return;
		}
		try {
			mWorker = createWorker();
			mCommands = Worker.current.createMessageChannel(mWorker);
			mReplies = mWorker.createMessageChannel(Worker.current);
			mWorker.setSharedProperty("commands", mCommands);
			mWorker.setSharedProperty("replies", mReplies);
			mWorker.setSharedProperty("config", {
				"host": mHost,
				"port": mPort,
				"enforceCertificate": mEnforceServerCertificate,
				"timeout": TransportSettings.connectTimeoutMilliseconds
			});
			mReplies.addEventListener("channelMessage", onReply);
			mWorker.addEventListener("workerState", onWorkerState);
			workers[mWorker] = this;
			liveWorkers = liveWorkers + 1;
			if (reaper == null) {
				reaper = new Timer(100);
				reaper.addEventListener("timer", reapWorkers);
			}
			reaper.start();
			mWorker.start();
		} catch (error:Dynamic) {
			_loc1_ = mWorker;
			fail((602 : UInt), error.message);
			if (_loc1_ != null) {
				_loc1_.terminate();
				releaseWorker(_loc1_);
			}
		}
	}

	public function send(bytes:ByteArray) {
		if (!connected || bytes == null || bytes.length == 0) {
			return;
		}
		try {
			mCommands.send((["send", bytes] : Array<ASAny>));
		} catch (error:Dynamic) {
			fail((602 : UInt), error.message);
		}
	}

	public function close() {
		if (mFinished) {
			return;
		}
		mFinished = true;
		mConnected = false;
		if (mReplies != null) {
			mReplies.removeEventListener("channelMessage", onReply);
		}
		if (mWorker != null) {
			mWorker.removeEventListener("workerState", onWorkerState);
			if (ASCompat.toBool(workers[mWorker])) {
				workers[mWorker] = true;
			}
			try {
				mCommands.send(["close"]);
			} catch (error:Dynamic) {
				mWorker.terminate();
			}
		}
		mWorker = null;
		mCommands = null;
		mReplies = null;
	}

	public function abandon() {
		close();
	}

	function createWorker():Worker {
		return WorkerDomain.current.createWorker((ASCompat.createInstance(WorkerBytes, []) : ByteArray), true);
	}

	function onReply(event:Event) {
		var _loc3_:Array<ASAny> = null;
		var _loc2_:ByteArray = null;
		if (mFinished || mDrainingReplies) {
			return;
		}
		mDrainingReplies = true;
		{
			try {
				while (!mFinished && mReplies.messageAvailable) {
					_loc3_ = ASCompat.dynamicAs(mReplies.receive(), Array);
					switch (_loc3_[0]) {
						case "connected":
							mConnected = true;
							dispatchEvent(GameTransportEvent.connectedEvent());

						case "data":
							_loc2_ = (_loc3_[1] : ByteArray);
							_loc2_.endian = "littleEndian";
							_loc2_.position = (0 : UInt);
							dispatchEvent(GameTransportEvent.dataEvent(_loc2_));

						case "failed":
							fail((ASCompat.toInt(_loc3_[1]) : UInt), _loc3_[2], element(_loc3_, 3), element(_loc3_, 4));

						case "closed":
							close();
							dispatchEvent(GameTransportEvent.closedEvent(0, "", "server"));
					}
				}
			} catch (__finallyError0:Dynamic) {
				{
					mDrainingReplies = false;
				};
				throw __finallyError0;
			};
			{
				mDrainingReplies = false;
			};
		}
	}

	function onWorkerState(event:Event) {
		if (!mFinished && mWorker.state == "terminated") {
			onReply(null);
			if (!mFinished && !mDrainingReplies && !mReplies.messageAvailable) {
				fail((602 : UInt), "TLS worker stopped unexpectedly.");
			}
		}
	}

	function fail(code:UInt, text:String, certificateStatus:String = "", certificateDetail:String = "") {
		if (mFinished) {
			return;
		}
		close();
		dispatchEvent(GameTransportEvent.failedEvent(code, text, certificateStatus, certificateDetail));
	}
}
