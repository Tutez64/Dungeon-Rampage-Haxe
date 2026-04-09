package box2D.dynamics.joints
;
   import box2D.common.math.B2Mat22;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Settings;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2TimeStep;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2GearJoint extends B2Joint
   {
      
      var m_ground1:B2Body;
      
      var m_ground2:B2Body;
      
      var m_revolute1:B2RevoluteJoint;
      
      var m_prismatic1:B2PrismaticJoint;
      
      var m_revolute2:B2RevoluteJoint;
      
      var m_prismatic2:B2PrismaticJoint;
      
      var m_groundAnchor1:B2Vec2;
      
      var m_groundAnchor2:B2Vec2;
      
      var m_localAnchor1:B2Vec2;
      
      var m_localAnchor2:B2Vec2;
      
      var m_J:B2Jacobian;
      
      var m_constant:Float = Math.NaN;
      
      var m_ratio:Float = Math.NaN;
      
      var m_mass:Float = Math.NaN;
      
      var m_impulse:Float = Math.NaN;
      
      public function new(param1:B2GearJointDef)
      {
         var _loc4_= Math.NaN;
         var _loc5_= Math.NaN;
         this.m_groundAnchor1 = new B2Vec2();
         this.m_groundAnchor2 = new B2Vec2();
         this.m_localAnchor1 = new B2Vec2();
         this.m_localAnchor2 = new B2Vec2();
         this.m_J = new B2Jacobian();
         super(param1);
         var _loc2_= param1.joint1/*b2internal::*/.m_type;
         var _loc3_= param1.joint2/*b2internal::*/.m_type;
         this.m_revolute1 = null;
         this.m_prismatic1 = null;
         this.m_revolute2 = null;
         this.m_prismatic2 = null;
         this.m_ground1 = param1.joint1.GetBodyA();
         /*b2internal::*/m_bodyA = param1.joint1.GetBodyB();
         if(_loc2_ == B2Joint/*b2internal::*/.e_revoluteJoint)
         {
            this.m_revolute1 = ASCompat.reinterpretAs(param1.joint1 , B2RevoluteJoint);
            this.m_groundAnchor1.SetV(this.m_revolute1/*b2internal::*/.m_localAnchor1);
            this.m_localAnchor1.SetV(this.m_revolute1/*b2internal::*/.m_localAnchor2);
            _loc4_ = this.m_revolute1.GetJointAngle();
         }
         else
         {
            this.m_prismatic1 = ASCompat.reinterpretAs(param1.joint1 , B2PrismaticJoint);
            this.m_groundAnchor1.SetV(this.m_prismatic1/*b2internal::*/.m_localAnchor1);
            this.m_localAnchor1.SetV(this.m_prismatic1/*b2internal::*/.m_localAnchor2);
            _loc4_ = this.m_prismatic1.GetJointTranslation();
         }
         this.m_ground2 = param1.joint2.GetBodyA();
         /*b2internal::*/m_bodyB = param1.joint2.GetBodyB();
         if(_loc3_ == B2Joint/*b2internal::*/.e_revoluteJoint)
         {
            this.m_revolute2 = ASCompat.reinterpretAs(param1.joint2 , B2RevoluteJoint);
            this.m_groundAnchor2.SetV(this.m_revolute2/*b2internal::*/.m_localAnchor1);
            this.m_localAnchor2.SetV(this.m_revolute2/*b2internal::*/.m_localAnchor2);
            _loc5_ = this.m_revolute2.GetJointAngle();
         }
         else
         {
            this.m_prismatic2 = ASCompat.reinterpretAs(param1.joint2 , B2PrismaticJoint);
            this.m_groundAnchor2.SetV(this.m_prismatic2/*b2internal::*/.m_localAnchor1);
            this.m_localAnchor2.SetV(this.m_prismatic2/*b2internal::*/.m_localAnchor2);
            _loc5_ = this.m_prismatic2.GetJointTranslation();
         }
         this.m_ratio = param1.ratio;
         this.m_constant = _loc4_ + this.m_ratio * _loc5_;
         this.m_impulse = 0;
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
         return new B2Vec2(param1 * this.m_impulse * this.m_J.linearB.x,param1 * this.m_impulse * this.m_J.linearB.y);
      }
      
      override public function GetReactionTorque(param1:Float) : Float
      {
         var _loc2_= /*b2internal::*/m_bodyB/*b2internal::*/.m_xf.R;
         var _loc3_= this.m_localAnchor1.x - /*b2internal::*/m_bodyB/*b2internal::*/.m_sweep.localCenter.x;
         var _loc4_= this.m_localAnchor1.y - /*b2internal::*/m_bodyB/*b2internal::*/.m_sweep.localCenter.y;
         var _loc5_= _loc2_.col1.x * _loc3_ + _loc2_.col2.x * _loc4_;
         _loc4_ = _loc2_.col1.y * _loc3_ + _loc2_.col2.y * _loc4_;
         _loc3_ = _loc5_;
         var _loc6_= this.m_impulse * this.m_J.linearB.x;
         var _loc7_= this.m_impulse * this.m_J.linearB.y;
         return param1 * (this.m_impulse * this.m_J.angularB - _loc3_ * _loc7_ + _loc4_ * _loc6_);
      }
      
      public function GetRatio() : Float
      {
         return this.m_ratio;
      }
      
      public function SetRatio(param1:Float) 
      {
         this.m_ratio = param1;
      }
      
      override public function InitVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc4_:B2Body = null;
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc10_:B2Mat22 = null;
         var _loc11_:B2Vec2 = null;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc2_= this.m_ground1;
         var _loc3_= this.m_ground2;
         _loc4_ = /*b2internal::*/m_bodyA;
         var _loc5_= /*b2internal::*/m_bodyB;
         var _loc14_:Float = 0;
         this.m_J.SetZero();
         if(this.m_revolute1 != null)
         {
            this.m_J.angularA = -1;
            _loc14_ += _loc4_/*b2internal::*/.m_invI;
         }
         else
         {
            _loc10_ = _loc2_/*b2internal::*/.m_xf.R;
            _loc11_ = this.m_prismatic1/*b2internal::*/.m_localXAxis1;
            _loc6_ = _loc10_.col1.x * _loc11_.x + _loc10_.col2.x * _loc11_.y;
            _loc7_ = _loc10_.col1.y * _loc11_.x + _loc10_.col2.y * _loc11_.y;
            _loc10_ = _loc4_/*b2internal::*/.m_xf.R;
            _loc8_ = this.m_localAnchor1.x - _loc4_/*b2internal::*/.m_sweep.localCenter.x;
            _loc9_ = this.m_localAnchor1.y - _loc4_/*b2internal::*/.m_sweep.localCenter.y;
            _loc13_ = _loc10_.col1.x * _loc8_ + _loc10_.col2.x * _loc9_;
            _loc9_ = _loc10_.col1.y * _loc8_ + _loc10_.col2.y * _loc9_;
            _loc8_ = _loc13_;
            _loc12_ = _loc8_ * _loc7_ - _loc9_ * _loc6_;
            this.m_J.linearA.Set(-_loc6_,-_loc7_);
            this.m_J.angularA = -_loc12_;
            _loc14_ += _loc4_/*b2internal::*/.m_invMass + _loc4_/*b2internal::*/.m_invI * _loc12_ * _loc12_;
         }
         if(this.m_revolute2 != null)
         {
            this.m_J.angularB = -this.m_ratio;
            _loc14_ += this.m_ratio * this.m_ratio * _loc5_/*b2internal::*/.m_invI;
         }
         else
         {
            _loc10_ = _loc3_/*b2internal::*/.m_xf.R;
            _loc11_ = this.m_prismatic2/*b2internal::*/.m_localXAxis1;
            _loc6_ = _loc10_.col1.x * _loc11_.x + _loc10_.col2.x * _loc11_.y;
            _loc7_ = _loc10_.col1.y * _loc11_.x + _loc10_.col2.y * _loc11_.y;
            _loc10_ = _loc5_/*b2internal::*/.m_xf.R;
            _loc8_ = this.m_localAnchor2.x - _loc5_/*b2internal::*/.m_sweep.localCenter.x;
            _loc9_ = this.m_localAnchor2.y - _loc5_/*b2internal::*/.m_sweep.localCenter.y;
            _loc13_ = _loc10_.col1.x * _loc8_ + _loc10_.col2.x * _loc9_;
            _loc9_ = _loc10_.col1.y * _loc8_ + _loc10_.col2.y * _loc9_;
            _loc8_ = _loc13_;
            _loc12_ = _loc8_ * _loc7_ - _loc9_ * _loc6_;
            this.m_J.linearB.Set(-this.m_ratio * _loc6_,-this.m_ratio * _loc7_);
            this.m_J.angularB = -this.m_ratio * _loc12_;
            _loc14_ += this.m_ratio * this.m_ratio * (_loc5_/*b2internal::*/.m_invMass + _loc5_/*b2internal::*/.m_invI * _loc12_ * _loc12_);
         }
         this.m_mass = _loc14_ > 0 ? 1 / _loc14_ : 0;
         if(param1.warmStarting)
         {
            _loc4_/*b2internal::*/.m_linearVelocity.x += _loc4_/*b2internal::*/.m_invMass * this.m_impulse * this.m_J.linearA.x;
            _loc4_/*b2internal::*/.m_linearVelocity.y += _loc4_/*b2internal::*/.m_invMass * this.m_impulse * this.m_J.linearA.y;
            _loc4_/*b2internal::*/.m_angularVelocity += _loc4_/*b2internal::*/.m_invI * this.m_impulse * this.m_J.angularA;
            _loc5_/*b2internal::*/.m_linearVelocity.x += _loc5_/*b2internal::*/.m_invMass * this.m_impulse * this.m_J.linearB.x;
            _loc5_/*b2internal::*/.m_linearVelocity.y += _loc5_/*b2internal::*/.m_invMass * this.m_impulse * this.m_J.linearB.y;
            _loc5_/*b2internal::*/.m_angularVelocity += _loc5_/*b2internal::*/.m_invI * this.m_impulse * this.m_J.angularB;
         }
         else
         {
            this.m_impulse = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc2_= /*b2internal::*/m_bodyA;
         var _loc3_= /*b2internal::*/m_bodyB;
         var _loc4_= this.m_J.Compute(_loc2_/*b2internal::*/.m_linearVelocity,_loc2_/*b2internal::*/.m_angularVelocity,_loc3_/*b2internal::*/.m_linearVelocity,_loc3_/*b2internal::*/.m_angularVelocity);
         var _loc5_= -this.m_mass * _loc4_;
         this.m_impulse += _loc5_;
         _loc2_/*b2internal::*/.m_linearVelocity.x += _loc2_/*b2internal::*/.m_invMass * _loc5_ * this.m_J.linearA.x;
         _loc2_/*b2internal::*/.m_linearVelocity.y += _loc2_/*b2internal::*/.m_invMass * _loc5_ * this.m_J.linearA.y;
         _loc2_/*b2internal::*/.m_angularVelocity += _loc2_/*b2internal::*/.m_invI * _loc5_ * this.m_J.angularA;
         _loc3_/*b2internal::*/.m_linearVelocity.x += _loc3_/*b2internal::*/.m_invMass * _loc5_ * this.m_J.linearB.x;
         _loc3_/*b2internal::*/.m_linearVelocity.y += _loc3_/*b2internal::*/.m_invMass * _loc5_ * this.m_J.linearB.y;
         _loc3_/*b2internal::*/.m_angularVelocity += _loc3_/*b2internal::*/.m_invI * _loc5_ * this.m_J.angularB;
      }
      
      override public function SolvePositionConstraints(param1:Float) : Bool
      {
         var _loc5_= Math.NaN;
         var _loc6_= Math.NaN;
         var _loc2_:Float = 0;
         var _loc3_= /*b2internal::*/m_bodyA;
         var _loc4_= /*b2internal::*/m_bodyB;
         if(this.m_revolute1 != null)
         {
            _loc5_ = this.m_revolute1.GetJointAngle();
         }
         else
         {
            _loc5_ = this.m_prismatic1.GetJointTranslation();
         }
         if(this.m_revolute2 != null)
         {
            _loc6_ = this.m_revolute2.GetJointAngle();
         }
         else
         {
            _loc6_ = this.m_prismatic2.GetJointTranslation();
         }
         var _loc7_= this.m_constant - (_loc5_ + this.m_ratio * _loc6_);
         var _loc8_= -this.m_mass * _loc7_;
         _loc3_/*b2internal::*/.m_sweep.c.x += _loc3_/*b2internal::*/.m_invMass * _loc8_ * this.m_J.linearA.x;
         _loc3_/*b2internal::*/.m_sweep.c.y += _loc3_/*b2internal::*/.m_invMass * _loc8_ * this.m_J.linearA.y;
         _loc3_/*b2internal::*/.m_sweep.a += _loc3_/*b2internal::*/.m_invI * _loc8_ * this.m_J.angularA;
         _loc4_/*b2internal::*/.m_sweep.c.x += _loc4_/*b2internal::*/.m_invMass * _loc8_ * this.m_J.linearB.x;
         _loc4_/*b2internal::*/.m_sweep.c.y += _loc4_/*b2internal::*/.m_invMass * _loc8_ * this.m_J.linearB.y;
         _loc4_/*b2internal::*/.m_sweep.a += _loc4_/*b2internal::*/.m_invI * _loc8_ * this.m_J.angularB;
         _loc3_/*b2internal::*/.SynchronizeTransform();
         _loc4_/*b2internal::*/.SynchronizeTransform();
         return _loc2_ < B2Settings.b2_linearSlop;
      }
   }


