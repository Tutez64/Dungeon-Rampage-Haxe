package box2D.dynamics.joints;

import box2D.dynamics.B2Body;

class B2JointEdge {
	public var prev:B2JointEdge;

	public var other:B2Body;

	public var next:B2JointEdge;

	public var joint:B2Joint;

	public function new() {}
}
