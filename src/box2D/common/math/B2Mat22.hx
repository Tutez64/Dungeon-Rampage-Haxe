package box2D.common.math
;
    class B2Mat22
   {
      
      public var col1:B2Vec2 = new B2Vec2();
      
      public var col2:B2Vec2 = new B2Vec2();
      
      public function new()
      {
         
         this.col1.x = this.col2.y = 1;
      }
      
      public static function FromAngle(param1:Float) : B2Mat22
      {
         var _loc2_= new B2Mat22();
         _loc2_.Set(param1);
         return _loc2_;
      }
      
      public static function FromVV(param1:B2Vec2, param2:B2Vec2) : B2Mat22
      {
         var _loc3_= new B2Mat22();
         _loc3_.SetVV(param1,param2);
         return _loc3_;
      }
      
      public function Set(param1:Float) 
      {
         var _loc2_= Math.NaN;
         _loc2_ = Math.cos(param1);
         var _loc3_= Math.sin(param1);
         this.col1.x = _loc2_;
         this.col2.x = -_loc3_;
         this.col1.y = _loc3_;
         this.col2.y = _loc2_;
      }
      
      public function SetVV(param1:B2Vec2, param2:B2Vec2) 
      {
         this.col1.SetV(param1);
         this.col2.SetV(param2);
      }
      
      public function Copy() : B2Mat22
      {
         var _loc1_= new B2Mat22();
         _loc1_.SetM(this);
         return _loc1_;
      }
      
      public function SetM(param1:B2Mat22) 
      {
         this.col1.SetV(param1.col1);
         this.col2.SetV(param1.col2);
      }
      
      public function AddM(param1:B2Mat22) 
      {
         this.col1.x += param1.col1.x;
         this.col1.y += param1.col1.y;
         this.col2.x += param1.col2.x;
         this.col2.y += param1.col2.y;
      }
      
      public function SetIdentity() 
      {
         this.col1.x = 1;
         this.col2.x = 0;
         this.col1.y = 0;
         this.col2.y = 1;
      }
      
      public function SetZero() 
      {
         this.col1.x = 0;
         this.col2.x = 0;
         this.col1.y = 0;
         this.col2.y = 0;
      }
      
      public function GetAngle() : Float
      {
         return Math.atan2(this.col1.y,this.col1.x);
      }
      
      public function GetInverse(param1:B2Mat22) : B2Mat22
      {
         var _loc3_= Math.NaN;
         var _loc6_= Math.NaN;
         var _loc2_= this.col1.x;
         _loc3_ = this.col2.x;
         var _loc4_= this.col1.y;
         var _loc5_= this.col2.y;
         _loc6_ = _loc2_ * _loc5_ - _loc3_ * _loc4_;
         if(_loc6_ != 0)
         {
            _loc6_ = 1 / _loc6_;
         }
         param1.col1.x = _loc6_ * _loc5_;
         param1.col2.x = -_loc6_ * _loc3_;
         param1.col1.y = -_loc6_ * _loc4_;
         param1.col2.y = _loc6_ * _loc2_;
         return param1;
      }
      
      public function Solve(param1:B2Vec2, param2:Float, param3:Float) : B2Vec2
      {
         var _loc4_= this.col1.x;
         var _loc5_= this.col2.x;
         var _loc6_= this.col1.y;
         var _loc7_= this.col2.y;
         var _loc8_= _loc4_ * _loc7_ - _loc5_ * _loc6_;
         if(_loc8_ != 0)
         {
            _loc8_ = 1 / _loc8_;
         }
         param1.x = _loc8_ * (_loc7_ * param2 - _loc5_ * param3);
         param1.y = _loc8_ * (_loc4_ * param3 - _loc6_ * param2);
         return param1;
      }
      
      public function Abs() 
      {
         this.col1.Abs();
         this.col2.Abs();
      }
   }


