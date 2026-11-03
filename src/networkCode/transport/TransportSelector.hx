package networkCode.transport;

class TransportSelector {
	public static inline final KIND_TLS_SOCKET = "tlsSocket";

	public static inline final KIND_WSS = "wss";

	var mEndpoints:GameEndpoints;

	var mExperimentalWebSocketReconnects:Bool = false;

	var mCandidates:Vector<TransportCandidate>;

	var mCredentialSource:ASFunction;

	public function new(endpoints:GameEndpoints, experimentalWebSocketReconnects:Bool, credentialSource:ASFunction = null) {
		mEndpoints = endpoints;
		mExperimentalWebSocketReconnects = experimentalWebSocketReconnects;
		mCredentialSource = credentialSource;
		mCandidates = new Vector<TransportCandidate>();
		if (endpoints == null) {
			return;
		}
		if (!experimentalWebSocketReconnects) {
			addTlsSocket();
			addWebSocket();
		} else {
			addWebSocket();
			addTlsSocket();
		}
	}

	public static function createWssTransport(url:String, enforce:Bool):IGameTransport {
		return new NativeWebSocketTransport(url, enforce);
	}

	@:isVar public var count(get, never):Int;

	public function get_count():Int {
		return mCandidates.length;
	}

	public function candidateAt(index:Int):TransportCandidate {
		if (index < 0 || index >= mCandidates.length) {
			return null;
		}
		return mCandidates[index];
	}

	public function describe():String {
		var _loc2_ = 0;
		if (mCandidates.length == 0) {
			return "none: this environment offers no transport this player can dial";
		}
		var _loc1_:Array<ASAny> = [];
		_loc2_ = 0;
		while (_loc2_ < mCandidates.length) {
			_loc1_.push(mCandidates[_loc2_].name);
			_loc2_++;
		}
		return _loc1_.join(", ");
	}

	public function createTransport(index:Int):IGameTransport {
		var enforce:Bool;
		var candidate = candidateAt(index);
		if (candidate == null) {
			return null;
		}
		enforce = mEndpoints.enforceServerCertificate;
		switch (candidate.kind) {
			case "wss":
				return withSessions(candidate.url, function(param1:String):IGameTransport {
					return createWssTransport(param1, enforce);
				});
			case "tlsSocket":
				return new TlsSocketTransport(candidate.host, candidate.port, enforce);
			default:
				return null;
		}
		return null;
	}

	function withSessions(url:String, factory:ASFunction):IGameTransport {
		var _loc4_ = ASCompat.dynamicAs(factory(url), IGameTransport);
		if (_loc4_ == null || !_loc4_.supportsSessions) {
			return _loc4_;
		}
		var _loc3_ = ASCompat.coerceFunction(mExperimentalWebSocketReconnects && TransportSettings.sessionsEnabled ? factory : null);
		return new SessionTransport(url, _loc3_, _loc4_, mCredentialSource);
	}

	function addWebSocket() {
		var _loc1_ = mEndpoints.wssUrl;
		if (_loc1_ == "") {
			return;
		}
		mCandidates.push(new TransportCandidate("wss", "", 0, _loc1_));
	}

	function addTlsSocket() {
		if (!mEndpoints.tlsOffered) {
			return;
		}
		mCandidates.push(new TransportCandidate("tlsSocket", mEndpoints.address, mEndpoints.port));
	}
}
