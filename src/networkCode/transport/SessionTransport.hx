package networkCode.transport;

import brain.logger.Logger;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Timer;

class SessionTransport extends EventDispatcher implements IGameTransport {
	public static inline final STATE_IDLE = "idle";

	public static inline final STATE_HANDSHAKING = "handshaking";

	public static inline final STATE_OPEN = "open";

	public static inline final STATE_WAITING = "waiting";

	public static inline final STATE_RESUMING = "resuming";

	public static inline final STATE_FINISHED = "finished";

	public static inline final REPLAY_BUFFER_FULL = "client replay buffer full";

	public static inline final BAD_CONTROL_MESSAGE = "bad control message from the bridge";

	static inline final DROP_KIND_SOCKET = "socket";

	static inline final DROP_KIND_SILENCE = "silence";

	static inline final FINAL_ATTEMPT_SPREAD:Float = 0.05;

	static inline final MAX_DEAD_END_ATTEMPTS = 3;

	static inline final DEAD_END_FLOOR_MILLISECONDS = 10000;

	static inline final SILENCE_TICK_MILLISECONDS = 1000;

	static final BACKOFF_MILLISECONDS:Array<ASAny> = [1000, 2000, 4000, 8000, 10000];

	static final JITTER_FRACTIONS:Array<ASAny> = [0, 0, 0.1, 0.25, 0.25];

	var mBaseUrl:String;

	var mInnerFactory:ASFunction;

	var mInnerName:String;

	var mInner:IGameTransport;

	var mState:String = "idle";

	var mToken:String;

	var mPod:Int = 0;

	var mBridgeGraceMilliseconds:Float = 0;

	var mReceivedBytes:Float = 0;

	var mAckedBytes:Float = 0;

	var mLastInboundMilliseconds:Int = 0;

	var mReplay:SessionReplayBuffer;

	var mAckTimer:Timer;

	var mSilenceTimer:Timer;

	var mAttemptTimer:Timer;

	var mBackoffTimer:Timer;

	var mInsideConnect:Bool = false;

	var mSuppressed:Bool = false;

	var mDropAtMilliseconds:Int = 0;

	var mDropKind:String;

	var mResumeAttempts:Int = 0;

	var mDeadEndAttempts:Int = 0;

	var mFinalAttemptScheduled:Bool = false;

	var mReconnectStartedAtMilliseconds:Int = 0;

	var mAttemptConnected:Bool = false;

	var mLastCode:Int = 0;

	var mLastReason:String = "";

	var mGoneReason:String;

	var mCredentialSource:ASFunction;

	var mWarnedAboutCredential:Bool = false;

	public function new(baseUrl:String, innerFactory:ASFunction, firstInner:IGameTransport, credentialSource:ASFunction = null) {
		super();
		mBaseUrl = baseUrl;
		mCredentialSource = credentialSource;
		mInnerFactory = innerFactory;
		mInner = firstInner;
		mInnerName = firstInner != null ? firstInner.name : baseUrl;
		mReplay = new SessionReplayBuffer();
	}

	public static function resumeUrlFor(baseUrl:String, pod:Int):String {
		var _loc3_ = baseUrl;
		while (_loc3_.length > 0 && _loc3_.charAt(_loc3_.length - 1) == "/") {
			_loc3_ = _loc3_.substr(0, _loc3_.length - 1);
		}
		return _loc3_ + "/" + pod;
	}

	static function shorten(text:String):String {
		if (text == null) {
			return "null";
		}
		return text.length <= 200 ? text : text.substr(0, 200) + "... (" + text.length + " chars)";
	}

	static function restart(timer:Timer, delay:Float, repeatCount:Int, handler:ASFunction):Timer {
		if (timer == null) {
			timer = new Timer(delay, repeatCount);
			timer.addEventListener("timer", handler);
		}
		timer.reset();
		timer.delay = delay;
		timer.start();
		return timer;
	}

