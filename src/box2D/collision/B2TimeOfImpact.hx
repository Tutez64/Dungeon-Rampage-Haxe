package box2D.collision
;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Transform;
   import box2D.common.B2Settings;
   
    class B2TimeOfImpact
   {
      
      static var b2_toiCalls:Int = 0;
      
      static var b2_toiIters:Int = 0;
      
      static var b2_toiMaxIters:Int = 0;
      
      static var b2_toiRootIters:Int = 0;
      
      static var b2_toiMaxRootIters:Int = 0;
      
      static var s_cache:B2SimplexCache = new B2SimplexCache();
      
      static var s_distanceInput:B2DistanceInput = new B2DistanceInput();
      
      static var s_xfA:B2Transform = new B2Transform();
      
      static var s_xfB:B2Transform = new B2Transform();
      
      static var s_fcn:B2SeparationFunction = new B2SeparationFunction();
      
      static var s_distanceOutput:B2DistanceOutput = new B2DistanceOutput();
      
      public function new()
      {
         
      }
      
      public static function TimeOfImpact(param1:B2TOIInput) : Float
      {
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc18_= 0;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         ++b2_toiCalls;
         var _loc2_= param1.proxyA;
         var _loc3_= param1.proxyB;
         var _loc4_= param1.sweepA;
         var _loc5_= param1.sweepB;
         B2Settings.b2Assert(_loc4_.t0 == _loc5_.t0);
         B2Settings.b2Assert(1 - _loc4_.t0 > ASCompat.MIN_FLOAT);
         var _loc6_= _loc2_.m_radius + _loc3_.m_radius;
         var _loc7_= param1.tolerance;
         var _loc8_:Float = 0;
         var _loc9_= 1000;
         var _loc10_= 0;
         var _loc11_:Float = 0;
         s_cache.count = (0 : UInt);
         s_distanceInput.useRadii = false;
         do
         {
            _loc4_.GetTransform(s_xfA,_loc8_);
            _loc5_.GetTransform(s_xfB,_loc8_);
            s_distanceInput.proxyA = _loc2_;
            s_distanceInput.proxyB = _loc3_;
            s_distanceInput.transformA = s_xfA;
            s_distanceInput.transformB = s_xfB;
            B2Distance.Distance(s_distanceOutput,s_cache,s_distanceInput);
            if(s_distanceOutput.distance <= 0)
            {
               _loc8_ = 1;
               break;
            }
            s_fcn.Initialize(s_cache,_loc2_,s_xfA,_loc3_,s_xfB);
            _loc12_ = s_fcn.Evaluate(s_xfA,s_xfB);
            if(_loc12_ <= 0)
            {
               _loc8_ = 1;
               break;
            }
            if(_loc10_ == 0)
            {
               if(_loc12_ > _loc6_)
               {
                  _loc11_ = B2Math.Max(_loc6_ - _loc7_,0.75 * _loc6_);
               }
               else
               {
                  _loc11_ = B2Math.Max(_loc12_ - _loc7_,0.02 * _loc6_);
               }
            }
            if(_loc12_ - _loc11_ < 0.5 * _loc7_)
            {
               if(_loc10_ == 0)
               {
                  _loc8_ = 1;
               }
               break;
            }
            _loc13_ = _loc8_;
            _loc14_ = _loc8_;
            _loc15_ = 1;
            _loc16_ = _loc12_;
            _loc4_.GetTransform(s_xfA,_loc15_);
            _loc5_.GetTransform(s_xfB,_loc15_);
            _loc17_ = s_fcn.Evaluate(s_xfA,s_xfB);
            if(_loc17_ >= _loc11_)
            {
               _loc8_ = 1;
               break;
            }
            _loc18_ = 0;
            do
            {
               if((_loc18_ & 1) != 0)
               {
                  _loc19_ = _loc14_ + (_loc11_ - _loc16_) * (_loc15_ - _loc14_) / (_loc17_ - _loc16_);
               }
               else
               {
                  _loc19_ = 0.5 * (_loc14_ + _loc15_);
               }
               _loc4_.GetTransform(s_xfA,_loc19_);
               _loc5_.GetTransform(s_xfB,_loc19_);
               _loc20_ = s_fcn.Evaluate(s_xfA,s_xfB);
               if(B2Math.Abs(_loc20_ - _loc11_) < 0.025 * _loc7_)
               {
                  _loc13_ = _loc19_;
                  break;
               }
               if(_loc20_ > _loc11_)
               {
                  _loc14_ = _loc19_;
                  _loc16_ = _loc20_;
               }
               else
               {
                  _loc15_ = _loc19_;
                  _loc17_ = _loc20_;
               }
               _loc18_++;
               ++b2_toiRootIters;
            }
            while(_loc18_ != 50);
            
            b2_toiMaxRootIters = Std.int(B2Math.Max(b2_toiMaxRootIters,_loc18_));
            if(_loc13_ < (1 + 100 * ASCompat.MIN_FLOAT) * _loc8_)
            {
               break;
            }
            _loc8_ = _loc13_;
            _loc10_++;
            ++b2_toiIters;
         }
         while(_loc10_ != _loc9_);
         
         b2_toiMaxIters = Std.int(B2Math.Max(b2_toiMaxIters,_loc10_));
         return _loc8_;
      }
   }


