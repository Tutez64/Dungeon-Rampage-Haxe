package events;

class SteamAvatarUrlReceivedEvent extends GameObjectEvent {
	public static inline final NAME = "STEAM_AVATAR_URL_RECEIVED_EVENT";

	var mSteamAvatarUrl:String;

	public function new(steamAvatarUrlReceivedEventType:String, id:UInt, steamAvatarUrl:String, bubbles:Bool = false, cancelable:Bool = false) {
		mSteamAvatarUrl = steamAvatarUrl;
		super(steamAvatarUrlReceivedEventType, id, bubbles, cancelable);
	}

	@:isVar public var steamAvatarUrl(get, never):String;

	public function get_steamAvatarUrl():String {
		return mSteamAvatarUrl;
	}
}
