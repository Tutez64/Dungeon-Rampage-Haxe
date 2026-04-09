package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   
    class B2Jacobian
   {
      
      public var linearA:B2Vec2 = new B2Vec2();
      
      public var angularA:Float = Math.NaN;
      
      public var linearB:B2Vec2 = new B2Vec2();
      
      public var angularB:Float = Math.NaN;
      
      public function new()
      {
         
      }
      
      public function SetZero() 
      {
         this.linearA.SetZero();
         this.angularA = 0;
         this.linearB.SetZero();
         this.angularB = 0;
      }
      
      public function Set(param1:B2Vec2, param2:Float, param3:B2Vec2, param4:Float) 
      {
         this.linearA.SetV(param1);
         this.angularA = param2;
         this.linearB.SetV(param3);
         this.angularB = param4;
      }
      
      public function Compute(param1:B2Vec2, param2:Float, param3:B2Vec2, param4:Float) : Float
      {
         return this.linearA.x * param1.x + this.linearA.y * param1.y + this.angularA * param2 + (this.linearB.x * param3.x + this.linearB.y * param3.y) + this.angularB * param4;
      }
   }


