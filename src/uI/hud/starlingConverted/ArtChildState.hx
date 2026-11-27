package uI.hud.starlingConverted;

import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class ArtChildState {
	public var child:Int = 0;

	public var matrix:Matrix;

	public var alpha:Float = Math.NaN;

	public var visible:Bool = false;

	public var blendMode:String;

	public var colorTransform:ColorTransform;

	public var frame:Int = 0;

	@:allow(uI.hud.starlingConverted) var filterState:Int = 0;

	@:allow(uI.hud.starlingConverted) var parentClip:Rectangle;

	public function new() {}
}
