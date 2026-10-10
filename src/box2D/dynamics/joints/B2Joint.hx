package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2TimeStep;

/*use*/ /*namespace*/ /*b2internal*/ class B2Joint {
	/*b2internal*/
	public static inline final e_unknownJoint = 0;

	/*b2internal*/
	public static inline final e_revoluteJoint = 1;

	/*b2internal*/
	public static inline final e_prismaticJoint = 2;

	/*b2internal*/
	public static inline final e_distanceJoint = 3;

	/*b2internal*/
	public static inline final e_pulleyJoint = 4;

	/*b2internal*/
	public static inline final e_mouseJoint = 5;

	/*b2internal*/
	public static inline final e_gearJoint = 6;

	/*b2internal*/
	public static inline final e_lineJoint = 7;

	/*b2internal*/
	public static inline final e_weldJoint = 8;

	/*b2internal*/
	public static inline final e_frictionJoint = 9;

	/*b2internal*/
	public static inline final e_inactiveLimit = 0;

	/*b2internal*/
	public static inline final e_atLowerLimit = 1;

	/*b2internal*/
	public static inline final e_atUpperLimit = 2;

	/*b2internal*/
	public static inline final e_equalLimits = 3;

	/*b2internal*/
	public var m_type:Int = 0;

	/*b2internal*/
	public var m_prev:B2Joint;

	/*b2internal*/
	public var m_next:B2Joint;

	/*b2internal*/
	public var m_edgeA:B2JointEdge = new B2JointEdge();

	/*b2internal*/
	public var m_edgeB:B2JointEdge = new B2JointEdge();

	/*b2internal*/
	public var m_bodyA:B2Body;

	/*b2internal*/
	public var m_bodyB:B2Body;

	/*b2internal*/
	public var m_islandFlag:Bool = false;

	/*b2internal*/
	public var m_collideConnected:Bool = false;

	var m_userData:ASAny;

	/*b2internal*/
	public var m_localCenterA:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_localCenterB:B2Vec2 = new B2Vec2();

	/*b2internal*/
	public var m_invMassA:Float = Math.NaN;

	/*b2internal*/
	public var m_invMassB:Float = Math.NaN;

	/*b2internal*/
	public var m_invIA:Float = Math.NaN;

	/*b2internal*/
	public var m_invIB:Float = Math.NaN;

	public function new(def:B2JointDef) {
		B2Settings.b2Assert(def.bodyA != def.bodyB);
		this.m_type = def.type;
		this.m_prev = null;
		this.m_next = null;
		this.m_bodyA = def.bodyA;
		this.m_bodyB = def.bodyB;
		this.m_collideConnected = def.collideConnected;
		this.m_islandFlag = false;
		this.m_userData = def.userData;
	}

	/*b2internal*/
	public static function Create(def:B2JointDef, allocator:ASAny):B2Joint {
		var _loc3_:B2Joint = null;
		switch (def.type) {
			case e_distanceJoint:
				_loc3_ = new B2DistanceJoint(ASCompat.reinterpretAs(def, B2DistanceJointDef));

			case e_mouseJoint:
				_loc3_ = new B2MouseJoint(ASCompat.reinterpretAs(def, B2MouseJointDef));

			case e_prismaticJoint:
				_loc3_ = new B2PrismaticJoint(ASCompat.reinterpretAs(def, B2PrismaticJointDef));

			case e_revoluteJoint:
				_loc3_ = new B2RevoluteJoint(ASCompat.reinterpretAs(def, B2RevoluteJointDef));

			case e_pulleyJoint:
				_loc3_ = new B2PulleyJoint(ASCompat.reinterpretAs(def, B2PulleyJointDef));

			case e_gearJoint:
				_loc3_ = new B2GearJoint(ASCompat.reinterpretAs(def, B2GearJointDef));

			case e_lineJoint:
				_loc3_ = new B2LineJoint(ASCompat.reinterpretAs(def, B2LineJointDef));

			case e_weldJoint:
				_loc3_ = new B2WeldJoint(ASCompat.reinterpretAs(def, B2WeldJointDef));

			case e_frictionJoint:
				_loc3_ = new B2FrictionJoint(ASCompat.reinterpretAs(def, B2FrictionJointDef));
		}
		return _loc3_;
	}

	/*b2internal*/
	public static function Destroy(joint:B2Joint, allocator:ASAny) {}

	public function GetType():Int {
		return this.m_type;
	}

	public function GetAnchorA():B2Vec2 {
		return null;
	}

	public function GetAnchorB():B2Vec2 {
		return null;
	}

	public function GetReactionForce(inv_dt:Float):B2Vec2 {
		return null;
	}

	public function GetReactionTorque(inv_dt:Float):Float {
		return 0;
	}

	public function GetBodyA():B2Body {
		return this.m_bodyA;
	}

	public function GetBodyB():B2Body {
		return this.m_bodyB;
	}

	public function GetNext():B2Joint {
		return this.m_next;
	}

	public function GetUserData():ASAny {
		return this.m_userData;
	}

	public function SetUserData(data:ASAny) {
		this.m_userData = data;
	}

	public function IsActive():Bool {
		return this.m_bodyA.IsActive() && this.m_bodyB.IsActive();
	}

	/*b2internal*/
	public function InitVelocityConstraints(step:B2TimeStep) {}

	/*b2internal*/
	public function SolveVelocityConstraints(step:B2TimeStep) {}

	/*b2internal*/
	public function FinalizeVelocityConstraints() {}

	/*b2internal*/
	public function SolvePositionConstraints(baumgarte:Float):Bool {
		return false;
	}
}