	static function stopIfAny(timer:Timer) {
		if (timer != null) {
			timer.stop();
		}
	}

	public static function backoffMilliseconds(attempt:Int):Int {
		var _loc3_ = attempt - 1;
		if (_loc3_ < 0) {
			_loc3_ = 0;
		}
		if (_loc3_ >= BACKOFF_MILLISECONDS.length) {
			_loc3_ = BACKOFF_MILLISECONDS.length - 1;
		}
		var _loc2_ = ASCompat.toNumber(BACKOFF_MILLISECONDS[_loc3_]);
		_loc2_ += _loc2_ * ASCompat.toNumber(JITTER_FRACTIONS[_loc3_]) * Math.random();
		return ASCompat.floatToInt(_loc2_);
	}

	public static function finalAttemptMilliseconds(remaining:Int, grace:Int):Int {
		var _loc3_ = remaining - grace * 0.05 * Math.random();
		return _loc3_ < 0 ? 0 : ASCompat.floatToInt(_loc3_);
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return mInnerName + " (session)";
	}

	@:isVar public var connected(get, never):Bool;

	public function get_connected():Bool {
		return mState == "open" || mState == "waiting" || mState == "resuming";
	}

	@:isVar public var supportsSessions(get, never):Bool;

	public function get_supportsSessions():Bool {
		return true;
	}

	@:isVar public var resumeEnabled(get, never):Bool;

	public function get_resumeEnabled():Bool {
		return mInnerFactory != null;
	}

	@:isVar public var state(get, never):String;

	public function get_state():String {
		return mState;
	}

	@:isVar public var sessionToken(get, never):String;

	public function get_sessionToken():String {
		return mToken;
	}

	@:isVar public var podOrdinal(get, never):Int;

	public function get_podOrdinal():Int {
		return mPod;
	}

	@:isVar public var receivedBytes(get, never):Float;

	public function get_receivedBytes():Float {
		return mReceivedBytes;
	}

	@:isVar public var sentBytes(get, never):Float;

	public function get_sentBytes():Float {
		return mReplay.sentBytes;
	}

	@:isVar public var unacknowledgedBytes(get, never):Float;

	public function get_unacknowledgedBytes():Float {
		return mReplay.unacknowledgedBytes;
	}

	@:isVar public var resumeAttempts(get, never):Int;

	public function get_resumeAttempts():Int {
		return mResumeAttempts;
	}

	@:isVar public var helloMessage(get, never):String;

	public function get_helloMessage():String {
		return SessionProtocol.helloMessageFor(currentCredential());
	}

	public function connect() {
		if (mState != "idle") {
			return;
		}
		if (mInner == null) {
			finishWithFailure((602 : UInt), "No transport to open the session on.");
			return;
		}
		mState = "handshaking";
		attachInner(mInner);
		mInsideConnect = true;
		{
			try {
				try {
					mInner.connect();
				} catch (error:Dynamic) {
					finishWithFailure((602 : UInt), error.message);
					{
						{
							mInsideConnect = false;
						};
						return;
					};
				};
			} catch (__finallyError1:Dynamic) {
				{
					mInsideConnect = false;
				};
				throw __finallyError1;
			};
			{
				mInsideConnect = false;
			};
		}
		if (mState == "handshaking") {
			armAttemptWatchdog();
		}
	}

	function attachInner(transport:IGameTransport) {
		mInner = transport;
		mInner.addEventListener("gameTransportConnected", onInnerConnected);
		mInner.addEventListener("gameTransportData", onInnerData);
		mInner.addEventListener("gameTransportText", onInnerText);
		mInner.addEventListener("gameTransportClosed", onInnerClosed);
		mInner.addEventListener("gameTransportFailed", onInnerFailed);
	}

