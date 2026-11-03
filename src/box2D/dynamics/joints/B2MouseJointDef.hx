package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import flash.Boot;

class B2MouseJointDef extends B2JointDef {
	public var target:B2Vec2;

	public var maxForce:Float = Math.NaN;

	public var frequencyHz:Float = Math.NaN;

	public var dampingRatio:Float = Math.NaN;

	public function new() {
		if (!Boot.skip_constructor) {
			super();
			target = new B2Vec2();
			type = 5;
			maxForce = 0;
			frequencyHz = 5;
			dampingRatio = 0.7;
		}
	}
}
