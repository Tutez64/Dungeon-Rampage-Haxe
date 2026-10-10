package brain.mouseScrollPlugin;

import flash.display.InteractiveObject;
import flash.events.MouseEvent;

class CustomMouseWheelEvent extends MouseEvent {
	public static inline final MOVE = "onMove";

	public function new(type:String, bubbles:Bool = true, cancelable:Bool = false, localX:Float = 0, localY:Float = 0, relatedObject:InteractiveObject = null,
			ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false, buttonDown:Bool = false, delta:Int = 0) {
		super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
	}
}
