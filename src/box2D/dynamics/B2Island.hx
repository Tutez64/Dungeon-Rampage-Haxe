package box2D.dynamics
;
   import box2D.collision.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.contacts.*;
   import box2D.dynamics.joints.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2Island
   {
      
      static var s_impulse:B2ContactImpulse = new B2ContactImpulse();
      
      var m_allocator:ASAny;
      
      var m_listener:B2ContactListener;
      
      var m_contactSolver:B2ContactSolver;
      
      /*b2internal*/ public var m_bodies:Vector<B2Body>;
      
      /*b2internal*/ public var m_contacts:Vector<B2Contact>;
      
      /*b2internal*/ public var m_joints:Vector<B2Joint>;
      
      /*b2internal*/ public var m_bodyCount:Int = 0;
      
      /*b2internal*/ public var m_jointCount:Int = 0;
      
      /*b2internal*/ public var m_contactCount:Int = 0;
      
      var m_bodyCapacity:Int = 0;
      
      /*b2internal*/ public var m_contactCapacity:Int = 0;
      
      /*b2internal*/ public var m_jointCapacity:Int = 0;
      
      public function new()
      {
         
         this/*b2internal::*/.m_bodies = new Vector<B2Body>();
         this/*b2internal::*/.m_contacts = new Vector<B2Contact>();
         this/*b2internal::*/.m_joints = new Vector<B2Joint>();
      }
      
      public function Initialize(param1:Int, param2:Int, param3:Int, param4:ASAny, param5:B2ContactListener, param6:B2ContactSolver) 
      {
         var _loc7_= 0;
         this.m_bodyCapacity = param1;
         this/*b2internal::*/.m_contactCapacity = param2;
         this/*b2internal::*/.m_jointCapacity = param3;
         this/*b2internal::*/.m_bodyCount = 0;
         this/*b2internal::*/.m_contactCount = 0;
         this/*b2internal::*/.m_jointCount = 0;
         this.m_allocator = param4;
         this.m_listener = param5;
         this.m_contactSolver = param6;
         _loc7_ = this/*b2internal::*/.m_bodies.length;
         while(_loc7_ < param1)
         {
            this/*b2internal::*/.m_bodies[_loc7_] = null;
            _loc7_++;
         }
         _loc7_ = this/*b2internal::*/.m_contacts.length;
         while(_loc7_ < param2)
         {
            this/*b2internal::*/.m_contacts[_loc7_] = null;
            _loc7_++;
         }
         _loc7_ = this/*b2internal::*/.m_joints.length;
         while(_loc7_ < param3)
         {
            this/*b2internal::*/.m_joints[_loc7_] = null;
            _loc7_++;
         }
      }
      
      public function Clear() 
      {
         this/*b2internal::*/.m_bodyCount = 0;
         this/*b2internal::*/.m_contactCount = 0;
         this/*b2internal::*/.m_jointCount = 0;
      }
      
      public function Solve(param1:B2TimeStep, param2:B2Vec2, param3:Bool) 
      {
         var _loc4_= 0;
         var _loc5_= 0;
         var _loc6_:B2Body = null;
         var _loc7_:B2Joint = null;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc12_= false;
         var _loc13_= false;
         var _loc14_= false;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         _loc4_ = 0;
         while(_loc4_ < this/*b2internal::*/.m_bodyCount)
         {
            _loc6_ = this/*b2internal::*/.m_bodies[_loc4_];
            if(_loc6_.GetType() == B2Body.b2_dynamicBody)
            {
               _loc6_/*b2internal::*/.m_linearVelocity.x += param1.dt * (param2.x + _loc6_/*b2internal::*/.m_invMass * _loc6_/*b2internal::*/.m_force.x);
               _loc6_/*b2internal::*/.m_linearVelocity.y += param1.dt * (param2.y + _loc6_/*b2internal::*/.m_invMass * _loc6_/*b2internal::*/.m_force.y);
               _loc6_/*b2internal::*/.m_angularVelocity += param1.dt * _loc6_/*b2internal::*/.m_invI * _loc6_/*b2internal::*/.m_torque;
               _loc6_/*b2internal::*/.m_linearVelocity.Multiply(B2Math.Clamp(1 - param1.dt * _loc6_/*b2internal::*/.m_linearDamping,0,1));
               _loc6_/*b2internal::*/.m_angularVelocity *= B2Math.Clamp(1 - param1.dt * _loc6_/*b2internal::*/.m_angularDamping,0,1);
            }
            _loc4_++;
         }
         this.m_contactSolver.Initialize(param1,this/*b2internal::*/.m_contacts,this/*b2internal::*/.m_contactCount,this.m_allocator);
         var _loc8_= this.m_contactSolver;
         _loc8_.InitVelocityConstraints(param1);
         _loc4_ = 0;
         while(_loc4_ < this/*b2internal::*/.m_jointCount)
         {
            _loc7_ = this/*b2internal::*/.m_joints[_loc4_];
            _loc7_/*b2internal::*/.InitVelocityConstraints(param1);
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < param1.velocityIterations)
         {
            _loc5_ = 0;
            while(_loc5_ < this/*b2internal::*/.m_jointCount)
            {
               _loc7_ = this/*b2internal::*/.m_joints[_loc5_];
               _loc7_/*b2internal::*/.SolveVelocityConstraints(param1);
               _loc5_++;
            }
            _loc8_.SolveVelocityConstraints();
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < this/*b2internal::*/.m_jointCount)
         {
            _loc7_ = this/*b2internal::*/.m_joints[_loc4_];
            _loc7_/*b2internal::*/.FinalizeVelocityConstraints();
            _loc4_++;
         }
         _loc8_.FinalizeVelocityConstraints();
         _loc4_ = 0;
         while(_loc4_ < this/*b2internal::*/.m_bodyCount)
         {
            _loc6_ = this/*b2internal::*/.m_bodies[_loc4_];
            if(_loc6_.GetType() != B2Body.b2_staticBody)
            {
               _loc9_ = param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.x;
               _loc10_ = param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.y;
               if(_loc9_ * _loc9_ + _loc10_ * _loc10_ > B2Settings.b2_maxTranslationSquared)
               {
                  _loc6_/*b2internal::*/.m_linearVelocity.Normalize();
                  _loc6_/*b2internal::*/.m_linearVelocity.x *= B2Settings.b2_maxTranslation * param1.inv_dt;
                  _loc6_/*b2internal::*/.m_linearVelocity.y *= B2Settings.b2_maxTranslation * param1.inv_dt;
               }
               _loc11_ = param1.dt * _loc6_/*b2internal::*/.m_angularVelocity;
               if(_loc11_ * _loc11_ > B2Settings.b2_maxRotationSquared)
               {
                  if(_loc6_/*b2internal::*/.m_angularVelocity < 0)
                  {
                     _loc6_/*b2internal::*/.m_angularVelocity = -B2Settings.b2_maxRotation * param1.inv_dt;
                  }
                  else
                  {
                     _loc6_/*b2internal::*/.m_angularVelocity = B2Settings.b2_maxRotation * param1.inv_dt;
                  }
               }
               _loc6_/*b2internal::*/.m_sweep.c0.SetV(_loc6_/*b2internal::*/.m_sweep.c);
               _loc6_/*b2internal::*/.m_sweep.a0 = _loc6_/*b2internal::*/.m_sweep.a;
               _loc6_/*b2internal::*/.m_sweep.c.x += param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.x;
               _loc6_/*b2internal::*/.m_sweep.c.y += param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.y;
               _loc6_/*b2internal::*/.m_sweep.a += param1.dt * _loc6_/*b2internal::*/.m_angularVelocity;
               _loc6_/*b2internal::*/.SynchronizeTransform();
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < param1.positionIterations)
         {
            _loc12_ = _loc8_.SolvePositionConstraints(B2Settings.b2_contactBaumgarte);
            _loc13_ = true;
            _loc5_ = 0;
            while(_loc5_ < this/*b2internal::*/.m_jointCount)
            {
               _loc7_ = this/*b2internal::*/.m_joints[_loc5_];
               _loc14_ = _loc7_/*b2internal::*/.SolvePositionConstraints(B2Settings.b2_contactBaumgarte);
               _loc13_ = _loc13_ && _loc14_;
               _loc5_++;
            }
            if(_loc12_ && _loc13_)
            {
               break;
            }
            _loc4_++;
         }
         this.Report(_loc8_/*b2internal::*/.m_constraints);
         if(param3)
         {
            _loc15_ = ASCompat.MAX_FLOAT;
            _loc16_ = B2Settings.b2_linearSleepTolerance * B2Settings.b2_linearSleepTolerance;
            _loc17_ = B2Settings.b2_angularSleepTolerance * B2Settings.b2_angularSleepTolerance;
            _loc4_ = 0;
            while(_loc4_ < this/*b2internal::*/.m_bodyCount)
            {
               _loc6_ = this/*b2internal::*/.m_bodies[_loc4_];
               if(_loc6_.GetType() != B2Body.b2_staticBody)
               {
                  if(((_loc6_/*b2internal::*/.m_flags : Int) & (B2Body/*b2internal::*/.e_allowSleepFlag : Int)) == 0)
                  {
                     _loc6_/*b2internal::*/.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  if(((_loc6_/*b2internal::*/.m_flags : Int) & (B2Body/*b2internal::*/.e_allowSleepFlag : Int)) == 0 || _loc6_/*b2internal::*/.m_angularVelocity * _loc6_/*b2internal::*/.m_angularVelocity > _loc17_ || B2Math.Dot(_loc6_/*b2internal::*/.m_linearVelocity,_loc6_/*b2internal::*/.m_linearVelocity) > _loc16_)
                  {
                     _loc6_/*b2internal::*/.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  else
                  {
                     _loc6_/*b2internal::*/.m_sleepTime += param1.dt;
                     _loc15_ = B2Math.Min(_loc15_,_loc6_/*b2internal::*/.m_sleepTime);
                  }
               }
               _loc4_++;
            }
            if(_loc15_ >= B2Settings.b2_timeToSleep)
            {
               _loc4_ = 0;
               while(_loc4_ < this/*b2internal::*/.m_bodyCount)
               {
                  _loc6_ = this/*b2internal::*/.m_bodies[_loc4_];
                  _loc6_.SetAwake(false);
                  _loc4_++;
               }
            }
         }
      }
      
      public function SolveTOI(param1:B2TimeStep) 
      {
         var _loc2_= 0;
         var _loc3_= 0;
         var _loc6_:B2Body = null;
         var _loc7_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc10_= false;
         var _loc11_= false;
         var _loc12_= false;
         this.m_contactSolver.Initialize(param1,this/*b2internal::*/.m_contacts,this/*b2internal::*/.m_contactCount,this.m_allocator);
         var _loc4_= this.m_contactSolver;
         _loc2_ = 0;
         while(_loc2_ < this/*b2internal::*/.m_jointCount)
         {
            this/*b2internal::*/.m_joints[_loc2_]/*b2internal::*/.InitVelocityConstraints(param1);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < param1.velocityIterations)
         {
            _loc4_.SolveVelocityConstraints();
            _loc3_ = 0;
            while(_loc3_ < this/*b2internal::*/.m_jointCount)
            {
               this/*b2internal::*/.m_joints[_loc3_]/*b2internal::*/.SolveVelocityConstraints(param1);
               _loc3_++;
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this/*b2internal::*/.m_bodyCount)
         {
            _loc6_ = this/*b2internal::*/.m_bodies[_loc2_];
            if(_loc6_.GetType() != B2Body.b2_staticBody)
            {
               _loc7_ = param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.x;
               _loc8_ = param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.y;
               if(_loc7_ * _loc7_ + _loc8_ * _loc8_ > B2Settings.b2_maxTranslationSquared)
               {
                  _loc6_/*b2internal::*/.m_linearVelocity.Normalize();
                  _loc6_/*b2internal::*/.m_linearVelocity.x *= B2Settings.b2_maxTranslation * param1.inv_dt;
                  _loc6_/*b2internal::*/.m_linearVelocity.y *= B2Settings.b2_maxTranslation * param1.inv_dt;
               }
               _loc9_ = param1.dt * _loc6_/*b2internal::*/.m_angularVelocity;
               if(_loc9_ * _loc9_ > B2Settings.b2_maxRotationSquared)
               {
                  if(_loc6_/*b2internal::*/.m_angularVelocity < 0)
                  {
                     _loc6_/*b2internal::*/.m_angularVelocity = -B2Settings.b2_maxRotation * param1.inv_dt;
                  }
                  else
                  {
                     _loc6_/*b2internal::*/.m_angularVelocity = B2Settings.b2_maxRotation * param1.inv_dt;
                  }
               }
               _loc6_/*b2internal::*/.m_sweep.c0.SetV(_loc6_/*b2internal::*/.m_sweep.c);
               _loc6_/*b2internal::*/.m_sweep.a0 = _loc6_/*b2internal::*/.m_sweep.a;
               _loc6_/*b2internal::*/.m_sweep.c.x += param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.x;
               _loc6_/*b2internal::*/.m_sweep.c.y += param1.dt * _loc6_/*b2internal::*/.m_linearVelocity.y;
               _loc6_/*b2internal::*/.m_sweep.a += param1.dt * _loc6_/*b2internal::*/.m_angularVelocity;
               _loc6_/*b2internal::*/.SynchronizeTransform();
            }
            _loc2_++;
         }
         var _loc5_:Float = 0.75;
         _loc2_ = 0;
         while(_loc2_ < param1.positionIterations)
         {
            _loc10_ = _loc4_.SolvePositionConstraints(_loc5_);
            _loc11_ = true;
            _loc3_ = 0;
            while(_loc3_ < this/*b2internal::*/.m_jointCount)
            {
               _loc12_ = this/*b2internal::*/.m_joints[_loc3_]/*b2internal::*/.SolvePositionConstraints(B2Settings.b2_contactBaumgarte);
               _loc11_ = _loc11_ && _loc12_;
               _loc3_++;
            }
            if(_loc10_ && _loc11_)
            {
               break;
            }
            _loc2_++;
         }
         this.Report(_loc4_/*b2internal::*/.m_constraints);
      }
      
      public function Report(param1:Vector<B2ContactConstraint>) 
      {
         var _loc3_:B2Contact = null;
         var _loc4_:B2ContactConstraint = null;
         var _loc5_= 0;
         if(this.m_listener == null)
         {
            return;
         }
         var _loc2_= 0;
         while(_loc2_ < this/*b2internal::*/.m_contactCount)
         {
            _loc3_ = this/*b2internal::*/.m_contacts[_loc2_];
            _loc4_ = param1[_loc2_];
            _loc5_ = 0;
            while(_loc5_ < _loc4_.pointCount)
            {
               s_impulse.normalImpulses[_loc5_] = _loc4_.points[_loc5_].normalImpulse;
               s_impulse.tangentImpulses[_loc5_] = _loc4_.points[_loc5_].tangentImpulse;
               _loc5_++;
            }
            this.m_listener.PostSolve(_loc3_,s_impulse);
            _loc2_++;
         }
      }
      
      public function AddBody(param1:B2Body) 
      {
         param1/*b2internal::*/.m_islandIndex = this/*b2internal::*/.m_bodyCount;
         this/*b2internal::*/.m_bodies[this/*b2internal::*/.m_bodyCount++] = param1;
      }
      
      public function AddContact(param1:B2Contact) 
      {
         this/*b2internal::*/.m_contacts[this/*b2internal::*/.m_contactCount++] = param1;
      }
      
      public function AddJoint(param1:B2Joint) 
      {
         this/*b2internal::*/.m_joints[this/*b2internal::*/.m_jointCount++] = param1;
      }
   }


