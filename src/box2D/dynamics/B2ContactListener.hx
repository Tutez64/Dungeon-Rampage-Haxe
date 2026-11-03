package box2D.dynamics;

import box2D.collision.B2Manifold;
import box2D.dynamics.contacts.B2Contact;

class B2ContactListener {
	public static var b2_defaultListener:B2ContactListener = new B2ContactListener();

	public function new() {}

	public function preSolve(contact:B2Contact, oldManifold:B2Manifold) {
		PreSolve(contact, oldManifold);
	}

	public function postSolve(contact:B2Contact, impulse:B2ContactImpulse) {
		PostSolve(contact, impulse);
	}

	public function endContact(contact:B2Contact) {
		EndContact(contact);
	}

	public function beginContact(contact:B2Contact) {
		BeginContact(contact);
	}

	public function PreSolve(contact:B2Contact, oldManifold:B2Manifold) {}

	public function PostSolve(contact:B2Contact, impulse:B2ContactImpulse) {}

	public function EndContact(contact:B2Contact) {}

	public function BeginContact(contact:B2Contact) {}
}