	function detachInner(cleanly:Bool) {
		if (mInner == null) {
			return;
		}
		var _loc2_ = mInner;
		mInner = null;
		_loc2_.removeEventListener("gameTransportConnected", onInnerConnected);
		_loc2_.removeEventListener("gameTransportData", onInnerData);
		_loc2_.removeEventListener("gameTransportText", onInnerText);
		_loc2_.removeEventListener("gameTransportClosed", onInnerClosed);
		_loc2_.removeEventListener("gameTransportFailed", onInnerFailed);
		try {
			if (cleanly) {
				_loc2_.close();
			} else {
				_loc2_.abandon();
			}
		} catch (error:Dynamic) {}
	}

	function onInnerConnected(event:GameTransportEvent) {
		markInbound();
		var _loc2_ = currentCredential();
		warnAboutOmittedCredentialFields(_loc2_);
		if (mState == "handshaking") {
			sendControl(SessionProtocol.helloMessageFor(_loc2_));
			return;
		}
		if (mState == "resuming") {
			mAttemptConnected = true;
			sendControl(SessionProtocol.resumeMessageFor(mToken, mReceivedBytes, mDropKind, _loc2_));
		}
	}

	function onHello(message:ASObject) {
		if (mState != "handshaking") {
			Logger.warnch("WS", "SessionTransport got a hello reply in state " + mState);
			return;
		}
		var _loc3_ = message.session == null ? "" : ASCompat.toString(message.session);
		if (!SessionProtocol.isPlausibleToken(_loc3_)) {
			rejectControl("implausible session token");
			return;
		}
		var _loc2_ = ASCompat.toNumber(message.pod);
		if (!SessionProtocol.isPlausiblePod(_loc2_)) {
			rejectControl("pod ordinal " + _loc2_);
			return;
		}
		mToken = _loc3_;
		mPod = ASCompat.floatToInt(_loc2_);
		var _loc4_ = ASCompat.toNumber(message.grace_ms);
		mBridgeGraceMilliseconds = SessionProtocol.isWholeCount(_loc4_) && _loc4_ > 0 ? _loc4_ : 0;
		cancelAttemptWatchdog();
		mState = "open";
		startSessionTimers();
		Logger.infoch("WS",
			"SessionTransport opened session "
			+ shortToken()
			+ " on pod "
			+ mPod
			+ " (grace "
			+ _loc4_
			+ "ms advertised, "
			+ graceMilliseconds
			+ "ms in force, bridge buffer "
			+ ASCompat.toNumber(message.buffer)
			+ " bytes)");
		raise(GameTransportEvent.connectedEvent());
		if (mInsideConnect) {
			ASCompat.setTimeout(flushOutbound, 0);
			return;
		}
		flushOutbound();
	}

	function currentCredential():SessionCredential {
		if (mCredentialSource == null) {
			return null;
		}
		try {
			return ASCompat.dynamicAs(mCredentialSource(), SessionCredential);
		} catch (error:Dynamic) {
			warnOnceAboutCredential("SessionTransport could not read its credential: " + Std.string(error.message) + "; sending none.");
		}
		return null;
	}

	function warnAboutOmittedCredentialFields(credential:SessionCredential) {
		if (credential == null || credential.omittedFields == "") {
			return;
		}
		warnOnceAboutCredential("SessionTransport is sending no "
			+ credential.omittedFields
			+ " in its session control messages; the bridge may refuse the connection.");
	}

	function warnOnceAboutCredential(text:String) {
		if (mWarnedAboutCredential) {
			return;
		}
		mWarnedAboutCredential = true;
		Logger.warnch("WS", text);
	}

	public function send(bytes:ByteArray) {
		if (mState == "finished" || bytes == null || bytes.length == 0) {
			return;
		}
		if (!mReplay.append(bytes)) {
			Logger.warnch("WS",
				"SessionTransport client replay buffer full: "
				+ mReplay.unacknowledgedBytes
				+ " bytes unacknowledged, cap "
				+ TransportSettings.sessionOutboundBufferBytes);
			finishWithClose(0, "client replay buffer full", "client");
			return;
		}
		flushOutbound();
	}

