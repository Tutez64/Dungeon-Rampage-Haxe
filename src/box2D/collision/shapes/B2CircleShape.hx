package box2D.collision.shapes
;
   import box2D.collision.B2AABB;
   import box2D.collision.B2RayCastInput;
   import box2D.collision.B2RayCastOutput;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Transform;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Settings;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2CircleShape extends B2Shape
   {
      
      /*b2internal*/ public var m_p:B2Vec2 = new B2Vec2();
      
      public function new(param1:Float = 0)
      {
         super();
         /*b2internal::*/m_type = /*b2internal::*/B2Shape.e_circleShape;
         /*b2internal::*/m_radius = param1;
      }
      
      override public function Copy() : B2Shape
      {
         var _loc1_:B2Shape = new B2CircleShape();
         _loc1_.Set(this);
         return _loc1_;
      }
      
      override public function Set(param1:B2Shape) 
      {
         var _loc2_:B2CircleShape = null;
         super.Set(param1);
         if(Std.isOfType(param1 , B2CircleShape))
         {
            _loc2_ = ASCompat.reinterpretAs(param1 , B2CircleShape);
            this/*b2internal::*/.m_p.SetV(_loc2_/*b2internal::*/.m_p);
         }
      }
      
      override public function TestPoint(param1:B2Transform, param2:B2Vec2) : Bool
      {
         var _loc3_= param1.R;
         var _loc4_= param1.position.x + (_loc3_.col1.x * this/*b2internal::*/.m_p.x + _loc3_.col2.x * this/*b2internal::*/.m_p.y);
         var _loc5_= param1.position.y + (_loc3_.col1.y * this/*b2internal::*/.m_p.x + _loc3_.col2.y * this/*b2internal::*/.m_p.y);
         _loc4_ = param2.x - _loc4_;
         _loc5_ = param2.y - _loc5_;
         return _loc4_ * _loc4_ + _loc5_ * _loc5_ <= /*b2internal::*/m_radius * /*b2internal::*/m_radius;
      }
      
      override public function RayCast(param1:B2RayCastOutput, param2:B2RayCastInput, param3:B2Transform) : Bool
      {
         var _loc8_= Math.NaN;
         var _loc4_= param3.R;
         var _loc5_= param3.position.x + (_loc4_.col1.x * this/*b2internal::*/.m_p.x + _loc4_.col2.x * this/*b2internal::*/.m_p.y);
         var _loc6_= param3.position.y + (_loc4_.col1.y * this/*b2internal::*/.m_p.x + _loc4_.col2.y * this/*b2internal::*/.m_p.y);
         var _loc7_= param2.p1.x - _loc5_;
         _loc8_ = param2.p1.y - _loc6_;
         var _loc9_= _loc7_ * _loc7_ + _loc8_ * _loc8_ - /*b2internal::*/m_radius * /*b2internal::*/m_radius;
         var _loc10_= param2.p2.x - param2.p1.x;
         var _loc11_= param2.p2.y - param2.p1.y;
         var _loc12_= _loc7_ * _loc10_ + _loc8_ * _loc11_;
         var _loc13_= _loc10_ * _loc10_ + _loc11_ * _loc11_;
         var _loc14_= _loc12_ * _loc12_ - _loc13_ * _loc9_;
         if(_loc14_ < 0 || _loc13_ < ASCompat.MIN_FLOAT)
         {
            return false;
         }
         var _loc15_= -(_loc12_ + Math.sqrt(_loc14_));
         if(0 <= _loc15_ && _loc15_ <= param2.maxFraction * _loc13_)
         {
            _loc15_ /= _loc13_;
            param1.fraction = _loc15_;
            param1.normal.x = _loc7_ + _loc15_ * _loc10_;
            param1.normal.y = _loc8_ + _loc15_ * _loc11_;
            param1.normal.Normalize();
            return true;
         }
         return false;
      }
      
      override public function ComputeAABB(param1:B2AABB, param2:B2Transform) 
      {
         var _loc3_= param2.R;
         var _loc4_= param2.position.x + (_loc3_.col1.x * this/*b2internal::*/.m_p.x + _loc3_.col2.x * this/*b2internal::*/.m_p.y);
         var _loc5_= param2.position.y + (_loc3_.col1.y * this/*b2internal::*/.m_p.x + _loc3_.col2.y * this/*b2internal::*/.m_p.y);
         param1.lowerBound.Set(_loc4_ - /*b2internal::*/m_radius,_loc5_ - /*b2internal::*/m_radius);
         param1.upperBound.Set(_loc4_ + /*b2internal::*/m_radius,_loc5_ + /*b2internal::*/m_radius);
      }
      
      override public function ComputeMass(param1:B2MassData, param2:Float) 
      {
         param1.mass = param2 * B2Settings.b2_pi * /*b2internal::*/m_radius * /*b2internal::*/m_radius;
         param1.center.SetV(this/*b2internal::*/.m_p);
         param1.I = param1.mass * (0.5 * /*b2internal::*/m_radius * /*b2internal::*/m_radius + (this/*b2internal::*/.m_p.x * this/*b2internal::*/.m_p.x + this/*b2internal::*/.m_p.y * this/*b2internal::*/.m_p.y));
      }
      
      override public function ComputeSubmergedArea(param1:B2Vec2, param2:Float, param3:B2Transform, param4:B2Vec2) : Float
      {
         var _loc9_= Math.NaN;
         var _loc5_= B2Math.MulX(param3,this/*b2internal::*/.m_p);
         var _loc6_= -(B2Math.Dot(param1,_loc5_) - param2);
         if(_loc6_ < -/*b2internal::*/m_radius + ASCompat.MIN_FLOAT)
         {
            return 0;
         }
         if(_loc6_ > /*b2internal::*/m_radius)
         {
            param4.SetV(_loc5_);
            return Math.PI * /*b2internal::*/m_radius * /*b2internal::*/m_radius;
         }
         var _loc7_= /*b2internal::*/m_radius * /*b2internal::*/m_radius;
         var _loc8_= _loc6_ * _loc6_;
         _loc9_ = _loc7_ * (Math.asin(_loc6_ / /*b2internal::*/m_radius) + Math.PI / 2) + _loc6_ * Math.sqrt(_loc7_ - _loc8_);
         var _loc10_= -2 / 3 * Math.pow(_loc7_ - _loc8_,1.5) / _loc9_;
         param4.x = _loc5_.x + param1.x * _loc10_;
         param4.y = _loc5_.y + param1.y * _loc10_;
         return _loc9_;
      }
      
      public function GetLocalPosition() : B2Vec2
      {
         return this/*b2internal::*/.m_p;
      }
      
      public function SetLocalPosition(param1:B2Vec2) 
      {
         this/*b2internal::*/.m_p.SetV(param1);
      }
      
      public function GetRadius() : Float
      {
         return /*b2internal::*/m_radius;
      }
      
      public function SetRadius(param1:Float) 
      {
         /*b2internal::*/m_radius = param1;
      }
   }


