package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;

class B2Joint {
	public var m_userData:ASAny;

	public var m_type:Int = 0;

	public var m_prev:B2Joint;

	public var m_next:B2Joint;

	public var m_localCenterB:B2Vec2;

	public var m_localCenterA:B2Vec2;

	public var m_islandFlag:Bool = false;

	public var m_invMassB:Float = Math.NaN;

	public var m_invMassA:Float = Math.NaN;

	public var m_invIB:Float = Math.NaN;

	public var m_invIA:Float = Math.NaN;

	public var m_edgeB:B2JointEdge;

	public var m_edgeA:B2JointEdge;

	public var m_collideConnected:Bool = false;

	public var m_bodyB:B2Body;

	public var m_bodyA:B2Body;

	public function new(def:B2JointDef = /*undefined*/ null) {
		m_edgeA = new B2JointEdge();
		m_edgeB = new B2JointEdge();
		m_localCenterA = new B2Vec2();
		m_localCenterB = new B2Vec2();
		B2Settings.b2Assert(def.bodyA != def.bodyB);
		m_type = def.type;
		m_prev = null;
		m_next = null;
		m_bodyA = def.bodyA;
		m_bodyB = def.bodyB;
		m_collideConnected = def.collideConnected;
		m_islandFlag = false;
		m_userData = def.userData;
	}

	public static function create(def:B2JointDef, allocator:ASAny):B2Joint {
		var _loc3_:B2Joint = null;
		switch (def.type) {
			case 1:
				_loc3_ = new B2RevoluteJoint(cast(def, B2RevoluteJointDef));

			case 2:
				_loc3_ = new B2PrismaticJoint(cast(def, B2PrismaticJointDef));

			case 3:
				_loc3_ = new B2DistanceJoint(cast(def, B2DistanceJointDef));

			case 4:
				_loc3_ = new B2PulleyJoint(cast(def, B2PulleyJointDef));

			case 5:
				_loc3_ = new B2MouseJoint(cast(def, B2MouseJointDef));

			case 6:
				_loc3_ = new B2GearJoint(cast(def, B2GearJointDef));

			case 7:
				_loc3_ = new B2LineJoint(cast(def, B2LineJointDef));

			case 8:
				_loc3_ = new B2WeldJoint(cast(def, B2WeldJointDef));

			case 9:
				_loc3_ = new B2FrictionJoint(cast(def, B2FrictionJointDef));
		}
		return _loc3_;
	}

	public static function destroy(joint:B2Joint, allocator:ASAny) {}

	public static function Create(def:B2JointDef, allocator:ASAny):B2Joint {
		return B2Joint.create(def, allocator);
	}

	public static function Destroy(joint:B2Joint, allocator:ASAny) {
		B2Joint.destroy(joint, allocator);
	}

	public function solveVelocityConstraints(step:B2TimeStep) {
		SolveVelocityConstraints(step);
	}

	public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	public function setUserData(data:ASAny) {
		SetUserData(data);
	}

	public function isActive():Bool {
		return IsActive();
	}

	public function initVelocityConstraints(step:B2TimeStep) {
		InitVelocityConstraints(step);
	}

	public function getUserData():ASAny {
		return GetUserData();
	}

	public function getType():Int {
		return GetType();
	}

	public function getReactionTorque(inv_dt:Float):Float {
		return GetReactionTorque(inv_dt);
	}

	public function getReactionForce(inv_dt:Float):B2Vec2 {
		return GetReactionForce(inv_dt);
	}

	public function getNext():B2Joint {
		return GetNext();
	}

	public function getBodyB():B2Body {
		return GetBodyB();
	}

	public function getBodyA():B2Body {
		return GetBodyA();
	}

	public function getAnchorB():B2Vec2 {
		return GetAnchorB();
	}

	public function getAnchorA():B2Vec2 {
		return GetAnchorA();
	}

	public function finalizeVelocityConstraints() {
		FinalizeVelocityConstraints();
	}

	public function SolveVelocityConstraints(step:B2TimeStep) {}

	public function SolvePositionConstraints(baumgarte:Float):Bool {
		return false;
	}

	public function SetUserData(data:ASAny) {
		m_userData = data;
	}

	public function IsActive():Bool {
		if ((m_bodyA.m_flags & B2Body.e_activeFlag) == B2Body.e_activeFlag) {
			return (m_bodyB.m_flags & B2Body.e_activeFlag) == B2Body.e_activeFlag;
		}
		return false;
	}

	public function InitVelocityConstraints(step:B2TimeStep) {}

	public function GetUserData():ASAny {
		return m_userData;
	}

	public function GetType():Int {
		return m_type;
	}

	public function GetReactionTorque(inv_dt:Float):Float {
		return 0;
	}

	public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return null;
	}

	public function GetNext():B2Joint {
		return m_next;
	}

	public function GetBodyB():B2Body {
		return m_bodyB;
	}

	public function GetBodyA():B2Body {
		return m_bodyA;
	}

	public function GetAnchorB():B2Vec2 {
		return null;
	}

	public function GetAnchorA():B2Vec2 {
		return null;
	}

	public function FinalizeVelocityConstraints() {}
}