	public function sendText(text:String) {
		throw new Error("SessionTransport owns the text channel; nothing above it may send control messages.");
	}

	function onInnerData(event:GameTransportEvent) {
		if (mState != "open") {
			rejectControl("data before the handshake completed");
			return;
		}
		if (event.bytes == null || event.bytes.length == 0) {
			return;
		}
		markInbound();
		mReceivedBytes += event.bytes.length;
		dispatchEvent(GameTransportEvent.dataEvent(event.bytes));
		maybeSendAck(false);
	}

	function onInnerText(event:GameTransportEvent) {
		markInbound();
		var _loc2_:ASObject = SessionProtocol.parseControl(event.text);
		if (_loc2_ == null) {
			Logger.warnch("WS", "SessionTransport ignoring an unreadable control message: " + shorten(event.text));
			return;
		}
		switch (ASCompat.toString(_loc2_.t)) {
			case "hello":
				onHello(_loc2_);

			case "resumed":
				onResumed(_loc2_);

			case "gone":
				onGone(_loc2_);

			case "ack":
				onAck(_loc2_);

			default:
				Logger.debugch("WS", "SessionTransport ignoring control message " + shorten(event.text));
		}
	}

	function onAck(message:ASObject) {
		var _loc2_ = ASCompat.toNumber(message.recv);
		if (!SessionProtocol.isWholeCount(_loc2_) || _loc2_ > mReplay.handedBytes) {
			rejectControl("ack " + _loc2_ + " above the " + mReplay.handedBytes + " bytes handed to a socket");
			return;
		}
		mReplay.discardAcknowledged(_loc2_);
	}

	function rejectControl(detail:String) {
		finishWithClose(0, "bad control message from the bridge: " + detail, "server");
	}

	function sendControl(text:String):Bool {
		var _loc5_:Bool;
		if (mInner == null || !mInner.connected) {
			return false;
		}
		var _loc2_ = mInner;
		try {
			_loc2_.sendText(text);
			return mInner == _loc2_ && _loc2_.connected;
		} catch (error:Dynamic) {
			Logger.warnch("WS", "SessionTransport could not send a control message: " + Std.string(error.message));
			_loc5_ = false;
		}
		return _loc5_;
	}

	function shortToken():String {
		return mToken == null ? "none" : mToken.substr(0, 8);
	}

	function flushOutbound() {
		var _loc1_:ByteArray = null;
		while (mState == "open" && mInner != null && mInner.connected && mReplay.hasPending) {
			_loc1_ = mReplay.nextChunk();
			if (_loc1_ == null) {
				Logger.error("SessionTransport cannot make progress flushing at " + mReplay.forwardedBytes + " of " + sentBytes
					+ "; ending the session rather than looping.");
				finishWithClose(0, "client replay buffer full", "client");
				return;
			}
			mInner.send(_loc1_);
		}
	}

	function maybeSendAck(force:Bool) {
		if (mState != "open" || mInner == null || !mInner.connected) {
			return;
		}
		if (mReceivedBytes <= mAckedBytes) {
			return;
		}
		if (!force && mReceivedBytes - mAckedBytes < TransportSettings.sessionAckEveryBytes) {
			return;
		}
		var _loc2_ = mReceivedBytes;
		if (sendControl(SessionProtocol.ackMessage(_loc2_))) {
			mAckedBytes = Math.max(mAckedBytes, _loc2_);
		}
	}

	function startSessionTimers() {
		markInbound();
		var _loc1_ = ASCompat.floatToInt(Math.max(100, ASCompat.floatToInt(TransportSettings.sessionAckEverySeconds * 1000)));
		mAckTimer = restart(mAckTimer, _loc1_, 0, onAckTimer);
		mSilenceTimer = restart(mSilenceTimer, 1000, 0, onSilenceTimer);
	}

