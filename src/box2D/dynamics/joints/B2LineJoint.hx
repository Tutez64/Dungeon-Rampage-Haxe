package box2D.dynamics.joints
;
   import box2D.common.math.B2Mat22;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Settings;
   import box2D.dynamics.B2TimeStep;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2LineJoint extends B2Joint
   {
      
      /*b2internal*/ public var m_localAnchor1:B2Vec2;
      
      /*b2internal*/ public var m_localAnchor2:B2Vec2;
      
      /*b2internal*/ public var m_localXAxis1:B2Vec2;
      
      var m_localYAxis1:B2Vec2;
      
      var m_axis:B2Vec2;
      
      var m_perp:B2Vec2;
      
      var m_s1:Float = Math.NaN;
      
      var m_s2:Float = Math.NaN;
      
      var m_a1:Float = Math.NaN;
      
      var m_a2:Float = Math.NaN;
      
      var m_K:B2Mat22;
      
      var m_impulse:B2Vec2;
      
      var m_motorMass:Float = Math.NaN;
      
      var m_motorImpulse:Float = Math.NaN;
      
      var m_lowerTranslation:Float = Math.NaN;
      
      var m_upperTranslation:Float = Math.NaN;
      
      var m_maxMotorForce:Float = Math.NaN;
      
      var m_motorSpeed:Float = Math.NaN;
      
      var m_enableLimit:Bool = false;
      
      var m_enableMotor:Bool = false;
      
      var m_limitState:Int = 0;
      
      public function new(param1:B2LineJointDef)
      {
         var _loc2_:B2Mat22 = null;
         var _loc3_= Math.NaN;
         var _loc4_= Math.NaN;
         this/*b2internal::*/.m_localAnchor1 = new B2Vec2();
         this/*b2internal::*/.m_localAnchor2 = new B2Vec2();
         this/*b2internal::*/.m_localXAxis1 = new B2Vec2();
         this.m_localYAxis1 = new B2Vec2();
         this.m_axis = new B2Vec2();
         this.m_perp = new B2Vec2();
         this.m_K = new B2Mat22();
         this.m_impulse = new B2Vec2();
         super(param1);
         this/*b2internal::*/.m_localAnchor1.SetV(param1.localAnchorA);
         this/*b2internal::*/.m_localAnchor2.SetV(param1.localAnchorB);
         this/*b2internal::*/.m_localXAxis1.SetV(param1.localAxisA);
         this.m_localYAxis1.x = -this/*b2internal::*/.m_localXAxis1.y;
         this.m_localYAxis1.y = this/*b2internal::*/.m_localXAxis1.x;
         this.m_impulse.SetZero();
         this.m_motorMass = 0;
         this.m_motorImpulse = 0;
         this.m_lowerTranslation = param1.lowerTranslation;
         this.m_upperTranslation = param1.upperTranslation;
         this.m_maxMotorForce = param1.maxMotorForce;
         this.m_motorSpeed = param1.motorSpeed;
         this.m_enableLimit = param1.enableLimit;
         this.m_enableMotor = param1.enableMotor;
         this.m_limitState = /*b2internal::*/B2Joint.e_inactiveLimit;
         this.m_axis.SetZero();
         this.m_perp.SetZero();
      }
      
      override public function GetAnchorA() : B2Vec2
      {
         return /*b2internal::*/m_bodyA.GetWorldPoint(this/*b2internal::*/.m_localAnchor1);
      }
      
      override public function GetAnchorB() : B2Vec2
      {
         return /*b2internal::*/m_bodyB.GetWorldPoint(this/*b2internal::*/.m_localAnchor2);
      }
      
      override public function GetReactionForce(param1:Float) : B2Vec2
      {
         return new B2Vec2(param1 * (this.m_impulse.x * this.m_perp.x + (this.m_motorImpulse + this.m_impulse.y) * this.m_axis.x),param1 * (this.m_impulse.x * this.m_perp.y + (this.m_motorImpulse + this.m_impulse.y) * this.m_axis.y));
      }
      
      override public function GetReactionTorque(param1:Float) : Float
      {
         return param1 * this.m_impulse.y;
      }
      
      public function GetJointTranslation() : Float
      {
         var _loc3_:B2Mat22 = null;
         var _loc1_= /*b2internal::*/m_bodyA;
         var _loc2_= /*b2internal::*/m_bodyB;
         var _loc4_= _loc1_.GetWorldPoint(this/*b2internal::*/.m_localAnchor1);
         var _loc5_= _loc2_.GetWorldPoint(this/*b2internal::*/.m_localAnchor2);
         var _loc6_= _loc5_.x - _loc4_.x;
         var _loc7_= _loc5_.y - _loc4_.y;
         var _loc8_= _loc1_.GetWorldVector(this/*b2internal::*/.m_localXAxis1);
         return _loc8_.x * _loc6_ + _loc8_.y * _loc7_;
      }
      
      public function GetJointSpeed() : Float
      {
         var _loc3_:B2Mat22 = null;
         var _loc1_= /*b2internal::*/m_bodyA;
         var _loc2_= /*b2internal::*/m_bodyB;
         _loc3_ = _loc1_/*b2internal::*/.m_xf.R;
         var _loc4_= this/*b2internal::*/.m_localAnchor1.x - _loc1_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc5_= this/*b2internal::*/.m_localAnchor1.y - _loc1_/*b2internal::*/.m_sweep.localCenter.y;
         var _loc6_= _loc3_.col1.x * _loc4_ + _loc3_.col2.x * _loc5_;
         _loc5_ = _loc3_.col1.y * _loc4_ + _loc3_.col2.y * _loc5_;
         _loc4_ = _loc6_;
         _loc3_ = _loc2_/*b2internal::*/.m_xf.R;
         var _loc7_= this/*b2internal::*/.m_localAnchor2.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc8_= this/*b2internal::*/.m_localAnchor2.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
         _loc6_ = _loc3_.col1.x * _loc7_ + _loc3_.col2.x * _loc8_;
         _loc8_ = _loc3_.col1.y * _loc7_ + _loc3_.col2.y * _loc8_;
         _loc7_ = _loc6_;
         var _loc9_= _loc1_/*b2internal::*/.m_sweep.c.x + _loc4_;
         var _loc10_= _loc1_/*b2internal::*/.m_sweep.c.y + _loc5_;
         var _loc11_= _loc2_/*b2internal::*/.m_sweep.c.x + _loc7_;
         var _loc12_= _loc2_/*b2internal::*/.m_sweep.c.y + _loc8_;
         var _loc13_= _loc11_ - _loc9_;
         var _loc14_= _loc12_ - _loc10_;
         var _loc15_= _loc1_.GetWorldVector(this/*b2internal::*/.m_localXAxis1);
         var _loc16_= _loc1_/*b2internal::*/.m_linearVelocity;
         var _loc17_= _loc2_/*b2internal::*/.m_linearVelocity;
         var _loc18_= _loc1_/*b2internal::*/.m_angularVelocity;
         var _loc19_= _loc2_/*b2internal::*/.m_angularVelocity;
         return _loc13_ * (-_loc18_ * _loc15_.y) + _loc14_ * (_loc18_ * _loc15_.x) + (_loc15_.x * (_loc17_.x + -_loc19_ * _loc8_ - _loc16_.x - -_loc18_ * _loc5_) + _loc15_.y * (_loc17_.y + _loc19_ * _loc7_ - _loc16_.y - _loc18_ * _loc4_));
      }
      
      public function IsLimitEnabled() : Bool
      {
         return this.m_enableLimit;
      }
      
      public function EnableLimit(param1:Bool) 
      {
         /*b2internal::*/m_bodyA.SetAwake(true);
         /*b2internal::*/m_bodyB.SetAwake(true);
         this.m_enableLimit = param1;
      }
      
      public function GetLowerLimit() : Float
      {
         return this.m_lowerTranslation;
      }
      
      public function GetUpperLimit() : Float
      {
         return this.m_upperTranslation;
      }
      
      public function SetLimits(param1:Float, param2:Float) 
      {
         /*b2internal::*/m_bodyA.SetAwake(true);
         /*b2internal::*/m_bodyB.SetAwake(true);
         this.m_lowerTranslation = param1;
         this.m_upperTranslation = param2;
      }
      
      public function IsMotorEnabled() : Bool
      {
         return this.m_enableMotor;
      }
      
      public function EnableMotor(param1:Bool) 
      {
         /*b2internal::*/m_bodyA.SetAwake(true);
         /*b2internal::*/m_bodyB.SetAwake(true);
         this.m_enableMotor = param1;
      }
      
      public function SetMotorSpeed(param1:Float) 
      {
         /*b2internal::*/m_bodyA.SetAwake(true);
         /*b2internal::*/m_bodyB.SetAwake(true);
         this.m_motorSpeed = param1;
      }
      
      public function GetMotorSpeed() : Float
      {
         return this.m_motorSpeed;
      }
      
      public function SetMaxMotorForce(param1:Float) 
      {
         /*b2internal::*/m_bodyA.SetAwake(true);
         /*b2internal::*/m_bodyB.SetAwake(true);
         this.m_maxMotorForce = param1;
      }
      
      public function GetMaxMotorForce() : Float
      {
         return this.m_maxMotorForce;
      }
      
      public function GetMotorForce() : Float
      {
         return this.m_motorImpulse;
      }
      
      override public function InitVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc4_:B2Mat22 = null;
         var _loc5_= Math.NaN;
         var _loc18_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc2_= /*b2internal::*/m_bodyA;
         var _loc3_= /*b2internal::*/m_bodyB;
         /*b2internal::*/m_localCenterA.SetV(_loc2_.GetLocalCenter());
         /*b2internal::*/m_localCenterB.SetV(_loc3_.GetLocalCenter());
         var _loc6_= _loc2_.GetTransform();
         var _loc7_= _loc3_.GetTransform();
         _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
         var _loc8_= this/*b2internal::*/.m_localAnchor1.x - /*b2internal::*/m_localCenterA.x;
         var _loc9_= this/*b2internal::*/.m_localAnchor1.y - /*b2internal::*/m_localCenterA.y;
         _loc5_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
         _loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
         _loc8_ = _loc5_;
         _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
         var _loc10_= this/*b2internal::*/.m_localAnchor2.x - /*b2internal::*/m_localCenterB.x;
         var _loc11_= this/*b2internal::*/.m_localAnchor2.y - /*b2internal::*/m_localCenterB.y;
         _loc5_ = _loc4_.col1.x * _loc10_ + _loc4_.col2.x * _loc11_;
         _loc11_ = _loc4_.col1.y * _loc10_ + _loc4_.col2.y * _loc11_;
         _loc10_ = _loc5_;
         var _loc12_= _loc3_/*b2internal::*/.m_sweep.c.x + _loc10_ - _loc2_/*b2internal::*/.m_sweep.c.x - _loc8_;
         var _loc13_= _loc3_/*b2internal::*/.m_sweep.c.y + _loc11_ - _loc2_/*b2internal::*/.m_sweep.c.y - _loc9_;
         /*b2internal::*/m_invMassA = _loc2_/*b2internal::*/.m_invMass;
         /*b2internal::*/m_invMassB = _loc3_/*b2internal::*/.m_invMass;
         /*b2internal::*/m_invIA = _loc2_/*b2internal::*/.m_invI;
         /*b2internal::*/m_invIB = _loc3_/*b2internal::*/.m_invI;
         this.m_axis.SetV(B2Math.MulMV(_loc6_.R,this/*b2internal::*/.m_localXAxis1));
         this.m_a1 = (_loc12_ + _loc8_) * this.m_axis.y - (_loc13_ + _loc9_) * this.m_axis.x;
         this.m_a2 = _loc10_ * this.m_axis.y - _loc11_ * this.m_axis.x;
         this.m_motorMass = /*b2internal::*/m_invMassA + /*b2internal::*/m_invMassB + /*b2internal::*/m_invIA * this.m_a1 * this.m_a1 + /*b2internal::*/m_invIB * this.m_a2 * this.m_a2;
         this.m_motorMass = this.m_motorMass > ASCompat.MIN_FLOAT ? 1 / this.m_motorMass : 0;
         this.m_perp.SetV(B2Math.MulMV(_loc6_.R,this.m_localYAxis1));
         this.m_s1 = (_loc12_ + _loc8_) * this.m_perp.y - (_loc13_ + _loc9_) * this.m_perp.x;
         this.m_s2 = _loc10_ * this.m_perp.y - _loc11_ * this.m_perp.x;
         var _loc14_= /*b2internal::*/m_invMassA;
         var _loc15_= /*b2internal::*/m_invMassB;
         var _loc16_= /*b2internal::*/m_invIA;
         var _loc17_= /*b2internal::*/m_invIB;
         this.m_K.col1.x = _loc14_ + _loc15_ + _loc16_ * this.m_s1 * this.m_s1 + _loc17_ * this.m_s2 * this.m_s2;
         this.m_K.col1.y = _loc16_ * this.m_s1 * this.m_a1 + _loc17_ * this.m_s2 * this.m_a2;
         this.m_K.col2.x = this.m_K.col1.y;
         this.m_K.col2.y = _loc14_ + _loc15_ + _loc16_ * this.m_a1 * this.m_a1 + _loc17_ * this.m_a2 * this.m_a2;
         if(this.m_enableLimit)
         {
            _loc18_ = this.m_axis.x * _loc12_ + this.m_axis.y * _loc13_;
            if(B2Math.Abs(this.m_upperTranslation - this.m_lowerTranslation) < 2 * B2Settings.b2_linearSlop)
            {
               this.m_limitState = /*b2internal::*/B2Joint.e_equalLimits;
            }
            else if(_loc18_ <= this.m_lowerTranslation)
            {
               if(this.m_limitState != /*b2internal::*/B2Joint.e_atLowerLimit)
               {
                  this.m_limitState = /*b2internal::*/B2Joint.e_atLowerLimit;
                  this.m_impulse.y = 0;
               }
            }
            else if(_loc18_ >= this.m_upperTranslation)
            {
               if(this.m_limitState != /*b2internal::*/B2Joint.e_atUpperLimit)
               {
                  this.m_limitState = /*b2internal::*/B2Joint.e_atUpperLimit;
                  this.m_impulse.y = 0;
               }
            }
            else
            {
               this.m_limitState = /*b2internal::*/B2Joint.e_inactiveLimit;
               this.m_impulse.y = 0;
            }
         }
         else
         {
            this.m_limitState = /*b2internal::*/B2Joint.e_inactiveLimit;
         }
         if(this.m_enableMotor == false)
         {
            this.m_motorImpulse = 0;
         }
         if(param1.warmStarting)
         {
            this.m_impulse.x *= param1.dtRatio;
            this.m_impulse.y *= param1.dtRatio;
            this.m_motorImpulse *= param1.dtRatio;
            _loc19_ = this.m_impulse.x * this.m_perp.x + (this.m_motorImpulse + this.m_impulse.y) * this.m_axis.x;
            _loc20_ = this.m_impulse.x * this.m_perp.y + (this.m_motorImpulse + this.m_impulse.y) * this.m_axis.y;
            _loc21_ = this.m_impulse.x * this.m_s1 + (this.m_motorImpulse + this.m_impulse.y) * this.m_a1;
            _loc22_ = this.m_impulse.x * this.m_s2 + (this.m_motorImpulse + this.m_impulse.y) * this.m_a2;
            _loc2_/*b2internal::*/.m_linearVelocity.x -= /*b2internal::*/m_invMassA * _loc19_;
            _loc2_/*b2internal::*/.m_linearVelocity.y -= /*b2internal::*/m_invMassA * _loc20_;
            _loc2_/*b2internal::*/.m_angularVelocity -= /*b2internal::*/m_invIA * _loc21_;
            _loc3_/*b2internal::*/.m_linearVelocity.x += /*b2internal::*/m_invMassB * _loc19_;
            _loc3_/*b2internal::*/.m_linearVelocity.y += /*b2internal::*/m_invMassB * _loc20_;
            _loc3_/*b2internal::*/.m_angularVelocity += /*b2internal::*/m_invIB * _loc22_;
         }
         else
         {
            this.m_impulse.SetZero();
            this.m_motorImpulse = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc18_:B2Vec2 = null;
         var _loc19_:B2Vec2 = null;
         var _loc20_= Math.NaN;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc2_= /*b2internal::*/m_bodyA;
         var _loc3_= /*b2internal::*/m_bodyB;
         var _loc4_= _loc2_/*b2internal::*/.m_linearVelocity;
         var _loc5_= _loc2_/*b2internal::*/.m_angularVelocity;
         var _loc6_= _loc3_/*b2internal::*/.m_linearVelocity;
         var _loc7_= _loc3_/*b2internal::*/.m_angularVelocity;
         if(this.m_enableMotor && this.m_limitState != /*b2internal::*/B2Joint.e_equalLimits)
         {
            _loc13_ = this.m_axis.x * (_loc6_.x - _loc4_.x) + this.m_axis.y * (_loc6_.y - _loc4_.y) + this.m_a2 * _loc7_ - this.m_a1 * _loc5_;
            _loc14_ = this.m_motorMass * (this.m_motorSpeed - _loc13_);
            _loc15_ = this.m_motorImpulse;
            _loc16_ = param1.dt * this.m_maxMotorForce;
            this.m_motorImpulse = B2Math.Clamp(this.m_motorImpulse + _loc14_,-_loc16_,_loc16_);
            _loc14_ = this.m_motorImpulse - _loc15_;
            _loc8_ = _loc14_ * this.m_axis.x;
            _loc9_ = _loc14_ * this.m_axis.y;
            _loc10_ = _loc14_ * this.m_a1;
            _loc11_ = _loc14_ * this.m_a2;
            _loc4_.x -= /*b2internal::*/m_invMassA * _loc8_;
            _loc4_.y -= /*b2internal::*/m_invMassA * _loc9_;
            _loc5_ -= /*b2internal::*/m_invIA * _loc10_;
            _loc6_.x += /*b2internal::*/m_invMassB * _loc8_;
            _loc6_.y += /*b2internal::*/m_invMassB * _loc9_;
            _loc7_ += /*b2internal::*/m_invIB * _loc11_;
         }
         var _loc12_= this.m_perp.x * (_loc6_.x - _loc4_.x) + this.m_perp.y * (_loc6_.y - _loc4_.y) + this.m_s2 * _loc7_ - this.m_s1 * _loc5_;
         if(this.m_enableLimit && this.m_limitState != /*b2internal::*/B2Joint.e_inactiveLimit)
         {
            _loc17_ = this.m_axis.x * (_loc6_.x - _loc4_.x) + this.m_axis.y * (_loc6_.y - _loc4_.y) + this.m_a2 * _loc7_ - this.m_a1 * _loc5_;
            _loc18_ = this.m_impulse.Copy();
            _loc19_ = this.m_K.Solve(new B2Vec2(),-_loc12_,-_loc17_);
            this.m_impulse.Add(_loc19_);
            if(this.m_limitState == /*b2internal::*/B2Joint.e_atLowerLimit)
            {
               this.m_impulse.y = B2Math.Max(this.m_impulse.y,0);
            }
            else if(this.m_limitState == /*b2internal::*/B2Joint.e_atUpperLimit)
            {
               this.m_impulse.y = B2Math.Min(this.m_impulse.y,0);
            }
            _loc20_ = -_loc12_ - (this.m_impulse.y - _loc18_.y) * this.m_K.col2.x;
            if(this.m_K.col1.x != 0)
            {
               _loc21_ = _loc20_ / this.m_K.col1.x + _loc18_.x;
            }
            else
            {
               _loc21_ = _loc18_.x;
            }
            this.m_impulse.x = _loc21_;
            _loc19_.x = this.m_impulse.x - _loc18_.x;
            _loc19_.y = this.m_impulse.y - _loc18_.y;
            _loc8_ = _loc19_.x * this.m_perp.x + _loc19_.y * this.m_axis.x;
            _loc9_ = _loc19_.x * this.m_perp.y + _loc19_.y * this.m_axis.y;
            _loc10_ = _loc19_.x * this.m_s1 + _loc19_.y * this.m_a1;
            _loc11_ = _loc19_.x * this.m_s2 + _loc19_.y * this.m_a2;
            _loc4_.x -= /*b2internal::*/m_invMassA * _loc8_;
            _loc4_.y -= /*b2internal::*/m_invMassA * _loc9_;
            _loc5_ -= /*b2internal::*/m_invIA * _loc10_;
            _loc6_.x += /*b2internal::*/m_invMassB * _loc8_;
            _loc6_.y += /*b2internal::*/m_invMassB * _loc9_;
            _loc7_ += /*b2internal::*/m_invIB * _loc11_;
         }
         else
         {
            if(this.m_K.col1.x != 0)
            {
               _loc22_ = -_loc12_ / this.m_K.col1.x;
            }
            else
            {
               _loc22_ = 0;
            }
            this.m_impulse.x += _loc22_;
            _loc8_ = _loc22_ * this.m_perp.x;
            _loc9_ = _loc22_ * this.m_perp.y;
            _loc10_ = _loc22_ * this.m_s1;
            _loc11_ = _loc22_ * this.m_s2;
            _loc4_.x -= /*b2internal::*/m_invMassA * _loc8_;
            _loc4_.y -= /*b2internal::*/m_invMassA * _loc9_;
            _loc5_ -= /*b2internal::*/m_invIA * _loc10_;
            _loc6_.x += /*b2internal::*/m_invMassB * _loc8_;
            _loc6_.y += /*b2internal::*/m_invMassB * _loc9_;
            _loc7_ += /*b2internal::*/m_invIB * _loc11_;
         }
         _loc2_/*b2internal::*/.m_linearVelocity.SetV(_loc4_);
         _loc2_/*b2internal::*/.m_angularVelocity = _loc5_;
         _loc3_/*b2internal::*/.m_linearVelocity.SetV(_loc6_);
         _loc3_/*b2internal::*/.m_angularVelocity = _loc7_;
      }
      
      override public function SolvePositionConstraints(param1:Float) : Bool
      {
         var _loc2_= Math.NaN;
         var _loc3_= Math.NaN;
         var _loc10_:B2Mat22 = null;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc34_= Math.NaN;
         var _loc35_= Math.NaN;
         var _loc36_= Math.NaN;
         var _loc4_= /*b2internal::*/m_bodyA;
         var _loc5_= /*b2internal::*/m_bodyB;
         var _loc6_= _loc4_/*b2internal::*/.m_sweep.c;
         var _loc7_= _loc4_/*b2internal::*/.m_sweep.a;
         var _loc8_= _loc5_/*b2internal::*/.m_sweep.c;
         var _loc9_= _loc5_/*b2internal::*/.m_sweep.a;
         var _loc16_:Float = 0;
         var _loc17_:Float = 0;
         var _loc18_= false;
         var _loc19_:Float = 0;
         var _loc20_= B2Mat22.FromAngle(_loc7_);
         var _loc21_= B2Mat22.FromAngle(_loc9_);
         _loc10_ = _loc20_;
         var _loc22_= this/*b2internal::*/.m_localAnchor1.x - /*b2internal::*/m_localCenterA.x;
         var _loc23_= this/*b2internal::*/.m_localAnchor1.y - /*b2internal::*/m_localCenterA.y;
         _loc11_ = _loc10_.col1.x * _loc22_ + _loc10_.col2.x * _loc23_;
         _loc23_ = _loc10_.col1.y * _loc22_ + _loc10_.col2.y * _loc23_;
         _loc22_ = _loc11_;
         _loc10_ = _loc21_;
         var _loc24_= this/*b2internal::*/.m_localAnchor2.x - /*b2internal::*/m_localCenterB.x;
         var _loc25_= this/*b2internal::*/.m_localAnchor2.y - /*b2internal::*/m_localCenterB.y;
         _loc11_ = _loc10_.col1.x * _loc24_ + _loc10_.col2.x * _loc25_;
         _loc25_ = _loc10_.col1.y * _loc24_ + _loc10_.col2.y * _loc25_;
         _loc24_ = _loc11_;
         var _loc26_= _loc8_.x + _loc24_ - _loc6_.x - _loc22_;
         var _loc27_= _loc8_.y + _loc25_ - _loc6_.y - _loc23_;
         if(this.m_enableLimit)
         {
            this.m_axis = B2Math.MulMV(_loc20_,this/*b2internal::*/.m_localXAxis1);
            this.m_a1 = (_loc26_ + _loc22_) * this.m_axis.y - (_loc27_ + _loc23_) * this.m_axis.x;
            this.m_a2 = _loc24_ * this.m_axis.y - _loc25_ * this.m_axis.x;
            _loc34_ = this.m_axis.x * _loc26_ + this.m_axis.y * _loc27_;
            if(B2Math.Abs(this.m_upperTranslation - this.m_lowerTranslation) < 2 * B2Settings.b2_linearSlop)
            {
               _loc19_ = B2Math.Clamp(_loc34_,-B2Settings.b2_maxLinearCorrection,B2Settings.b2_maxLinearCorrection);
               _loc16_ = B2Math.Abs(_loc34_);
               _loc18_ = true;
            }
            else if(_loc34_ <= this.m_lowerTranslation)
            {
               _loc19_ = B2Math.Clamp(_loc34_ - this.m_lowerTranslation + B2Settings.b2_linearSlop,-B2Settings.b2_maxLinearCorrection,0);
               _loc16_ = this.m_lowerTranslation - _loc34_;
               _loc18_ = true;
            }
            else if(_loc34_ >= this.m_upperTranslation)
            {
               _loc19_ = B2Math.Clamp(_loc34_ - this.m_upperTranslation + B2Settings.b2_linearSlop,0,B2Settings.b2_maxLinearCorrection);
               _loc16_ = _loc34_ - this.m_upperTranslation;
               _loc18_ = true;
            }
         }
         this.m_perp = B2Math.MulMV(_loc20_,this.m_localYAxis1);
         this.m_s1 = (_loc26_ + _loc22_) * this.m_perp.y - (_loc27_ + _loc23_) * this.m_perp.x;
         this.m_s2 = _loc24_ * this.m_perp.y - _loc25_ * this.m_perp.x;
         var _loc28_= new B2Vec2();
         var _loc29_= this.m_perp.x * _loc26_ + this.m_perp.y * _loc27_;
         _loc16_ = B2Math.Max(_loc16_,B2Math.Abs(_loc29_));
         _loc17_ = 0;
         if(_loc18_)
         {
            _loc12_ = /*b2internal::*/m_invMassA;
            _loc13_ = /*b2internal::*/m_invMassB;
            _loc14_ = /*b2internal::*/m_invIA;
            _loc15_ = /*b2internal::*/m_invIB;
            this.m_K.col1.x = _loc12_ + _loc13_ + _loc14_ * this.m_s1 * this.m_s1 + _loc15_ * this.m_s2 * this.m_s2;
            this.m_K.col1.y = _loc14_ * this.m_s1 * this.m_a1 + _loc15_ * this.m_s2 * this.m_a2;
            this.m_K.col2.x = this.m_K.col1.y;
            this.m_K.col2.y = _loc12_ + _loc13_ + _loc14_ * this.m_a1 * this.m_a1 + _loc15_ * this.m_a2 * this.m_a2;
            this.m_K.Solve(_loc28_,-_loc29_,-_loc19_);
         }
         else
         {
            _loc12_ = /*b2internal::*/m_invMassA;
            _loc13_ = /*b2internal::*/m_invMassB;
            _loc14_ = /*b2internal::*/m_invIA;
            _loc15_ = /*b2internal::*/m_invIB;
            _loc35_ = _loc12_ + _loc13_ + _loc14_ * this.m_s1 * this.m_s1 + _loc15_ * this.m_s2 * this.m_s2;
            if(_loc35_ != 0)
            {
               _loc36_ = -_loc29_ / _loc35_;
            }
            else
            {
               _loc36_ = 0;
            }
            _loc28_.x = _loc36_;
            _loc28_.y = 0;
         }
         var _loc30_= _loc28_.x * this.m_perp.x + _loc28_.y * this.m_axis.x;
         var _loc31_= _loc28_.x * this.m_perp.y + _loc28_.y * this.m_axis.y;
         var _loc32_= _loc28_.x * this.m_s1 + _loc28_.y * this.m_a1;
         var _loc33_= _loc28_.x * this.m_s2 + _loc28_.y * this.m_a2;
         _loc6_.x -= /*b2internal::*/m_invMassA * _loc30_;
         _loc6_.y -= /*b2internal::*/m_invMassA * _loc31_;
         _loc7_ -= /*b2internal::*/m_invIA * _loc32_;
         _loc8_.x += /*b2internal::*/m_invMassB * _loc30_;
         _loc8_.y += /*b2internal::*/m_invMassB * _loc31_;
         _loc9_ += /*b2internal::*/m_invIB * _loc33_;
         _loc4_/*b2internal::*/.m_sweep.a = _loc7_;
         _loc5_/*b2internal::*/.m_sweep.a = _loc9_;
         _loc4_/*b2internal::*/.SynchronizeTransform();
         _loc5_/*b2internal::*/.SynchronizeTransform();
         return _loc16_ <= B2Settings.b2_linearSlop && _loc17_ <= B2Settings.b2_angularSlop;
      }
   }


