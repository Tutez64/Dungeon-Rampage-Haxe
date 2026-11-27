package box2D.dynamics;

class B2ContactImpulse {
	public var tangentImpulses:Array<ASAny>;

	public var normalImpulses:Array<ASAny>;

	public function new() {
		normalImpulses = [];
		tangentImpulses = [];
	}
}
