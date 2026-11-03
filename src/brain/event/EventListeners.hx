package brain.event;

import flash.events.IEventDispatcher;

class EventListeners {
	public function new() {}

	public static function add(dispatcher:IEventDispatcher, type:String, listener:ASFunction, useCapture:Bool = false, priority:Int = 0,
			useWeakReference:Bool = false) {
		dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public static function remove(dispatcher:IEventDispatcher, type:String, listener:ASFunction, useCapture:Bool = false) {
		dispatcher.removeEventListener(type, listener, useCapture);
	}
}
