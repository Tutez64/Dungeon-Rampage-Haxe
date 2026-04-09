package box2D.collision
;
   import box2D.common.math.B2Vec2;
   
    class B2RayCastInput
   {
      
      public var p1:B2Vec2 = new B2Vec2();
      
      public var p2:B2Vec2 = new B2Vec2();
      
      public var maxFraction:Float = Math.NaN;
      
      public function new(param1:B2Vec2 = null, param2:B2Vec2 = null, param3:Float = 1)
      {
         
         if(param1 != null)
         {
            this.p1.SetV(param1);
         }
         if(param2 != null)
         {
            this.p2.SetV(param2);
         }
         this.maxFraction = param3;
      }
   }


