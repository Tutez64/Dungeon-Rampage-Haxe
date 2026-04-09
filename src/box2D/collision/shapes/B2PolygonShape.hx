package box2D.collision.shapes
;
   import box2D.collision.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2PolygonShape extends B2Shape
   {
      
      static var s_mat:B2Mat22 = new B2Mat22();
      
      /*b2internal*/ public var m_centroid:B2Vec2;
      
      /*b2internal*/ public var m_vertices:Vector<B2Vec2>;
      
      /*b2internal*/ public var m_normals:Vector<B2Vec2>;
      
      /*b2internal*/ public var m_vertexCount:Int = 0;
      
      public function new()
      {
         super();
         /*b2internal::*/m_type = /*b2internal::*/B2Shape.e_polygonShape;
         this/*b2internal::*/.m_centroid = new B2Vec2();
         this/*b2internal::*/.m_vertices = new Vector<B2Vec2>();
         this/*b2internal::*/.m_normals = new Vector<B2Vec2>();
      }
      
      public static function AsArray(param1:Array<ASAny>, param2:Float) : B2PolygonShape
      {
         var _loc3_= new B2PolygonShape();
         _loc3_.SetAsArray(param1,param2);
         return _loc3_;
      }
      
      public static function AsVector(param1:Vector<B2Vec2>, param2:Float) : B2PolygonShape
      {
         var _loc3_= new B2PolygonShape();
         _loc3_.SetAsVector(param1,param2);
         return _loc3_;
      }
      
      public static function AsBox(param1:Float, param2:Float) : B2PolygonShape
      {
         var _loc3_= new B2PolygonShape();
         _loc3_.SetAsBox(param1,param2);
         return _loc3_;
      }
      
      public static function AsOrientedBox(param1:Float, param2:Float, param3:B2Vec2 = null, param4:Float = 0) : B2PolygonShape
      {
         var _loc5_= new B2PolygonShape();
         _loc5_.SetAsOrientedBox(param1,param2,param3,param4);
         return _loc5_;
      }
      
      public static function AsEdge(param1:B2Vec2, param2:B2Vec2) : B2PolygonShape
      {
         var _loc3_= new B2PolygonShape();
         _loc3_.SetAsEdge(param1,param2);
         return _loc3_;
      }
      
      public static function ComputeCentroid(param1:Vector<B2Vec2>, param2:UInt) : B2Vec2
      {
         var _loc3_:B2Vec2 = null;
         var _loc7_= Math.NaN;
         var _loc9_:B2Vec2 = null;
         var _loc10_:B2Vec2 = null;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         _loc3_ = new B2Vec2();
         var _loc4_:Float = 0;
         var _loc5_:Float = 0;
         var _loc6_:Float = 0;
         _loc7_ = 1 / 3;
         var _loc8_= 0;
         while((_loc8_ : UInt) < param2)
         {
            _loc9_ = param1[_loc8_];
            _loc10_ = (_loc8_ + 1 : UInt) < param2 ? param1[_loc8_ + 1] : param1[0];
            _loc11_ = _loc9_.x - _loc5_;
            _loc12_ = _loc9_.y - _loc6_;
            _loc13_ = _loc10_.x - _loc5_;
            _loc14_ = _loc10_.y - _loc6_;
            _loc15_ = _loc11_ * _loc14_ - _loc12_ * _loc13_;
            _loc16_ = 0.5 * _loc15_;
            _loc4_ += _loc16_;
            _loc3_.x += _loc16_ * _loc7_ * (_loc5_ + _loc9_.x + _loc10_.x);
            _loc3_.y += _loc16_ * _loc7_ * (_loc6_ + _loc9_.y + _loc10_.y);
            _loc8_++;
         }
         _loc3_.x *= 1 / _loc4_;
         _loc3_.y *= 1 / _loc4_;
         return _loc3_;
      }
      
      /*b2internal*/ public static function ComputeOBB(param1:B2OBB, param2:Vector<B2Vec2>, param3:Int) 
      {
         var _loc4_= 0;
         var _loc7_:B2Vec2 = null;
         var _loc8_= Math.NaN;
         var _loc9_= Math.NaN;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= 0;
         var _loc18_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc23_= Math.NaN;
         var _loc24_= Math.NaN;
         var _loc25_:B2Mat22 = null;
         var _loc5_= new Vector<B2Vec2>((param3 + 1 : UInt));
         _loc4_ = 0;
         while(_loc4_ < param3)
         {
            _loc5_[_loc4_] = param2[_loc4_];
            _loc4_++;
         }
         _loc5_[param3] = _loc5_[0];
         var _loc6_:Float = ASCompat.MAX_FLOAT;
         _loc4_ = 1;
         while(_loc4_ <= param3)
         {
            _loc7_ = _loc5_[_loc4_ - 1];
            _loc8_ = _loc5_[_loc4_].x - _loc7_.x;
            _loc9_ = _loc5_[_loc4_].y - _loc7_.y;
            _loc10_ = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
            _loc8_ /= _loc10_;
            _loc9_ /= _loc10_;
            _loc11_ = -_loc9_;
            _loc12_ = _loc8_;
            _loc13_ = ASCompat.MAX_FLOAT;
            _loc14_ = ASCompat.MAX_FLOAT;
            _loc15_ = -ASCompat.MAX_FLOAT;
            _loc16_ = -ASCompat.MAX_FLOAT;
            _loc17_ = 0;
            while(_loc17_ < param3)
            {
               _loc19_ = _loc5_[_loc17_].x - _loc7_.x;
               _loc20_ = _loc5_[_loc17_].y - _loc7_.y;
               _loc21_ = _loc8_ * _loc19_ + _loc9_ * _loc20_;
               _loc22_ = _loc11_ * _loc19_ + _loc12_ * _loc20_;
               if(_loc21_ < _loc13_)
               {
                  _loc13_ = _loc21_;
               }
               if(_loc22_ < _loc14_)
               {
                  _loc14_ = _loc22_;
               }
               if(_loc21_ > _loc15_)
               {
                  _loc15_ = _loc21_;
               }
               if(_loc22_ > _loc16_)
               {
                  _loc16_ = _loc22_;
               }
               _loc17_++;
            }
            _loc18_ = (_loc15_ - _loc13_) * (_loc16_ - _loc14_);
            if(_loc18_ < 0.95 * _loc6_)
            {
               _loc6_ = _loc18_;
               param1.R.col1.x = _loc8_;
               param1.R.col1.y = _loc9_;
               param1.R.col2.x = _loc11_;
               param1.R.col2.y = _loc12_;
               _loc23_ = 0.5 * (_loc13_ + _loc15_);
               _loc24_ = 0.5 * (_loc14_ + _loc16_);
               _loc25_ = param1.R;
               param1.center.x = _loc7_.x + (_loc25_.col1.x * _loc23_ + _loc25_.col2.x * _loc24_);
               param1.center.y = _loc7_.y + (_loc25_.col1.y * _loc23_ + _loc25_.col2.y * _loc24_);
               param1.extents.x = 0.5 * (_loc15_ - _loc13_);
               param1.extents.y = 0.5 * (_loc16_ - _loc14_);
            }
            _loc4_++;
         }
      }
      
      override public function Copy() : B2Shape
      {
         var _loc1_= new B2PolygonShape();
         _loc1_.Set(this);
         return _loc1_;
      }
      
      override public function Set(param1:B2Shape) 
      {
         var _loc2_:B2PolygonShape = null;
         var _loc3_= 0;
         super.Set(param1);
         if(Std.isOfType(param1 , B2PolygonShape))
         {
            _loc2_ = ASCompat.reinterpretAs(param1 , B2PolygonShape);
            this/*b2internal::*/.m_centroid.SetV(_loc2_/*b2internal::*/.m_centroid);
            this/*b2internal::*/.m_vertexCount = _loc2_/*b2internal::*/.m_vertexCount;
            this.Reserve(this/*b2internal::*/.m_vertexCount);
            _loc3_ = 0;
            while(_loc3_ < this/*b2internal::*/.m_vertexCount)
            {
               this/*b2internal::*/.m_vertices[_loc3_].SetV(_loc2_/*b2internal::*/.m_vertices[_loc3_]);
               this/*b2internal::*/.m_normals[_loc3_].SetV(_loc2_/*b2internal::*/.m_normals[_loc3_]);
               _loc3_++;
            }
         }
      }
      
      public function SetAsArray(param1:Array<ASAny>, param2:Float = 0) 
      {
         var _loc4_:B2Vec2 = null;
         var _loc3_= new Vector<B2Vec2>();
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc4_  = ASCompat.dynamicAs(_tmp_, box2D.common.math.B2Vec2);
            _loc3_.push(_loc4_);
         }
         this.SetAsVector(_loc3_,param2);
      }
      
      public function SetAsVector(param1:Vector<B2Vec2>, param2:Float = 0) 
      {
         var _loc3_= 0;
         var _loc4_= 0;
         var _loc5_= 0;
         var _loc6_:B2Vec2 = null;
         if(param2 == 0)
         {
            param2 = param1.length;
         }
         B2Settings.b2Assert(2 <= param2);
         this/*b2internal::*/.m_vertexCount = Std.int(param2);
         this.Reserve(Std.int(param2));
         _loc3_ = 0;
         while(_loc3_ < this/*b2internal::*/.m_vertexCount)
         {
            this/*b2internal::*/.m_vertices[_loc3_].SetV(param1[_loc3_]);
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc4_ = _loc3_;
            _loc5_ = _loc3_ + 1 < this/*b2internal::*/.m_vertexCount ? _loc3_ + 1 : 0;
            _loc6_ = B2Math.SubtractVV(this/*b2internal::*/.m_vertices[_loc5_],this/*b2internal::*/.m_vertices[_loc4_]);
            B2Settings.b2Assert(_loc6_.LengthSquared() > ASCompat.MIN_FLOAT);
            this/*b2internal::*/.m_normals[_loc3_].SetV(B2Math.CrossVF(_loc6_,1));
            this/*b2internal::*/.m_normals[_loc3_].Normalize();
            _loc3_++;
         }
         this/*b2internal::*/.m_centroid = ComputeCentroid(this/*b2internal::*/.m_vertices,(this/*b2internal::*/.m_vertexCount : UInt));
      }
      
      public function SetAsBox(param1:Float, param2:Float) 
      {
         this/*b2internal::*/.m_vertexCount = 4;
         this.Reserve(4);
         this/*b2internal::*/.m_vertices[0].Set(-param1,-param2);
         this/*b2internal::*/.m_vertices[1].Set(param1,-param2);
         this/*b2internal::*/.m_vertices[2].Set(param1,param2);
         this/*b2internal::*/.m_vertices[3].Set(-param1,param2);
         this/*b2internal::*/.m_normals[0].Set(0,-1);
         this/*b2internal::*/.m_normals[1].Set(1,0);
         this/*b2internal::*/.m_normals[2].Set(0,1);
         this/*b2internal::*/.m_normals[3].Set(-1,0);
         this/*b2internal::*/.m_centroid.SetZero();
      }
      
      public function SetAsOrientedBox(param1:Float, param2:Float, param3:B2Vec2 = null, param4:Float = 0) 
      {
         this/*b2internal::*/.m_vertexCount = 4;
         this.Reserve(4);
         this/*b2internal::*/.m_vertices[0].Set(-param1,-param2);
         this/*b2internal::*/.m_vertices[1].Set(param1,-param2);
         this/*b2internal::*/.m_vertices[2].Set(param1,param2);
         this/*b2internal::*/.m_vertices[3].Set(-param1,param2);
         this/*b2internal::*/.m_normals[0].Set(0,-1);
         this/*b2internal::*/.m_normals[1].Set(1,0);
         this/*b2internal::*/.m_normals[2].Set(0,1);
         this/*b2internal::*/.m_normals[3].Set(-1,0);
         this/*b2internal::*/.m_centroid = param3;
         var _loc5_= new B2Transform();
         _loc5_.position = param3;
         _loc5_.R.Set(param4);
         var _loc6_= 0;
         while(_loc6_ < this/*b2internal::*/.m_vertexCount)
         {
            this/*b2internal::*/.m_vertices[_loc6_] = B2Math.MulX(_loc5_,this/*b2internal::*/.m_vertices[_loc6_]);
            this/*b2internal::*/.m_normals[_loc6_] = B2Math.MulMV(_loc5_.R,this/*b2internal::*/.m_normals[_loc6_]);
            _loc6_++;
         }
      }
      
      public function SetAsEdge(param1:B2Vec2, param2:B2Vec2) 
      {
         this/*b2internal::*/.m_vertexCount = 2;
         this.Reserve(2);
         this/*b2internal::*/.m_vertices[0].SetV(param1);
         this/*b2internal::*/.m_vertices[1].SetV(param2);
         this/*b2internal::*/.m_centroid.x = 0.5 * (param1.x + param2.x);
         this/*b2internal::*/.m_centroid.y = 0.5 * (param1.y + param2.y);
         this/*b2internal::*/.m_normals[0] = B2Math.CrossVF(B2Math.SubtractVV(param2,param1),1);
         this/*b2internal::*/.m_normals[0].Normalize();
         this/*b2internal::*/.m_normals[1].x = -this/*b2internal::*/.m_normals[0].x;
         this/*b2internal::*/.m_normals[1].y = -this/*b2internal::*/.m_normals[0].y;
      }
      
      override public function TestPoint(param1:B2Transform, param2:B2Vec2) : Bool
      {
         var _loc3_:B2Vec2 = null;
         var _loc10_= Math.NaN;
         var _loc4_= param1.R;
         var _loc5_= param2.x - param1.position.x;
         var _loc6_= param2.y - param1.position.y;
         var _loc7_= _loc5_ * _loc4_.col1.x + _loc6_ * _loc4_.col1.y;
         var _loc8_= _loc5_ * _loc4_.col2.x + _loc6_ * _loc4_.col2.y;
         var _loc9_= 0;
         while(_loc9_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc3_ = this/*b2internal::*/.m_vertices[_loc9_];
            _loc5_ = _loc7_ - _loc3_.x;
            _loc6_ = _loc8_ - _loc3_.y;
            _loc3_ = this/*b2internal::*/.m_normals[_loc9_];
            _loc10_ = _loc3_.x * _loc5_ + _loc3_.y * _loc6_;
            if(_loc10_ > 0)
            {
               return false;
            }
            _loc9_++;
         }
         return true;
      }
      
      override public function RayCast(param1:B2RayCastOutput, param2:B2RayCastInput, param3:B2Transform) : Bool
      {
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc8_:B2Mat22 = null;
         var _loc9_:B2Vec2 = null;
         var _loc18_= Math.NaN;
         var _loc19_= Math.NaN;
         var _loc4_:Float = 0;
         var _loc5_= param2.maxFraction;
         _loc6_ = param2.p1.x - param3.position.x;
         _loc7_ = param2.p1.y - param3.position.y;
         _loc8_ = param3.R;
         var _loc10_= _loc6_ * _loc8_.col1.x + _loc7_ * _loc8_.col1.y;
         var _loc11_= _loc6_ * _loc8_.col2.x + _loc7_ * _loc8_.col2.y;
         _loc6_ = param2.p2.x - param3.position.x;
         _loc7_ = param2.p2.y - param3.position.y;
         _loc8_ = param3.R;
         var _loc12_= _loc6_ * _loc8_.col1.x + _loc7_ * _loc8_.col1.y;
         var _loc13_= _loc6_ * _loc8_.col2.x + _loc7_ * _loc8_.col2.y;
         var _loc14_= _loc12_ - _loc10_;
         var _loc15_= _loc13_ - _loc11_;
         var _loc16_= -1;
         var _loc17_= 0;
         while(_loc17_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc9_ = this/*b2internal::*/.m_vertices[_loc17_];
            _loc6_ = _loc9_.x - _loc10_;
            _loc7_ = _loc9_.y - _loc11_;
            _loc9_ = this/*b2internal::*/.m_normals[_loc17_];
            _loc18_ = _loc9_.x * _loc6_ + _loc9_.y * _loc7_;
            _loc19_ = _loc9_.x * _loc14_ + _loc9_.y * _loc15_;
            if(_loc19_ == 0)
            {
               if(_loc18_ < 0)
               {
                  return false;
               }
            }
            else if(_loc19_ < 0 && _loc18_ < _loc4_ * _loc19_)
            {
               _loc4_ = _loc18_ / _loc19_;
               _loc16_ = _loc17_;
            }
            else if(_loc19_ > 0 && _loc18_ < _loc5_ * _loc19_)
            {
               _loc5_ = _loc18_ / _loc19_;
            }
            if(_loc5_ < _loc4_ - ASCompat.MIN_FLOAT)
            {
               return false;
            }
            _loc17_++;
         }
         if(_loc16_ >= 0)
         {
            param1.fraction = _loc4_;
            _loc8_ = param3.R;
            _loc9_ = this/*b2internal::*/.m_normals[_loc16_];
            param1.normal.x = _loc8_.col1.x * _loc9_.x + _loc8_.col2.x * _loc9_.y;
            param1.normal.y = _loc8_.col1.y * _loc9_.x + _loc8_.col2.y * _loc9_.y;
            return true;
         }
         return false;
      }
      
      override public function ComputeAABB(param1:B2AABB, param2:B2Transform) 
      {
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc3_= param2.R;
         var _loc4_= this/*b2internal::*/.m_vertices[0];
         var _loc5_= param2.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
         var _loc6_= param2.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
         var _loc7_= _loc5_;
         var _loc8_= _loc6_;
         var _loc9_= 1;
         while(_loc9_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc4_ = this/*b2internal::*/.m_vertices[_loc9_];
            _loc10_ = param2.position.x + (_loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y);
            _loc11_ = param2.position.y + (_loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y);
            _loc5_ = _loc5_ < _loc10_ ? _loc5_ : _loc10_;
            _loc6_ = _loc6_ < _loc11_ ? _loc6_ : _loc11_;
            _loc7_ = _loc7_ > _loc10_ ? _loc7_ : _loc10_;
            _loc8_ = _loc8_ > _loc11_ ? _loc8_ : _loc11_;
            _loc9_++;
         }
         param1.lowerBound.x = _loc5_ - /*b2internal::*/m_radius;
         param1.lowerBound.y = _loc6_ - /*b2internal::*/m_radius;
         param1.upperBound.x = _loc7_ + /*b2internal::*/m_radius;
         param1.upperBound.y = _loc8_ + /*b2internal::*/m_radius;
      }
      
      override public function ComputeMass(param1:B2MassData, param2:Float) 
      {
         var _loc11_:B2Vec2 = null;
         var _loc12_:B2Vec2 = null;
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
         var _loc24_= Math.NaN;
         var _loc25_= Math.NaN;
         var _loc26_= Math.NaN;
         if(this/*b2internal::*/.m_vertexCount == 2)
         {
            param1.center.x = 0.5 * (this/*b2internal::*/.m_vertices[0].x + this/*b2internal::*/.m_vertices[1].x);
            param1.center.y = 0.5 * (this/*b2internal::*/.m_vertices[0].y + this/*b2internal::*/.m_vertices[1].y);
            param1.mass = 0;
            param1.I = 0;
            return;
         }
         var _loc3_:Float = 0;
         var _loc4_:Float = 0;
         var _loc5_:Float = 0;
         var _loc6_:Float = 0;
         var _loc7_:Float = 0;
         var _loc8_:Float = 0;
         var _loc9_= 1 / 3;
         var _loc10_= 0;
         while(_loc10_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc11_ = this/*b2internal::*/.m_vertices[_loc10_];
            _loc12_ = _loc10_ + 1 < this/*b2internal::*/.m_vertexCount ? this/*b2internal::*/.m_vertices[_loc10_ + 1] : this/*b2internal::*/.m_vertices[0];
            _loc13_ = _loc11_.x - _loc7_;
            _loc14_ = _loc11_.y - _loc8_;
            _loc15_ = _loc12_.x - _loc7_;
            _loc16_ = _loc12_.y - _loc8_;
            _loc17_ = _loc13_ * _loc16_ - _loc14_ * _loc15_;
            _loc18_ = 0.5 * _loc17_;
            _loc5_ += _loc18_;
            _loc3_ += _loc18_ * _loc9_ * (_loc7_ + _loc11_.x + _loc12_.x);
            _loc4_ += _loc18_ * _loc9_ * (_loc8_ + _loc11_.y + _loc12_.y);
            _loc19_ = _loc7_;
            _loc20_ = _loc8_;
            _loc21_ = _loc13_;
            _loc22_ = _loc14_;
            _loc23_ = _loc15_;
            _loc24_ = _loc16_;
            _loc25_ = _loc9_ * (0.25 * (_loc21_ * _loc21_ + _loc23_ * _loc21_ + _loc23_ * _loc23_) + (_loc19_ * _loc21_ + _loc19_ * _loc23_)) + 0.5 * _loc19_ * _loc19_;
            _loc26_ = _loc9_ * (0.25 * (_loc22_ * _loc22_ + _loc24_ * _loc22_ + _loc24_ * _loc24_) + (_loc20_ * _loc22_ + _loc20_ * _loc24_)) + 0.5 * _loc20_ * _loc20_;
            _loc6_ += _loc17_ * (_loc25_ + _loc26_);
            _loc10_++;
         }
         param1.mass = param2 * _loc5_;
         _loc3_ *= 1 / _loc5_;
         _loc4_ *= 1 / _loc5_;
         param1.center.Set(_loc3_,_loc4_);
         param1.I = param2 * _loc6_;
      }
      
      override public function ComputeSubmergedArea(param1:B2Vec2, param2:Float, param3:B2Transform, param4:B2Vec2) : Float
      {
         var _loc12_= 0;
         var _loc22_:B2Vec2 = null;
         var _loc23_= false;
         var _loc24_:B2MassData = null;
         var _loc25_= Math.NaN;
         var _loc5_= B2Math.MulTMV(param3.R,param1);
         var _loc6_= param2 - B2Math.Dot(param1,param3.position);
         var _loc7_= new Vector<Float>();
         var _loc8_= 0;
         var _loc9_= -1;
         var _loc10_= -1;
         var _loc11_= false;
         _loc12_ = 0;
         while(_loc12_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc7_[_loc12_] = B2Math.Dot(_loc5_,this/*b2internal::*/.m_vertices[_loc12_]) - _loc6_;
            _loc23_ = _loc7_[_loc12_] < -ASCompat.MIN_FLOAT;
            if(_loc12_ > 0)
            {
               if(_loc23_)
               {
                  if(!_loc11_)
                  {
                     _loc9_ = _loc12_ - 1;
                     _loc8_++;
                  }
               }
               else if(_loc11_)
               {
                  _loc10_ = _loc12_ - 1;
                  _loc8_++;
               }
            }
            _loc11_ = _loc23_;
            _loc12_++;
         }
         do {
                  switch(_loc8_)
         {
            case 0:
               if(_loc11_)
               {
                  _loc24_ = new B2MassData();
                  this.ComputeMass(_loc24_,1);
                  param4.SetV(B2Math.MulX(param3,_loc24_.center));
                  return _loc24_.mass;
               }
               return 0;
               
            case 1:
               if(_loc9_ == -1)
               {
                  _loc9_ = this/*b2internal::*/.m_vertexCount - 1;
                  break;
               }
               _loc10_ = this/*b2internal::*/.m_vertexCount - 1;
         }
         } while (false);
         var _loc13_= (_loc9_ + 1) % this/*b2internal::*/.m_vertexCount;
         var _loc14_= (_loc10_ + 1) % this/*b2internal::*/.m_vertexCount;
         var _loc15_= (0 - _loc7_[_loc9_]) / (_loc7_[_loc13_] - _loc7_[_loc9_]);
         var _loc16_= (0 - _loc7_[_loc10_]) / (_loc7_[_loc14_] - _loc7_[_loc10_]);
         var _loc17_= new B2Vec2(this/*b2internal::*/.m_vertices[_loc9_].x * (1 - _loc15_) + this/*b2internal::*/.m_vertices[_loc13_].x * _loc15_,this/*b2internal::*/.m_vertices[_loc9_].y * (1 - _loc15_) + this/*b2internal::*/.m_vertices[_loc13_].y * _loc15_);
         var _loc18_= new B2Vec2(this/*b2internal::*/.m_vertices[_loc10_].x * (1 - _loc16_) + this/*b2internal::*/.m_vertices[_loc14_].x * _loc16_,this/*b2internal::*/.m_vertices[_loc10_].y * (1 - _loc16_) + this/*b2internal::*/.m_vertices[_loc14_].y * _loc16_);
         var _loc19_:Float = 0;
         var _loc20_= new B2Vec2();
         var _loc21_= this/*b2internal::*/.m_vertices[_loc13_];
         _loc12_ = _loc13_;
         while(_loc12_ != _loc14_)
         {
            _loc12_ = (_loc12_ + 1) % this/*b2internal::*/.m_vertexCount;
            if(_loc12_ == _loc14_)
            {
               _loc22_ = _loc18_;
            }
            else
            {
               _loc22_ = this/*b2internal::*/.m_vertices[_loc12_];
            }
            _loc25_ = 0.5 * ((_loc21_.x - _loc17_.x) * (_loc22_.y - _loc17_.y) - (_loc21_.y - _loc17_.y) * (_loc22_.x - _loc17_.x));
            _loc19_ += _loc25_;
            _loc20_.x += _loc25_ * (_loc17_.x + _loc21_.x + _loc22_.x) / 3;
            _loc20_.y += _loc25_ * (_loc17_.y + _loc21_.y + _loc22_.y) / 3;
            _loc21_ = _loc22_;
         }
         _loc20_.Multiply(1 / _loc19_);
         param4.SetV(B2Math.MulX(param3,_loc20_));
         return _loc19_;
      }
      
      public function GetVertexCount() : Int
      {
         return this/*b2internal::*/.m_vertexCount;
      }
      
      public function GetVertices() : Vector<B2Vec2>
      {
         return this/*b2internal::*/.m_vertices;
      }
      
      public function GetNormals() : Vector<B2Vec2>
      {
         return this/*b2internal::*/.m_normals;
      }
      
      public function GetSupport(param1:B2Vec2) : Int
      {
         var _loc5_= Math.NaN;
         var _loc2_= 0;
         var _loc3_= this/*b2internal::*/.m_vertices[0].x * param1.x + this/*b2internal::*/.m_vertices[0].y * param1.y;
         var _loc4_= 1;
         while(_loc4_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc5_ = this/*b2internal::*/.m_vertices[_loc4_].x * param1.x + this/*b2internal::*/.m_vertices[_loc4_].y * param1.y;
            if(_loc5_ > _loc3_)
            {
               _loc2_ = _loc4_;
               _loc3_ = _loc5_;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function GetSupportVertex(param1:B2Vec2) : B2Vec2
      {
         var _loc5_= Math.NaN;
         var _loc2_= 0;
         var _loc3_= this/*b2internal::*/.m_vertices[0].x * param1.x + this/*b2internal::*/.m_vertices[0].y * param1.y;
         var _loc4_= 1;
         while(_loc4_ < this/*b2internal::*/.m_vertexCount)
         {
            _loc5_ = this/*b2internal::*/.m_vertices[_loc4_].x * param1.x + this/*b2internal::*/.m_vertices[_loc4_].y * param1.y;
            if(_loc5_ > _loc3_)
            {
               _loc2_ = _loc4_;
               _loc3_ = _loc5_;
            }
            _loc4_++;
         }
         return this/*b2internal::*/.m_vertices[_loc2_];
      }
      
      function Validate() : Bool
      {
         return false;
      }
      
      function Reserve(param1:Int) 
      {
         var _loc2_= this/*b2internal::*/.m_vertices.length;
         while(_loc2_ < param1)
         {
            this/*b2internal::*/.m_vertices[_loc2_] = new B2Vec2();
            this/*b2internal::*/.m_normals[_loc2_] = new B2Vec2();
            _loc2_++;
         }
      }
   }


