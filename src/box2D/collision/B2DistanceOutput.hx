package box2D.collision
;
   import box2D.common.math.B2Vec2;
   
    class B2DistanceOutput
   {
      
      public var pointA:B2Vec2 = new B2Vec2();
      
      public var pointB:B2Vec2 = new B2Vec2();
      
      public var distance:Float = Math.NaN;
      
      public var iterations:Int = 0;
      
      public function new()
      {
         
      }
   }


