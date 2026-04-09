package box2D.dynamics
;
   import box2D.collision.shapes.B2Shape;
   
    class B2FixtureDef
   {
      
      public var shape:B2Shape;
      
      public var userData:ASAny;
      
      public var friction:Float = Math.NaN;
      
      public var restitution:Float = Math.NaN;
      
      public var density:Float = Math.NaN;
      
      public var isSensor:Bool = false;
      
      public var filter:B2FilterData = new B2FilterData();
      
      public function new()
      {
         
         this.shape = null;
         this.userData = null;
         this.friction = 0.2;
         this.restitution = 0;
         this.density = 0;
         this.filter.categoryBits = (1 : UInt);
         this.filter.maskBits = (65535 : UInt);
         this.filter.groupIndex = 0;
         this.isSensor = false;
      }
   }


