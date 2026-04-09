package box2D.dynamics.contacts
;
   import box2D.collision.*;
   import box2D.collision.shapes.B2Shape;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2ContactSolver
   {
      
      static var s_worldManifold:B2WorldManifold = new B2WorldManifold();
      
      static var s_psm:B2PositionSolverManifold = new B2PositionSolverManifold();
      
      var m_step:B2TimeStep = new B2TimeStep();
      
      var m_allocator:ASAny;
      
      /*b2internal*/ public var m_constraints:Vector<B2ContactConstraint> = new Vector();
      
      var m_constraintCount:Int = 0;
      
      public function new()
      {
         
      }
      
      public function Initialize(param1:B2TimeStep, param2:Vector<B2Contact>, param3:Int, param4:ASAny) 
      {
         var _loc5_:B2Contact = null;
         var _loc6_= 0;
         var _loc7_:B2Vec2 = null;
         var _loc8_:B2Mat22 = null;
         var _loc9_:B2Fixture = null;
         var _loc10_:B2Fixture = null;
         var _loc11_:B2Shape = null;
         var _loc12_:B2Shape = null;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_:B2Body = null;
         var _loc16_:B2Body = null;
         var _loc17_:B2Manifold = null;
         var _loc18_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc23_= Math.NaN;
         var _loc24_= Math.NaN;
         var _loc25_= Math.NaN;
         var _loc26_= Math.NaN;
         var _loc27_= Math.NaN;
         var _loc28_:B2ContactConstraint = null;
         var _loc29_= (0 : UInt);
         var _loc30_:B2ManifoldPoint = null;
         var _loc31_:B2ContactConstraintPoint = null;
         var _loc32_= Math.NaN;
         var _loc33_= Math.NaN;
         var _loc34_= Math.NaN;
         var _loc35_= Math.NaN;
         var _loc36_= Math.NaN;
         var _loc37_= Math.NaN;
         var _loc38_= Math.NaN;
         var _loc39_= Math.NaN;
         var _loc40_= Math.NaN;
         var _loc41_= Math.NaN;
         var _loc42_= Math.NaN;
         var _loc43_= Math.NaN;
         var _loc44_= Math.NaN;
         var _loc45_= Math.NaN;
         var _loc46_= Math.NaN;
         var _loc47_= Math.NaN;
         var _loc48_:B2ContactConstraintPoint = null;
         var _loc49_:B2ContactConstraintPoint = null;
         var _loc50_= Math.NaN;
         var _loc51_= Math.NaN;
         var _loc52_= Math.NaN;
         var _loc53_= Math.NaN;
         var _loc54_= Math.NaN;
         var _loc55_= Math.NaN;
         var _loc56_= Math.NaN;
         var _loc57_= Math.NaN;
         var _loc58_= Math.NaN;
         var _loc59_= Math.NaN;
         var _loc60_= Math.NaN;
         var _loc61_= Math.NaN;
         this.m_step.Set(param1);
         this.m_allocator = param4;
         this.m_constraintCount = param3;
         while(this/*b2internal::*/.m_constraints.length < this.m_constraintCount)
         {
            this/*b2internal::*/.m_constraints[this/*b2internal::*/.m_constraints.length] = new B2ContactConstraint();
         }
         _loc6_ = 0;
         while(_loc6_ < param3)
         {
            _loc5_ = param2[_loc6_];
            _loc9_ = _loc5_/*b2internal::*/.m_fixtureA;
            _loc10_ = _loc5_/*b2internal::*/.m_fixtureB;
            _loc11_ = _loc9_/*b2internal::*/.m_shape;
            _loc12_ = _loc10_/*b2internal::*/.m_shape;
            _loc13_ = _loc11_/*b2internal::*/.m_radius;
            _loc14_ = _loc12_/*b2internal::*/.m_radius;
            _loc15_ = _loc9_/*b2internal::*/.m_body;
            _loc16_ = _loc10_/*b2internal::*/.m_body;
            _loc17_ = _loc5_.GetManifold();
            _loc18_ = B2Settings.b2MixFriction(_loc9_.GetFriction(),_loc10_.GetFriction());
            _loc19_ = B2Settings.b2MixRestitution(_loc9_.GetRestitution(),_loc10_.GetRestitution());
            _loc20_ = _loc15_/*b2internal::*/.m_linearVelocity.x;
            _loc21_ = _loc15_/*b2internal::*/.m_linearVelocity.y;
            _loc22_ = _loc16_/*b2internal::*/.m_linearVelocity.x;
            _loc23_ = _loc16_/*b2internal::*/.m_linearVelocity.y;
            _loc24_ = _loc15_/*b2internal::*/.m_angularVelocity;
            _loc25_ = _loc16_/*b2internal::*/.m_angularVelocity;
            B2Settings.b2Assert(_loc17_.m_pointCount > 0);
            s_worldManifold.Initialize(_loc17_,_loc15_/*b2internal::*/.m_xf,_loc13_,_loc16_/*b2internal::*/.m_xf,_loc14_);
            _loc26_ = s_worldManifold.m_normal.x;
            _loc27_ = s_worldManifold.m_normal.y;
            _loc28_ = this/*b2internal::*/.m_constraints[_loc6_];
            _loc28_.bodyA = _loc15_;
            _loc28_.bodyB = _loc16_;
            _loc28_.manifold = _loc17_;
            _loc28_.normal.x = _loc26_;
            _loc28_.normal.y = _loc27_;
            _loc28_.pointCount = _loc17_.m_pointCount;
            _loc28_.friction = _loc18_;
            _loc28_.restitution = _loc19_;
            _loc28_.localPlaneNormal.x = _loc17_.m_localPlaneNormal.x;
            _loc28_.localPlaneNormal.y = _loc17_.m_localPlaneNormal.y;
            _loc28_.localPoint.x = _loc17_.m_localPoint.x;
            _loc28_.localPoint.y = _loc17_.m_localPoint.y;
            _loc28_.radius = _loc13_ + _loc14_;
            _loc28_.type = _loc17_.m_type;
            _loc29_ = (0 : UInt);
            while(_loc29_ < (_loc28_.pointCount : UInt))
            {
               _loc30_ = _loc17_.m_points[(_loc29_ : Int)];
               _loc31_ = _loc28_.points[(_loc29_ : Int)];
               _loc31_.normalImpulse = _loc30_.m_normalImpulse;
               _loc31_.tangentImpulse = _loc30_.m_tangentImpulse;
               _loc31_.localPoint.SetV(_loc30_.m_localPoint);
               _loc32_ = _loc31_.rA.x = s_worldManifold.m_points[(_loc29_ : Int)].x - _loc15_/*b2internal::*/.m_sweep.c.x;
               _loc33_ = _loc31_.rA.y = s_worldManifold.m_points[(_loc29_ : Int)].y - _loc15_/*b2internal::*/.m_sweep.c.y;
               _loc34_ = _loc31_.rB.x = s_worldManifold.m_points[(_loc29_ : Int)].x - _loc16_/*b2internal::*/.m_sweep.c.x;
               _loc35_ = _loc31_.rB.y = s_worldManifold.m_points[(_loc29_ : Int)].y - _loc16_/*b2internal::*/.m_sweep.c.y;
               _loc36_ = _loc32_ * _loc27_ - _loc33_ * _loc26_;
               _loc37_ = _loc34_ * _loc27_ - _loc35_ * _loc26_;
               _loc36_ *= _loc36_;
               _loc37_ *= _loc37_;
               _loc38_ = _loc15_/*b2internal::*/.m_invMass + _loc16_/*b2internal::*/.m_invMass + _loc15_/*b2internal::*/.m_invI * _loc36_ + _loc16_/*b2internal::*/.m_invI * _loc37_;
               _loc31_.normalMass = 1 / _loc38_;
               _loc39_ = _loc15_/*b2internal::*/.m_mass * _loc15_/*b2internal::*/.m_invMass + _loc16_/*b2internal::*/.m_mass * _loc16_/*b2internal::*/.m_invMass;
               _loc39_ = _loc39_ + (_loc15_/*b2internal::*/.m_mass * _loc15_/*b2internal::*/.m_invI * _loc36_ + _loc16_/*b2internal::*/.m_mass * _loc16_/*b2internal::*/.m_invI * _loc37_);
               _loc31_.equalizedMass = 1 / _loc39_;
               _loc40_ = _loc27_;
               _loc41_ = -_loc26_;
               _loc42_ = _loc32_ * _loc41_ - _loc33_ * _loc40_;
               _loc43_ = _loc34_ * _loc41_ - _loc35_ * _loc40_;
               _loc42_ *= _loc42_;
               _loc43_ *= _loc43_;
               _loc44_ = _loc15_/*b2internal::*/.m_invMass + _loc16_/*b2internal::*/.m_invMass + _loc15_/*b2internal::*/.m_invI * _loc42_ + _loc16_/*b2internal::*/.m_invI * _loc43_;
               _loc31_.tangentMass = 1 / _loc44_;
               _loc31_.velocityBias = 0;
               _loc45_ = _loc22_ + -_loc25_ * _loc35_ - _loc20_ - -_loc24_ * _loc33_;
               _loc46_ = _loc23_ + _loc25_ * _loc34_ - _loc21_ - _loc24_ * _loc32_;
               _loc47_ = _loc28_.normal.x * _loc45_ + _loc28_.normal.y * _loc46_;
               if(_loc47_ < -B2Settings.b2_velocityThreshold)
               {
                  _loc31_.velocityBias += -_loc28_.restitution * _loc47_;
               }
               _loc29_++;
            }
            if(_loc28_.pointCount == 2)
            {
               _loc48_ = _loc28_.points[0];
               _loc49_ = _loc28_.points[1];
               _loc50_ = _loc15_/*b2internal::*/.m_invMass;
               _loc51_ = _loc15_/*b2internal::*/.m_invI;
               _loc52_ = _loc16_/*b2internal::*/.m_invMass;
               _loc53_ = _loc16_/*b2internal::*/.m_invI;
               _loc54_ = _loc48_.rA.x * _loc27_ - _loc48_.rA.y * _loc26_;
               _loc55_ = _loc48_.rB.x * _loc27_ - _loc48_.rB.y * _loc26_;
               _loc56_ = _loc49_.rA.x * _loc27_ - _loc49_.rA.y * _loc26_;
               _loc57_ = _loc49_.rB.x * _loc27_ - _loc49_.rB.y * _loc26_;
               _loc58_ = _loc50_ + _loc52_ + _loc51_ * _loc54_ * _loc54_ + _loc53_ * _loc55_ * _loc55_;
               _loc59_ = _loc50_ + _loc52_ + _loc51_ * _loc56_ * _loc56_ + _loc53_ * _loc57_ * _loc57_;
               _loc60_ = _loc50_ + _loc52_ + _loc51_ * _loc54_ * _loc56_ + _loc53_ * _loc55_ * _loc57_;
               _loc61_ = 100;
               if(_loc58_ * _loc58_ < _loc61_ * (_loc58_ * _loc59_ - _loc60_ * _loc60_))
               {
                  _loc28_.K.col1.Set(_loc58_,_loc60_);
                  _loc28_.K.col2.Set(_loc60_,_loc59_);
                  _loc28_.K.GetInverse(_loc28_.normalMass);
               }
               else
               {
                  _loc28_.pointCount = 1;
               }
            }
            _loc6_++;
         }
      }
      
      public function InitVelocityConstraints(param1:B2TimeStep) 
      {
         var _loc2_:B2Vec2 = null;
         var _loc3_:B2Vec2 = null;
         var _loc4_:B2Mat22 = null;
         var _loc6_:B2ContactConstraint = null;
         var _loc7_:B2Body = null;
         var _loc8_:B2Body = null;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc18_= 0;
         var _loc19_= 0;
         var _loc20_:B2ContactConstraintPoint = null;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc23_:B2ContactConstraintPoint = null;
         var _loc5_= 0;
         while(_loc5_ < this.m_constraintCount)
         {
            _loc6_ = this/*b2internal::*/.m_constraints[_loc5_];
            _loc7_ = _loc6_.bodyA;
            _loc8_ = _loc6_.bodyB;
            _loc9_ = _loc7_/*b2internal::*/.m_invMass;
            _loc10_ = _loc7_/*b2internal::*/.m_invI;
            _loc11_ = _loc8_/*b2internal::*/.m_invMass;
            _loc12_ = _loc8_/*b2internal::*/.m_invI;
            _loc13_ = _loc6_.normal.x;
            _loc15_ = _loc14_ = _loc6_.normal.y;
            _loc16_ = -_loc13_;
            if(param1.warmStarting)
            {
               _loc19_ = _loc6_.pointCount;
               _loc18_ = 0;
               while(_loc18_ < _loc19_)
               {
                  _loc20_ = _loc6_.points[_loc18_];
                  _loc20_.normalImpulse *= param1.dtRatio;
                  _loc20_.tangentImpulse *= param1.dtRatio;
                  _loc21_ = _loc20_.normalImpulse * _loc13_ + _loc20_.tangentImpulse * _loc15_;
                  _loc22_ = _loc20_.normalImpulse * _loc14_ + _loc20_.tangentImpulse * _loc16_;
                  _loc7_/*b2internal::*/.m_angularVelocity -= _loc10_ * (_loc20_.rA.x * _loc22_ - _loc20_.rA.y * _loc21_);
                  _loc7_/*b2internal::*/.m_linearVelocity.x -= _loc9_ * _loc21_;
                  _loc7_/*b2internal::*/.m_linearVelocity.y -= _loc9_ * _loc22_;
                  _loc8_/*b2internal::*/.m_angularVelocity += _loc12_ * (_loc20_.rB.x * _loc22_ - _loc20_.rB.y * _loc21_);
                  _loc8_/*b2internal::*/.m_linearVelocity.x += _loc11_ * _loc21_;
                  _loc8_/*b2internal::*/.m_linearVelocity.y += _loc11_ * _loc22_;
                  _loc18_++;
               }
            }
            else
            {
               _loc19_ = _loc6_.pointCount;
               _loc18_ = 0;
               while(_loc18_ < _loc19_)
               {
                  _loc23_ = _loc6_.points[_loc18_];
                  _loc23_.normalImpulse = 0;
                  _loc23_.tangentImpulse = 0;
                  _loc18_++;
               }
            }
            _loc5_++;
         }
      }
      
      public function SolveVelocityConstraints() 
      {
         var _loc1_= 0;
         var _loc2_:B2ContactConstraintPoint = null;
         var _loc3_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc8_= Math.NaN;
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
         var _loc22_:B2Mat22 = null;
         var _loc23_:B2Vec2 = null;
         var _loc25_:B2ContactConstraint = null;
         var _loc26_:B2Body = null;
         var _loc27_:B2Body = null;
         var _loc28_= Math.NaN;
         var _loc29_= Math.NaN;
         var _loc30_:B2Vec2 = null;
         var _loc31_:B2Vec2 = null;
         var _loc32_= Math.NaN;
         var _loc33_= Math.NaN;
         var _loc34_= Math.NaN;
         var _loc35_= Math.NaN;
         var _loc36_= Math.NaN;
         var _loc37_= Math.NaN;
         var _loc38_= Math.NaN;
         var _loc39_= Math.NaN;
         var _loc40_= Math.NaN;
         var _loc41_= Math.NaN;
         var _loc42_= 0;
         var _loc43_:B2ContactConstraintPoint = null;
         var _loc44_:B2ContactConstraintPoint = null;
         var _loc45_= Math.NaN;
         var _loc46_= Math.NaN;
         var _loc47_= Math.NaN;
         var _loc48_= Math.NaN;
         var _loc49_= Math.NaN;
         var _loc50_= Math.NaN;
         var _loc51_= Math.NaN;
         var _loc52_= Math.NaN;
         var _loc53_= Math.NaN;
         var _loc54_= Math.NaN;
         var _loc55_= Math.NaN;
         var _loc56_= Math.NaN;
         var _loc57_= Math.NaN;
         var _loc24_= 0;
         while(_loc24_ < this.m_constraintCount)
         {
            _loc25_ = this/*b2internal::*/.m_constraints[_loc24_];
            _loc26_ = _loc25_.bodyA;
            _loc27_ = _loc25_.bodyB;
            _loc28_ = _loc26_/*b2internal::*/.m_angularVelocity;
            _loc29_ = _loc27_/*b2internal::*/.m_angularVelocity;
            _loc30_ = _loc26_/*b2internal::*/.m_linearVelocity;
            _loc31_ = _loc27_/*b2internal::*/.m_linearVelocity;
            _loc32_ = _loc26_/*b2internal::*/.m_invMass;
            _loc33_ = _loc26_/*b2internal::*/.m_invI;
            _loc34_ = _loc27_/*b2internal::*/.m_invMass;
            _loc35_ = _loc27_/*b2internal::*/.m_invI;
            _loc36_ = _loc25_.normal.x;
            _loc38_ = _loc37_ = _loc25_.normal.y;
            _loc39_ = -_loc36_;
            _loc40_ = _loc25_.friction;
            _loc1_ = 0;
            while(_loc1_ < _loc25_.pointCount)
            {
               _loc2_ = _loc25_.points[_loc1_];
               _loc7_ = _loc31_.x - _loc29_ * _loc2_.rB.y - _loc30_.x + _loc28_ * _loc2_.rA.y;
               _loc8_ = _loc31_.y + _loc29_ * _loc2_.rB.x - _loc30_.y - _loc28_ * _loc2_.rA.x;
               _loc10_ = _loc7_ * _loc38_ + _loc8_ * _loc39_;
               _loc11_ = _loc2_.tangentMass * -_loc10_;
               _loc12_ = _loc40_ * _loc2_.normalImpulse;
               _loc13_ = B2Math.Clamp(_loc2_.tangentImpulse + _loc11_,-_loc12_,_loc12_);
               _loc11_ = _loc13_ - _loc2_.tangentImpulse;
               _loc14_ = _loc11_ * _loc38_;
               _loc15_ = _loc11_ * _loc39_;
               _loc30_.x -= _loc32_ * _loc14_;
               _loc30_.y -= _loc32_ * _loc15_;
               _loc28_ -= _loc33_ * (_loc2_.rA.x * _loc15_ - _loc2_.rA.y * _loc14_);
               _loc31_.x += _loc34_ * _loc14_;
               _loc31_.y += _loc34_ * _loc15_;
               _loc29_ += _loc35_ * (_loc2_.rB.x * _loc15_ - _loc2_.rB.y * _loc14_);
               _loc2_.tangentImpulse = _loc13_;
               _loc1_++;
            }
            _loc42_ = _loc25_.pointCount;
            if(_loc25_.pointCount == 1)
            {
               _loc2_ = _loc25_.points[0];
               _loc7_ = _loc31_.x + -_loc29_ * _loc2_.rB.y - _loc30_.x - -_loc28_ * _loc2_.rA.y;
               _loc8_ = _loc31_.y + _loc29_ * _loc2_.rB.x - _loc30_.y - _loc28_ * _loc2_.rA.x;
               _loc9_ = _loc7_ * _loc36_ + _loc8_ * _loc37_;
               _loc11_ = -_loc2_.normalMass * (_loc9_ - _loc2_.velocityBias);
               _loc13_ = _loc2_.normalImpulse + _loc11_;
               _loc13_ = _loc13_ > 0 ? _loc13_ : 0;
               _loc11_ = _loc13_ - _loc2_.normalImpulse;
               _loc14_ = _loc11_ * _loc36_;
               _loc15_ = _loc11_ * _loc37_;
               _loc30_.x -= _loc32_ * _loc14_;
               _loc30_.y -= _loc32_ * _loc15_;
               _loc28_ -= _loc33_ * (_loc2_.rA.x * _loc15_ - _loc2_.rA.y * _loc14_);
               _loc31_.x += _loc34_ * _loc14_;
               _loc31_.y += _loc34_ * _loc15_;
               _loc29_ += _loc35_ * (_loc2_.rB.x * _loc15_ - _loc2_.rB.y * _loc14_);
               _loc2_.normalImpulse = _loc13_;
            }
            else
            {
               _loc43_ = _loc25_.points[0];
               _loc44_ = _loc25_.points[1];
               _loc45_ = _loc43_.normalImpulse;
               _loc46_ = _loc44_.normalImpulse;
               _loc47_ = _loc31_.x - _loc29_ * _loc43_.rB.y - _loc30_.x + _loc28_ * _loc43_.rA.y;
               _loc48_ = _loc31_.y + _loc29_ * _loc43_.rB.x - _loc30_.y - _loc28_ * _loc43_.rA.x;
               _loc49_ = _loc31_.x - _loc29_ * _loc44_.rB.y - _loc30_.x + _loc28_ * _loc44_.rA.y;
               _loc50_ = _loc31_.y + _loc29_ * _loc44_.rB.x - _loc30_.y - _loc28_ * _loc44_.rA.x;
               _loc51_ = _loc47_ * _loc36_ + _loc48_ * _loc37_;
               _loc52_ = _loc49_ * _loc36_ + _loc50_ * _loc37_;
               _loc53_ = _loc51_ - _loc43_.velocityBias;
               _loc54_ = _loc52_ - _loc44_.velocityBias;
               _loc22_ = _loc25_.K;
               _loc53_ -= _loc22_.col1.x * _loc45_ + _loc22_.col2.x * _loc46_;
               _loc54_ -= _loc22_.col1.y * _loc45_ + _loc22_.col2.y * _loc46_;
               _loc55_ = 0.001;
               _loc22_ = _loc25_.normalMass;
               _loc56_ = -(_loc22_.col1.x * _loc53_ + _loc22_.col2.x * _loc54_);
               _loc57_ = -(_loc22_.col1.y * _loc53_ + _loc22_.col2.y * _loc54_);
               if(_loc56_ >= 0 && _loc57_ >= 0)
               {
                  _loc16_ = _loc56_ - _loc45_;
                  _loc17_ = _loc57_ - _loc46_;
                  _loc18_ = _loc16_ * _loc36_;
                  _loc19_ = _loc16_ * _loc37_;
                  _loc20_ = _loc17_ * _loc36_;
                  _loc21_ = _loc17_ * _loc37_;
                  _loc30_.x -= _loc32_ * (_loc18_ + _loc20_);
                  _loc30_.y -= _loc32_ * (_loc19_ + _loc21_);
                  _loc28_ -= _loc33_ * (_loc43_.rA.x * _loc19_ - _loc43_.rA.y * _loc18_ + _loc44_.rA.x * _loc21_ - _loc44_.rA.y * _loc20_);
                  _loc31_.x += _loc34_ * (_loc18_ + _loc20_);
                  _loc31_.y += _loc34_ * (_loc19_ + _loc21_);
                  _loc29_ += _loc35_ * (_loc43_.rB.x * _loc19_ - _loc43_.rB.y * _loc18_ + _loc44_.rB.x * _loc21_ - _loc44_.rB.y * _loc20_);
                  _loc43_.normalImpulse = _loc56_;
                  _loc44_.normalImpulse = _loc57_;
               }
               else
               {
                  _loc56_ = -_loc43_.normalMass * _loc53_;
                  _loc57_ = 0;
                  _loc51_ = 0;
                  _loc52_ = _loc25_.K.col1.y * _loc56_ + _loc54_;
                  if(_loc56_ >= 0 && _loc52_ >= 0)
                  {
                     _loc16_ = _loc56_ - _loc45_;
                     _loc17_ = _loc57_ - _loc46_;
                     _loc18_ = _loc16_ * _loc36_;
                     _loc19_ = _loc16_ * _loc37_;
                     _loc20_ = _loc17_ * _loc36_;
                     _loc21_ = _loc17_ * _loc37_;
                     _loc30_.x -= _loc32_ * (_loc18_ + _loc20_);
                     _loc30_.y -= _loc32_ * (_loc19_ + _loc21_);
                     _loc28_ -= _loc33_ * (_loc43_.rA.x * _loc19_ - _loc43_.rA.y * _loc18_ + _loc44_.rA.x * _loc21_ - _loc44_.rA.y * _loc20_);
                     _loc31_.x += _loc34_ * (_loc18_ + _loc20_);
                     _loc31_.y += _loc34_ * (_loc19_ + _loc21_);
                     _loc29_ += _loc35_ * (_loc43_.rB.x * _loc19_ - _loc43_.rB.y * _loc18_ + _loc44_.rB.x * _loc21_ - _loc44_.rB.y * _loc20_);
                     _loc43_.normalImpulse = _loc56_;
                     _loc44_.normalImpulse = _loc57_;
                  }
                  else
                  {
                     _loc56_ = 0;
                     _loc57_ = -_loc44_.normalMass * _loc54_;
                     _loc51_ = _loc25_.K.col2.x * _loc57_ + _loc53_;
                     _loc52_ = 0;
                     if(_loc57_ >= 0 && _loc51_ >= 0)
                     {
                        _loc16_ = _loc56_ - _loc45_;
                        _loc17_ = _loc57_ - _loc46_;
                        _loc18_ = _loc16_ * _loc36_;
                        _loc19_ = _loc16_ * _loc37_;
                        _loc20_ = _loc17_ * _loc36_;
                        _loc21_ = _loc17_ * _loc37_;
                        _loc30_.x -= _loc32_ * (_loc18_ + _loc20_);
                        _loc30_.y -= _loc32_ * (_loc19_ + _loc21_);
                        _loc28_ -= _loc33_ * (_loc43_.rA.x * _loc19_ - _loc43_.rA.y * _loc18_ + _loc44_.rA.x * _loc21_ - _loc44_.rA.y * _loc20_);
                        _loc31_.x += _loc34_ * (_loc18_ + _loc20_);
                        _loc31_.y += _loc34_ * (_loc19_ + _loc21_);
                        _loc29_ += _loc35_ * (_loc43_.rB.x * _loc19_ - _loc43_.rB.y * _loc18_ + _loc44_.rB.x * _loc21_ - _loc44_.rB.y * _loc20_);
                        _loc43_.normalImpulse = _loc56_;
                        _loc44_.normalImpulse = _loc57_;
                     }
                     else
                     {
                        _loc56_ = 0;
                        _loc57_ = 0;
                        _loc51_ = _loc53_;
                        _loc52_ = _loc54_;
                        if(_loc51_ >= 0 && _loc52_ >= 0)
                        {
                           _loc16_ = _loc56_ - _loc45_;
                           _loc17_ = _loc57_ - _loc46_;
                           _loc18_ = _loc16_ * _loc36_;
                           _loc19_ = _loc16_ * _loc37_;
                           _loc20_ = _loc17_ * _loc36_;
                           _loc21_ = _loc17_ * _loc37_;
                           _loc30_.x -= _loc32_ * (_loc18_ + _loc20_);
                           _loc30_.y -= _loc32_ * (_loc19_ + _loc21_);
                           _loc28_ -= _loc33_ * (_loc43_.rA.x * _loc19_ - _loc43_.rA.y * _loc18_ + _loc44_.rA.x * _loc21_ - _loc44_.rA.y * _loc20_);
                           _loc31_.x += _loc34_ * (_loc18_ + _loc20_);
                           _loc31_.y += _loc34_ * (_loc19_ + _loc21_);
                           _loc29_ += _loc35_ * (_loc43_.rB.x * _loc19_ - _loc43_.rB.y * _loc18_ + _loc44_.rB.x * _loc21_ - _loc44_.rB.y * _loc20_);
                           _loc43_.normalImpulse = _loc56_;
                           _loc44_.normalImpulse = _loc57_;
                        }
                     }
                  }
               }
            }
            _loc26_/*b2internal::*/.m_angularVelocity = _loc28_;
            _loc27_/*b2internal::*/.m_angularVelocity = _loc29_;
            _loc24_++;
         }
      }
      
      public function FinalizeVelocityConstraints() 
      {
         var _loc2_:B2ContactConstraint = null;
         var _loc3_:B2Manifold = null;
         var _loc4_= 0;
         var _loc5_:B2ManifoldPoint = null;
         var _loc6_:B2ContactConstraintPoint = null;
         var _loc1_= 0;
         while(_loc1_ < this.m_constraintCount)
         {
            _loc2_ = this/*b2internal::*/.m_constraints[_loc1_];
            _loc3_ = _loc2_.manifold;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.pointCount)
            {
               _loc5_ = _loc3_.m_points[_loc4_];
               _loc6_ = _loc2_.points[_loc4_];
               _loc5_.m_normalImpulse = _loc6_.normalImpulse;
               _loc5_.m_tangentImpulse = _loc6_.tangentImpulse;
               _loc4_++;
            }
            _loc1_++;
         }
      }
      
      public function SolvePositionConstraints(param1:Float) : Bool
      {
         var _loc4_:B2ContactConstraint = null;
         var _loc5_:B2Body = null;
         var _loc6_:B2Body = null;
         var _loc7_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_:B2Vec2 = null;
         var _loc12_= 0;
         var _loc13_:B2ContactConstraintPoint = null;
         var _loc14_:B2Vec2 = null;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc18_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc23_= Math.NaN;
         var _loc2_:Float = 0;
         var _loc3_= 0;
         while(_loc3_ < this.m_constraintCount)
         {
            _loc4_ = this/*b2internal::*/.m_constraints[_loc3_];
            _loc5_ = _loc4_.bodyA;
            _loc6_ = _loc4_.bodyB;
            _loc7_ = _loc5_/*b2internal::*/.m_mass * _loc5_/*b2internal::*/.m_invMass;
            _loc8_ = _loc5_/*b2internal::*/.m_mass * _loc5_/*b2internal::*/.m_invI;
            _loc9_ = _loc6_/*b2internal::*/.m_mass * _loc6_/*b2internal::*/.m_invMass;
            _loc10_ = _loc6_/*b2internal::*/.m_mass * _loc6_/*b2internal::*/.m_invI;
            s_psm.Initialize(_loc4_);
            _loc11_ = s_psm.m_normal;
            _loc12_ = 0;
            while(_loc12_ < _loc4_.pointCount)
            {
               _loc13_ = _loc4_.points[_loc12_];
               _loc14_ = s_psm.m_points[_loc12_];
               _loc15_ = s_psm.m_separations[_loc12_];
               _loc16_ = _loc14_.x - _loc5_/*b2internal::*/.m_sweep.c.x;
               _loc17_ = _loc14_.y - _loc5_/*b2internal::*/.m_sweep.c.y;
               _loc18_ = _loc14_.x - _loc6_/*b2internal::*/.m_sweep.c.x;
               _loc19_ = _loc14_.y - _loc6_/*b2internal::*/.m_sweep.c.y;
               _loc2_ = _loc2_ < _loc15_ ? _loc2_ : _loc15_;
               _loc20_ = B2Math.Clamp(param1 * (_loc15_ + B2Settings.b2_linearSlop),-B2Settings.b2_maxLinearCorrection,0);
               _loc21_ = -_loc13_.equalizedMass * _loc20_;
               _loc22_ = _loc21_ * _loc11_.x;
               _loc23_ = _loc21_ * _loc11_.y;
               _loc5_/*b2internal::*/.m_sweep.c.x -= _loc7_ * _loc22_;
               _loc5_/*b2internal::*/.m_sweep.c.y -= _loc7_ * _loc23_;
               _loc5_/*b2internal::*/.m_sweep.a -= _loc8_ * (_loc16_ * _loc23_ - _loc17_ * _loc22_);
               _loc5_/*b2internal::*/.SynchronizeTransform();
               _loc6_/*b2internal::*/.m_sweep.c.x += _loc9_ * _loc22_;
               _loc6_/*b2internal::*/.m_sweep.c.y += _loc9_ * _loc23_;
               _loc6_/*b2internal::*/.m_sweep.a += _loc10_ * (_loc18_ * _loc23_ - _loc19_ * _loc22_);
               _loc6_/*b2internal::*/.SynchronizeTransform();
               _loc12_++;
            }
            _loc3_++;
         }
         return _loc2_ > -1.5 * B2Settings.b2_linearSlop;
      }
   }


