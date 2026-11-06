package box2D.dynamics.joints;

import box2D.dynamics.B2Body;

class B2JointDef {
	public var userData:ASAny;

	public var type:Int = 0;

	public var collideConnected:Bool = false;

	public var bodyB:B2Body;

	public var bodyA:B2Body;

	public function new() {
		type = 0;
		userData = null;
		bodyA = null;
		bodyB = null;
		collideConnected = false;
	}
}
