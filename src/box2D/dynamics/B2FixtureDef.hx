package box2D.dynamics;

import box2D.collision.shapes.B2Shape;

class B2FixtureDef {
	public var userData:ASAny;

	public var shape:B2Shape;

	public var restitution:Float = Math.NaN;

	public var isSensor:Bool = false;

	public var friction:Float = Math.NaN;

	public var filter:B2FilterData;

	public var density:Float = Math.NaN;

	public function new() {
		filter = new B2FilterData();
		shape = null;
		userData = null;
		friction = 0.2;
		restitution = 0;
		density = 0;
		filter.categoryBits = 1;
		filter.maskBits = 65535;
		filter.groupIndex = 0;
		isSensor = false;
	}
}
