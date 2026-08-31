package box2D.dynamics;

import box2D.collision.B2Manifold;
import box2D.dynamics.contacts.B2Contact;

/*use*/ /*namespace*/ /*b2internal*/ class B2ContactListener {
	/*b2internal*/
	public static var b2_defaultListener:B2ContactListener = new B2ContactListener();

	public function new() {}

	public function BeginContact(contact:B2Contact) {}

	public function EndContact(contact:B2Contact) {}

	public function PreSolve(contact:B2Contact, oldManifold:B2Manifold) {}

	public function PostSolve(contact:B2Contact, impulse:B2ContactImpulse) {}
}
