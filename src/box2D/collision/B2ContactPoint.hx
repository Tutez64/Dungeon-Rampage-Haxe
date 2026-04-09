package box2D.collision
;
   import box2D.collision.shapes.B2Shape;
   import box2D.common.math.B2Vec2;
   
    class B2ContactPoint
   {
      
      public var shape1:B2Shape;
      
      public var shape2:B2Shape;
      
      public var position:B2Vec2 = new B2Vec2();
      
      public var velocity:B2Vec2 = new B2Vec2();
      
      public var normal:B2Vec2 = new B2Vec2();
      
      public var separation:Float = Math.NaN;
      
      public var friction:Float = Math.NaN;
      
      public var restitution:Float = Math.NaN;
      
      public var id:B2ContactID = new B2ContactID();
      
      public function new()
      {
         
      }
   }


