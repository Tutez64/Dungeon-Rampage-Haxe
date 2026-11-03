package box2D.dynamics;

import box2D.collision.IBroadPhase;
import box2D.collision.B2ContactPoint;
import box2D.collision.B2DynamicTreeBroadPhase;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.contacts.B2ContactFactory;
import flash.Boot;

class B2ContactManager {
	public static var s_evalCP:B2ContactPoint = new B2ContactPoint();

	public var m_world:B2World;

	public var m_contactListener:B2ContactListener;

	public var m_contactList:B2Contact;

	public var m_contactFilter:B2ContactFilter;

	public var m_contactFactory:B2ContactFactory;

	public var m_contactCount:Int = 0;

	public var m_broadPhase:IBroadPhase;

	public var m_allocator:ASAny;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_world = null;
		m_contactCount = 0;
		m_contactFilter = B2ContactFilter.b2_defaultFilter;
		m_contactListener = B2ContactListener.b2_defaultListener;
		m_contactFactory = new B2ContactFactory(m_allocator);
		m_broadPhase = new B2DynamicTreeBroadPhase();
	}

	public function findNewContacts() {
		FindNewContacts();
	}

	public function destroy(c:B2Contact) {
		Destroy(c);
	}

	public function collide() {
		Collide();
	}

	public function addPair(proxyUserDataA:ASAny, proxyUserDataB:ASAny) {
		AddPair(proxyUserDataA, proxyUserDataB);
	}

	public function FindNewContacts() {
		m_broadPhase.updatePairs(addPair);
	}

	public function Destroy(c:B2Contact) {
		var _loc2_ = c.getFixtureA();
		var _loc3_ = c.getFixtureB();
		var _loc4_ = _loc2_.getBody();
		var _loc5_ = _loc3_.getBody();
		if (c.isTouching()) {
			m_contactListener.endContact(c);
		}
		if (c.m_prev != null) {
			c.m_prev.m_next = c.m_next;
		}
		if (c.m_next != null) {
			c.m_next.m_prev = c.m_prev;
		}
		if (c == m_world.m_contactList) {
			m_world.m_contactList = c.m_next;
		}
		if (c.m_nodeA.prev != null) {
			c.m_nodeA.prev.next = c.m_nodeA.next;
		}
		if (c.m_nodeA.next != null) {
			c.m_nodeA.next.prev = c.m_nodeA.prev;
		}
		if (c.m_nodeA == _loc4_.m_contactList) {
			_loc4_.m_contactList = c.m_nodeA.next;
		}
		if (c.m_nodeB.prev != null) {
			c.m_nodeB.prev.next = c.m_nodeB.next;
		}
		if (c.m_nodeB.next != null) {
			c.m_nodeB.next.prev = c.m_nodeB.prev;
		}
		if (c.m_nodeB == _loc5_.m_contactList) {
			_loc5_.m_contactList = c.m_nodeB.next;
		}
		m_contactFactory.destroy(c);
		--m_contactCount;
	}

	public function Collide() {
		var _loc2_ = ASCompat.dynamicAs(null, B2Fixture);
		var _loc3_ = ASCompat.dynamicAs(null, B2Fixture);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc6_ = ASCompat.dynamicAs(null, B2Contact);
		var _loc7_:ASAny = null;
		var _loc8_:ASAny = null;
		var _loc9_ = false;
		var _loc1_ = m_world.m_contactList;
		while (_loc1_ != null) {
			_loc2_ = _loc1_.getFixtureA();
			_loc3_ = _loc1_.getFixtureB();
			_loc4_ = _loc2_.getBody();
			_loc5_ = _loc3_.getBody();
			if ((ASCompat.toInt(_loc4_.m_flags) & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false
				&& (ASCompat.toInt(_loc5_.m_flags) & B2Body.e_awakeFlag) == B2Body.e_awakeFlag == false) {
				_loc1_ = _loc1_.getNext();
			} else {
				if ((_loc1_.m_flags & B2Contact.e_filterFlag) != 0) {
					if (_loc5_.shouldCollide(_loc4_) == false) {
						_loc6_ = _loc1_;
						_loc1_ = ASCompat.coerce(_loc6_.getNext(), box2D.dynamics.contacts.B2Contact);
						destroy(_loc6_);
						continue;
					}
					if (m_contactFilter.shouldCollide(_loc2_, _loc3_) == false) {
						_loc6_ = _loc1_;
						_loc1_ = ASCompat.coerce(_loc6_.getNext(), box2D.dynamics.contacts.B2Contact);
						destroy(_loc6_);
						continue;
					}
					_loc1_.m_flags = _loc1_.m_flags & ~B2Contact.e_filterFlag;
				}
				_loc7_ = _loc2_.m_proxy;
				_loc8_ = _loc3_.m_proxy;
				_loc9_ = m_broadPhase.testOverlap(_loc7_, _loc8_);
				if (_loc9_ == false) {
					_loc6_ = _loc1_;
					_loc1_ = ASCompat.coerce(_loc6_.getNext(), box2D.dynamics.contacts.B2Contact);
					destroy(_loc6_);
				} else {
					_loc1_.update(m_contactListener);
					_loc1_ = _loc1_.getNext();
				}
			}
		}
	}

	public function AddPair(proxyUserDataA:ASAny, proxyUserDataB:ASAny) {
		var _loc8_ = ASCompat.dynamicAs(null, B2Fixture);
		var _loc9_ = ASCompat.dynamicAs(null, B2Fixture);
		var _loc3_ = ASCompat.coerce(proxyUserDataA, box2D.dynamics.B2Fixture);
		var _loc4_ = ASCompat.coerce(proxyUserDataB, box2D.dynamics.B2Fixture);
		var _loc5_ = _loc3_.getBody();
		var _loc6_ = _loc4_.getBody();
		if (_loc5_ == _loc6_) {
			return;
		}
		var _loc7_ = _loc6_.getContactList();
		while (_loc7_ != null) {
			if (_loc7_.other == _loc5_) {
				_loc8_ = _loc7_.contact.getFixtureA();
				_loc9_ = _loc7_.contact.getFixtureB();
				if (_loc8_ == _loc3_ && _loc9_ == _loc4_) {
					return;
				}
				if (_loc8_ == _loc4_ && _loc9_ == _loc3_) {
					return;
				}
			}
			_loc7_ = _loc7_.next;
		}
		if (_loc6_.shouldCollide(_loc5_) == false) {
			return;
		}
		if (m_contactFilter.shouldCollide(_loc3_, _loc4_) == false) {
			return;
		}
		var _loc10_ = m_contactFactory.create(_loc3_, _loc4_);
		_loc3_ = _loc10_.getFixtureA();
		_loc4_ = _loc10_.getFixtureB();
		_loc5_ = _loc3_.m_body;
		_loc6_ = _loc4_.m_body;
		_loc10_.m_prev = null;
		_loc10_.m_next = m_world.m_contactList;
		if (m_world.m_contactList != null) {
			m_world.m_contactList.m_prev = _loc10_;
		}
		m_world.m_contactList = _loc10_;
		_loc10_.m_nodeA.contact = _loc10_;
		_loc10_.m_nodeA.other = _loc6_;
		_loc10_.m_nodeA.prev = null;
		_loc10_.m_nodeA.next = _loc5_.m_contactList;
		if (_loc5_.m_contactList != null) {
			_loc5_.m_contactList.prev = _loc10_.m_nodeA;
		}
		_loc5_.m_contactList = _loc10_.m_nodeA;
		_loc10_.m_nodeB.contact = _loc10_;
		_loc10_.m_nodeB.other = _loc5_;
		_loc10_.m_nodeB.prev = null;
		_loc10_.m_nodeB.next = _loc6_.m_contactList;
		if (_loc6_.m_contactList != null) {
			_loc6_.m_contactList.prev = _loc10_.m_nodeB;
		}
		_loc6_.m_contactList = _loc10_.m_nodeB;
		++m_contactCount;
	}
}
