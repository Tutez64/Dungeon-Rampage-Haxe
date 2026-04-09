package box2D.dynamics.joints
;
   import box2D.common.math.B2Mat22;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Settings;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2TimeStep;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2PulleyJoint extends B2Joint
   {
      
      /*b2internal*/ public static inline final b2_minPulleyLength:Float = 2;
      
      var m_ground:B2Body;
      
      var m_groundAnchor1:B2Vec2;
      
      var m_groundAnchor2:B2Vec2;
      
      var m_localAnchor1:B2Vec2;
      
      var m_localAnchor2:B2Vec2;
      
      var m_u1:B2Vec2;
      
      var m_u2:B2Vec2;
      
      var m_constant:Float = Math.NaN;
      
      var m_ratio:Float = Math.NaN;
      
      var m_maxLength1:Float = Math.NaN;
      
      var m_maxLength2:Float = Math.NaN;
      
      var m_pulleyMass:Float = Math.NaN;
      
      var m_limitMass1:Float = Math.NaN;
      
      var m_limitMass2:Float = Math.NaN;
      
      var m_impulse:Float = Math.NaN;
      
      var m_limitImpulse1:Float = Math.NaN;
      
      var m_limitImpulse2:Float = Math.NaN;
      
      var m_state:Int = 0;
      
      var m_limitState1:Int = 0;
      
      var m_limitState2:Int = 0;
      
      public function new(param1:B2PulleyJointDef)
      {
         var _loc2_:B2Mat22 = null;
         var _loc3_= Math.NaN;
         var _loc4_= Math.NaN;
         this.m_groundAnchor1 = new B2Vec2();
         this.m_groundAnchor2 = new B2Vec2();
         this.m_localAnchor1 = new B2Vec2();
         this.m_localAnchor2 = new B2Vec2();
         this.m_u1 = new B2Vec2();
         this.m_u2 = new B2Vec2();
         super(param1);
         this.m_ground = /*b2internal::*/m_bodyA/*b2internal::*/.m_world/*b2internal::*/.m_groundBody;
         this.m_groundAnchor1.x = param1.groundAnchorA.x - this.m_ground/*b2internal::*/.m_xf.position.x;
         this.m_groundAnchor1.y = param1.groundAnchorA.y - this.m_ground/*b2internal::*/.m_xf.position.y;
         this.m_groundAnchor2.x = param1.groundAnchorB.x - this.m_ground/*b2internal::*/.m_xf.position.x;
         this.m_groundAnchor2.y = param1.groundAnchorB.y - this.m_ground/*b2internal::*/.m_xf.position.y;
         this.m_localAnchor1.SetV(param1.localAnchorA);
         this.m_localAnchor2.SetV(param1.localAnchorB);
         this.m_ratio = param1.ratio;
         this.m_constant = param1.lengthA + this.m_ratio * param1.lengthB;
         this.m_maxLength1 = B2Math.Min(param1.maxLengthA,this.m_constant - this.m_ratio * /*b2internal::*/b2_minPulleyLength);
         this.m_maxLength2 = B2Math.Min(param1.maxLengthB,(this.m_constant - /*b2internal::*/b2_minPulleyLength) / this.m_ratio);
         this.m_impulse = 0;
         this.m_limitImpulse1 = 0;
         this.m_limitImpulse2 = 0;
      }
      
      override public function GetAnchorA() : B2Vec2
      {
         return /*b2internal::*/m_bodyA.GetWorldPoint(this.m_localAnchor1);
      }
      
      override public function GetAnchorB() : B2Vec2
      {
         return /*b2internal::*/m_bodyB.GetWorldPoint(this.m_localAnchor2);
      }
      
      override public function GetReactionForce(param1:Float) : B2Vec2
      {
         return new B2Vec2(param1 * this.m_impulse * this.m_u2.x,param1 * this.m_impulse * this.m_u2.y);
      }
      
      override public function GetReactionTorque(param1:Float) : Float
      {
         return 0;
      }
      
      public function GetGroundAnchorA() : B2Vec2
      {
         var _loc1_= this.m_ground/*b2internal::*/.m_xf.position.Copy();
         _loc1_.Add(this.m_groundAnchor1);
         return _loc1_;
      }
      
      public function GetGroundAnchorB() : B2Vec2
      {
         var _loc1_= this.m_ground/*b2internal::*/.m_xf.position.Copy();
         _loc1_.Add(this.m_groundAnchor2);
         return _loc1_;
      }
      
      public function GetLength1() : Float
      {
         var _loc1_= /*b2internal::*/m_bodyA.GetWorldPoint(this.m_localAnchor1);
         var _loc2_= this.m_ground/*b2internal::*/.m_xf.position.x + this.m_groundAnchor1.x;
         var _loc3_= this.m_ground/*b2internal::*/.m_xf.position.y + this.m_groundAnchor1.y;
         var _loc4_= _loc1_.x - _loc2_;
         var _loc5_= _loc1_.y - _loc3_;
         return Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
      }
      
      public function GetLength2() : Float
      {
         var _loc1_= /*b2internal::*/m_bodyB.GetWorldPoint(this.m_localAnchor2);
         var _loc2_= this.m_ground/*b2internal::*/.m_xf.position.x + this.m_groundAnchor2.x;
         var _loc3_= this.m_ground/*b2internal::*/.m_xf.position.y + this.m_groundAnchor2.y;
         var _loc4_= _loc1_.x - _loc2_;
         var _loc5_= _loc1_.y - _loc3_;
         return Math.sqrt(_loc4_ * _loc4_ + _loc5_ * _loc5_);
      }
      
      public function GetRatio() : Float
      {
         return this.m_ratio;
      }
      
      override public function InitVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc2_:B2Body = null;
         var _loc3_:B2Body = null;
         var _loc4_:B2Mat22 = null;
         var _loc6_= Math.NaN;
         var _loc23_= Math.NaN;
         var _loc24_= Math.NaN;
         var _loc25_= Math.NaN;
         var _loc26_= Math.NaN;
         _loc2_ = /*b2internal::*/m_bodyA;
         _loc3_ = /*b2internal::*/m_bodyB;
         _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
         var _loc5_= this.m_localAnchor1.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
         _loc6_ = this.m_localAnchor1.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
         var _loc7_= _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
         _loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
         _loc5_ = _loc7_;
         _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
         var _loc8_= this.m_localAnchor2.x - _loc3_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc9_= this.m_localAnchor2.y - _loc3_/*b2internal::*/.m_sweep.localCenter.y;
         _loc7_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
         _loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
         _loc8_ = _loc7_;
         var _loc10_= _loc2_/*b2internal::*/.m_sweep.c.x + _loc5_;
         var _loc11_= _loc2_/*b2internal::*/.m_sweep.c.y + _loc6_;
         var _loc12_= _loc3_/*b2internal::*/.m_sweep.c.x + _loc8_;
         var _loc13_= _loc3_/*b2internal::*/.m_sweep.c.y + _loc9_;
         var _loc14_= this.m_ground/*b2internal::*/.m_xf.position.x + this.m_groundAnchor1.x;
         var _loc15_= this.m_ground/*b2internal::*/.m_xf.position.y + this.m_groundAnchor1.y;
         var _loc16_= this.m_ground/*b2internal::*/.m_xf.position.x + this.m_groundAnchor2.x;
         var _loc17_= this.m_ground/*b2internal::*/.m_xf.position.y + this.m_groundAnchor2.y;
         this.m_u1.Set(_loc10_ - _loc14_,_loc11_ - _loc15_);
         this.m_u2.Set(_loc12_ - _loc16_,_loc13_ - _loc17_);
         var _loc18_= this.m_u1.Length();
         var _loc19_= this.m_u2.Length();
         if(_loc18_ > B2Settings.b2_linearSlop)
         {
            this.m_u1.Multiply(1 / _loc18_);
         }
         else
         {
            this.m_u1.SetZero();
         }
         if(_loc19_ > B2Settings.b2_linearSlop)
         {
            this.m_u2.Multiply(1 / _loc19_);
         }
         else
         {
            this.m_u2.SetZero();
         }
         var _loc20_= this.m_constant - _loc18_ - this.m_ratio * _loc19_;
         if(_loc20_ > 0)
         {
            this.m_state = /*b2internal::*/B2Joint.e_inactiveLimit;
            this.m_impulse = 0;
         }
         else
         {
            this.m_state = /*b2internal::*/B2Joint.e_atUpperLimit;
         }
         if(_loc18_ < this.m_maxLength1)
         {
            this.m_limitState1 = /*b2internal::*/B2Joint.e_inactiveLimit;
            this.m_limitImpulse1 = 0;
         }
         else
         {
            this.m_limitState1 = /*b2internal::*/B2Joint.e_atUpperLimit;
         }
         if(_loc19_ < this.m_maxLength2)
         {
            this.m_limitState2 = /*b2internal::*/B2Joint.e_inactiveLimit;
            this.m_limitImpulse2 = 0;
         }
         else
         {
            this.m_limitState2 = /*b2internal::*/B2Joint.e_atUpperLimit;
         }
         var _loc21_= _loc5_ * this.m_u1.y - _loc6_ * this.m_u1.x;
         var _loc22_= _loc8_ * this.m_u2.y - _loc9_ * this.m_u2.x;
         this.m_limitMass1 = _loc2_/*b2internal::*/.m_invMass + _loc2_/*b2internal::*/.m_invI * _loc21_ * _loc21_;
         this.m_limitMass2 = _loc3_/*b2internal::*/.m_invMass + _loc3_/*b2internal::*/.m_invI * _loc22_ * _loc22_;
         this.m_pulleyMass = this.m_limitMass1 + this.m_ratio * this.m_ratio * this.m_limitMass2;
         this.m_limitMass1 = 1 / this.m_limitMass1;
         this.m_limitMass2 = 1 / this.m_limitMass2;
         this.m_pulleyMass = 1 / this.m_pulleyMass;
         if(param1.warmStarting)
         {
            this.m_impulse *= param1.dtRatio;
            this.m_limitImpulse1 *= param1.dtRatio;
            this.m_limitImpulse2 *= param1.dtRatio;
            _loc23_ = (-this.m_impulse - this.m_limitImpulse1) * this.m_u1.x;
            _loc24_ = (-this.m_impulse - this.m_limitImpulse1) * this.m_u1.y;
            _loc25_ = (-this.m_ratio * this.m_impulse - this.m_limitImpulse2) * this.m_u2.x;
            _loc26_ = (-this.m_ratio * this.m_impulse - this.m_limitImpulse2) * this.m_u2.y;
            _loc2_/*b2internal::*/.m_linearVelocity.x += _loc2_/*b2internal::*/.m_invMass * _loc23_;
            _loc2_/*b2internal::*/.m_linearVelocity.y += _loc2_/*b2internal::*/.m_invMass * _loc24_;
            _loc2_/*b2internal::*/.m_angularVelocity += _loc2_/*b2internal::*/.m_invI * (_loc5_ * _loc24_ - _loc6_ * _loc23_);
            _loc3_/*b2internal::*/.m_linearVelocity.x += _loc3_/*b2internal::*/.m_invMass * _loc25_;
            _loc3_/*b2internal::*/.m_linearVelocity.y += _loc3_/*b2internal::*/.m_invMass * _loc26_;
            _loc3_/*b2internal::*/.m_angularVelocity += _loc3_/*b2internal::*/.m_invI * (_loc8_ * _loc26_ - _loc9_ * _loc25_);
         }
         else
         {
            this.m_impulse = 0;
            this.m_limitImpulse1 = 0;
            this.m_limitImpulse2 = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc4_:B2Mat22 = null;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc18_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc2_= /*b2internal::*/m_bodyA;
         var _loc3_= /*b2internal::*/m_bodyB;
         _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
         var _loc5_= this.m_localAnchor1.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc6_= this.m_localAnchor1.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
         var _loc7_= _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
         _loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
         _loc5_ = _loc7_;
         _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
         var _loc8_= this.m_localAnchor2.x - _loc3_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc9_= this.m_localAnchor2.y - _loc3_/*b2internal::*/.m_sweep.localCenter.y;
         _loc7_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
         _loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
         _loc8_ = _loc7_;
         if(this.m_state == /*b2internal::*/B2Joint.e_atUpperLimit)
         {
            _loc10_ = _loc2_/*b2internal::*/.m_linearVelocity.x + -_loc2_/*b2internal::*/.m_angularVelocity * _loc6_;
            _loc11_ = _loc2_/*b2internal::*/.m_linearVelocity.y + _loc2_/*b2internal::*/.m_angularVelocity * _loc5_;
            _loc12_ = _loc3_/*b2internal::*/.m_linearVelocity.x + -_loc3_/*b2internal::*/.m_angularVelocity * _loc9_;
            _loc13_ = _loc3_/*b2internal::*/.m_linearVelocity.y + _loc3_/*b2internal::*/.m_angularVelocity * _loc8_;
            _loc18_ = -(this.m_u1.x * _loc10_ + this.m_u1.y * _loc11_) - this.m_ratio * (this.m_u2.x * _loc12_ + this.m_u2.y * _loc13_);
            _loc19_ = this.m_pulleyMass * -_loc18_;
            _loc20_ = this.m_impulse;
            this.m_impulse = B2Math.Max(0,this.m_impulse + _loc19_);
            _loc19_ = this.m_impulse - _loc20_;
            _loc14_ = -_loc19_ * this.m_u1.x;
            _loc15_ = -_loc19_ * this.m_u1.y;
            _loc16_ = -this.m_ratio * _loc19_ * this.m_u2.x;
            _loc17_ = -this.m_ratio * _loc19_ * this.m_u2.y;
            _loc2_/*b2internal::*/.m_linearVelocity.x += _loc2_/*b2internal::*/.m_invMass * _loc14_;
            _loc2_/*b2internal::*/.m_linearVelocity.y += _loc2_/*b2internal::*/.m_invMass * _loc15_;
            _loc2_/*b2internal::*/.m_angularVelocity += _loc2_/*b2internal::*/.m_invI * (_loc5_ * _loc15_ - _loc6_ * _loc14_);
            _loc3_/*b2internal::*/.m_linearVelocity.x += _loc3_/*b2internal::*/.m_invMass * _loc16_;
            _loc3_/*b2internal::*/.m_linearVelocity.y += _loc3_/*b2internal::*/.m_invMass * _loc17_;
            _loc3_/*b2internal::*/.m_angularVelocity += _loc3_/*b2internal::*/.m_invI * (_loc8_ * _loc17_ - _loc9_ * _loc16_);
         }
         if(this.m_limitState1 == /*b2internal::*/B2Joint.e_atUpperLimit)
         {
            _loc10_ = _loc2_/*b2internal::*/.m_linearVelocity.x + -_loc2_/*b2internal::*/.m_angularVelocity * _loc6_;
            _loc11_ = _loc2_/*b2internal::*/.m_linearVelocity.y + _loc2_/*b2internal::*/.m_angularVelocity * _loc5_;
            _loc18_ = -(this.m_u1.x * _loc10_ + this.m_u1.y * _loc11_);
            _loc19_ = -this.m_limitMass1 * _loc18_;
            _loc20_ = this.m_limitImpulse1;
            this.m_limitImpulse1 = B2Math.Max(0,this.m_limitImpulse1 + _loc19_);
            _loc19_ = this.m_limitImpulse1 - _loc20_;
            _loc14_ = -_loc19_ * this.m_u1.x;
            _loc15_ = -_loc19_ * this.m_u1.y;
            _loc2_/*b2internal::*/.m_linearVelocity.x += _loc2_/*b2internal::*/.m_invMass * _loc14_;
            _loc2_/*b2internal::*/.m_linearVelocity.y += _loc2_/*b2internal::*/.m_invMass * _loc15_;
            _loc2_/*b2internal::*/.m_angularVelocity += _loc2_/*b2internal::*/.m_invI * (_loc5_ * _loc15_ - _loc6_ * _loc14_);
         }
         if(this.m_limitState2 == /*b2internal::*/B2Joint.e_atUpperLimit)
         {
            _loc12_ = _loc3_/*b2internal::*/.m_linearVelocity.x + -_loc3_/*b2internal::*/.m_angularVelocity * _loc9_;
            _loc13_ = _loc3_/*b2internal::*/.m_linearVelocity.y + _loc3_/*b2internal::*/.m_angularVelocity * _loc8_;
            _loc18_ = -(this.m_u2.x * _loc12_ + this.m_u2.y * _loc13_);
            _loc19_ = -this.m_limitMass2 * _loc18_;
            _loc20_ = this.m_limitImpulse2;
            this.m_limitImpulse2 = B2Math.Max(0,this.m_limitImpulse2 + _loc19_);
            _loc19_ = this.m_limitImpulse2 - _loc20_;
            _loc16_ = -_loc19_ * this.m_u2.x;
            _loc17_ = -_loc19_ * this.m_u2.y;
            _loc3_/*b2internal::*/.m_linearVelocity.x += _loc3_/*b2internal::*/.m_invMass * _loc16_;
            _loc3_/*b2internal::*/.m_linearVelocity.y += _loc3_/*b2internal::*/.m_invMass * _loc17_;
            _loc3_/*b2internal::*/.m_angularVelocity += _loc3_/*b2internal::*/.m_invI * (_loc8_ * _loc17_ - _loc9_ * _loc16_);
         }
      }
      
      override public function SolvePositionConstraints(param1:Float) : Bool
      {
         var _loc4_:B2Mat22 = null;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc18_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc23_= Math.NaN;
         var _loc2_= /*b2internal::*/m_bodyA;
         var _loc3_= /*b2internal::*/m_bodyB;
         var _loc5_= this.m_ground/*b2internal::*/.m_xf.position.x + this.m_groundAnchor1.x;
         var _loc6_= this.m_ground/*b2internal::*/.m_xf.position.y + this.m_groundAnchor1.y;
         var _loc7_= this.m_ground/*b2internal::*/.m_xf.position.x + this.m_groundAnchor2.x;
         var _loc8_= this.m_ground/*b2internal::*/.m_xf.position.y + this.m_groundAnchor2.y;
         var _loc24_:Float = 0;
         if(this.m_state == /*b2internal::*/B2Joint.e_atUpperLimit)
         {
            _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
            _loc9_ = this.m_localAnchor1.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
            _loc10_ = this.m_localAnchor1.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
            _loc23_ = _loc4_.col1.x * _loc9_ + _loc4_.col2.x * _loc10_;
            _loc10_ = _loc4_.col1.y * _loc9_ + _loc4_.col2.y * _loc10_;
            _loc9_ = _loc23_;
            _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
            _loc11_ = this.m_localAnchor2.x - _loc3_/*b2internal::*/.m_sweep.localCenter.x;
            _loc12_ = this.m_localAnchor2.y - _loc3_/*b2internal::*/.m_sweep.localCenter.y;
            _loc23_ = _loc4_.col1.x * _loc11_ + _loc4_.col2.x * _loc12_;
            _loc12_ = _loc4_.col1.y * _loc11_ + _loc4_.col2.y * _loc12_;
            _loc11_ = _loc23_;
            _loc13_ = _loc2_/*b2internal::*/.m_sweep.c.x + _loc9_;
            _loc14_ = _loc2_/*b2internal::*/.m_sweep.c.y + _loc10_;
            _loc15_ = _loc3_/*b2internal::*/.m_sweep.c.x + _loc11_;
            _loc16_ = _loc3_/*b2internal::*/.m_sweep.c.y + _loc12_;
            this.m_u1.Set(_loc13_ - _loc5_,_loc14_ - _loc6_);
            this.m_u2.Set(_loc15_ - _loc7_,_loc16_ - _loc8_);
            _loc17_ = this.m_u1.Length();
            _loc18_ = this.m_u2.Length();
            if(_loc17_ > B2Settings.b2_linearSlop)
            {
               this.m_u1.Multiply(1 / _loc17_);
            }
            else
            {
               this.m_u1.SetZero();
            }
            if(_loc18_ > B2Settings.b2_linearSlop)
            {
               this.m_u2.Multiply(1 / _loc18_);
            }
            else
            {
               this.m_u2.SetZero();
            }
            _loc19_ = this.m_constant - _loc17_ - this.m_ratio * _loc18_;
            _loc24_ = B2Math.Max(_loc24_,-_loc19_);
            _loc19_ = B2Math.Clamp(_loc19_ + B2Settings.b2_linearSlop,-B2Settings.b2_maxLinearCorrection,0);
            _loc20_ = -this.m_pulleyMass * _loc19_;
            _loc13_ = -_loc20_ * this.m_u1.x;
            _loc14_ = -_loc20_ * this.m_u1.y;
            _loc15_ = -this.m_ratio * _loc20_ * this.m_u2.x;
            _loc16_ = -this.m_ratio * _loc20_ * this.m_u2.y;
            _loc2_/*b2internal::*/.m_sweep.c.x += _loc2_/*b2internal::*/.m_invMass * _loc13_;
            _loc2_/*b2internal::*/.m_sweep.c.y += _loc2_/*b2internal::*/.m_invMass * _loc14_;
            _loc2_/*b2internal::*/.m_sweep.a += _loc2_/*b2internal::*/.m_invI * (_loc9_ * _loc14_ - _loc10_ * _loc13_);
            _loc3_/*b2internal::*/.m_sweep.c.x += _loc3_/*b2internal::*/.m_invMass * _loc15_;
            _loc3_/*b2internal::*/.m_sweep.c.y += _loc3_/*b2internal::*/.m_invMass * _loc16_;
            _loc3_/*b2internal::*/.m_sweep.a += _loc3_/*b2internal::*/.m_invI * (_loc11_ * _loc16_ - _loc12_ * _loc15_);
            _loc2_/*b2internal::*/.SynchronizeTransform();
            _loc3_/*b2internal::*/.SynchronizeTransform();
         }
         if(this.m_limitState1 == /*b2internal::*/B2Joint.e_atUpperLimit)
         {
            _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
            _loc9_ = this.m_localAnchor1.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
            _loc10_ = this.m_localAnchor1.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
            _loc23_ = _loc4_.col1.x * _loc9_ + _loc4_.col2.x * _loc10_;
            _loc10_ = _loc4_.col1.y * _loc9_ + _loc4_.col2.y * _loc10_;
            _loc9_ = _loc23_;
            _loc13_ = _loc2_/*b2internal::*/.m_sweep.c.x + _loc9_;
            _loc14_ = _loc2_/*b2internal::*/.m_sweep.c.y + _loc10_;
            this.m_u1.Set(_loc13_ - _loc5_,_loc14_ - _loc6_);
            _loc17_ = this.m_u1.Length();
            if(_loc17_ > B2Settings.b2_linearSlop)
            {
               this.m_u1.x *= 1 / _loc17_;
               this.m_u1.y *= 1 / _loc17_;
            }
            else
            {
               this.m_u1.SetZero();
            }
            _loc19_ = this.m_maxLength1 - _loc17_;
            _loc24_ = B2Math.Max(_loc24_,-_loc19_);
            _loc19_ = B2Math.Clamp(_loc19_ + B2Settings.b2_linearSlop,-B2Settings.b2_maxLinearCorrection,0);
            _loc20_ = -this.m_limitMass1 * _loc19_;
            _loc13_ = -_loc20_ * this.m_u1.x;
            _loc14_ = -_loc20_ * this.m_u1.y;
            _loc2_/*b2internal::*/.m_sweep.c.x += _loc2_/*b2internal::*/.m_invMass * _loc13_;
            _loc2_/*b2internal::*/.m_sweep.c.y += _loc2_/*b2internal::*/.m_invMass * _loc14_;
            _loc2_/*b2internal::*/.m_sweep.a += _loc2_/*b2internal::*/.m_invI * (_loc9_ * _loc14_ - _loc10_ * _loc13_);
            _loc2_/*b2internal::*/.SynchronizeTransform();
         }
         if(this.m_limitState2 == /*b2internal::*/B2Joint.e_atUpperLimit)
         {
            _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
            _loc11_ = this.m_localAnchor2.x - _loc3_/*b2internal::*/.m_sweep.localCenter.x;
            _loc12_ = this.m_localAnchor2.y - _loc3_/*b2internal::*/.m_sweep.localCenter.y;
            _loc23_ = _loc4_.col1.x * _loc11_ + _loc4_.col2.x * _loc12_;
            _loc12_ = _loc4_.col1.y * _loc11_ + _loc4_.col2.y * _loc12_;
            _loc11_ = _loc23_;
            _loc15_ = _loc3_/*b2internal::*/.m_sweep.c.x + _loc11_;
            _loc16_ = _loc3_/*b2internal::*/.m_sweep.c.y + _loc12_;
            this.m_u2.Set(_loc15_ - _loc7_,_loc16_ - _loc8_);
            _loc18_ = this.m_u2.Length();
            if(_loc18_ > B2Settings.b2_linearSlop)
            {
               this.m_u2.x *= 1 / _loc18_;
               this.m_u2.y *= 1 / _loc18_;
            }
            else
            {
               this.m_u2.SetZero();
            }
            _loc19_ = this.m_maxLength2 - _loc18_;
            _loc24_ = B2Math.Max(_loc24_,-_loc19_);
            _loc19_ = B2Math.Clamp(_loc19_ + B2Settings.b2_linearSlop,-B2Settings.b2_maxLinearCorrection,0);
            _loc20_ = -this.m_limitMass2 * _loc19_;
            _loc15_ = -_loc20_ * this.m_u2.x;
            _loc16_ = -_loc20_ * this.m_u2.y;
            _loc3_/*b2internal::*/.m_sweep.c.x += _loc3_/*b2internal::*/.m_invMass * _loc15_;
            _loc3_/*b2internal::*/.m_sweep.c.y += _loc3_/*b2internal::*/.m_invMass * _loc16_;
            _loc3_/*b2internal::*/.m_sweep.a += _loc3_/*b2internal::*/.m_invI * (_loc11_ * _loc16_ - _loc12_ * _loc15_);
            _loc3_/*b2internal::*/.SynchronizeTransform();
         }
         return _loc24_ < B2Settings.b2_linearSlop;
      }
   }


