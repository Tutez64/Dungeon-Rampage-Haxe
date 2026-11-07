package actor.starlingConvertedOverlay;

import brain.starling.swfConverter.BakedCell;
import flash.display.DisplayObject;

/*internal*/
class TagPart {
	public var source:DisplayObject;

	public var hide:Vector<DisplayObject>;

	public var shared:Bool = false;

	public var wantContent:String;

	public var wantScale:Float = 0;

	public var cell:BakedCell;

	public var cellContent:String;

	public var cellScale:Float = 0;

	public function new(source:DisplayObject, hide:Vector<DisplayObject> = null, shared:Bool = false) {
		this.source = source;
		this.hide = hide;
		this.shared = shared;
	}

	@:isVar public var current(get, never):Bool;

	public function get_current():Bool {
		return wantContent == null ? cell == null : cell != null
			&& cell.alive
			&& cellContent == wantContent
			&& cellScale > 0
			&& Math.abs(wantScale / cellScale - 1) <= 0.005;
	}

	@:isVar public var usable(get, never):Bool;

	public function get_usable():Bool {
		return wantContent == null || cell != null && cell.alive && cellContent == wantContent;
	}

	@:isVar public var drawn(get, never):Bool;

	public function get_drawn():Bool {
		return wantContent != null && cell != null && cellContent == wantContent && cell.alive && !cell.isEmpty;
	}
}
