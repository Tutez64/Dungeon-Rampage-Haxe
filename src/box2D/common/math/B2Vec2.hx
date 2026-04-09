package box2D.common.math
;
    class B2Vec2
   {
      
      public var x:Float = Math.NaN;
      
      public var y:Float = Math.NaN;
      
      public function new(param1:Float = 0, param2:Float = 0)
      {
         
         this.x = param1;
         this.y = param2;
      }
      
      public static function Make(param1:Float, param2:Float) : B2Vec2
      {
         return new B2Vec2(param1,param2);
      }
      
      public function SetZero() 
      {
         this.x = 0;
         this.y = 0;
      }
      
      public function Set(param1:Float = 0, param2:Float = 0) 
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function SetV(param1:B2Vec2) 
      {
         this.x = param1.x;
         this.y = param1.y;
      }
      
      public function GetNegative() : B2Vec2
      {
         return new B2Vec2(-this.x,-this.y);
      }
      
      public function NegativeSelf() 
      {
         this.x = -this.x;
         this.y = -this.y;
      }
      
      public function Copy() : B2Vec2
      {
         return new B2Vec2(this.x,this.y);
      }
      
      public function Add(param1:B2Vec2) 
      {
         this.x += param1.x;
         this.y += param1.y;
      }
      
      public function Subtract(param1:B2Vec2) 
      {
         this.x -= param1.x;
         this.y -= param1.y;
      }
      
      public function Multiply(param1:Float) 
      {
         this.x *= param1;
         this.y *= param1;
      }
      
      public function MulM(param1:B2Mat22) 
      {
         var _loc2_= this.x;
         this.x = param1.col1.x * _loc2_ + param1.col2.x * this.y;
         this.y = param1.col1.y * _loc2_ + param1.col2.y * this.y;
      }
      
      public function MulTM(param1:B2Mat22) 
      {
         var _loc2_= B2Math.Dot(this,param1.col1);
         this.y = B2Math.Dot(this,param1.col2);
         this.x = _loc2_;
      }
      
      public function CrossVF(param1:Float) 
      {
         var _loc2_= this.x;
         this.x = param1 * this.y;
         this.y = -param1 * _loc2_;
      }
      
      public function CrossFV(param1:Float) 
      {
         var _loc2_= this.x;
         this.x = -param1 * this.y;
         this.y = param1 * _loc2_;
      }
      
      public function MinV(param1:B2Vec2) 
      {
         this.x = this.x < param1.x ? this.x : param1.x;
         this.y = this.y < param1.y ? this.y : param1.y;
      }
      
      public function MaxV(param1:B2Vec2) 
      {
         this.x = this.x > param1.x ? this.x : param1.x;
         this.y = this.y > param1.y ? this.y : param1.y;
      }
      
      public function Abs() 
      {
         if(this.x < 0)
         {
            this.x = -this.x;
         }
         if(this.y < 0)
         {
            this.y = -this.y;
         }
      }
      
      public function Length() : Float
      {
         return Math.sqrt(this.x * this.x + this.y * this.y);
      }
      
      public function LengthSquared() : Float
      {
         return this.x * this.x + this.y * this.y;
      }
      
      public function Normalize() : Float
      {
         var _loc1_= Math.sqrt(this.x * this.x + this.y * this.y);
         if(_loc1_ < ASCompat.MIN_FLOAT)
         {
            return 0;
         }
         var _loc2_= 1 / _loc1_;
         this.x *= _loc2_;
         this.y *= _loc2_;
         return _loc1_;
      }
      
      public function IsValid() : Bool
      {
         return B2Math.IsValid(this.x) && B2Math.IsValid(this.y);
      }
   }


