package box2D.dynamics.contacts;

import box2D.collision.shapes.B2Shape;
import box2D.collision.B2Manifold;
import box2D.collision.B2ManifoldPoint;
import box2D.collision.B2WorldManifold;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2TimeStep;
import box2dcompat.As3Array;
import flash.Boot;

class B2ContactSolver {
	public static var staticFix:Int = B2Settings.b2_maxManifoldPoints;

	public static var s_worldManifold:B2WorldManifold = new B2WorldManifold();

	public static var s_psm:B2PositionSolverManifold = new B2PositionSolverManifold();

	public var m_step:B2TimeStep;

	public var m_constraints:Array<ASAny>;

	public var m_constraintCount:Int = 0;

	public var m_allocator:ASAny;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		m_constraintCount = 0;
		m_step = new B2TimeStep();
		m_constraints = [];
	}

	public function solveVelocityConstraints() {
		SolveVelocityConstraints();
	}

	public function solvePositionConstraints(baumgarte:Float):Bool {
		return SolvePositionConstraints(baumgarte);
	}

	public function initialize(step:B2TimeStep, contacts:Array<ASAny>, contactCount:Int, allocator:ASAny) {
		var __tmpAssignObj30:ASAny;
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Contact);
		var _loc11_ = 0;
		var _loc12_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc13_:ASAny = ASCompat.dynamicAs(null, B2Fixture);
		var _loc14_:ASAny = ASCompat.dynamicAs(null, B2Shape);
		var _loc15_:ASAny = ASCompat.dynamicAs(null, B2Shape);
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc19_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc20_:ASAny = ASCompat.dynamicAs(null, B2Manifold);
		var _loc21_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc23_ = Math.NaN;
		var _loc24_ = Math.NaN;
		var _loc25_ = Math.NaN;
		var _loc26_ = Math.NaN;
		var _loc27_ = Math.NaN;
		var _loc28_ = Math.NaN;
		var _loc29_ = Math.NaN;
		var _loc30_ = Math.NaN;
		var _loc31_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraint);
		var _loc32_ = 0;
		var _loc33_ = 0;
		var _loc34_ = 0;
		var _loc35_:ASAny = ASCompat.dynamicAs(null, B2ManifoldPoint);
		var _loc36_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		var _loc37_ = Math.NaN;
		var _loc38_ = Math.NaN;
		var _loc39_ = Math.NaN;
		var _loc40_ = Math.NaN;
		var _loc41_ = Math.NaN;
		var _loc42_ = Math.NaN;
		var _loc43_ = Math.NaN;
		var _loc44_ = Math.NaN;
		var _loc45_ = Math.NaN;
		var _loc46_ = Math.NaN;
		var _loc47_ = Math.NaN;
		var _loc48_ = Math.NaN;
		var _loc49_ = Math.NaN;
		var _loc50_ = Math.NaN;
		var _loc51_ = Math.NaN;
		var _loc52_ = Math.NaN;
		var _loc53_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		m_step.set(step);
		m_allocator = allocator;
		m_constraintCount = contactCount;
		while (m_constraints.length < m_constraintCount) {
			m_constraints[m_constraints.length] = new B2ContactConstraint();
		}
		var _loc9_ = 0;
		var _loc10_ = contactCount;
		while (_loc9_ < _loc10_) {
			_loc11_ = _loc9_++;
			_loc5_ = contacts[_loc11_];
			_loc12_ = _loc5_.m_fixtureA;
			_loc13_ = _loc5_.m_fixtureB;
			_loc14_ = _loc12_.m_shape;
			_loc15_ = _loc13_.m_shape;
			_loc16_ = ASCompat.toNumberField(_loc14_, "m_radius");
			_loc17_ = ASCompat.toNumberField(_loc15_, "m_radius");
			_loc18_ = _loc12_.m_body;
			_loc19_ = _loc13_.m_body;
			_loc20_ = _loc5_.getManifold();
			_loc21_ = B2Settings.b2MixFriction(ASCompat.toNumber(_loc12_.getFriction()), ASCompat.toNumber(_loc13_.getFriction()));
			_loc22_ = B2Settings.b2MixRestitution(ASCompat.toNumber(_loc12_.getRestitution()), ASCompat.toNumber(_loc13_.getRestitution()));
			_loc23_ = ASCompat.toNumberField(_loc18_.m_linearVelocity, "x");
			_loc24_ = ASCompat.toNumberField(_loc18_.m_linearVelocity, "y");
			_loc25_ = ASCompat.toNumberField(_loc19_.m_linearVelocity, "x");
			_loc26_ = ASCompat.toNumberField(_loc19_.m_linearVelocity, "y");
			_loc27_ = ASCompat.toNumberField(_loc18_, "m_angularVelocity");
			_loc28_ = ASCompat.toNumberField(_loc19_, "m_angularVelocity");
			B2Settings.b2Assert(ASCompat.toNumberField(_loc20_, "m_pointCount") > 0);
			B2ContactSolver.s_worldManifold.initialize(ASCompat.coerce(_loc20_, box2D.collision.B2Manifold),
				ASCompat.coerce(_loc18_.m_xf, box2D.common.math.B2Transform), _loc16_, ASCompat.coerce(_loc19_.m_xf, box2D.common.math.B2Transform), _loc17_);
			_loc29_ = B2ContactSolver.s_worldManifold.m_normal.x;
			_loc30_ = B2ContactSolver.s_worldManifold.m_normal.y;
			_loc31_ = m_constraints[_loc11_];
			ASCompat.setProperty(_loc31_, "bodyA", _loc18_);
			ASCompat.setProperty(_loc31_, "bodyB", _loc19_);
			ASCompat.setProperty(_loc31_, "manifold", _loc20_);
			ASCompat.setProperty(_loc31_.normal, "x", _loc29_);
			ASCompat.setProperty(_loc31_.normal, "y", _loc30_);
			ASCompat.setProperty(_loc31_, "pointCount", _loc20_.m_pointCount);
			ASCompat.setProperty(_loc31_, "friction", _loc21_);
			ASCompat.setProperty(_loc31_, "restitution", _loc22_);
			ASCompat.setProperty(_loc31_.localPlaneNormal, "x", _loc20_.m_localPlaneNormal.x);
			ASCompat.setProperty(_loc31_.localPlaneNormal, "y", _loc20_.m_localPlaneNormal.y);
			ASCompat.setProperty(_loc31_.localPoint, "x", _loc20_.m_localPoint.x);
			ASCompat.setProperty(_loc31_.localPoint, "y", _loc20_.m_localPoint.y);
			ASCompat.setProperty(_loc31_, "radius", _loc16_ + _loc17_);
			ASCompat.setProperty(_loc31_, "type", _loc20_.m_type);
			_loc32_ = 0;
			_loc33_ = ASCompat.toInt(_loc31_.pointCount);
			while (_loc32_ < _loc33_) {
				_loc34_ = _loc32_++;
				_loc35_ = _loc20_.m_points[_loc34_];
				_loc36_ = _loc31_.points[_loc34_];
				ASCompat.setProperty(_loc36_, "normalImpulse", _loc35_.m_normalImpulse);
				ASCompat.setProperty(_loc36_, "tangentImpulse", _loc35_.m_tangentImpulse);
				_loc36_.localPoint.setV(_loc35_.m_localPoint);
				_loc37_ = ASCompat.toNumber(ASCompat.setProperty(_loc36_.rA, "x",
					ASCompat.toNumberField(B2ContactSolver.s_worldManifold.m_points[_loc34_], "x") - ASCompat.toNumberField(_loc18_.m_sweep.c, "x")));
				_loc38_ = ASCompat.toNumber(ASCompat.setProperty(_loc36_.rA, "y",
					ASCompat.toNumberField(B2ContactSolver.s_worldManifold.m_points[_loc34_], "y") - ASCompat.toNumberField(_loc18_.m_sweep.c, "y")));
				_loc39_ = ASCompat.toNumber(ASCompat.setProperty(_loc36_.rB, "x",
					ASCompat.toNumberField(B2ContactSolver.s_worldManifold.m_points[_loc34_], "x") - ASCompat.toNumberField(_loc19_.m_sweep.c, "x")));
				_loc40_ = ASCompat.toNumber(ASCompat.setProperty(_loc36_.rB, "y",
					ASCompat.toNumberField(B2ContactSolver.s_worldManifold.m_points[_loc34_], "y") - ASCompat.toNumberField(_loc19_.m_sweep.c, "y")));
				_loc41_ = _loc37_ * _loc30_ - _loc38_ * _loc29_;
				_loc42_ = _loc39_ * _loc30_ - _loc40_ * _loc29_;
				_loc41_ *= _loc41_;
				_loc42_ *= _loc42_;
				_loc43_ = ASCompat.toNumber(_loc18_.m_invMass + _loc19_.m_invMass + ASCompat.toNumberField(_loc18_, "m_invI") * _loc41_
					+ ASCompat.toNumberField(_loc19_, "m_invI") * _loc42_);
				ASCompat.setProperty(_loc36_, "normalMass", 1 / _loc43_);
				_loc44_ = ASCompat.toNumberField(_loc18_, "m_mass") * ASCompat.toNumberField(_loc18_, "m_invMass")
					+ ASCompat.toNumberField(_loc19_, "m_mass") * ASCompat.toNumberField(_loc19_, "m_invMass");
				_loc44_ = _loc44_
					+ (ASCompat.toNumberField(_loc18_, "m_mass") * ASCompat.toNumberField(_loc18_, "m_invI") * _loc41_
						+ ASCompat.toNumberField(_loc19_, "m_mass") * ASCompat.toNumberField(_loc19_, "m_invI") * _loc42_);
				ASCompat.setProperty(_loc36_, "equalizedMass", 1 / _loc44_);
				_loc45_ = _loc30_;
				_loc46_ = -_loc29_;
				_loc47_ = _loc37_ * _loc46_ - _loc38_ * _loc45_;
				_loc48_ = _loc39_ * _loc46_ - _loc40_ * _loc45_;
				_loc47_ *= _loc47_;
				_loc48_ *= _loc48_;
				_loc49_ = ASCompat.toNumber(_loc18_.m_invMass + _loc19_.m_invMass + ASCompat.toNumberField(_loc18_, "m_invI") * _loc47_
					+ ASCompat.toNumberField(_loc19_, "m_invI") * _loc48_);
				ASCompat.setProperty(_loc36_, "tangentMass", 1 / _loc49_);
				ASCompat.setProperty(_loc36_, "velocityBias", 0);
				_loc50_ = _loc25_ + -_loc28_ * _loc40_ - _loc23_ - -_loc27_ * _loc38_;
				_loc51_ = _loc26_ + _loc28_ * _loc39_ - _loc24_ - _loc27_ * _loc37_;
				_loc52_ = ASCompat.toNumberField(_loc31_.normal, "x") * _loc50_ + ASCompat.toNumberField(_loc31_.normal, "y") * _loc51_;
				if (_loc52_ < -B2Settings.b2_velocityThreshold) {
					__tmpAssignObj30 = _loc36_;
					ASCompat.setProperty(__tmpAssignObj30, "velocityBias",
						__tmpAssignObj30.velocityBias + -ASCompat.toNumberField(_loc31_, "restitution") * _loc52_);
				}
			}
			if (ASCompat.toNumberField(_loc31_, "pointCount") == 2) {
				_loc36_ = _loc31_.points[0];
				_loc53_ = _loc31_.points[1];
				_loc37_ = ASCompat.toNumberField(_loc18_, "m_invMass");
				_loc38_ = ASCompat.toNumberField(_loc18_, "m_invI");
				_loc39_ = ASCompat.toNumberField(_loc19_, "m_invMass");
				_loc40_ = ASCompat.toNumberField(_loc19_, "m_invI");
				_loc41_ = ASCompat.toNumberField(_loc36_.rA, "x") * _loc30_ - ASCompat.toNumberField(_loc36_.rA, "y") * _loc29_;
				_loc42_ = ASCompat.toNumberField(_loc36_.rB, "x") * _loc30_ - ASCompat.toNumberField(_loc36_.rB, "y") * _loc29_;
				_loc43_ = ASCompat.toNumberField(_loc53_.rA, "x") * _loc30_ - ASCompat.toNumberField(_loc53_.rA, "y") * _loc29_;
				_loc44_ = ASCompat.toNumberField(_loc53_.rB, "x") * _loc30_ - ASCompat.toNumberField(_loc53_.rB, "y") * _loc29_;
				_loc45_ = _loc37_ + _loc39_ + _loc38_ * _loc41_ * _loc41_ + _loc40_ * _loc42_ * _loc42_;
				_loc46_ = _loc37_ + _loc39_ + _loc38_ * _loc43_ * _loc43_ + _loc40_ * _loc44_ * _loc44_;
				_loc47_ = _loc37_ + _loc39_ + _loc38_ * _loc41_ * _loc43_ + _loc40_ * _loc42_ * _loc44_;
				_loc48_ = 100;
				if (_loc45_ * _loc45_ < _loc48_ * (_loc45_ * _loc46_ - _loc47_ * _loc47_)) {
					_loc31_.K.col1.set(_loc45_, _loc47_);
					_loc31_.K.col2.set(_loc47_, _loc46_);
					_loc31_.K.getInverse(_loc31_.normalMass);
				} else {
					ASCompat.setProperty(_loc31_, "pointCount", 1);
				}
			}
		}
	}

	public function initVelocityConstraints(step:B2TimeStep) {
		InitVelocityConstraints(step);
	}

	public function finalizeVelocityConstraints() {
		FinalizeVelocityConstraints();
	}

	public function SolveVelocityConstraints() {
		var __tmpAssignObj31:ASAny;
		var __tmpAssignObj32:ASAny;
		var __tmpAssignObj33:ASAny;
		var __tmpAssignObj34:ASAny;
		var __tmpAssignObj35:ASAny;
		var __tmpAssignObj36:ASAny;
		var __tmpAssignObj37:ASAny;
		var __tmpAssignObj38:ASAny;
		var __tmpAssignObj39:ASAny;
		var __tmpAssignObj40:ASAny;
		var __tmpAssignObj41:ASAny;
		var __tmpAssignObj42:ASAny;
		var __tmpAssignObj43:ASAny;
		var __tmpAssignObj44:ASAny;
		var __tmpAssignObj45:ASAny;
		var __tmpAssignObj46:ASAny;
		var __tmpAssignObj47:ASAny;
		var __tmpAssignObj48:ASAny;
		var __tmpAssignObj49:ASAny;
		var __tmpAssignObj50:ASAny;
		var __tmpAssignObj51:ASAny;
		var __tmpAssignObj52:ASAny;
		var __tmpAssignObj53:ASAny;
		var __tmpAssignObj54:ASAny;
		var _loc2_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc21_ = Math.NaN;
		var _loc22_:ASAny = ASCompat.dynamicAs(null, B2Mat22);
		var _loc26_ = 0;
		var _loc27_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraint);
		var _loc28_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc29_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc30_ = Math.NaN;
		var _loc31_ = Math.NaN;
		var _loc32_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc33_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc34_ = Math.NaN;
		var _loc35_ = Math.NaN;
		var _loc36_ = Math.NaN;
		var _loc37_ = Math.NaN;
		var _loc38_ = Math.NaN;
		var _loc39_ = Math.NaN;
		var _loc40_ = Math.NaN;
		var _loc41_ = Math.NaN;
		var _loc42_ = Math.NaN;
		var _loc44_ = 0;
		var _loc45_ = 0;
		var _loc46_ = 0;
		var _loc47_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		var _loc48_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		var _loc49_ = Math.NaN;
		var _loc50_ = Math.NaN;
		var _loc51_ = Math.NaN;
		var _loc52_ = Math.NaN;
		var _loc53_ = Math.NaN;
		var _loc54_ = Math.NaN;
		var _loc55_ = Math.NaN;
		var _loc56_ = Math.NaN;
		var _loc57_ = Math.NaN;
		var _loc58_ = Math.NaN;
		var _loc59_ = Math.NaN;
		var _loc60_ = Math.NaN;
		var _loc61_ = Math.NaN;
		var _loc24_ = 0;
		var _loc25_ = m_constraintCount;
		while (_loc24_ < _loc25_) {
			_loc26_ = _loc24_++;
			_loc27_ = m_constraints[_loc26_];
			_loc28_ = _loc27_.bodyA;
			_loc29_ = _loc27_.bodyB;
			_loc30_ = ASCompat.toNumberField(_loc28_, "m_angularVelocity");
			_loc31_ = ASCompat.toNumberField(_loc29_, "m_angularVelocity");
			_loc32_ = _loc28_.m_linearVelocity;
			_loc33_ = _loc29_.m_linearVelocity;
			_loc34_ = ASCompat.toNumberField(_loc28_, "m_invMass");
			_loc35_ = ASCompat.toNumberField(_loc28_, "m_invI");
			_loc36_ = ASCompat.toNumberField(_loc29_, "m_invMass");
			_loc37_ = ASCompat.toNumberField(_loc29_, "m_invI");
			_loc38_ = ASCompat.toNumberField(_loc27_.normal, "x");
			_loc40_ = _loc39_ = ASCompat.toNumberField(_loc27_.normal, "y");
			_loc41_ = -_loc38_;
			_loc42_ = ASCompat.toNumberField(_loc27_, "friction");
			_loc44_ = 0;
			_loc45_ = ASCompat.toInt(_loc27_.pointCount);
			while (_loc44_ < _loc45_) {
				_loc46_ = _loc44_++;
				_loc2_ = _loc27_.points[_loc46_];
				_loc7_ = ASCompat.toNumberField(_loc33_, "x") - _loc31_ * ASCompat.toNumberField(_loc2_.rB, "y") - ASCompat.toNumberField(_loc32_, "x")
					+ _loc30_ * ASCompat.toNumberField(_loc2_.rA, "y");
				_loc8_ = ASCompat.toNumber(_loc33_.y + _loc31_ * ASCompat.toNumberField(_loc2_.rB, "x"))
					- ASCompat.toNumberField(_loc32_, "y")
					- _loc30_ * ASCompat.toNumberField(_loc2_.rA, "x");
				_loc10_ = _loc7_ * _loc40_ + _loc8_ * _loc41_;
				_loc11_ = ASCompat.toNumberField(_loc2_, "tangentMass") * -_loc10_;
				_loc12_ = _loc42_ * ASCompat.toNumberField(_loc2_, "normalImpulse");
				_loc13_ = B2Math.clamp(ASCompat.toNumber(_loc2_.tangentImpulse + _loc11_), -_loc12_, _loc12_);
				_loc11_ = _loc13_ - ASCompat.toNumberField(_loc2_, "tangentImpulse");
				_loc14_ = _loc11_ * _loc40_;
				_loc15_ = _loc11_ * _loc41_;
				__tmpAssignObj31 = _loc32_;
				ASCompat.setProperty(__tmpAssignObj31, "x", __tmpAssignObj31.x - _loc34_ * _loc14_);
				__tmpAssignObj32 = _loc32_;
				ASCompat.setProperty(__tmpAssignObj32, "y", __tmpAssignObj32.y - _loc34_ * _loc15_);
				_loc30_ -= _loc35_ * (ASCompat.toNumberField(_loc2_.rA, "x") * _loc15_ - ASCompat.toNumberField(_loc2_.rA, "y") * _loc14_);
				__tmpAssignObj33 = _loc33_;
				ASCompat.setProperty(__tmpAssignObj33, "x", __tmpAssignObj33.x + _loc36_ * _loc14_);
				__tmpAssignObj34 = _loc33_;
				ASCompat.setProperty(__tmpAssignObj34, "y", __tmpAssignObj34.y + _loc36_ * _loc15_);
				_loc31_ += _loc37_ * (ASCompat.toNumberField(_loc2_.rB, "x") * _loc15_ - ASCompat.toNumberField(_loc2_.rB, "y") * _loc14_);
				ASCompat.setProperty(_loc2_, "tangentImpulse", _loc13_);
			}
			_loc44_ = ASCompat.toInt(_loc27_.pointCount);
			if (ASCompat.toNumberField(_loc27_, "pointCount") == 1) {
				_loc2_ = _loc27_.points[0];
				_loc7_ = ASCompat.toNumber(_loc33_.x + -_loc31_ * ASCompat.toNumberField(_loc2_.rB, "y"))
					- ASCompat.toNumberField(_loc32_, "x")
					- -_loc30_ * ASCompat.toNumberField(_loc2_.rA, "y");
				_loc8_ = ASCompat.toNumber(_loc33_.y + _loc31_ * ASCompat.toNumberField(_loc2_.rB, "x"))
					- ASCompat.toNumberField(_loc32_, "y")
					- _loc30_ * ASCompat.toNumberField(_loc2_.rA, "x");
				_loc9_ = _loc7_ * _loc38_ + _loc8_ * _loc39_;
				_loc11_ = -ASCompat.toNumberField(_loc2_, "normalMass") * (_loc9_ - ASCompat.toNumberField(_loc2_, "velocityBias"));
				_loc13_ = ASCompat.toNumber(_loc2_.normalImpulse + _loc11_);
				if (_loc13_ <= 0) {
					_loc13_ = 0;
				}
				_loc11_ = _loc13_ - ASCompat.toNumberField(_loc2_, "normalImpulse");
				_loc14_ = _loc11_ * _loc38_;
				_loc15_ = _loc11_ * _loc39_;
				__tmpAssignObj35 = _loc32_;
				ASCompat.setProperty(__tmpAssignObj35, "x", __tmpAssignObj35.x - _loc34_ * _loc14_);
				__tmpAssignObj36 = _loc32_;
				ASCompat.setProperty(__tmpAssignObj36, "y", __tmpAssignObj36.y - _loc34_ * _loc15_);
				_loc30_ -= _loc35_ * (ASCompat.toNumberField(_loc2_.rA, "x") * _loc15_ - ASCompat.toNumberField(_loc2_.rA, "y") * _loc14_);
				__tmpAssignObj37 = _loc33_;
				ASCompat.setProperty(__tmpAssignObj37, "x", __tmpAssignObj37.x + _loc36_ * _loc14_);
				__tmpAssignObj38 = _loc33_;
				ASCompat.setProperty(__tmpAssignObj38, "y", __tmpAssignObj38.y + _loc36_ * _loc15_);
				_loc31_ += _loc37_ * (ASCompat.toNumberField(_loc2_.rB, "x") * _loc15_ - ASCompat.toNumberField(_loc2_.rB, "y") * _loc14_);
				ASCompat.setProperty(_loc2_, "normalImpulse", _loc13_);
			} else {
				_loc47_ = _loc27_.points[0];
				_loc48_ = _loc27_.points[1];
				_loc49_ = ASCompat.toNumberField(_loc47_, "normalImpulse");
				_loc50_ = ASCompat.toNumberField(_loc48_, "normalImpulse");
				_loc51_ = ASCompat.toNumberField(_loc33_, "x") - _loc31_ * ASCompat.toNumberField(_loc47_.rB, "y") - ASCompat.toNumberField(_loc32_, "x")
					+ _loc30_ * ASCompat.toNumberField(_loc47_.rA, "y");
				_loc52_ = ASCompat.toNumber(_loc33_.y + _loc31_ * ASCompat.toNumberField(_loc47_.rB, "x"))
					- ASCompat.toNumberField(_loc32_, "y")
					- _loc30_ * ASCompat.toNumberField(_loc47_.rA, "x");
				_loc53_ = ASCompat.toNumberField(_loc33_, "x") - _loc31_ * ASCompat.toNumberField(_loc48_.rB, "y") - ASCompat.toNumberField(_loc32_, "x")
					+ _loc30_ * ASCompat.toNumberField(_loc48_.rA, "y");
				_loc54_ = ASCompat.toNumber(_loc33_.y + _loc31_ * ASCompat.toNumberField(_loc48_.rB, "x"))
					- ASCompat.toNumberField(_loc32_, "y")
					- _loc30_ * ASCompat.toNumberField(_loc48_.rA, "x");
				_loc55_ = _loc51_ * _loc38_ + _loc52_ * _loc39_;
				_loc56_ = _loc53_ * _loc38_ + _loc54_ * _loc39_;
				_loc57_ = _loc55_ - ASCompat.toNumberField(_loc47_, "velocityBias");
				_loc58_ = _loc56_ - ASCompat.toNumberField(_loc48_, "velocityBias");
				_loc22_ = _loc27_.K;
				_loc57_ -= ASCompat.toNumberField(_loc22_.col1, "x") * _loc49_ + ASCompat.toNumberField(_loc22_.col2, "x") * _loc50_;
				_loc58_ -= ASCompat.toNumberField(_loc22_.col1, "y") * _loc49_ + ASCompat.toNumberField(_loc22_.col2, "y") * _loc50_;
				_loc59_ = 0.001;
				_loc45_ = 0;
				if (_loc45_ < 1) {
					_loc46_ = _loc45_++;
					_loc22_ = _loc27_.normalMass;
					_loc60_ = -(ASCompat.toNumberField(_loc22_.col1, "x") * _loc57_ + ASCompat.toNumberField(_loc22_.col2, "x") * _loc58_);
					_loc61_ = -(ASCompat.toNumberField(_loc22_.col1, "y") * _loc57_ + ASCompat.toNumberField(_loc22_.col2, "y") * _loc58_);
					if (_loc60_ >= 0 && _loc61_ >= 0) {
						_loc16_ = _loc60_ - _loc49_;
						_loc17_ = _loc61_ - _loc50_;
						_loc18_ = _loc16_ * _loc38_;
						_loc19_ = _loc16_ * _loc39_;
						_loc20_ = _loc17_ * _loc38_;
						_loc21_ = _loc17_ * _loc39_;
						__tmpAssignObj39 = _loc32_;
						ASCompat.setProperty(__tmpAssignObj39, "x", __tmpAssignObj39.x - _loc34_ * (_loc18_ + _loc20_));
						__tmpAssignObj40 = _loc32_;
						ASCompat.setProperty(__tmpAssignObj40, "y", __tmpAssignObj40.y - _loc34_ * (_loc19_ + _loc21_));
						_loc30_ -= _loc35_ * (ASCompat.toNumberField(_loc47_.rA, "x") * _loc19_ - ASCompat.toNumberField(_loc47_.rA, "y") * _loc18_
							+ ASCompat.toNumberField(_loc48_.rA, "x") * _loc21_ - ASCompat.toNumberField(_loc48_.rA, "y") * _loc20_);
						__tmpAssignObj41 = _loc33_;
						ASCompat.setProperty(__tmpAssignObj41, "x", __tmpAssignObj41.x + _loc36_ * (_loc18_ + _loc20_));
						__tmpAssignObj42 = _loc33_;
						ASCompat.setProperty(__tmpAssignObj42, "y", __tmpAssignObj42.y + _loc36_ * (_loc19_ + _loc21_));
						_loc31_ += _loc37_ * (ASCompat.toNumberField(_loc47_.rB, "x") * _loc19_ - ASCompat.toNumberField(_loc47_.rB, "y") * _loc18_
							+ ASCompat.toNumberField(_loc48_.rB, "x") * _loc21_ - ASCompat.toNumberField(_loc48_.rB, "y") * _loc20_);
						ASCompat.setProperty(_loc47_, "normalImpulse", _loc60_);
						ASCompat.setProperty(_loc48_, "normalImpulse", _loc61_);
					} else {
						_loc60_ = -ASCompat.toNumberField(_loc47_, "normalMass") * _loc57_;
						_loc61_ = 0;
						_loc55_ = 0;
						_loc56_ = ASCompat.toNumberField(_loc27_.K.col1, "y") * _loc60_ + _loc58_;
						if (_loc60_ >= 0 && _loc56_ >= 0) {
							_loc16_ = _loc60_ - _loc49_;
							_loc17_ = _loc61_ - _loc50_;
							_loc18_ = _loc16_ * _loc38_;
							_loc19_ = _loc16_ * _loc39_;
							_loc20_ = _loc17_ * _loc38_;
							_loc21_ = _loc17_ * _loc39_;
							__tmpAssignObj43 = _loc32_;
							ASCompat.setProperty(__tmpAssignObj43, "x", __tmpAssignObj43.x - _loc34_ * (_loc18_ + _loc20_));
							__tmpAssignObj44 = _loc32_;
							ASCompat.setProperty(__tmpAssignObj44, "y", __tmpAssignObj44.y - _loc34_ * (_loc19_ + _loc21_));
							_loc30_ -= _loc35_ * (ASCompat.toNumberField(_loc47_.rA, "x") * _loc19_ - ASCompat.toNumberField(_loc47_.rA, "y") * _loc18_
								+ ASCompat.toNumberField(_loc48_.rA, "x") * _loc21_ - ASCompat.toNumberField(_loc48_.rA, "y") * _loc20_);
							__tmpAssignObj45 = _loc33_;
							ASCompat.setProperty(__tmpAssignObj45, "x", __tmpAssignObj45.x + _loc36_ * (_loc18_ + _loc20_));
							__tmpAssignObj46 = _loc33_;
							ASCompat.setProperty(__tmpAssignObj46, "y", __tmpAssignObj46.y + _loc36_ * (_loc19_ + _loc21_));
							_loc31_ += _loc37_ * (ASCompat.toNumberField(_loc47_.rB, "x") * _loc19_ - ASCompat.toNumberField(_loc47_.rB, "y") * _loc18_
								+ ASCompat.toNumberField(_loc48_.rB, "x") * _loc21_ - ASCompat.toNumberField(_loc48_.rB, "y") * _loc20_);
							ASCompat.setProperty(_loc47_, "normalImpulse", _loc60_);
							ASCompat.setProperty(_loc48_, "normalImpulse", _loc61_);
						} else {
							_loc60_ = 0;
							_loc61_ = -ASCompat.toNumberField(_loc48_, "normalMass") * _loc58_;
							_loc55_ = ASCompat.toNumberField(_loc27_.K.col2, "x") * _loc61_ + _loc57_;
							_loc56_ = 0;
							if (_loc61_ >= 0 && _loc55_ >= 0) {
								_loc16_ = _loc60_ - _loc49_;
								_loc17_ = _loc61_ - _loc50_;
								_loc18_ = _loc16_ * _loc38_;
								_loc19_ = _loc16_ * _loc39_;
								_loc20_ = _loc17_ * _loc38_;
								_loc21_ = _loc17_ * _loc39_;
								__tmpAssignObj47 = _loc32_;
								ASCompat.setProperty(__tmpAssignObj47, "x", __tmpAssignObj47.x - _loc34_ * (_loc18_ + _loc20_));
								__tmpAssignObj48 = _loc32_;
								ASCompat.setProperty(__tmpAssignObj48, "y", __tmpAssignObj48.y - _loc34_ * (_loc19_ + _loc21_));
								_loc30_ -= _loc35_ * (ASCompat.toNumberField(_loc47_.rA, "x") * _loc19_ - ASCompat.toNumberField(_loc47_.rA, "y") * _loc18_
									+ ASCompat.toNumberField(_loc48_.rA, "x") * _loc21_ - ASCompat.toNumberField(_loc48_.rA, "y") * _loc20_);
								__tmpAssignObj49 = _loc33_;
								ASCompat.setProperty(__tmpAssignObj49, "x", __tmpAssignObj49.x + _loc36_ * (_loc18_ + _loc20_));
								__tmpAssignObj50 = _loc33_;
								ASCompat.setProperty(__tmpAssignObj50, "y", __tmpAssignObj50.y + _loc36_ * (_loc19_ + _loc21_));
								_loc31_ += _loc37_ * (ASCompat.toNumberField(_loc47_.rB, "x") * _loc19_ - ASCompat.toNumberField(_loc47_.rB, "y") * _loc18_
									+ ASCompat.toNumberField(_loc48_.rB, "x") * _loc21_ - ASCompat.toNumberField(_loc48_.rB, "y") * _loc20_);
								ASCompat.setProperty(_loc47_, "normalImpulse", _loc60_);
								ASCompat.setProperty(_loc48_, "normalImpulse", _loc61_);
							} else {
								_loc60_ = 0;
								_loc61_ = 0;
								_loc55_ = _loc57_;
								_loc56_ = _loc58_;
								if (_loc55_ >= 0 && _loc56_ >= 0) {
									_loc16_ = _loc60_ - _loc49_;
									_loc17_ = _loc61_ - _loc50_;
									_loc18_ = _loc16_ * _loc38_;
									_loc19_ = _loc16_ * _loc39_;
									_loc20_ = _loc17_ * _loc38_;
									_loc21_ = _loc17_ * _loc39_;
									__tmpAssignObj51 = _loc32_;
									ASCompat.setProperty(__tmpAssignObj51, "x", __tmpAssignObj51.x - _loc34_ * (_loc18_ + _loc20_));
									__tmpAssignObj52 = _loc32_;
									ASCompat.setProperty(__tmpAssignObj52, "y", __tmpAssignObj52.y - _loc34_ * (_loc19_ + _loc21_));
									_loc30_ -= _loc35_ * (ASCompat.toNumberField(_loc47_.rA, "x") * _loc19_
										- ASCompat.toNumberField(_loc47_.rA, "y") * _loc18_ + ASCompat.toNumberField(_loc48_.rA, "x") * _loc21_
										- ASCompat.toNumberField(_loc48_.rA, "y") * _loc20_);
									__tmpAssignObj53 = _loc33_;
									ASCompat.setProperty(__tmpAssignObj53, "x", __tmpAssignObj53.x + _loc36_ * (_loc18_ + _loc20_));
									__tmpAssignObj54 = _loc33_;
									ASCompat.setProperty(__tmpAssignObj54, "y", __tmpAssignObj54.y + _loc36_ * (_loc19_ + _loc21_));
									_loc31_ += _loc37_ * (ASCompat.toNumberField(_loc47_.rB, "x") * _loc19_
										- ASCompat.toNumberField(_loc47_.rB, "y") * _loc18_ + ASCompat.toNumberField(_loc48_.rB, "x") * _loc21_
										- ASCompat.toNumberField(_loc48_.rB, "y") * _loc20_);
									ASCompat.setProperty(_loc47_, "normalImpulse", _loc60_);
									ASCompat.setProperty(_loc48_, "normalImpulse", _loc61_);
								}
							}
						}
					}
				}
			}
			ASCompat.setProperty(_loc28_, "m_angularVelocity", _loc30_);
			ASCompat.setProperty(_loc29_, "m_angularVelocity", _loc31_);
		}
	}

	public function SolvePositionConstraints(baumgarte:Float):Bool {
		var __tmpAssignObj55:ASAny;
		var __tmpAssignObj56:ASAny;
		var __tmpAssignObj57:ASAny;
		var __tmpAssignObj58:ASAny;
		var __tmpAssignObj59:ASAny;
		var __tmpAssignObj60:ASAny;
		var _loc5_ = 0;
		var _loc6_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraint);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc9_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc14_ = 0;
		var _loc15_ = 0;
		var _loc16_ = 0;
		var _loc17_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		var _loc18_:ASAny = ASCompat.dynamicAs(null, B2Vec2);
		var _loc19_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc21_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc23_ = Math.NaN;
		var _loc24_ = Math.NaN;
		var _loc25_ = Math.NaN;
		var _loc26_ = Math.NaN;
		var _loc27_ = Math.NaN;
		var _loc2_:Float = 0;
		var _loc3_ = 0;
		var _loc4_ = m_constraintCount;
		while (_loc3_ < _loc4_) {
			_loc5_ = _loc3_++;
			_loc6_ = m_constraints[_loc5_];
			_loc7_ = _loc6_.bodyA;
			_loc8_ = _loc6_.bodyB;
			_loc9_ = ASCompat.toNumberField(_loc7_, "m_mass") * ASCompat.toNumberField(_loc7_, "m_invMass");
			_loc10_ = ASCompat.toNumberField(_loc7_, "m_mass") * ASCompat.toNumberField(_loc7_, "m_invI");
			_loc11_ = ASCompat.toNumberField(_loc8_, "m_mass") * ASCompat.toNumberField(_loc8_, "m_invMass");
			_loc12_ = ASCompat.toNumberField(_loc8_, "m_mass") * ASCompat.toNumberField(_loc8_, "m_invI");
			B2ContactSolver.s_psm.initialize(ASCompat.coerce(_loc6_, box2D.dynamics.contacts.B2ContactConstraint));
			_loc13_ = B2ContactSolver.s_psm.m_normal;
			_loc14_ = 0;
			_loc15_ = ASCompat.toInt(_loc6_.pointCount);
			while (_loc14_ < _loc15_) {
				_loc16_ = _loc14_++;
				_loc17_ = _loc6_.points[_loc16_];
				_loc18_ = B2ContactSolver.s_psm.m_points[_loc16_];
				_loc19_ = ASCompat.toNumber(B2ContactSolver.s_psm.m_separations[_loc16_]);
				_loc20_ = ASCompat.toNumberField(_loc18_, "x") - ASCompat.toNumberField(_loc7_.m_sweep.c, "x");
				_loc21_ = ASCompat.toNumberField(_loc18_, "y") - ASCompat.toNumberField(_loc7_.m_sweep.c, "y");
				_loc22_ = ASCompat.toNumberField(_loc18_, "x") - ASCompat.toNumberField(_loc8_.m_sweep.c, "x");
				_loc23_ = ASCompat.toNumberField(_loc18_, "y") - ASCompat.toNumberField(_loc8_.m_sweep.c, "y");
				if (_loc2_ >= _loc19_) {
					_loc2_ = _loc19_;
				}
				_loc24_ = B2Math.clamp(baumgarte * (_loc19_ + B2Settings.b2_linearSlop), -B2Settings.b2_maxLinearCorrection, 0);
				_loc25_ = -ASCompat.toNumberField(_loc17_, "equalizedMass") * _loc24_;
				_loc26_ = _loc25_ * ASCompat.toNumberField(_loc13_, "x");
				_loc27_ = _loc25_ * ASCompat.toNumberField(_loc13_, "y");
				__tmpAssignObj55 = _loc7_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj55, "x", __tmpAssignObj55.x - _loc9_ * _loc26_);
				__tmpAssignObj56 = _loc7_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj56, "y", __tmpAssignObj56.y - _loc9_ * _loc27_);
				__tmpAssignObj57 = _loc7_.m_sweep;
				ASCompat.setProperty(__tmpAssignObj57, "a", __tmpAssignObj57.a - _loc10_ * (_loc20_ * _loc27_ - _loc21_ * _loc26_));
				_loc7_.synchronizeTransform();
				__tmpAssignObj58 = _loc8_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj58, "x", __tmpAssignObj58.x + _loc11_ * _loc26_);
				__tmpAssignObj59 = _loc8_.m_sweep.c;
				ASCompat.setProperty(__tmpAssignObj59, "y", __tmpAssignObj59.y + _loc11_ * _loc27_);
				__tmpAssignObj60 = _loc8_.m_sweep;
				ASCompat.setProperty(__tmpAssignObj60, "a", __tmpAssignObj60.a + _loc12_ * (_loc22_ * _loc27_ - _loc23_ * _loc26_));
				_loc8_.synchronizeTransform();
			}
		}
		return _loc2_ > -1.5 * B2Settings.b2_linearSlop;
	}

	public function Initialize(step:B2TimeStep, contacts:ASAny, contactCount:Int, allocator:ASAny) {
		initialize(step, As3Array.of(contacts), contactCount, allocator);
	}

	public function InitVelocityConstraints(step:B2TimeStep) {
		var __tmpAssignObj61:ASAny;
		var __tmpAssignObj62:ASAny;
		var __tmpAssignObj63:ASAny;
		var __tmpAssignObj64:ASAny;
		var __tmpAssignObj65:ASAny;
		var __tmpAssignObj66:ASAny;
		var __tmpAssignObj67:ASAny;
		var __tmpAssignObj68:ASAny;
		var _loc7_ = 0;
		var _loc8_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraint);
		var _loc9_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc10_:ASAny = ASCompat.dynamicAs(null, B2Body);
		var _loc11_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc21_ = 0;
		var _loc22_ = 0;
		var _loc23_ = 0;
		var _loc24_ = 0;
		var _loc25_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		var _loc26_ = Math.NaN;
		var _loc27_ = Math.NaN;
		var _loc5_ = 0;
		var _loc6_ = m_constraintCount;
		while (_loc5_ < _loc6_) {
			_loc7_ = _loc5_++;
			_loc8_ = m_constraints[_loc7_];
			_loc9_ = _loc8_.bodyA;
			_loc10_ = _loc8_.bodyB;
			_loc11_ = ASCompat.toNumberField(_loc9_, "m_invMass");
			_loc12_ = ASCompat.toNumberField(_loc9_, "m_invI");
			_loc13_ = ASCompat.toNumberField(_loc10_, "m_invMass");
			_loc14_ = ASCompat.toNumberField(_loc10_, "m_invI");
			_loc15_ = ASCompat.toNumberField(_loc8_.normal, "x");
			_loc17_ = _loc16_ = ASCompat.toNumberField(_loc8_.normal, "y");
			_loc18_ = -_loc15_;
			if (step.warmStarting) {
				_loc21_ = ASCompat.toInt(_loc8_.pointCount);
				_loc22_ = 0;
				_loc23_ = _loc21_;
				while (_loc22_ < _loc23_) {
					_loc24_ = _loc22_++;
					_loc25_ = _loc8_.points[_loc24_];
					__tmpAssignObj61 = _loc25_;
					ASCompat.setProperty(__tmpAssignObj61, "normalImpulse", __tmpAssignObj61.normalImpulse * step.dtRatio);
					__tmpAssignObj62 = _loc25_;
					ASCompat.setProperty(__tmpAssignObj62, "tangentImpulse", __tmpAssignObj62.tangentImpulse * step.dtRatio);
					_loc26_ = ASCompat.toNumberField(_loc25_, "normalImpulse") * _loc15_ + ASCompat.toNumberField(_loc25_, "tangentImpulse") * _loc17_;
					_loc27_ = ASCompat.toNumberField(_loc25_, "normalImpulse") * _loc16_ + ASCompat.toNumberField(_loc25_, "tangentImpulse") * _loc18_;
					__tmpAssignObj63 = _loc9_;
					ASCompat.setProperty(__tmpAssignObj63, "m_angularVelocity",
						__tmpAssignObj63.m_angularVelocity - _loc12_ * (ASCompat.toNumberField(_loc25_.rA, "x") * _loc27_
							- ASCompat.toNumberField(_loc25_.rA, "y") * _loc26_));
					__tmpAssignObj64 = _loc9_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj64, "x", __tmpAssignObj64.x - _loc11_ * _loc26_);
					__tmpAssignObj65 = _loc9_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj65, "y", __tmpAssignObj65.y - _loc11_ * _loc27_);
					__tmpAssignObj66 = _loc10_;
					ASCompat.setProperty(__tmpAssignObj66, "m_angularVelocity",
						__tmpAssignObj66.m_angularVelocity + _loc14_ * (ASCompat.toNumberField(_loc25_.rB, "x") * _loc27_
							- ASCompat.toNumberField(_loc25_.rB, "y") * _loc26_));
					__tmpAssignObj67 = _loc10_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj67, "x", __tmpAssignObj67.x + _loc13_ * _loc26_);
					__tmpAssignObj68 = _loc10_.m_linearVelocity;
					ASCompat.setProperty(__tmpAssignObj68, "y", __tmpAssignObj68.y + _loc13_ * _loc27_);
				}
			} else {
				_loc21_ = ASCompat.toInt(_loc8_.pointCount);
				_loc22_ = 0;
				_loc23_ = _loc21_;
				while (_loc22_ < _loc23_) {
					_loc24_ = _loc22_++;
					_loc25_ = _loc8_.points[_loc24_];
					ASCompat.setProperty(_loc25_, "normalImpulse", 0);
					ASCompat.setProperty(_loc25_, "tangentImpulse", 0);
				}
			}
		}
	}

	public function FinalizeVelocityConstraints() {
		var _loc3_ = 0;
		var _loc4_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraint);
		var _loc5_:ASAny = ASCompat.dynamicAs(null, B2Manifold);
		var _loc6_ = 0;
		var _loc7_ = 0;
		var _loc8_ = 0;
		var _loc9_:ASAny = ASCompat.dynamicAs(null, B2ManifoldPoint);
		var _loc10_:ASAny = ASCompat.dynamicAs(null, B2ContactConstraintPoint);
		var _loc1_ = 0;
		var _loc2_ = m_constraintCount;
		while (_loc1_ < _loc2_) {
			_loc3_ = _loc1_++;
			_loc4_ = m_constraints[_loc3_];
			_loc5_ = _loc4_.manifold;
			_loc6_ = 0;
			_loc7_ = ASCompat.toInt(_loc4_.pointCount);
			while (_loc6_ < _loc7_) {
				_loc8_ = _loc6_++;
				_loc9_ = _loc5_.m_points[_loc8_];
				_loc10_ = _loc4_.points[_loc8_];
				ASCompat.setProperty(_loc9_, "m_normalImpulse", _loc10_.normalImpulse);
				ASCompat.setProperty(_loc9_, "m_tangentImpulse", _loc10_.tangentImpulse);
			}
		}
	}
}
