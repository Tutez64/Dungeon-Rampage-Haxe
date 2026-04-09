package box2D.dynamics.contacts
;
   import box2D.common.math.B2Vec2;
   
    class B2ContactConstraintPoint
   {
      
      public var localPoint:B2Vec2 = new B2Vec2();
      
      public var rA:B2Vec2 = new B2Vec2();
      
      public var rB:B2Vec2 = new B2Vec2();
      
      public var normalImpulse:Float = Math.NaN;
      
      public var tangentImpulse:Float = Math.NaN;
      
      public var normalMass:Float = Math.NaN;
      
      public var tangentMass:Float = Math.NaN;
      
      public var equalizedMass:Float = Math.NaN;
      
      public var velocityBias:Float = Math.NaN;
      
      public function new()
      {
         
      }
   }


