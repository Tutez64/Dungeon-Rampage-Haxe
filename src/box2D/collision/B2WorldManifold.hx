package box2D.collision
;
   import box2D.common.*;
   import box2D.common.math.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2WorldManifold
   {
      
      public var m_normal:B2Vec2 = new B2Vec2();
      
      public var m_points:Vector<B2Vec2>;
      
      public function new()
      {
         
         this.m_points = new Vector<B2Vec2>((B2Settings.b2_maxManifoldPoints : UInt));
         var _loc1_= 0;
         while(_loc1_ < B2Settings.b2_maxManifoldPoints)
         {
            this.m_points[_loc1_] = new B2Vec2();
            _loc1_++;
         }
      }
      
      public function Initialize(param1:B2Manifold, param2:B2Transform, param3:Float, param4:B2Transform, param5:Float) 
      {
         var _loc6_= 0;
         var _loc7_:B2Vec2 = null;
         var _loc8_:B2Mat22 = null;
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
         var _loc22_= Math.NaN;
         var _loc23_= Math.NaN;
         var _loc24_= Math.NaN;
         var _loc25_= Math.NaN;
         var _loc26_= Math.NaN;
         if(param1.m_pointCount == 0)
         {
            return;
         }
         switch(param1.m_type)
         {
            case B2Manifold.e_circles:
               _loc8_ = param2.R;
               _loc7_ = param1.m_localPoint;
               _loc15_ = param2.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc16_ = param2.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = param4.R;
               _loc7_ = param1.m_points[0].m_localPoint;
               _loc17_ = param4.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc18_ = param4.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc19_ = _loc17_ - _loc15_;
               _loc20_ = _loc18_ - _loc16_;
               _loc21_ = _loc19_ * _loc19_ + _loc20_ * _loc20_;
               if(_loc21_ > ASCompat.MIN_FLOAT * ASCompat.MIN_FLOAT)
               {
                  _loc26_ = Math.sqrt(_loc21_);
                  this.m_normal.x = _loc19_ / _loc26_;
                  this.m_normal.y = _loc20_ / _loc26_;
               }
               else
               {
                  this.m_normal.x = 1;
                  this.m_normal.y = 0;
               }
               _loc22_ = _loc15_ + param3 * this.m_normal.x;
               _loc23_ = _loc16_ + param3 * this.m_normal.y;
               _loc24_ = _loc17_ - param5 * this.m_normal.x;
               _loc25_ = _loc18_ - param5 * this.m_normal.y;
               this.m_points[0].x = 0.5 * (_loc22_ + _loc24_);
               this.m_points[0].y = 0.5 * (_loc23_ + _loc25_);
               
            case B2Manifold.e_faceA:
               _loc8_ = param2.R;
               _loc7_ = param1.m_localPlaneNormal;
               _loc9_ = _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc10_ = _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = param2.R;
               _loc7_ = param1.m_localPoint;
               _loc11_ = param2.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc12_ = param2.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               this.m_normal.x = _loc9_;
               this.m_normal.y = _loc10_;
               _loc6_ = 0;
               while(_loc6_ < param1.m_pointCount)
               {
                  _loc8_ = param4.R;
                  _loc7_ = param1.m_points[_loc6_].m_localPoint;
                  _loc13_ = param4.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
                  _loc14_ = param4.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
                  this.m_points[_loc6_].x = _loc13_ + 0.5 * (param3 - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - param5) * _loc9_;
                  this.m_points[_loc6_].y = _loc14_ + 0.5 * (param3 - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - param5) * _loc10_;
                  _loc6_++;
               }
               
            case B2Manifold.e_faceB:
               _loc8_ = param4.R;
               _loc7_ = param1.m_localPlaneNormal;
               _loc9_ = _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc10_ = _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = param4.R;
               _loc7_ = param1.m_localPoint;
               _loc11_ = param4.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc12_ = param4.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               this.m_normal.x = -_loc9_;
               this.m_normal.y = -_loc10_;
               _loc6_ = 0;
               while(_loc6_ < param1.m_pointCount)
               {
                  _loc8_ = param2.R;
                  _loc7_ = param1.m_points[_loc6_].m_localPoint;
                  _loc13_ = param2.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
                  _loc14_ = param2.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
                  this.m_points[_loc6_].x = _loc13_ + 0.5 * (param5 - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - param3) * _loc9_;
                  this.m_points[_loc6_].y = _loc14_ + 0.5 * (param5 - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - param3) * _loc10_;
                  _loc6_++;
               }
         }
      }
   }


