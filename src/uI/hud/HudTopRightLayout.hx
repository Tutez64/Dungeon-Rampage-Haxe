package uI.hud;

import flash.geom.Point;
import flash.geom.Rectangle;

class HudTopRightLayout {
	static inline final CENTRE_X:Float = 1872.475;

	static inline final CENTRE_Y:Float = 57;

	static inline final GEAR_SCALE:Float = 0.9;

	static inline final GLYPH_SIZE:Float = 39.47715759277344;

	public function new() {}

	static function core(gear:Bool):Rectangle {
		return gear ? new Rectangle(-29.5, -32.75, 65.55, 63.85) : new Rectangle(-12.4, -13.35, 27.55, 27.45);
	}

	public static function closePosition(scaleX:Float, scaleY:Float):Point {
		var _loc3_ = core(false);
		return new Point(1872.475 - (_loc3_.x + _loc3_.width / 2) * scaleX, 57 - (_loc3_.y + _loc3_.height / 2) * scaleY);
	}

	public static function gearPosition():Point {
		var _loc1_ = core(true);
		return new Point(1872.475 - (_loc1_.x + _loc1_.width / 2) * 0.9, 143.5);
	}

	public static function glyphSize(scaleX:Float, scaleY:Float):Point {
		return new Point(39.47715759277344 / scaleX, 39.47715759277344 / scaleY);
	}

	public static function glyphPosition(gear:Bool, scaleX:Float, scaleY:Float):Point {
		var _loc5_ = core(gear);
		var _loc4_ = glyphSize(scaleX, scaleY);
		return new Point(_loc5_.right - _loc4_.x / 2, _loc5_.top - _loc4_.y / 2);
	}
}
