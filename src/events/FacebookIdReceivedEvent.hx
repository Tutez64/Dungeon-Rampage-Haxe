package events;

class FacebookIdReceivedEvent extends GameObjectEvent {
	public static inline final NAME = "FACEBOOK_ID_RECEIVED_EVENT";

	var mFacebookId:String;

	public function new(type:String, id:UInt, facebookId:String, bubbles:Bool = false, cancelable:Bool = false) {
		mFacebookId = facebookId;
		super(type, id, bubbles, cancelable);
	}

	@:isVar public var facebookId(get, never):String;

	public function get_facebookId():String {
		return mFacebookId;
	}
}