	function stopSessionTimers() {
		stopIfAny(mAckTimer);
		stopIfAny(mSilenceTimer);
	}

	function onAckTimer(event:TimerEvent) {
		maybeSendAck(true);
	}

	function onSilenceTimer(event:TimerEvent) {
		if (mState != "open") {
			return;
		}
		var _loc2_ = flash.Lib.getTimer() - mLastInboundMilliseconds;
		if (_loc2_ < ASCompat.floatToInt(TransportSettings.dropDetectSeconds * 1000)) {
			return;
		}
		var _loc3_ = "no data from the bridge for " + _loc2_ + "ms";
		if (mInnerFactory == null) {
			finishWithClose(0, _loc3_, "server");
			return;
		}
		beginReconnect(0, _loc3_, "silence");
	}

	function markInbound() {
		mLastInboundMilliseconds = flash.Lib.getTimer();
	}

	function onInnerClosed(event:GameTransportEvent) {
		if (mState == "finished") {
			return;
		}
		endOfSocket(event.code, event.reason, GameTransportEvent.closedEvent(event.code, event.reason, event.initiator));
	}

	function onInnerFailed(event:GameTransportEvent) {
		if (mState == "finished") {
			return;
		}
		endOfSocket(0, event.text, GameTransportEvent.failedEvent(event.errorCode, event.text, event.certificateStatus, event.certificateDetail));
	}

	function endOfSocket(code:Int, reason:String, passUp:GameTransportEvent) {
		if (mState == "resuming") {
			attemptFailed(code, reason);
			return;
		}
		if (mInnerFactory == null
			|| mToken == null
			|| mState == "handshaking"
			|| code == 1000
			|| SessionProtocol.isUnrecoverable(code)) {
			if (SessionProtocol.isUnrecoverable(code)) {
				if (reason == null || reason == "") {
					passUp = GameTransportEvent.closedEvent(code, SessionProtocol.closeReasonFor(code), passUp.initiator);
				}
				passUp.terminal = true;
			}
			finishWith(passUp);
			return;
		}
		beginReconnect(code, reason, "socket");
	}

	@:isVar var reconnectInProgress(get, never):Bool;

	function get_reconnectInProgress():Bool {
		return mState == "waiting" || mState == "resuming";
	}

	function beginReconnect(code:Int, reason:String, kind:String) {
		stopSessionTimers();
		detachInner(false);
		mDropAtMilliseconds = mLastInboundMilliseconds;
		mReconnectStartedAtMilliseconds = flash.Lib.getTimer();
		mResumeAttempts = 0;
		mDeadEndAttempts = 0;
		mFinalAttemptScheduled = false;
		mDropKind = kind;
		mLastCode = code;
		mLastReason = reason == null ? "" : reason;
		mState = "waiting";
		Logger.warnch("WS", "SessionTransport lost the socket under session "
			+ shortToken()
			+ " (code "
			+ code
			+ " \""
			+ mLastReason
			+ "\"); resuming");
		raise(GameTransportEvent.reconnectingEvent(code, mLastReason, 0));
		if (mState != "waiting") {
			return;
		}
		startResumeAttempt();
	}

	function startResumeAttempt() {
		var _loc1_:IGameTransport = null;
		if (mState != "waiting") {
			return;
		}
		if (elapsedSinceDrop() >= graceMilliseconds) {
			giveUp();
			return;
		}
		mResumeAttempts = mResumeAttempts + 1;
		mState = "resuming";
		mGoneReason = null;
		mAttemptConnected = false;
		raise(GameTransportEvent.reconnectAttemptEvent(mResumeAttempts, elapsedSinceDrop(), graceMilliseconds));
		if (mState != "resuming") {
			return;
		}
		var _loc2_ = resumeUrlFor(mBaseUrl, mPod);
		try {
			_loc1_ = ASCompat.dynamicAs(mInnerFactory(_loc2_), IGameTransport);
		} catch (factoryError:Dynamic) {
			attemptFailed(0, "could not build a transport for " + _loc2_ + ": " + Std.string(factoryError.message));
			return;
		}
		if (_loc1_ == null) {
			attemptFailed(0, "no transport for " + _loc2_);
			return;
		}
		attachInner(_loc1_);
		armAttemptWatchdog();
		try {
			_loc1_.connect();
		} catch (connectError:Dynamic) {
			attemptFailed(0, connectError.message);
		}
	}

