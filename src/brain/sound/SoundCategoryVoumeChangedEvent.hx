package brain.sound;

import flash.events.Event;

class SoundCategoryVoumeChangedEvent extends Event {
	public static inline final TYPE = "SoundCategoryVoumeChangedEvent";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("SoundCategoryVoumeChangedEvent", bubbles, cancelable);
	}
}
