package box2D.collision
;
   import box2D.collision.shapes.*;
   import box2D.common.*;
   import box2D.common.math.*;
   
   /*internal*/ class B2SeparationFunction
   {
      
      public static inline final e_points= 1;
      
      public static inline final e_faceA= 2;
      
      public static inline final e_faceB= 4;
      
      public var m_proxyA:B2DistanceProxy;
      
      public var m_proxyB:B2DistanceProxy;
      
      public var m_type:Int = 0;
      
      public var m_localPoint:B2Vec2 = new B2Vec2();
      
      public var m_axis:B2Vec2 = new B2Vec2();
      
      public function new()
      {
         
      }
      
      public function Initialize(param1:B2SimplexCache, param2:B2DistanceProxy, param3:B2Transform, param4:B2DistanceProxy, param5:B2Transform) 
      {
         var _loc7_:B2Vec2 = null;
         var _loc8_:B2Vec2 = null;
         var _loc9_:B2Vec2 = null;
         var _loc10_:B2Vec2 = null;
         var _loc11_:B2Vec2 = null;
         var _loc12_:B2Vec2 = null;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         var _loc16_= Math.NaN;
         var _loc17_= Math.NaN;
         var _loc18_= Math.NaN;
         var _loc19_:B2Mat22 = null;
         var _loc20_:B2Vec2 = null;
         var _loc21_= Math.NaN;
         var _loc22_= Math.NaN;
         var _loc23_:B2Vec2 = null;
         var _loc24_:B2Vec2 = null;
         var _loc25_:B2Vec2 = null;
         var _loc26_:B2Vec2 = null;
         var _loc27_= Math.NaN;
         var _loc28_= Math.NaN;
         var _loc29_:B2Vec2 = null;
         var _loc30_= Math.NaN;
         var _loc31_= Math.NaN;
         var _loc32_= Math.NaN;
         var _loc33_= Math.NaN;
         var _loc34_= Math.NaN;
         this.m_proxyA = param2;
         this.m_proxyB = param4;
         var _loc6_:Int = param1.count;
         B2Settings.b2Assert(0 < _loc6_ && _loc6_ < 3);
         if(_loc6_ == 1)
         {
            this.m_type = e_points;
            _loc7_ = this.m_proxyA.GetVertex(param1.indexA[0]);
            _loc10_ = this.m_proxyB.GetVertex(param1.indexB[0]);
            _loc20_ = _loc7_;
            _loc19_ = param3.R;
            _loc13_ = param3.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc14_ = param3.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc20_ = _loc10_;
            _loc19_ = param5.R;
            _loc15_ = param5.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc16_ = param5.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            this.m_axis.x = _loc15_ - _loc13_;
            this.m_axis.y = _loc16_ - _loc14_;
            this.m_axis.Normalize();
         }
         else if(param1.indexB[0] == param1.indexB[1])
         {
            this.m_type = e_faceA;
            _loc8_ = this.m_proxyA.GetVertex(param1.indexA[0]);
            _loc9_ = this.m_proxyA.GetVertex(param1.indexA[1]);
            _loc10_ = this.m_proxyB.GetVertex(param1.indexB[0]);
            this.m_localPoint.x = 0.5 * (_loc8_.x + _loc9_.x);
            this.m_localPoint.y = 0.5 * (_loc8_.y + _loc9_.y);
            this.m_axis = B2Math.CrossVF(B2Math.SubtractVV(_loc9_,_loc8_),1);
            this.m_axis.Normalize();
            _loc20_ = this.m_axis;
            _loc19_ = param3.R;
            _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
            _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
            _loc20_ = this.m_localPoint;
            _loc19_ = param3.R;
            _loc13_ = param3.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc14_ = param3.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc20_ = _loc10_;
            _loc19_ = param5.R;
            _loc15_ = param5.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc16_ = param5.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc21_ = (_loc15_ - _loc13_) * _loc17_ + (_loc16_ - _loc14_) * _loc18_;
            if(_loc21_ < 0)
            {
               this.m_axis.NegativeSelf();
            }
         }
         else if(param1.indexA[0] == param1.indexA[0])
         {
            this.m_type = e_faceB;
            _loc11_ = this.m_proxyB.GetVertex(param1.indexB[0]);
            _loc12_ = this.m_proxyB.GetVertex(param1.indexB[1]);
            _loc7_ = this.m_proxyA.GetVertex(param1.indexA[0]);
            this.m_localPoint.x = 0.5 * (_loc11_.x + _loc12_.x);
            this.m_localPoint.y = 0.5 * (_loc11_.y + _loc12_.y);
            this.m_axis = B2Math.CrossVF(B2Math.SubtractVV(_loc12_,_loc11_),1);
            this.m_axis.Normalize();
            _loc20_ = this.m_axis;
            _loc19_ = param5.R;
            _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
            _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
            _loc20_ = this.m_localPoint;
            _loc19_ = param5.R;
            _loc15_ = param5.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc16_ = param5.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc20_ = _loc7_;
            _loc19_ = param3.R;
            _loc13_ = param3.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc14_ = param3.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc21_ = (_loc13_ - _loc15_) * _loc17_ + (_loc14_ - _loc16_) * _loc18_;
            if(_loc21_ < 0)
            {
               this.m_axis.NegativeSelf();
            }
         }
         else
         {
            _loc8_ = this.m_proxyA.GetVertex(param1.indexA[0]);
            _loc9_ = this.m_proxyA.GetVertex(param1.indexA[1]);
            _loc11_ = this.m_proxyB.GetVertex(param1.indexB[0]);
            _loc12_ = this.m_proxyB.GetVertex(param1.indexB[1]);
            _loc23_ = B2Math.MulX(param3,_loc7_);
            _loc24_ = B2Math.MulMV(param3.R,B2Math.SubtractVV(_loc9_,_loc8_));
            _loc25_ = B2Math.MulX(param5,_loc10_);
            _loc26_ = B2Math.MulMV(param5.R,B2Math.SubtractVV(_loc12_,_loc11_));
            _loc27_ = _loc24_.x * _loc24_.x + _loc24_.y * _loc24_.y;
            _loc28_ = _loc26_.x * _loc26_.x + _loc26_.y * _loc26_.y;
            _loc29_ = B2Math.SubtractVV(_loc26_,_loc24_);
            _loc30_ = _loc24_.x * _loc29_.x + _loc24_.y * _loc29_.y;
            _loc31_ = _loc26_.x * _loc29_.x + _loc26_.y * _loc29_.y;
            _loc32_ = _loc24_.x * _loc26_.x + _loc24_.y * _loc26_.y;
            _loc33_ = _loc27_ * _loc28_ - _loc32_ * _loc32_;
            _loc21_ = 0;
            if(_loc33_ != 0)
            {
               _loc21_ = B2Math.Clamp((_loc32_ * _loc31_ - _loc30_ * _loc28_) / _loc33_,0,1);
            }
            _loc34_ = (_loc32_ * _loc21_ + _loc31_) / _loc28_;
            if(_loc34_ < 0)
            {
               _loc34_ = 0;
               _loc21_ = B2Math.Clamp((_loc32_ - _loc30_) / _loc27_,0,1);
            }
            _loc7_ = new B2Vec2();
            _loc7_.x = _loc8_.x + _loc21_ * (_loc9_.x - _loc8_.x);
            _loc7_.y = _loc8_.y + _loc21_ * (_loc9_.y - _loc8_.y);
            _loc10_ = new B2Vec2();
            _loc10_.x = _loc11_.x + _loc21_ * (_loc12_.x - _loc11_.x);
            _loc10_.y = _loc11_.y + _loc21_ * (_loc12_.y - _loc11_.y);
            if(_loc21_ == 0 || _loc21_ == 1)
            {
               this.m_type = e_faceB;
               this.m_axis = B2Math.CrossVF(B2Math.SubtractVV(_loc12_,_loc11_),1);
               this.m_axis.Normalize();
               this.m_localPoint = _loc10_;
               _loc20_ = this.m_axis;
               _loc19_ = param5.R;
               _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
               _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
               _loc20_ = this.m_localPoint;
               _loc19_ = param5.R;
               _loc15_ = param5.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc16_ = param5.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc20_ = _loc7_;
               _loc19_ = param3.R;
               _loc13_ = param3.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc14_ = param3.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc22_ = (_loc13_ - _loc15_) * _loc17_ + (_loc14_ - _loc16_) * _loc18_;
               if(_loc21_ < 0)
               {
                  this.m_axis.NegativeSelf();
               }
            }
            else
            {
               this.m_type = e_faceA;
               this.m_axis = B2Math.CrossVF(B2Math.SubtractVV(_loc9_,_loc8_),1);
               this.m_localPoint = _loc7_;
               _loc20_ = this.m_axis;
               _loc19_ = param3.R;
               _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
               _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
               _loc20_ = this.m_localPoint;
               _loc19_ = param3.R;
               _loc13_ = param3.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc14_ = param3.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc20_ = _loc10_;
               _loc19_ = param5.R;
               _loc15_ = param5.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc16_ = param5.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc22_ = (_loc15_ - _loc13_) * _loc17_ + (_loc16_ - _loc14_) * _loc18_;
               if(_loc21_ < 0)
               {
                  this.m_axis.NegativeSelf();
               }
            }
         }
      }
      
      public function Evaluate(param1:B2Transform, param2:B2Transform) : Float
      {
         var _loc3_:B2Vec2 = null;
         var _loc4_:B2Vec2 = null;
         var _loc5_:B2Vec2 = null;
         var _loc6_:B2Vec2 = null;
         var _loc7_:B2Vec2 = null;
         var _loc8_:B2Vec2 = null;
         var _loc9_= Math.NaN;
         var _loc10_:B2Vec2 = null;
         switch(this.m_type)
         {
            case e_points:
               _loc3_ = B2Math.MulTMV(param1.R,this.m_axis);
               _loc4_ = B2Math.MulTMV(param2.R,this.m_axis.GetNegative());
               _loc5_ = this.m_proxyA.GetSupportVertex(_loc3_);
               _loc6_ = this.m_proxyB.GetSupportVertex(_loc4_);
               _loc7_ = B2Math.MulX(param1,_loc5_);
               _loc8_ = B2Math.MulX(param2,_loc6_);
               return (_loc8_.x - _loc7_.x) * this.m_axis.x + (_loc8_.y - _loc7_.y) * this.m_axis.y;
            case e_faceA:
               _loc10_ = B2Math.MulMV(param1.R,this.m_axis);
               _loc7_ = B2Math.MulX(param1,this.m_localPoint);
               _loc4_ = B2Math.MulTMV(param2.R,_loc10_.GetNegative());
               _loc6_ = this.m_proxyB.GetSupportVertex(_loc4_);
               _loc8_ = B2Math.MulX(param2,_loc6_);
               return (_loc8_.x - _loc7_.x) * _loc10_.x + (_loc8_.y - _loc7_.y) * _loc10_.y;
            case e_faceB:
               _loc10_ = B2Math.MulMV(param2.R,this.m_axis);
               _loc8_ = B2Math.MulX(param2,this.m_localPoint);
               _loc3_ = B2Math.MulTMV(param1.R,_loc10_.GetNegative());
               _loc5_ = this.m_proxyA.GetSupportVertex(_loc3_);
               _loc7_ = B2Math.MulX(param1,_loc5_);
               return (_loc7_.x - _loc8_.x) * _loc10_.x + (_loc7_.y - _loc8_.y) * _loc10_.y;
            default:
               B2Settings.b2Assert(false);
               return 0;
         }
return Math.NaN;
      }
   }


