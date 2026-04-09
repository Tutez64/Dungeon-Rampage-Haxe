package box2D.dynamics
;
    class B2TimeStep
   {
      
      public var dt:Float = Math.NaN;
      
      public var inv_dt:Float = Math.NaN;
      
      public var dtRatio:Float = Math.NaN;
      
      public var velocityIterations:Int = 0;
      
      public var positionIterations:Int = 0;
      
      public var warmStarting:Bool = false;
      
      public function new()
      {
         
      }
      
      public function Set(param1:B2TimeStep) 
      {
         this.dt = param1.dt;
         this.inv_dt = param1.inv_dt;
         this.positionIterations = param1.positionIterations;
         this.velocityIterations = param1.velocityIterations;
         this.warmStarting = param1.warmStarting;
      }
   }


