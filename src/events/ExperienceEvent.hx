package events;

class ExperienceEvent extends GameObjectEvent {
	public static inline final EXPERIENCE_UPDATE = "ExperienceEvent_EXPERIENCE_UPDATE";

	public var experience:UInt = 0;

	public function new(type:String, id:UInt, experience:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		this.experience = experience;
		super(type, id, bubbles, cancelable);
	}
}
