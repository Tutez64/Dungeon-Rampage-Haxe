package box2D.collision
;
   import box2D.collision.shapes.*;
   import box2D.common.*;
   import box2D.common.math.*;
   
   /*internal*/ class B2Simplex
   {
      
      public var m_v1:B2SimplexVertex = new B2SimplexVertex();
      
      public var m_v2:B2SimplexVertex = new B2SimplexVertex();
      
      public var m_v3:B2SimplexVertex = new B2SimplexVertex();
      
      public var m_vertices:Vector<B2SimplexVertex> = new Vector((3 : UInt));
      
      public var m_count:Int = 0;
      
      public function new()
      {
         
         this.m_vertices[0] = this.m_v1;
         this.m_vertices[1] = this.m_v2;
         this.m_vertices[2] = this.m_v3;
      }
      
      public function ReadCache(param1:B2SimplexCache, param2:B2DistanceProxy, param3:B2Transform, param4:B2DistanceProxy, param5:B2Transform) 
      {
         var _loc6_:B2Vec2 = null;
         var _loc7_:B2Vec2 = null;
         var _loc10_:B2SimplexVertex = null;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         B2Settings.b2Assert(0 <= param1.count && param1.count <= 3);
         this.m_count = (param1.count : Int);
         var _loc8_= this.m_vertices;
         var _loc9_= 0;
         while(_loc9_ < this.m_count)
         {
            _loc10_ = _loc8_[_loc9_];
            _loc10_.indexA = param1.indexA[_loc9_];
            _loc10_.indexB = param1.indexB[_loc9_];
            _loc6_ = param2.GetVertex(_loc10_.indexA);
            _loc7_ = param4.GetVertex(_loc10_.indexB);
            _loc10_.wA = B2Math.MulX(param3,_loc6_);
            _loc10_.wB = B2Math.MulX(param5,_loc7_);
            _loc10_.w = B2Math.SubtractVV(_loc10_.wB,_loc10_.wA);
            _loc10_.a = 0;
            _loc9_++;
         }
         if(this.m_count > 1)
         {
            _loc11_ = param1.metric;
            _loc12_ = this.GetMetric();
            if(_loc12_ < 0.5 * _loc11_ || 2 * _loc11_ < _loc12_ || _loc12_ < ASCompat.MIN_FLOAT)
            {
               this.m_count = 0;
            }
         }
         if(this.m_count == 0)
         {
            _loc10_ = _loc8_[0];
            _loc10_.indexA = 0;
            _loc10_.indexB = 0;
            _loc6_ = param2.GetVertex(0);
            _loc7_ = param4.GetVertex(0);
            _loc10_.wA = B2Math.MulX(param3,_loc6_);
            _loc10_.wB = B2Math.MulX(param5,_loc7_);
            _loc10_.w = B2Math.SubtractVV(_loc10_.wB,_loc10_.wA);
            this.m_count = 1;
         }
      }
      
      public function WriteCache(param1:B2SimplexCache) 
      {
         param1.metric = this.GetMetric();
         param1.count = (this.m_count : UInt);
         var _loc2_= this.m_vertices;
         var _loc3_= 0;
         while(_loc3_ < this.m_count)
         {
            param1.indexA[_loc3_] = _loc2_[_loc3_].indexA;
            param1.indexB[_loc3_] = _loc2_[_loc3_].indexB;
            _loc3_++;
         }
      }
      
      public function GetSearchDirection() : B2Vec2
      {
         var _loc1_:B2Vec2 = null;
         var _loc2_= Math.NaN;
         switch(this.m_count)
         {
            case 1:
               return this.m_v1.w.GetNegative();
            case 2:
               _loc1_ = B2Math.SubtractVV(this.m_v2.w,this.m_v1.w);
               _loc2_ = B2Math.CrossVV(_loc1_,this.m_v1.w.GetNegative());
               if(_loc2_ > 0)
               {
                  return B2Math.CrossFV(1,_loc1_);
               }
               return B2Math.CrossVF(_loc1_,1);
               
            default:
               B2Settings.b2Assert(false);
               return new B2Vec2();
         }
return null;
      }
      
      public function GetClosestPoint() : B2Vec2
      {
         switch(this.m_count)
         {
            case 0:
               B2Settings.b2Assert(false);
               return new B2Vec2();
            case 1:
               return this.m_v1.w;
            case 2:
               return new B2Vec2(this.m_v1.a * this.m_v1.w.x + this.m_v2.a * this.m_v2.w.x,this.m_v1.a * this.m_v1.w.y + this.m_v2.a * this.m_v2.w.y);
            default:
               B2Settings.b2Assert(false);
               return new B2Vec2();
         }
return null;
      }
      
      public function GetWitnessPoints(param1:B2Vec2, param2:B2Vec2) 
      {
         switch(this.m_count)
         {
            case 0:
               B2Settings.b2Assert(false);
               
            case 1:
               param1.SetV(this.m_v1.wA);
               param2.SetV(this.m_v1.wB);
               
            case 2:
               param1.x = this.m_v1.a * this.m_v1.wA.x + this.m_v2.a * this.m_v2.wA.x;
               param1.y = this.m_v1.a * this.m_v1.wA.y + this.m_v2.a * this.m_v2.wA.y;
               param2.x = this.m_v1.a * this.m_v1.wB.x + this.m_v2.a * this.m_v2.wB.x;
               param2.y = this.m_v1.a * this.m_v1.wB.y + this.m_v2.a * this.m_v2.wB.y;
               
            case 3:
               param2.x = param1.x = this.m_v1.a * this.m_v1.wA.x + this.m_v2.a * this.m_v2.wA.x + this.m_v3.a * this.m_v3.wA.x;
               param2.y = param1.y = this.m_v1.a * this.m_v1.wA.y + this.m_v2.a * this.m_v2.wA.y + this.m_v3.a * this.m_v3.wA.y;
               
            default:
               B2Settings.b2Assert(false);
         }
      }
      
      public function GetMetric() : Float
      {
         switch(this.m_count)
         {
            case 0:
               B2Settings.b2Assert(false);
               return 0;
            case 1:
               return 0;
            case 2:
               return B2Math.SubtractVV(this.m_v1.w,this.m_v2.w).Length();
            case 3:
               return B2Math.CrossVV(B2Math.SubtractVV(this.m_v2.w,this.m_v1.w),B2Math.SubtractVV(this.m_v3.w,this.m_v1.w));
            default:
               B2Settings.b2Assert(false);
               return 0;
         }
return Math.NaN;
      }
      
      public function Solve2() 
      {
         var _loc1_= this.m_v1.w;
         var _loc2_= this.m_v2.w;
         var _loc3_= B2Math.SubtractVV(_loc2_,_loc1_);
         var _loc4_= -(_loc1_.x * _loc3_.x + _loc1_.y * _loc3_.y);
         if(_loc4_ <= 0)
         {
            this.m_v1.a = 1;
            this.m_count = 1;
            return;
         }
         var _loc5_= _loc2_.x * _loc3_.x + _loc2_.y * _loc3_.y;
         if(_loc5_ <= 0)
         {
            this.m_v2.a = 1;
            this.m_count = 1;
            this.m_v1.Set(this.m_v2);
            return;
         }
         var _loc6_= 1 / (_loc5_ + _loc4_);
         this.m_v1.a = _loc5_ * _loc6_;
         this.m_v2.a = _loc4_ * _loc6_;
         this.m_count = 2;
      }
      
      public function Solve3() 
      {
         var _loc24_= Math.NaN;
         var _loc25_= Math.NaN;
         var _loc26_= Math.NaN;
         var _loc1_= this.m_v1.w;
         var _loc2_= this.m_v2.w;
         var _loc3_= this.m_v3.w;
         var _loc4_= B2Math.SubtractVV(_loc2_,_loc1_);
         var _loc5_= B2Math.Dot(_loc1_,_loc4_);
         var _loc6_:Float;
         var _loc7_= _loc6_ = B2Math.Dot(_loc2_,_loc4_);
         var _loc8_= -_loc5_;
         var _loc9_= B2Math.SubtractVV(_loc3_,_loc1_);
         var _loc10_= B2Math.Dot(_loc1_,_loc9_);
         var _loc11_:Float;
         var _loc12_= _loc11_ = B2Math.Dot(_loc3_,_loc9_);
         var _loc13_= -_loc10_;
         var _loc14_= B2Math.SubtractVV(_loc3_,_loc2_);
         var _loc15_= B2Math.Dot(_loc2_,_loc14_);
         var _loc16_:Float;
         var _loc17_= _loc16_ = B2Math.Dot(_loc3_,_loc14_);
         var _loc18_= -_loc15_;
         var _loc19_= B2Math.CrossVV(_loc4_,_loc9_);
         var _loc20_= _loc19_ * B2Math.CrossVV(_loc2_,_loc3_);
         var _loc21_= _loc19_ * B2Math.CrossVV(_loc3_,_loc1_);
         var _loc22_= _loc19_ * B2Math.CrossVV(_loc1_,_loc2_);
         if(_loc8_ <= 0 && _loc13_ <= 0)
         {
            this.m_v1.a = 1;
            this.m_count = 1;
            return;
         }
         if(_loc7_ > 0 && _loc8_ > 0 && _loc22_ <= 0)
         {
            _loc24_ = 1 / (_loc7_ + _loc8_);
            this.m_v1.a = _loc7_ * _loc24_;
            this.m_v2.a = _loc8_ * _loc24_;
            this.m_count = 2;
            return;
         }
         if(_loc12_ > 0 && _loc13_ > 0 && _loc21_ <= 0)
         {
            _loc25_ = 1 / (_loc12_ + _loc13_);
            this.m_v1.a = _loc12_ * _loc25_;
            this.m_v3.a = _loc13_ * _loc25_;
            this.m_count = 2;
            this.m_v2.Set(this.m_v3);
            return;
         }
         if(_loc7_ <= 0 && _loc18_ <= 0)
         {
            this.m_v2.a = 1;
            this.m_count = 1;
            this.m_v1.Set(this.m_v2);
            return;
         }
         if(_loc12_ <= 0 && _loc17_ <= 0)
         {
            this.m_v3.a = 1;
            this.m_count = 1;
            this.m_v1.Set(this.m_v3);
            return;
         }
         if(_loc17_ > 0 && _loc18_ > 0 && _loc20_ <= 0)
         {
            _loc26_ = 1 / (_loc17_ + _loc18_);
            this.m_v2.a = _loc17_ * _loc26_;
            this.m_v3.a = _loc18_ * _loc26_;
            this.m_count = 2;
            this.m_v1.Set(this.m_v3);
            return;
         }
         var _loc23_= 1 / (_loc20_ + _loc21_ + _loc22_);
         this.m_v1.a = _loc20_ * _loc23_;
         this.m_v2.a = _loc21_ * _loc23_;
         this.m_v3.a = _loc22_ * _loc23_;
         this.m_count = 3;
      }
   }


