package events;

class PlayerIsTypingEvent extends GameObjectEvent {
	public static inline final PLAYER_IS_TYPING = "PLAYER_IS_TYPING";

	public static inline final PLAYER_CHAT_FOCUS_IN = "CHAT_BOX_FOCUS_IN";

	public static inline final PLAYER_CHAT_FOCUS_OUT = "CHAT_BOX_FOCUS_OUT";

	public var subtype:String;

	public function new(type:String, id:UInt, subType:String, bubbles:Bool = false, cancelable:Bool = false) {
		subtype = subType;
		super(type, id, bubbles, cancelable);
	}
}
