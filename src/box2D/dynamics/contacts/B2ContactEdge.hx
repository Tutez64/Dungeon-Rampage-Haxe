package box2D.dynamics.contacts;

import box2D.dynamics.B2Body;

class B2ContactEdge {
	public var prev:B2ContactEdge;

	public var other:B2Body;

	public var next:B2ContactEdge;

	public var contact:B2Contact;

	public function new() {}
}
