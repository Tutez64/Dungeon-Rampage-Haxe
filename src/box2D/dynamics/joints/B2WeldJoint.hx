package box2D.dynamics.joints
;
   import box2D.common.math.B2Mat22;
   import box2D.common.math.B2Mat33;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Vec2;
   import box2D.common.math.B2Vec3;
   import box2D.common.B2Settings;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2TimeStep;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2WeldJoint extends B2Joint
   {
      
      var m_localAnchorA:B2Vec2 = new B2Vec2();
      
      var m_localAnchorB:B2Vec2 = new B2Vec2();
      
      var m_referenceAngle:Float = Math.NaN;
      
      var m_impulse:B2Vec3 = new B2Vec3();
      
      var m_mass:B2Mat33 = new B2Mat33();
      
      public function new(param1:B2WeldJointDef)
      {
         super(param1);
         this.m_localAnchorA.SetV(param1.localAnchorA);
         this.m_localAnchorB.SetV(param1.localAnchorB);
         this.m_referenceAngle = param1.referenceAngle;
         this.m_impulse.SetZero();
         this.m_mass = new B2Mat33();
      }
      
      override public function GetAnchorA() : B2Vec2
      {
         return /*b2internal::*/m_bodyA.GetWorldPoint(this.m_localAnchorA);
      }
      
      override public function GetAnchorB() : B2Vec2
      {
         return /*b2internal::*/m_bodyB.GetWorldPoint(this.m_localAnchorB);
      }
      
      override public function GetReactionForce(param1:Float) : B2Vec2
      {
         return new B2Vec2(param1 * this.m_impulse.x,param1 * this.m_impulse.y);
      }
      
      override public function GetReactionTorque(param1:Float) : Float
      {
         return param1 * this.m_impulse.z;
      }
      
      override public function InitVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc2_:B2Mat22 = null;
         var _loc3_= Math.NaN;
         var _loc4_:B2Body = null;
         var _loc5_:B2Body = null;
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         _loc4_ = /*b2internal::*/m_bodyA;
         _loc5_ = /*b2internal::*/m_bodyB;
         _loc2_ = _loc4_/*b2internal::*/.m_xf.R;
         _loc6_ = this.m_localAnchorA.x - _loc4_/*b2internal::*/.m_sweep.localCenter.x;
         _loc7_ = this.m_localAnchorA.y - _loc4_/*b2internal::*/.m_sweep.localCenter.y;
         _loc3_ = _loc2_.col1.x * _loc6_ + _loc2_.col2.x * _loc7_;
         _loc7_ = _loc2_.col1.y * _loc6_ + _loc2_.col2.y * _loc7_;
         _loc6_ = _loc3_;
         _loc2_ = _loc5_/*b2internal::*/.m_xf.R;
         _loc8_ = this.m_localAnchorB.x - _loc5_/*b2internal::*/.m_sweep.localCenter.x;
         _loc9_ = this.m_localAnchorB.y - _loc5_/*b2internal::*/.m_sweep.localCenter.y;
         _loc3_ = _loc2_.col1.x * _loc8_ + _loc2_.col2.x * _loc9_;
         _loc9_ = _loc2_.col1.y * _loc8_ + _loc2_.col2.y * _loc9_;
         _loc8_ = _loc3_;
         _loc10_ = _loc4_/*b2internal::*/.m_invMass;
         _loc11_ = _loc5_/*b2internal::*/.m_invMass;
         _loc12_ = _loc4_/*b2internal::*/.m_invI;
         _loc13_ = _loc5_/*b2internal::*/.m_invI;
         this.m_mass.col1.x = _loc10_ + _loc11_ + _loc7_ * _loc7_ * _loc12_ + _loc9_ * _loc9_ * _loc13_;
         this.m_mass.col2.x = -_loc7_ * _loc6_ * _loc12_ - _loc9_ * _loc8_ * _loc13_;
         this.m_mass.col3.x = -_loc7_ * _loc12_ - _loc9_ * _loc13_;
         this.m_mass.col1.y = this.m_mass.col2.x;
         this.m_mass.col2.y = _loc10_ + _loc11_ + _loc6_ * _loc6_ * _loc12_ + _loc8_ * _loc8_ * _loc13_;
         this.m_mass.col3.y = _loc6_ * _loc12_ + _loc8_ * _loc13_;
         this.m_mass.col1.z = this.m_mass.col3.x;
         this.m_mass.col2.z = this.m_mass.col3.y;
         this.m_mass.col3.z = _loc12_ + _loc13_;
         if(param1.warmStarting)
         {
            this.m_impulse.x *= param1.dtRatio;
            this.m_impulse.y *= param1.dtRatio;
            this.m_impulse.z *= param1.dtRatio;
            _loc4_/*b2internal::*/.m_linearVelocity.x -= _loc10_ * this.m_impulse.x;
            _loc4_/*b2internal::*/.m_linearVelocity.y -= _loc10_ * this.m_impulse.y;
            _loc4_/*b2internal::*/.m_angularVelocity -= _loc12_ * (_loc6_ * this.m_impulse.y - _loc7_ * this.m_impulse.x + this.m_impulse.z);
            _loc5_/*b2internal::*/.m_linearVelocity.x += _loc11_ * this.m_impulse.x;
            _loc5_/*b2internal::*/.m_linearVelocity.y += _loc11_ * this.m_impulse.y;
            _loc5_/*b2internal::*/.m_angularVelocity += _loc13_ * (_loc8_ * this.m_impulse.y - _loc9_ * this.m_impulse.x + this.m_impulse.z);
         }
         else
         {
            this.m_impulse.SetZero();
         }
      }
      
      override public function SolveVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc2_:B2Mat22 = null;
         var _loc3_= Math.NaN;
         var _loc4_= /*b2internal::*/m_bodyA;
         var _loc5_= /*b2internal::*/m_bodyB;
         var _loc6_= _loc4_/*b2internal::*/.m_linearVelocity;
         var _loc7_= _loc4_/*b2internal::*/.m_angularVelocity;
         var _loc8_= _loc5_/*b2internal::*/.m_linearVelocity;
         var _loc9_= _loc5_/*b2internal::*/.m_angularVelocity;
         var _loc10_= _loc4_/*b2internal::*/.m_invMass;
         var _loc11_= _loc5_/*b2internal::*/.m_invMass;
         var _loc12_= _loc4_/*b2internal::*/.m_invI;
         var _loc13_= _loc5_/*b2internal::*/.m_invI;
         _loc2_ = _loc4_/*b2internal::*/.m_xf.R;
         var _loc14_= this.m_localAnchorA.x - _loc4_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc15_= this.m_localAnchorA.y - _loc4_/*b2internal::*/.m_sweep.localCenter.y;
         _loc3_ = _loc2_.col1.x * _loc14_ + _loc2_.col2.x * _loc15_;
         _loc15_ = _loc2_.col1.y * _loc14_ + _loc2_.col2.y * _loc15_;
         _loc14_ = _loc3_;
         _loc2_ = _loc5_/*b2internal::*/.m_xf.R;
         var _loc16_= this.m_localAnchorB.x - _loc5_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc17_= this.m_localAnchorB.y - _loc5_/*b2internal::*/.m_sweep.localCenter.y;
         _loc3_ = _loc2_.col1.x * _loc16_ + _loc2_.col2.x * _loc17_;
         _loc17_ = _loc2_.col1.y * _loc16_ + _loc2_.col2.y * _loc17_;
         _loc16_ = _loc3_;
         var _loc18_= _loc8_.x - _loc9_ * _loc17_ - _loc6_.x + _loc7_ * _loc15_;
         var _loc19_= _loc8_.y + _loc9_ * _loc16_ - _loc6_.y - _loc7_ * _loc14_;
         var _loc20_= _loc9_ - _loc7_;
         var _loc21_= new B2Vec3();
         this.m_mass.Solve33(_loc21_,-_loc18_,-_loc19_,-_loc20_);
         this.m_impulse.Add(_loc21_);
         _loc6_.x -= _loc10_ * _loc21_.x;
         _loc6_.y -= _loc10_ * _loc21_.y;
         _loc7_ -= _loc12_ * (_loc14_ * _loc21_.y - _loc15_ * _loc21_.x + _loc21_.z);
         _loc8_.x += _loc11_ * _loc21_.x;
         _loc8_.y += _loc11_ * _loc21_.y;
         _loc9_ += _loc13_ * (_loc16_ * _loc21_.y - _loc17_ * _loc21_.x + _loc21_.z);
         _loc4_/*b2internal::*/.m_angularVelocity = _loc7_;
         _loc5_/*b2internal::*/.m_angularVelocity = _loc9_;
      }
      
      override public function SolvePositionConstraints(param1:Float) : Bool
      {
         var _loc2_:B2Mat22 = null;
         var _loc3_= Math.NaN;
         var _loc4_= /*b2internal::*/m_bodyA;
         var _loc5_= /*b2internal::*/m_bodyB;
         _loc2_ = _loc4_/*b2internal::*/.m_xf.R;
         var _loc6_= this.m_localAnchorA.x - _loc4_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc7_= this.m_localAnchorA.y - _loc4_/*b2internal::*/.m_sweep.localCenter.y;
         _loc3_ = _loc2_.col1.x * _loc6_ + _loc2_.col2.x * _loc7_;
         _loc7_ = _loc2_.col1.y * _loc6_ + _loc2_.col2.y * _loc7_;
         _loc6_ = _loc3_;
         _loc2_ = _loc5_/*b2internal::*/.m_xf.R;
         var _loc8_= this.m_localAnchorB.x - _loc5_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc9_= this.m_localAnchorB.y - _loc5_/*b2internal::*/.m_sweep.localCenter.y;
         _loc3_ = _loc2_.col1.x * _loc8_ + _loc2_.col2.x * _loc9_;
         _loc9_ = _loc2_.col1.y * _loc8_ + _loc2_.col2.y * _loc9_;
         _loc8_ = _loc3_;
         var _loc10_= _loc4_/*b2internal::*/.m_invMass;
         var _loc11_= _loc5_/*b2internal::*/.m_invMass;
         var _loc12_= _loc4_/*b2internal::*/.m_invI;
         var _loc13_= _loc5_/*b2internal::*/.m_invI;
         var _loc14_= _loc5_/*b2internal::*/.m_sweep.c.x + _loc8_ - _loc4_/*b2internal::*/.m_sweep.c.x - _loc6_;
         var _loc15_= _loc5_/*b2internal::*/.m_sweep.c.y + _loc9_ - _loc4_/*b2internal::*/.m_sweep.c.y - _loc7_;
         var _loc16_= _loc5_/*b2internal::*/.m_sweep.a - _loc4_/*b2internal::*/.m_sweep.a - this.m_referenceAngle;
         var _loc17_= 10 * B2Settings.b2_linearSlop;
         var _loc18_= Math.sqrt(_loc14_ * _loc14_ + _loc15_ * _loc15_);
         var _loc19_= B2Math.Abs(_loc16_);
         if(_loc18_ > _loc17_)
         {
            _loc12_ *= 1;
            _loc13_ *= 1;
         }
         this.m_mass.col1.x = _loc10_ + _loc11_ + _loc7_ * _loc7_ * _loc12_ + _loc9_ * _loc9_ * _loc13_;
         this.m_mass.col2.x = -_loc7_ * _loc6_ * _loc12_ - _loc9_ * _loc8_ * _loc13_;
         this.m_mass.col3.x = -_loc7_ * _loc12_ - _loc9_ * _loc13_;
         this.m_mass.col1.y = this.m_mass.col2.x;
         this.m_mass.col2.y = _loc10_ + _loc11_ + _loc6_ * _loc6_ * _loc12_ + _loc8_ * _loc8_ * _loc13_;
         this.m_mass.col3.y = _loc6_ * _loc12_ + _loc8_ * _loc13_;
         this.m_mass.col1.z = this.m_mass.col3.x;
         this.m_mass.col2.z = this.m_mass.col3.y;
         this.m_mass.col3.z = _loc12_ + _loc13_;
         var _loc20_= new B2Vec3();
         this.m_mass.Solve33(_loc20_,-_loc14_,-_loc15_,-_loc16_);
         _loc4_/*b2internal::*/.m_sweep.c.x -= _loc10_ * _loc20_.x;
         _loc4_/*b2internal::*/.m_sweep.c.y -= _loc10_ * _loc20_.y;
         _loc4_/*b2internal::*/.m_sweep.a -= _loc12_ * (_loc6_ * _loc20_.y - _loc7_ * _loc20_.x + _loc20_.z);
         _loc5_/*b2internal::*/.m_sweep.c.x += _loc11_ * _loc20_.x;
         _loc5_/*b2internal::*/.m_sweep.c.y += _loc11_ * _loc20_.y;
         _loc5_/*b2internal::*/.m_sweep.a += _loc13_ * (_loc8_ * _loc20_.y - _loc9_ * _loc20_.x + _loc20_.z);
         _loc4_/*b2internal::*/.SynchronizeTransform();
         _loc5_/*b2internal::*/.SynchronizeTransform();
         return _loc18_ <= B2Settings.b2_linearSlop && _loc19_ <= B2Settings.b2_angularSlop;
      }
   }