	function attemptFailed(code:Int, reason:String) {
		if (mState != "resuming") {
			return;
		}
		if (code != 0) {
			mLastCode = code;
		}
		if (mGoneReason != null) {
			mLastReason = mGoneReason;
			mGoneReason = null;
		} else if (reason != null && reason != "") {
			mLastReason = reason;
		} else if (SessionProtocol.isUnrecoverable(code)) {
			mLastReason = SessionProtocol.closeReasonFor(code);
		}
		cancelAttemptWatchdog();
		detachInner(false);
		mState = "waiting";
		if (SessionProtocol.isUnrecoverable(code)) {
			sessionIsGone();
			return;
		}
		if (code == 4004 || !mAttemptConnected) {
			mDeadEndAttempts = mDeadEndAttempts + 1;
		}
		var _loc3_ = elapsedSinceDrop();
		var _loc5_ = graceMilliseconds;
		if (_loc3_ >= _loc5_) {
			giveUp();
			return;
		}
		if (mDeadEndAttempts >= 3 && elapsedSinceReconnectBegan() >= 10000) {
			giveUp();
			return;
		}
		if (mFinalAttemptScheduled) {
			giveUp();
			return;
		}
		var _loc4_ = backoffMilliseconds(mResumeAttempts);
		if (_loc3_ + _loc4_ > _loc5_) {
			_loc4_ = finalAttemptMilliseconds(_loc5_ - _loc3_, _loc5_);
			mFinalAttemptScheduled = true;
		}
		Logger.infoch("WS",
			"SessionTransport resume attempt "
			+ mResumeAttempts
			+ " failed ("
			+ mLastCode
			+ " \""
			+ mLastReason
			+ "\"); retrying in "
			+ _loc4_
			+ "ms");
		mBackoffTimer = restart(mBackoffTimer, _loc4_, 1, onBackoffElapsed);
	}

	function onBackoffElapsed(event:TimerEvent) {
		startResumeAttempt();
	}

	function armAttemptWatchdog() {
		var _loc1_:Int = TransportSettings.connectTimeoutMilliseconds;
		mAttemptTimer = restart(mAttemptTimer, _loc1_, 1, onAttemptWatchdog);
	}

	function cancelAttemptWatchdog() {
		stopIfAny(mAttemptTimer);
	}

	function onAttemptWatchdog(event:TimerEvent) {
		if (mState == "handshaking") {
			finishWithFailure((602 : UInt), "The session handshake at " + mBaseUrl + " went unanswered.");
			return;
		}
		if (mState == "resuming") {
			attemptFailed(0, "the resume went unanswered");
		}
	}

	function onResumed(message:ASObject) {
		if (mState != "resuming") {
			Logger.warnch("WS", "SessionTransport got a resumed reply in state " + mState);
			return;
		}
		var _loc3_ = ASCompat.toNumber(message.recv);
		if (!SessionProtocol.isWholeCount(_loc3_) || _loc3_ < mReplay.acknowledgedBytes || _loc3_ > mReplay.handedBytes) {
			rejectControl("resumed recv " + _loc3_ + " outside " + mReplay.acknowledgedBytes + ".." + mReplay.handedBytes);
			return;
		}
		cancelAttemptWatchdog();
		var _loc2_ = flash.Lib.getTimer() - mDropAtMilliseconds;
		var _loc4_ = sentBytes - _loc3_;
		mReplay.discardAcknowledged(_loc3_);
		mReplay.rewindTo(_loc3_);
		mAckedBytes = 0;
		mState = "open";
		startSessionTimers();
		Logger.infoch("WS",
			"SessionTransport resumed session "
			+ shortToken()
			+ " after "
			+ _loc2_
			+ "ms and "
			+ mResumeAttempts
			+ " attempt(s); replaying "
			+ _loc4_
			+ " bytes, received "
			+ mReceivedBytes);
		raise(GameTransportEvent.resumedEvent(mResumeAttempts, _loc2_));
		flushOutbound();
		maybeSendAck(true);
	}

