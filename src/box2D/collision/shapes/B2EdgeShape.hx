package box2D.collision.shapes
;
   import box2D.collision.B2AABB;
   import box2D.collision.B2RayCastInput;
   import box2D.collision.B2RayCastOutput;
   import box2D.common.math.B2Mat22;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Transform;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Settings;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2EdgeShape extends B2Shape
   {
      
      var s_supportVec:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_v1:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_v2:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_coreV1:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_coreV2:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_length:Float = Math.NaN;
      
      /*b2internal*/ public var m_normal:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_direction:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_cornerDir1:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_cornerDir2:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_cornerConvex1:Bool = false;
      
      /*b2internal*/ public var m_cornerConvex2:Bool = false;
      
      /*b2internal*/ public var m_nextEdge:B2EdgeShape;
      
      /*b2internal*/ public var m_prevEdge:B2EdgeShape;
      
      public function new(param1:B2Vec2, param2:B2Vec2)
      {
         super();
         /*b2internal::*/m_type = /*b2internal::*/B2Shape.e_edgeShape;
         this/*b2internal::*/.m_prevEdge = null;
         this/*b2internal::*/.m_nextEdge = null;
         this/*b2internal::*/.m_v1 = param1;
         this/*b2internal::*/.m_v2 = param2;
         this/*b2internal::*/.m_direction.Set(this/*b2internal::*/.m_v2.x - this/*b2internal::*/.m_v1.x,this/*b2internal::*/.m_v2.y - this/*b2internal::*/.m_v1.y);
         this/*b2internal::*/.m_length = this/*b2internal::*/.m_direction.Normalize();
         this/*b2internal::*/.m_normal.Set(this/*b2internal::*/.m_direction.y,-this/*b2internal::*/.m_direction.x);
         this/*b2internal::*/.m_coreV1.Set(-B2Settings.b2_toiSlop * (this/*b2internal::*/.m_normal.x - this/*b2internal::*/.m_direction.x) + this/*b2internal::*/.m_v1.x,-B2Settings.b2_toiSlop * (this/*b2internal::*/.m_normal.y - this/*b2internal::*/.m_direction.y) + this/*b2internal::*/.m_v1.y);
         this/*b2internal::*/.m_coreV2.Set(-B2Settings.b2_toiSlop * (this/*b2internal::*/.m_normal.x + this/*b2internal::*/.m_direction.x) + this/*b2internal::*/.m_v2.x,-B2Settings.b2_toiSlop * (this/*b2internal::*/.m_normal.y + this/*b2internal::*/.m_direction.y) + this/*b2internal::*/.m_v2.y);
         this/*b2internal::*/.m_cornerDir1 = this/*b2internal::*/.m_normal;
         this/*b2internal::*/.m_cornerDir2.Set(-this/*b2internal::*/.m_normal.x,-this/*b2internal::*/.m_normal.y);
      }
      
      override public function TestPoint(param1:B2Transform, param2:B2Vec2) : Bool
      {
         return false;
      }
      
      override public function RayCast(param1:B2RayCastOutput, param2:B2RayCastInput, param3:B2Transform) : Bool
      {
         var _loc4_:B2Mat22 = null;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc5_= param2.p2.x - param2.p1.x;
         var _loc6_= param2.p2.y - param2.p1.y;
         _loc4_ = param3.R;
         var _loc7_= param3.position.x + (_loc4_.col1.x * this/*b2internal::*/.m_v1.x + _loc4_.col2.x * this/*b2internal::*/.m_v1.y);
         var _loc8_= param3.position.y + (_loc4_.col1.y * this/*b2internal::*/.m_v1.x + _loc4_.col2.y * this/*b2internal::*/.m_v1.y);
         var _loc9_= param3.position.y + (_loc4_.col1.y * this/*b2internal::*/.m_v2.x + _loc4_.col2.y * this/*b2internal::*/.m_v2.y) - _loc8_;
         var _loc10_= -(param3.position.x + (_loc4_.col1.x * this/*b2internal::*/.m_v2.x + _loc4_.col2.x * this/*b2internal::*/.m_v2.y) - _loc7_);
         var _loc11_= 100 * ASCompat.MIN_FLOAT;
         var _loc12_= -(_loc5_ * _loc9_ + _loc6_ * _loc10_);
         if(_loc12_ > _loc11_)
         {
            _loc13_ = param2.p1.x - _loc7_;
            _loc14_ = param2.p1.y - _loc8_;
            _loc15_ = _loc13_ * _loc9_ + _loc14_ * _loc10_;
            if(0 <= _loc15_ && _loc15_ <= param2.maxFraction * _loc12_)
            {
               _loc16_ = -_loc5_ * _loc14_ + _loc6_ * _loc13_;
               if(-_loc11_ * _loc12_ <= _loc16_ && _loc16_ <= _loc12_ * (1 + _loc11_))
               {
                  _loc15_ /= _loc12_;
                  param1.fraction = _loc15_;
                  _loc17_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
                  param1.normal.x = _loc9_ / _loc17_;
                  param1.normal.y = _loc10_ / _loc17_;
                  return true;
               }
            }
         }
         return false;
      }
      
      override public function ComputeAABB(param1:B2AABB, param2:B2Transform) 
      {
         var _loc4_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc3_= param2.R;
         _loc4_ = param2.position.x + (_loc3_.col1.x * this/*b2internal::*/.m_v1.x + _loc3_.col2.x * this/*b2internal::*/.m_v1.y);
         _loc5_ = param2.position.y + (_loc3_.col1.y * this/*b2internal::*/.m_v1.x + _loc3_.col2.y * this/*b2internal::*/.m_v1.y);
         _loc6_ = param2.position.x + (_loc3_.col1.x * this/*b2internal::*/.m_v2.x + _loc3_.col2.x * this/*b2internal::*/.m_v2.y);
         _loc7_ = param2.position.y + (_loc3_.col1.y * this/*b2internal::*/.m_v2.x + _loc3_.col2.y * this/*b2internal::*/.m_v2.y);
         if(_loc4_ < _loc6_)
         {
            param1.lowerBound.x = _loc4_;
            param1.upperBound.x = _loc6_;
         }
         else
         {
            param1.lowerBound.x = _loc6_;
            param1.upperBound.x = _loc4_;
         }
         if(_loc5_ < _loc7_)
         {
            param1.lowerBound.y = _loc5_;
            param1.upperBound.y = _loc7_;
         }
         else
         {
            param1.lowerBound.y = _loc7_;
            param1.upperBound.y = _loc5_;
         }
      }
      
      override public function ComputeMass(param1:B2MassData, param2:Float) 
      {
         param1.mass = 0;
         param1.center.SetV(this/*b2internal::*/.m_v1);
         param1.I = 0;
      }
      
      override public function ComputeSubmergedArea(param1:B2Vec2, param2:Float, param3:B2Transform, param4:B2Vec2) : Float
      {
         var _loc5_= new B2Vec2(param1.x * param2,param1.y * param2);
         var _loc6_= B2Math.MulX(param3,this/*b2internal::*/.m_v1);
         var _loc7_= B2Math.MulX(param3,this/*b2internal::*/.m_v2);
         var _loc8_= B2Math.Dot(param1,_loc6_) - param2;
         var _loc9_= B2Math.Dot(param1,_loc7_) - param2;
         if(_loc8_ > 0)
         {
            if(_loc9_ > 0)
            {
               return 0;
            }
            _loc6_.x = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.x + _loc8_ / (_loc8_ - _loc9_) * _loc7_.x;
            _loc6_.y = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.y + _loc8_ / (_loc8_ - _loc9_) * _loc7_.y;
         }
         else if(_loc9_ > 0)
         {
            _loc7_.x = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.x + _loc8_ / (_loc8_ - _loc9_) * _loc7_.x;
            _loc7_.y = -_loc9_ / (_loc8_ - _loc9_) * _loc6_.y + _loc8_ / (_loc8_ - _loc9_) * _loc7_.y;
         }
         param4.x = (_loc5_.x + _loc6_.x + _loc7_.x) / 3;
         param4.y = (_loc5_.y + _loc6_.y + _loc7_.y) / 3;
         return 0.5 * ((_loc6_.x - _loc5_.x) * (_loc7_.y - _loc5_.y) - (_loc6_.y - _loc5_.y) * (_loc7_.x - _loc5_.x));
      }
      
      public function GetLength() : Float
      {
         return this/*b2internal::*/.m_length;
      }
      
      public function GetVertex1() : B2Vec2
      {
         return this/*b2internal::*/.m_v1;
      }
      
      public function GetVertex2() : B2Vec2
      {
         return this/*b2internal::*/.m_v2;
      }
      
      public function GetCoreVertex1() : B2Vec2
      {
         return this/*b2internal::*/.m_coreV1;
      }
      
      public function GetCoreVertex2() : B2Vec2
      {
         return this/*b2internal::*/.m_coreV2;
      }
      
      public function GetNormalVector() : B2Vec2
      {
         return this/*b2internal::*/.m_normal;
      }
      
      public function GetDirectionVector() : B2Vec2
      {
         return this/*b2internal::*/.m_direction;
      }
      
      public function GetCorner1Vector() : B2Vec2
      {
         return this/*b2internal::*/.m_cornerDir1;
      }
      
      public function GetCorner2Vector() : B2Vec2
      {
         return this/*b2internal::*/.m_cornerDir2;
      }
      
      public function Corner1IsConvex() : Bool
      {
         return this/*b2internal::*/.m_cornerConvex1;
      }
      
      public function Corner2IsConvex() : Bool
      {
         return this/*b2internal::*/.m_cornerConvex2;
      }
      
      public function GetFirstVertex(param1:B2Transform) : B2Vec2
      {
         var _loc2_= param1.R;
         return new B2Vec2(param1.position.x + (_loc2_.col1.x * this/*b2internal::*/.m_coreV1.x + _loc2_.col2.x * this/*b2internal::*/.m_coreV1.y),param1.position.y + (_loc2_.col1.y * this/*b2internal::*/.m_coreV1.x + _loc2_.col2.y * this/*b2internal::*/.m_coreV1.y));
      }
      
      public function GetNextEdge() : B2EdgeShape
      {
         return this/*b2internal::*/.m_nextEdge;
      }
      
      public function GetPrevEdge() : B2EdgeShape
      {
         return this/*b2internal::*/.m_prevEdge;
      }
      
      public function Support(param1:B2Transform, param2:Float, param3:Float) : B2Vec2
      {
         var _loc4_= param1.R;
         var _loc5_= param1.position.x + (_loc4_.col1.x * this/*b2internal::*/.m_coreV1.x + _loc4_.col2.x * this/*b2internal::*/.m_coreV1.y);
         var _loc6_= param1.position.y + (_loc4_.col1.y * this/*b2internal::*/.m_coreV1.x + _loc4_.col2.y * this/*b2internal::*/.m_coreV1.y);
         var _loc7_= param1.position.x + (_loc4_.col1.x * this/*b2internal::*/.m_coreV2.x + _loc4_.col2.x * this/*b2internal::*/.m_coreV2.y);
         var _loc8_= param1.position.y + (_loc4_.col1.y * this/*b2internal::*/.m_coreV2.x + _loc4_.col2.y * this/*b2internal::*/.m_coreV2.y);
         if(_loc5_ * param2 + _loc6_ * param3 > _loc7_ * param2 + _loc8_ * param3)
         {
            this.s_supportVec.x = _loc5_;
            this.s_supportVec.y = _loc6_;
         }
         else
         {
            this.s_supportVec.x = _loc7_;
            this.s_supportVec.y = _loc8_;
         }
         return this.s_supportVec;
      }
      
      /*b2internal*/ public function SetPrevEdge(param1:B2EdgeShape, param2:B2Vec2, param3:B2Vec2, param4:Bool) 
      {
         this/*b2internal::*/.m_prevEdge = param1;
         this/*b2internal::*/.m_coreV1 = param2;
         this/*b2internal::*/.m_cornerDir1 = param3;
         this/*b2internal::*/.m_cornerConvex1 = param4;
      }
      
      /*b2internal*/ public function SetNextEdge(param1:B2EdgeShape, param2:B2Vec2, param3:B2Vec2, param4:Bool) 
      {
         this/*b2internal::*/.m_nextEdge = param1;
         this/*b2internal::*/.m_coreV2 = param2;
         this/*b2internal::*/.m_cornerDir2 = param3;
         this/*b2internal::*/.m_cornerConvex2 = param4;
      }
   }


