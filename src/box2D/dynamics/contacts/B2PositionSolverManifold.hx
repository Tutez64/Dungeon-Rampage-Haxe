package box2D.dynamics.contacts
;
   import box2D.collision.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
   /*internal*/ class B2PositionSolverManifold
   {
      
      static var circlePointA:B2Vec2 = new B2Vec2();
      
      static var circlePointB:B2Vec2 = new B2Vec2();
      
      public var m_normal:B2Vec2;
      
      public var m_points:Vector<B2Vec2>;
      
      public var m_separations:Vector<Float>;
      
      public function new()
      {
         
         this.m_normal = new B2Vec2();
         this.m_separations = new Vector<Float>((B2Settings.b2_maxManifoldPoints : UInt));
         this.m_points = new Vector<B2Vec2>((B2Settings.b2_maxManifoldPoints : UInt));
         var _loc1_= 0;
         while(_loc1_ < B2Settings.b2_maxManifoldPoints)
         {
            this.m_points[_loc1_] = new B2Vec2();
            _loc1_++;
         }
      }
      
      public function Initialize(param1:B2ContactConstraint) 
      {
         var _loc2_= 0;
         var _loc3_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc5_:B2Mat22 = null;
         var _loc6_:B2Vec2 = null;
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
         B2Settings.b2Assert(param1.pointCount > 0);
         switch(param1.type)
         {
            case B2Manifold.e_circles:
               _loc5_ = param1.bodyA/*b2internal::*/.m_xf.R;
               _loc6_ = param1.localPoint;
               _loc9_ = param1.bodyA/*b2internal::*/.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc10_ = param1.bodyA/*b2internal::*/.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = param1.bodyB/*b2internal::*/.m_xf.R;
               _loc6_ = param1.points[0].localPoint;
               _loc11_ = param1.bodyB/*b2internal::*/.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc12_ = param1.bodyB/*b2internal::*/.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc13_ = _loc11_ - _loc9_;
               _loc14_ = _loc12_ - _loc10_;
               _loc15_ = _loc13_ * _loc13_ + _loc14_ * _loc14_;
               if(_loc15_ > ASCompat.MIN_FLOAT * ASCompat.MIN_FLOAT)
               {
                  _loc16_ = Math.sqrt(_loc15_);
                  this.m_normal.x = _loc13_ / _loc16_;
                  this.m_normal.y = _loc14_ / _loc16_;
               }
               else
               {
                  this.m_normal.x = 1;
                  this.m_normal.y = 0;
               }
               this.m_points[0].x = 0.5 * (_loc9_ + _loc11_);
               this.m_points[0].y = 0.5 * (_loc10_ + _loc12_);
               this.m_separations[0] = _loc13_ * this.m_normal.x + _loc14_ * this.m_normal.y - param1.radius;
               
            case B2Manifold.e_faceA:
               _loc5_ = param1.bodyA/*b2internal::*/.m_xf.R;
               _loc6_ = param1.localPlaneNormal;
               this.m_normal.x = _loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y;
               this.m_normal.y = _loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y;
               _loc5_ = param1.bodyA/*b2internal::*/.m_xf.R;
               _loc6_ = param1.localPoint;
               _loc7_ = param1.bodyA/*b2internal::*/.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc8_ = param1.bodyA/*b2internal::*/.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = param1.bodyB/*b2internal::*/.m_xf.R;
               _loc2_ = 0;
               while(_loc2_ < param1.pointCount)
               {
                  _loc6_ = param1.points[_loc2_].localPoint;
                  _loc3_ = param1.bodyB/*b2internal::*/.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
                  _loc4_ = param1.bodyB/*b2internal::*/.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
                  this.m_separations[_loc2_] = (_loc3_ - _loc7_) * this.m_normal.x + (_loc4_ - _loc8_) * this.m_normal.y - param1.radius;
                  this.m_points[_loc2_].x = _loc3_;
                  this.m_points[_loc2_].y = _loc4_;
                  _loc2_++;
               }
               
            case B2Manifold.e_faceB:
               _loc5_ = param1.bodyB/*b2internal::*/.m_xf.R;
               _loc6_ = param1.localPlaneNormal;
               this.m_normal.x = _loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y;
               this.m_normal.y = _loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y;
               _loc5_ = param1.bodyB/*b2internal::*/.m_xf.R;
               _loc6_ = param1.localPoint;
               _loc7_ = param1.bodyB/*b2internal::*/.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc8_ = param1.bodyB/*b2internal::*/.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = param1.bodyA/*b2internal::*/.m_xf.R;
               _loc2_ = 0;
               while(_loc2_ < param1.pointCount)
               {
                  _loc6_ = param1.points[_loc2_].localPoint;
                  _loc3_ = param1.bodyA/*b2internal::*/.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
                  _loc4_ = param1.bodyA/*b2internal::*/.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
                  this.m_separations[_loc2_] = (_loc3_ - _loc7_) * this.m_normal.x + (_loc4_ - _loc8_) * this.m_normal.y - param1.radius;
                  this.m_points[_loc2_].Set(_loc3_,_loc4_);
                  _loc2_++;
               }
               this.m_normal.x *= -1;
               this.m_normal.y *= -1;
         }
      }
   }


