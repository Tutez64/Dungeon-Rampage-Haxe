package box2D.dynamics;

import flash.Boot;

class B2ContactImpulse {
	public var tangentImpulses:Array<ASAny>;

	public var normalImpulses:Array<ASAny>;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		normalImpulses = [];
		tangentImpulses = [];
	}
}
