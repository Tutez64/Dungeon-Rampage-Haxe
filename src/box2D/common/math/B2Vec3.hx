package box2D.common.math
;
    class B2Vec3
   {
      
      public var x:Float = Math.NaN;
      
      public var y:Float = Math.NaN;
      
      public var z:Float = Math.NaN;
      
      public function new(param1:Float = 0, param2:Float = 0, param3:Float = 0)
      {
         
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
      
      public function SetZero() 
      {
         this.x = this.y = this.z = 0;
      }
      
      public function Set(param1:Float, param2:Float, param3:Float) 
      {
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
      
      public function SetV(param1:B2Vec3) 
      {
         this.x = param1.x;
         this.y = param1.y;
         this.z = param1.z;
      }
      
      public function GetNegative() : B2Vec3
      {
         return new B2Vec3(-this.x,-this.y,-this.z);
      }
      
      public function NegativeSelf() 
      {
         this.x = -this.x;
         this.y = -this.y;
         this.z = -this.z;
      }
      
      public function Copy() : B2Vec3
      {
         return new B2Vec3(this.x,this.y,this.z);
      }
      
      public function Add(param1:B2Vec3) 
      {
         this.x += param1.x;
         this.y += param1.y;
         this.z += param1.z;
      }
      
      public function Subtract(param1:B2Vec3) 
      {
         this.x -= param1.x;
         this.y -= param1.y;
         this.z -= param1.z;
      }
      
      public function Multiply(param1:Float) 
      {
         this.x *= param1;
         this.y *= param1;
         this.z *= param1;
      }
   }


