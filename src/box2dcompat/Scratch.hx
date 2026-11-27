package box2dcompat;

import box2D.collision.B2AABB;
import box2D.common.math.B2Vec2;

class Scratch {
	public static var aabbs:Array<ASAny> = [new B2AABB(), new B2AABB()];

	public static var difference:B2Vec2 = new B2Vec2();

	public static var centre:B2Vec2 = new B2Vec2();

	public static var spare:B2AABB = new B2AABB();

	public function new() {}

	public static function aabb(slot:Int):B2AABB {
		return ASCompat.coerce(Scratch.aabbs[slot], box2D.collision.B2AABB);
	}

	public static function center(box:B2AABB):B2Vec2 {
		Scratch.centre.x = (box.lowerBound.x + box.upperBound.x) / 2;
		Scratch.centre.y = (box.lowerBound.y + box.upperBound.y) / 2;
		return Scratch.centre;
	}

	public static function swap(retired:B2AABB):B2AABB {
		var _loc2_ = Scratch.spare;
		Scratch.spare = retired;
		return _loc2_;
	}

	public static function subtract(a:B2Vec2, b:B2Vec2):B2Vec2 {
		Scratch.difference.x = a.x - b.x;
		Scratch.difference.y = a.y - b.y;
		return Scratch.difference;
	}
}
