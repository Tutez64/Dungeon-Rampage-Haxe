package events;

class ChatEvent extends GameObjectEvent {
	public static inline final INCOMING_CHAT_UPDATE = "ChatEvent_INCOMING_CHAT_UPDATE";

	public static inline final OUTGOING_CHAT_UPDATE = "ChatEvent_OUTGOING_CHAT_UPDATE";

	public var message:String;

	public function new(type:String, id:UInt, message:String, bubbles:Bool = false, cancelable:Bool = false) {
		this.message = message;
		super(type, id, bubbles, cancelable);
	}
}
