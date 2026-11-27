package starling.events;

import flash.geom.Point;

class ResizeEvent extends Event {
	public static inline final RESIZE = "resize";

	public function new(type:String, width:Int, height:Int, bubbles:Bool = false) {
		super(type, bubbles, new Point(width, height));
	}

	@:isVar public var width(get, never):Int;

	public function get_width():Int {
		return ASCompat.floatToInt(ASCompat.dynamicAs(data, Point).x);
	}

	@:isVar public var height(get, never):Int;

	public function get_height():Int {
		return ASCompat.floatToInt(ASCompat.dynamicAs(data, Point).y);
	}
}