	function onGone(message:ASObject) {
		var _loc2_ = message.reason == null ? "session gone" : ASCompat.toString(message.reason);
		Logger.warnch("WS", "SessionTransport session " + shortToken() + " is gone: " + _loc2_);
		if (mState != "resuming") {
			return;
		}
		mGoneReason = _loc2_;
	}

	function sessionIsGone() {
		Logger.warnch("WS",
			"SessionTransport session "
			+ shortToken()
			+ " cannot be resumed after "
			+ elapsedSinceDrop()
			+ "ms and "
			+ mResumeAttempts
			+ " attempt(s): "
			+ mLastCode
			+ " \""
			+ mLastReason
			+ "\"");
		finishWith(GameTransportEvent.closedEvent(mLastCode, mLastReason, "server"));
	}

	function giveUp() {
		Logger.warnch("WS",
			"SessionTransport gave up on session "
			+ shortToken()
			+ " after "
			+ elapsedSinceDrop()
			+ "ms and "
			+ mResumeAttempts
			+ " attempt(s): "
			+ mLastCode
			+ " \""
			+ mLastReason
			+ "\"");
		var _loc1_ = GameTransportEvent.closedEvent(mLastCode, mLastReason, "server");
		_loc1_.gaveUp = true;
		finishWith(_loc1_);
	}

	function elapsedSinceDrop():Int {
		return flash.Lib.getTimer() - mDropAtMilliseconds;
	}

	function elapsedSinceReconnectBegan():Int {
		return flash.Lib.getTimer() - mReconnectStartedAtMilliseconds;
	}

	@:isVar public var graceMilliseconds(get, never):Int;

	public function get_graceMilliseconds():Int {
		var _loc1_ = TransportSettings.reconnectGraceSeconds * 1000;
		if (mBridgeGraceMilliseconds > 0 && mBridgeGraceMilliseconds < _loc1_) {
			_loc1_ = mBridgeGraceMilliseconds;
		}
		return ASCompat.floatToInt(_loc1_);
	}

	public function close() {
		finish(true);
	}

	public function abandon() {
		finish(false);
	}

	function finish(cleanly:Bool) {
		mSuppressed = true;
		teardown(cleanly);
	}

	function teardown(cleanly:Bool) {
		mState = "finished";
		stopAllTimers();
		detachInner(cleanly);
		mReplay.clear();
	}

	function stopAllTimers() {
		stopSessionTimers();
		cancelAttemptWatchdog();
		stopIfAny(mBackoffTimer);
	}

	function finishWithFailure(errorCode:UInt, text:String) {
		finishWith(GameTransportEvent.failedEvent(errorCode, text));
	}

	function finishWithClose(code:Int, reason:String, initiator:String) {
		finishWith(GameTransportEvent.closedEvent(code, reason, initiator));
	}

	function finishWith(event:GameTransportEvent) {
		if (mState == "finished") {
			return;
		}
		if (reconnectInProgress) {
			event.attempts = mResumeAttempts;
			event.elapsedMilliseconds = elapsedSinceDrop();
		}
		teardown(true);
		raise(event);
	}

	function raise(event:GameTransportEvent, deferred:Bool = false) {
		if (mSuppressed) {
			return;
		}
		if (mInsideConnect && !deferred) {
			ASCompat.setTimeout(raise, 0, event, true);
			return;
		}
		dispatchEvent(event);
	}
}
