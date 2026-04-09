package box2D.collision
;
   import box2D.collision.shapes.*;
   import box2D.common.*;
   import box2D.common.math.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2Distance
   {
      
      static var b2_gjkCalls:Int = 0;
      
      static var b2_gjkIters:Int = 0;
      
      static var b2_gjkMaxIters:Int = 0;
      
      static var s_simplex:B2Simplex = new B2Simplex();
      
      static var s_saveA:Vector<Int> = new Vector((3 : UInt));
      
      static var s_saveB:Vector<Int> = new Vector((3 : UInt));
      
      public function new()
      {
         
      }
      
      public static function Distance(param1:B2DistanceOutput, param2:B2SimplexCache, param3:B2DistanceInput) 
      {
         var _loc17_= 0;
         var _loc18_:B2Vec2 = null;
         var _loc20_:B2Vec2 = null;
         var _loc21_:B2SimplexVertex = null;
         var _loc22_= false;
         var _loc23_= Math.NaN;
         var _loc24_= Math.NaN;
         var _loc25_:B2Vec2 = null;
         ++b2_gjkCalls;
         var _loc4_= param3.proxyA;
         var _loc5_= param3.proxyB;
         var _loc6_= param3.transformA;
         var _loc7_= param3.transformB;
         var _loc8_= s_simplex;
         _loc8_.ReadCache(param2,_loc4_,_loc6_,_loc5_,_loc7_);
         var _loc9_= _loc8_.m_vertices;
         var _loc10_= 20;
         var _loc11_= s_saveA;
         var _loc12_= s_saveB;
         var _loc13_= 0;
         var _loc14_= _loc8_.GetClosestPoint();
         var _loc15_:Float;
         var _loc16_= _loc15_ = _loc14_.LengthSquared();
         var _loc19_= 0;
         while(_loc19_ < _loc10_)
         {
            _loc13_ = _loc8_.m_count;
            _loc17_ = 0;
            while(_loc17_ < _loc13_)
            {
               _loc11_[_loc17_] = _loc9_[_loc17_].indexA;
               _loc12_[_loc17_] = _loc9_[_loc17_].indexB;
               _loc17_++;
            }
            switch(_loc8_.m_count)
            {
               case 1:
                  
               case 2:
                  _loc8_.Solve2();
                  
               case 3:
                  _loc8_.Solve3();
                  
               default:
                  B2Settings.b2Assert(false);
            }
            if(_loc8_.m_count == 3)
            {
               break;
            }
            _loc18_ = _loc8_.GetClosestPoint();
            _loc16_ = _loc18_.LengthSquared();
            if(_loc16_ > _loc15_)
            {
            }
            _loc15_ = _loc16_;
            _loc20_ = _loc8_.GetSearchDirection();
            if(_loc20_.LengthSquared() < ASCompat.MIN_FLOAT * ASCompat.MIN_FLOAT)
            {
               break;
            }
            _loc21_ = _loc9_[_loc8_.m_count];
            _loc21_.indexA = Std.int(_loc4_.GetSupport(B2Math.MulTMV(_loc6_.R,_loc20_.GetNegative())));
            _loc21_.wA = B2Math.MulX(_loc6_,_loc4_.GetVertex(_loc21_.indexA));
            _loc21_.indexB = Std.int(_loc5_.GetSupport(B2Math.MulTMV(_loc7_.R,_loc20_)));
            _loc21_.wB = B2Math.MulX(_loc7_,_loc5_.GetVertex(_loc21_.indexB));
            _loc21_.w = B2Math.SubtractVV(_loc21_.wB,_loc21_.wA);
            _loc19_++;
            ++b2_gjkIters;
            _loc22_ = false;
            _loc17_ = 0;
            while(_loc17_ < _loc13_)
            {
               if(_loc21_.indexA == _loc11_[_loc17_] && _loc21_.indexB == _loc12_[_loc17_])
               {
                  _loc22_ = true;
                  break;
               }
               _loc17_++;
            }
            if(_loc22_)
            {
               break;
            }
            ++_loc8_.m_count;
         }
         b2_gjkMaxIters = Std.int(B2Math.Max(b2_gjkMaxIters,_loc19_));
         _loc8_.GetWitnessPoints(param1.pointA,param1.pointB);
         param1.distance = B2Math.SubtractVV(param1.pointA,param1.pointB).Length();
         param1.iterations = _loc19_;
         _loc8_.WriteCache(param2);
         if(param3.useRadii)
         {
            _loc23_ = _loc4_.m_radius;
            _loc24_ = _loc5_.m_radius;
            if(param1.distance > _loc23_ + _loc24_ && param1.distance > ASCompat.MIN_FLOAT)
            {
               param1.distance -= _loc23_ + _loc24_;
               _loc25_ = B2Math.SubtractVV(param1.pointB,param1.pointA);
               _loc25_.Normalize();
               param1.pointA.x += _loc23_ * _loc25_.x;
               param1.pointA.y += _loc23_ * _loc25_.y;
               param1.pointB.x -= _loc24_ * _loc25_.x;
               param1.pointB.y -= _loc24_ * _loc25_.y;
            }
            else
            {
               _loc18_ = new B2Vec2();
               _loc18_.x = 0.5 * (param1.pointA.x + param1.pointB.x);
               _loc18_.y = 0.5 * (param1.pointA.y + param1.pointB.y);
               param1.pointA.x = param1.pointB.x = _loc18_.x;
               param1.pointA.y = param1.pointB.y = _loc18_.y;
               param1.distance = 0;
            }
         }
      }
   }


