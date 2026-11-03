package actor.starlingConvertedOverlay;

import flash.filters.GlowFilter;

class FloaterStyle {
	public static final CRIT_GLOW:GlowFilter = new GlowFilter((16777062 : UInt), 1, 0.4, 0.4, 30, 1);

	public var text:String;

	public var color:UInt = 0;

	public var scale:Float = Math.NaN;

	public var directionX:Float = Math.NaN;

	public var directionY:Float = Math.NaN;

	public var rotation:Float = Math.NaN;

	public var crit:Bool = false;

	public function new() {}
}
