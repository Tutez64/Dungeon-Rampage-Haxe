package box2D.collision
;
   import box2D.common.math.B2Transform;
   
    class B2DistanceInput
   {
      
      public var proxyA:B2DistanceProxy;
      
      public var proxyB:B2DistanceProxy;
      
      public var transformA:B2Transform;
      
      public var transformB:B2Transform;
      
      public var useRadii:Bool = false;
      
      public function new()
      {
         
      }
   }


