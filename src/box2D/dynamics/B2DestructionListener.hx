package box2D.dynamics;

import box2D.dynamics.joints.B2Joint;

class B2DestructionListener {
	public function new() {}

	public function sayGoodbyeJoint(joint:B2Joint) {
		SayGoodbyeJoint(joint);
	}

	public function sayGoodbyeFixture(fixture:B2Fixture) {
		SayGoodbyeFixture(fixture);
	}

	public function SayGoodbyeJoint(joint:B2Joint) {}

	public function SayGoodbyeFixture(fixture:B2Fixture) {}
}
