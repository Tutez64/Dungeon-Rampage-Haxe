package box2D.dynamics;

import box2D.common.math.B2Vec2;
import flash.Boot;

class B2BodyDef {
	public var userData:ASAny;

	public var type:Int = 0;

	public var position:B2Vec2;

	public var linearVelocity:B2Vec2;

	public var linearDamping:Float = Math.NaN;

	public var inertiaScale:Float = Math.NaN;

	public var gravityScale:Float = Math.NaN;

	public var fixedRotation:Bool = false;

	public var bullet:Bool = false;

	public var awake:Bool = false;

	public var angularVelocity:Float = Math.NaN;

	public var angularDamping:Float = Math.NaN;

	public var angle:Float = Math.NaN;

	public var allowSleep:Bool = false;

	public var active:Bool = false;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		position = new B2Vec2();
		linearVelocity = new B2Vec2();
		userData = null;
		angle = 0;
		angularVelocity = 0;
		linearDamping = 0;
		angularDamping = 0;
		allowSleep = true;
		awake = true;
		fixedRotation = false;
		bullet = false;
		type = 0;
		active = true;
		inertiaScale = 1;
		gravityScale = 1;
	}
}
