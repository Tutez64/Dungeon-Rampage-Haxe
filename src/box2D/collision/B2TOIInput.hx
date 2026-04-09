package box2D.collision
;
   import box2D.common.math.B2Sweep;
   
    class B2TOIInput
   {
      
      public var proxyA:B2DistanceProxy = new B2DistanceProxy();
      
      public var proxyB:B2DistanceProxy = new B2DistanceProxy();
      
      public var sweepA:B2Sweep = new B2Sweep();
      
      public var sweepB:B2Sweep = new B2Sweep();
      
      public var tolerance:Float = Math.NaN;
      
      public function new()
      {
         
      }
   }


