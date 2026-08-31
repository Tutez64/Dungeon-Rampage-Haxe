package events;

class ManaEvent extends GameObjectEvent {
	public static inline final MANA_UPDATE = "ManaEvent_MANA_UPDATE";

	public var mana:UInt = 0;

	public var maxMana:UInt = 0;

	public function new(type:String, id:UInt, mana:UInt, maxMana:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		this.mana = mana;
		this.maxMana = maxMana;
		super(type, id, bubbles, cancelable);
	}
}
