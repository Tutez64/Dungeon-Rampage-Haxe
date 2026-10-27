package brain.event;

import brain.facade.Facade;
import flash.display.Sprite;

class EventManager extends Sprite {
	public function new(facade:Facade) {
		super();
		facade.addRootDisplayObject(this);
	}
}
