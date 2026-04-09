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
   
    class B2RevoluteJoint extends B2Joint
   {
      
      static var tImpulse:B2Vec2 = new B2Vec2();
      
      var K:B2Mat22 = new B2Mat22();
      
      var K1:B2Mat22 = new B2Mat22();
      
      var K2:B2Mat22 = new B2Mat22();
      
      var K3:B2Mat22 = new B2Mat22();
      
      var impulse3:B2Vec3 = new B2Vec3();
      
      var impulse2:B2Vec2 = new B2Vec2();
      
      var reduced:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_localAnchor1:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_localAnchor2:B2Vec2 = new B2Vec2();
      
      var m_impulse:B2Vec3 = new B2Vec3();
      
      var m_motorImpulse:Float = Math.NaN;
      
      var m_mass:B2Mat33 = new B2Mat33();
      
      var m_motorMass:Float = Math.NaN;
      
      var m_enableMotor:Bool = false;
      
      var m_maxMotorTorque:Float = Math.NaN;
      
      var m_motorSpeed:Float = Math.NaN;
      
      var m_enableLimit:Bool = false;
      
      var m_referenceAngle:Float = Math.NaN;
      
      var m_lowerAngle:Float = Math.NaN;
      
      var m_upperAngle:Float = Math.NaN;
      
      var m_limitState:Int = 0;
      
      public function new(param1:B2RevoluteJointDef)
      {
         super(param1);
         this/*b2internal::*/.m_localAnchor1.SetV(param1.localAnchorA);
         this/*b2internal::*/.m_localAnchor2.SetV(param1.localAnchorB);
         this.m_referenceAngle = param1.referenceAngle;
         this.m_impulse.SetZero();
         this.m_motorImpulse = 0;
         this.m_lowerAngle = param1.lowerAngle;
         this.m_upperAngle = param1.upperAngle;
         this.m_maxMotorTorque = param1.maxMotorTorque;
         this.m_motorSpeed = param1.motorSpeed;
         this.m_enableLimit = param1.enableLimit;
         this.m_enableMotor = param1.enableMotor;
         this.m_limitState = /*b2internal::*/B2Joint.e_inactiveLimit;
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
         return new B2Vec2(param1 * this.m_impulse.x,param1 * this.m_impulse.y);
      }
      
      override public function GetReactionTorque(param1:Float) : Float
      {
         return param1 * this.m_impulse.z;
      }
      
      public function GetJointAngle() : Float
      {
         return /*b2internal::*/m_bodyB/*b2internal::*/.m_sweep.a - /*b2internal::*/m_bodyA/*b2internal::*/.m_sweep.a - this.m_referenceAngle;
      }
      
      public function GetJointSpeed() : Float
      {
         return /*b2internal::*/m_bodyB/*b2internal::*/.m_angularVelocity - /*b2internal::*/m_bodyA/*b2internal::*/.m_angularVelocity;
      }
      
      public function IsLimitEnabled() : Bool
      {
         return this.m_enableLimit;
      }
      
      public function EnableLimit(param1:Bool) 
      {
         this.m_enableLimit = param1;
      }
      
      public function GetLowerLimit() : Float
      {
         return this.m_lowerAngle;
      }
      
      public function GetUpperLimit() : Float
      {
         return this.m_upperAngle;
      }
      
      public function SetLimits(param1:Float, param2:Float) 
      {
         this.m_lowerAngle = param1;
         this.m_upperAngle = param2;
      }
      
      public function IsMotorEnabled() : Bool
      {
         /*b2internal::*/m_bodyA.SetAwake(true);
         /*b2internal::*/m_bodyB.SetAwake(true);
         return this.m_enableMotor;
      }
      
      public function EnableMotor(param1:Bool) 
      {
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
      
      public function SetMaxMotorTorque(param1:Float) 
      {
         this.m_maxMotorTorque = param1;
      }
      
      public function GetMotorTorque() : Float
      {
         return this.m_maxMotorTorque;
      }
      
      override public function InitVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc2_:B2Body = null;
         var _loc3_:B2Body = null;
         var _loc4_:B2Mat22 = null;
         var _loc5_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         _loc2_ = /*b2internal::*/m_bodyA;
         _loc3_ = /*b2internal::*/m_bodyB;
         if(this.m_enableMotor || this.m_enableLimit)
         {
         }
         _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
         var _loc6_= this/*b2internal::*/.m_localAnchor1.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
         _loc7_ = this/*b2internal::*/.m_localAnchor1.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
         _loc5_ = _loc4_.col1.x * _loc6_ + _loc4_.col2.x * _loc7_;
         _loc7_ = _loc4_.col1.y * _loc6_ + _loc4_.col2.y * _loc7_;
         _loc6_ = _loc5_;
         _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
         var _loc8_= this/*b2internal::*/.m_localAnchor2.x - _loc3_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc9_= this/*b2internal::*/.m_localAnchor2.y - _loc3_/*b2internal::*/.m_sweep.localCenter.y;
         _loc5_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
         _loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
         _loc8_ = _loc5_;
         var _loc10_= _loc2_/*b2internal::*/.m_invMass;
         var _loc11_= _loc3_/*b2internal::*/.m_invMass;
         var _loc12_= _loc2_/*b2internal::*/.m_invI;
         var _loc13_= _loc3_/*b2internal::*/.m_invI;
         this.m_mass.col1.x = _loc10_ + _loc11_ + _loc7_ * _loc7_ * _loc12_ + _loc9_ * _loc9_ * _loc13_;
         this.m_mass.col2.x = -_loc7_ * _loc6_ * _loc12_ - _loc9_ * _loc8_ * _loc13_;
         this.m_mass.col3.x = -_loc7_ * _loc12_ - _loc9_ * _loc13_;
         this.m_mass.col1.y = this.m_mass.col2.x;
         this.m_mass.col2.y = _loc10_ + _loc11_ + _loc6_ * _loc6_ * _loc12_ + _loc8_ * _loc8_ * _loc13_;
         this.m_mass.col3.y = _loc6_ * _loc12_ + _loc8_ * _loc13_;
         this.m_mass.col1.z = this.m_mass.col3.x;
         this.m_mass.col2.z = this.m_mass.col3.y;
         this.m_mass.col3.z = _loc12_ + _loc13_;
         this.m_motorMass = 1 / (_loc12_ + _loc13_);
         if(this.m_enableMotor == false)
         {
            this.m_motorImpulse = 0;
         }
         if(this.m_enableLimit)
         {
            _loc14_ = _loc3_/*b2internal::*/.m_sweep.a - _loc2_/*b2internal::*/.m_sweep.a - this.m_referenceAngle;
            if(B2Math.Abs(this.m_upperAngle - this.m_lowerAngle) < 2 * B2Settings.b2_angularSlop)
            {
               this.m_limitState = /*b2internal::*/B2Joint.e_equalLimits;
            }
            else if(_loc14_ <= this.m_lowerAngle)
            {
               if(this.m_limitState != /*b2internal::*/B2Joint.e_atLowerLimit)
               {
                  this.m_impulse.z = 0;
               }
               this.m_limitState = /*b2internal::*/B2Joint.e_atLowerLimit;
            }
            else if(_loc14_ >= this.m_upperAngle)
            {
               if(this.m_limitState != /*b2internal::*/B2Joint.e_atUpperLimit)
               {
                  this.m_impulse.z = 0;
               }
               this.m_limitState = /*b2internal::*/B2Joint.e_atUpperLimit;
            }
            else
            {
               this.m_limitState = /*b2internal::*/B2Joint.e_inactiveLimit;
               this.m_impulse.z = 0;
            }
         }
         else
         {
            this.m_limitState = /*b2internal::*/B2Joint.e_inactiveLimit;
         }
         if(param1.warmStarting)
         {
            this.m_impulse.x *= param1.dtRatio;
            this.m_impulse.y *= param1.dtRatio;
            this.m_motorImpulse *= param1.dtRatio;
            _loc15_ = this.m_impulse.x;
            _loc16_ = this.m_impulse.y;
            _loc2_/*b2internal::*/.m_linearVelocity.x -= _loc10_ * _loc15_;
            _loc2_/*b2internal::*/.m_linearVelocity.y -= _loc10_ * _loc16_;
            _loc2_/*b2internal::*/.m_angularVelocity -= _loc12_ * (_loc6_ * _loc16_ - _loc7_ * _loc15_ + this.m_motorImpulse + this.m_impulse.z);
            _loc3_/*b2internal::*/.m_linearVelocity.x += _loc11_ * _loc15_;
            _loc3_/*b2internal::*/.m_linearVelocity.y += _loc11_ * _loc16_;
            _loc3_/*b2internal::*/.m_angularVelocity += _loc13_ * (_loc8_ * _loc16_ - _loc9_ * _loc15_ + this.m_motorImpulse + this.m_impulse.z);
         }
         else
         {
            this.m_impulse.SetZero();
            this.m_motorImpulse = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc4_:B2Mat22 = null;
         var _loc5_= Math.NaN;
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc23_= Math.NaN;
         var _loc24_= Math.NaN;
         var _loc25_= Math.NaN;
         var _loc26_= Math.NaN;
         var _loc27_= Math.NaN;
         var _loc2_= /*b2internal::*/m_bodyA;
         var _loc3_= /*b2internal::*/m_bodyB;
         var _loc11_= _loc2_/*b2internal::*/.m_linearVelocity;
         var _loc12_= _loc2_/*b2internal::*/.m_angularVelocity;
         var _loc13_= _loc3_/*b2internal::*/.m_linearVelocity;
         var _loc14_= _loc3_/*b2internal::*/.m_angularVelocity;
         var _loc15_= _loc2_/*b2internal::*/.m_invMass;
         var _loc16_= _loc3_/*b2internal::*/.m_invMass;
         var _loc17_= _loc2_/*b2internal::*/.m_invI;
         var _loc18_= _loc3_/*b2internal::*/.m_invI;
         if(this.m_enableMotor && this.m_limitState != /*b2internal::*/B2Joint.e_equalLimits)
         {
            _loc19_ = _loc14_ - _loc12_ - this.m_motorSpeed;
            _loc20_ = this.m_motorMass * -_loc19_;
            _loc21_ = this.m_motorImpulse;
            _loc22_ = param1.dt * this.m_maxMotorTorque;
            this.m_motorImpulse = B2Math.Clamp(this.m_motorImpulse + _loc20_,-_loc22_,_loc22_);
            _loc20_ = this.m_motorImpulse - _loc21_;
            _loc12_ -= _loc17_ * _loc20_;
            _loc14_ += _loc18_ * _loc20_;
         }
         if(this.m_enableLimit && this.m_limitState != /*b2internal::*/B2Joint.e_inactiveLimit)
         {
            _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
            _loc7_ = this/*b2internal::*/.m_localAnchor1.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
            _loc8_ = this/*b2internal::*/.m_localAnchor1.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
            _loc5_ = _loc4_.col1.x * _loc7_ + _loc4_.col2.x * _loc8_;
            _loc8_ = _loc4_.col1.y * _loc7_ + _loc4_.col2.y * _loc8_;
            _loc7_ = _loc5_;
            _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
            _loc9_ = this/*b2internal::*/.m_localAnchor2.x - _loc3_/*b2internal::*/.m_sweep.localCenter.x;
            _loc10_ = this/*b2internal::*/.m_localAnchor2.y - _loc3_/*b2internal::*/.m_sweep.localCenter.y;
            _loc5_ = _loc4_.col1.x * _loc9_ + _loc4_.col2.x * _loc10_;
            _loc10_ = _loc4_.col1.y * _loc9_ + _loc4_.col2.y * _loc10_;
            _loc9_ = _loc5_;
            _loc23_ = _loc13_.x + -_loc14_ * _loc10_ - _loc11_.x - -_loc12_ * _loc8_;
            _loc24_ = _loc13_.y + _loc14_ * _loc9_ - _loc11_.y - _loc12_ * _loc7_;
            _loc25_ = _loc14_ - _loc12_;
            this.m_mass.Solve33(this.impulse3,-_loc23_,-_loc24_,-_loc25_);
            if(this.m_limitState == /*b2internal::*/B2Joint.e_equalLimits)
            {
               this.m_impulse.Add(this.impulse3);
            }
            else if(this.m_limitState == /*b2internal::*/B2Joint.e_atLowerLimit)
            {
               _loc6_ = this.m_impulse.z + this.impulse3.z;
               if(_loc6_ < 0)
               {
                  this.m_mass.Solve22(this.reduced,-_loc23_,-_loc24_);
                  this.impulse3.x = this.reduced.x;
                  this.impulse3.y = this.reduced.y;
                  this.impulse3.z = -this.m_impulse.z;
                  this.m_impulse.x += this.reduced.x;
                  this.m_impulse.y += this.reduced.y;
                  this.m_impulse.z = 0;
               }
            }
            else if(this.m_limitState == /*b2internal::*/B2Joint.e_atUpperLimit)
            {
               _loc6_ = this.m_impulse.z + this.impulse3.z;
               if(_loc6_ > 0)
               {
                  this.m_mass.Solve22(this.reduced,-_loc23_,-_loc24_);
                  this.impulse3.x = this.reduced.x;
                  this.impulse3.y = this.reduced.y;
                  this.impulse3.z = -this.m_impulse.z;
                  this.m_impulse.x += this.reduced.x;
                  this.m_impulse.y += this.reduced.y;
                  this.m_impulse.z = 0;
               }
            }
            _loc11_.x -= _loc15_ * this.impulse3.x;
            _loc11_.y -= _loc15_ * this.impulse3.y;
            _loc12_ -= _loc17_ * (_loc7_ * this.impulse3.y - _loc8_ * this.impulse3.x + this.impulse3.z);
            _loc13_.x += _loc16_ * this.impulse3.x;
            _loc13_.y += _loc16_ * this.impulse3.y;
            _loc14_ += _loc18_ * (_loc9_ * this.impulse3.y - _loc10_ * this.impulse3.x + this.impulse3.z);
         }
         else
         {
            _loc4_ = _loc2_/*b2internal::*/.m_xf.R;
            _loc7_ = this/*b2internal::*/.m_localAnchor1.x - _loc2_/*b2internal::*/.m_sweep.localCenter.x;
            _loc8_ = this/*b2internal::*/.m_localAnchor1.y - _loc2_/*b2internal::*/.m_sweep.localCenter.y;
            _loc5_ = _loc4_.col1.x * _loc7_ + _loc4_.col2.x * _loc8_;
            _loc8_ = _loc4_.col1.y * _loc7_ + _loc4_.col2.y * _loc8_;
            _loc7_ = _loc5_;
            _loc4_ = _loc3_/*b2internal::*/.m_xf.R;
            _loc9_ = this/*b2internal::*/.m_localAnchor2.x - _loc3_/*b2internal::*/.m_sweep.localCenter.x;
            _loc10_ = this/*b2internal::*/.m_localAnchor2.y - _loc3_/*b2internal::*/.m_sweep.localCenter.y;
            _loc5_ = _loc4_.col1.x * _loc9_ + _loc4_.col2.x * _loc10_;
            _loc10_ = _loc4_.col1.y * _loc9_ + _loc4_.col2.y * _loc10_;
            _loc9_ = _loc5_;
            _loc26_ = _loc13_.x + -_loc14_ * _loc10_ - _loc11_.x - -_loc12_ * _loc8_;
            _loc27_ = _loc13_.y + _loc14_ * _loc9_ - _loc11_.y - _loc12_ * _loc7_;
            this.m_mass.Solve22(this.impulse2,-_loc26_,-_loc27_);
            this.m_impulse.x += this.impulse2.x;
            this.m_impulse.y += this.impulse2.y;
            _loc11_.x -= _loc15_ * this.impulse2.x;
            _loc11_.y -= _loc15_ * this.impulse2.y;
            _loc12_ -= _loc17_ * (_loc7_ * this.impulse2.y - _loc8_ * this.impulse2.x);
            _loc13_.x += _loc16_ * this.impulse2.x;
            _loc13_.y += _loc16_ * this.impulse2.y;
            _loc14_ += _loc18_ * (_loc9_ * this.impulse2.y - _loc10_ * this.impulse2.x);
         }
         _loc2_/*b2internal::*/.m_linearVelocity.SetV(_loc11_);
         _loc2_/*b2internal::*/.m_angularVelocity = _loc12_;
         _loc3_/*b2internal::*/.m_linearVelocity.SetV(_loc13_);
         _loc3_/*b2internal::*/.m_angularVelocity = _loc14_;
      }
      
      override public function SolvePositionConstraints(param1:Float) : Bool
      {
         var _loc2_= Math.NaN;
         var _loc3_= Math.NaN;
         var _loc4_:B2Mat22 = null;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc25_= Math.NaN;
         var _loc26_= Math.NaN;
         var _loc27_= Math.NaN;
         var _loc28_= Math.NaN;
         var _loc29_= Math.NaN;
         var _loc30_= Math.NaN;
         var _loc31_= Math.NaN;
         var _loc5_= /*b2internal::*/m_bodyA;
         var _loc6_= /*b2internal::*/m_bodyB;
         var _loc7_:Float = 0;
         var _loc8_:Float = 0;
         if(this.m_enableLimit && this.m_limitState != /*b2internal::*/B2Joint.e_inactiveLimit)
         {
            _loc25_ = _loc6_/*b2internal::*/.m_sweep.a - _loc5_/*b2internal::*/.m_sweep.a - this.m_referenceAngle;
            _loc26_ = 0;
            if(this.m_limitState == /*b2internal::*/B2Joint.e_equalLimits)
            {
               _loc3_ = B2Math.Clamp(_loc25_ - this.m_lowerAngle,-B2Settings.b2_maxAngularCorrection,B2Settings.b2_maxAngularCorrection);
               _loc26_ = -this.m_motorMass * _loc3_;
               _loc7_ = B2Math.Abs(_loc3_);
            }
            else if(this.m_limitState == /*b2internal::*/B2Joint.e_atLowerLimit)
            {
               _loc3_ = _loc25_ - this.m_lowerAngle;
               _loc7_ = -_loc3_;
               _loc3_ = B2Math.Clamp(_loc3_ + B2Settings.b2_angularSlop,-B2Settings.b2_maxAngularCorrection,0);
               _loc26_ = -this.m_motorMass * _loc3_;
            }
            else if(this.m_limitState == /*b2internal::*/B2Joint.e_atUpperLimit)
            {
               _loc3_ = _loc25_ - this.m_upperAngle;
               _loc7_ = _loc3_;
               _loc3_ = B2Math.Clamp(_loc3_ - B2Settings.b2_angularSlop,0,B2Settings.b2_maxAngularCorrection);
               _loc26_ = -this.m_motorMass * _loc3_;
            }
            _loc5_/*b2internal::*/.m_sweep.a -= _loc5_/*b2internal::*/.m_invI * _loc26_;
            _loc6_/*b2internal::*/.m_sweep.a += _loc6_/*b2internal::*/.m_invI * _loc26_;
            _loc5_/*b2internal::*/.SynchronizeTransform();
            _loc6_/*b2internal::*/.SynchronizeTransform();
         }
         _loc4_ = _loc5_/*b2internal::*/.m_xf.R;
         var _loc12_= this/*b2internal::*/.m_localAnchor1.x - _loc5_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc13_= this/*b2internal::*/.m_localAnchor1.y - _loc5_/*b2internal::*/.m_sweep.localCenter.y;
         _loc9_ = _loc4_.col1.x * _loc12_ + _loc4_.col2.x * _loc13_;
         _loc13_ = _loc4_.col1.y * _loc12_ + _loc4_.col2.y * _loc13_;
         _loc12_ = _loc9_;
         _loc4_ = _loc6_/*b2internal::*/.m_xf.R;
         var _loc14_= this/*b2internal::*/.m_localAnchor2.x - _loc6_/*b2internal::*/.m_sweep.localCenter.x;
         var _loc15_= this/*b2internal::*/.m_localAnchor2.y - _loc6_/*b2internal::*/.m_sweep.localCenter.y;
         _loc9_ = _loc4_.col1.x * _loc14_ + _loc4_.col2.x * _loc15_;
         _loc15_ = _loc4_.col1.y * _loc14_ + _loc4_.col2.y * _loc15_;
         _loc14_ = _loc9_;
         var _loc16_= _loc6_/*b2internal::*/.m_sweep.c.x + _loc14_ - _loc5_/*b2internal::*/.m_sweep.c.x - _loc12_;
         var _loc17_= _loc6_/*b2internal::*/.m_sweep.c.y + _loc15_ - _loc5_/*b2internal::*/.m_sweep.c.y - _loc13_;
         var _loc18_= _loc16_ * _loc16_ + _loc17_ * _loc17_;
         var _loc19_:Float;
         _loc8_ = _loc19_ = Math.sqrt(_loc18_);
         var _loc20_= _loc5_/*b2internal::*/.m_invMass;
         var _loc21_= _loc6_/*b2internal::*/.m_invMass;
         var _loc22_= _loc5_/*b2internal::*/.m_invI;
         var _loc23_= _loc6_/*b2internal::*/.m_invI;
         var _loc24_= 10 * B2Settings.b2_linearSlop;
         if(_loc18_ > _loc24_ * _loc24_)
         {
            _loc27_ = _loc16_ / _loc19_;
            _loc28_ = _loc17_ / _loc19_;
            _loc29_ = _loc20_ + _loc21_;
            _loc30_ = 1 / _loc29_;
            _loc10_ = _loc30_ * -_loc16_;
            _loc11_ = _loc30_ * -_loc17_;
            _loc31_ = 0.5;
            _loc5_/*b2internal::*/.m_sweep.c.x -= _loc31_ * _loc20_ * _loc10_;
            _loc5_/*b2internal::*/.m_sweep.c.y -= _loc31_ * _loc20_ * _loc11_;
            _loc6_/*b2internal::*/.m_sweep.c.x += _loc31_ * _loc21_ * _loc10_;
            _loc6_/*b2internal::*/.m_sweep.c.y += _loc31_ * _loc21_ * _loc11_;
            _loc16_ = _loc6_/*b2internal::*/.m_sweep.c.x + _loc14_ - _loc5_/*b2internal::*/.m_sweep.c.x - _loc12_;
            _loc17_ = _loc6_/*b2internal::*/.m_sweep.c.y + _loc15_ - _loc5_/*b2internal::*/.m_sweep.c.y - _loc13_;
         }
         this.K1.col1.x = _loc20_ + _loc21_;
         this.K1.col2.x = 0;
         this.K1.col1.y = 0;
         this.K1.col2.y = _loc20_ + _loc21_;
         this.K2.col1.x = _loc22_ * _loc13_ * _loc13_;
         this.K2.col2.x = -_loc22_ * _loc12_ * _loc13_;
         this.K2.col1.y = -_loc22_ * _loc12_ * _loc13_;
         this.K2.col2.y = _loc22_ * _loc12_ * _loc12_;
         this.K3.col1.x = _loc23_ * _loc15_ * _loc15_;
         this.K3.col2.x = -_loc23_ * _loc14_ * _loc15_;
         this.K3.col1.y = -_loc23_ * _loc14_ * _loc15_;
         this.K3.col2.y = _loc23_ * _loc14_ * _loc14_;
         this.K.SetM(this.K1);
         this.K.AddM(this.K2);
         this.K.AddM(this.K3);
         this.K.Solve(tImpulse,-_loc16_,-_loc17_);
         _loc10_ = tImpulse.x;
         _loc11_ = tImpulse.y;
         _loc5_/*b2internal::*/.m_sweep.c.x -= _loc5_/*b2internal::*/.m_invMass * _loc10_;
         _loc5_/*b2internal::*/.m_sweep.c.y -= _loc5_/*b2internal::*/.m_invMass * _loc11_;
         _loc5_/*b2internal::*/.m_sweep.a -= _loc5_/*b2internal::*/.m_invI * (_loc12_ * _loc11_ - _loc13_ * _loc10_);
         _loc6_/*b2internal::*/.m_sweep.c.x += _loc6_/*b2internal::*/.m_invMass * _loc10_;
         _loc6_/*b2internal::*/.m_sweep.c.y += _loc6_/*b2internal::*/.m_invMass * _loc11_;
         _loc6_/*b2internal::*/.m_sweep.a += _loc6_/*b2internal::*/.m_invI * (_loc14_ * _loc11_ - _loc15_ * _loc10_);
         _loc5_/*b2internal::*/.SynchronizeTransform();
         _loc6_/*b2internal::*/.SynchronizeTransform();
         return _loc8_ <= B2Settings.b2_linearSlop && _loc7_ <= B2Settings.b2_angularSlop;
      }
   }


