package events;

class HpEvent extends GameObjectEvent {
	public static inline final HP_UPDATE = "HpEvent_HP_UPDATE";

	public var hp:UInt = 0;

	public var maxHp:UInt = 0;

	public function new(type:String, id:UInt, hp:UInt, maxHp:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		this.hp = hp;
		this.maxHp = maxHp;
		super(type, id, bubbles, cancelable);
	}
}
