package box2D.dynamics
;
   import box2D.common.math.B2Vec2;
   
    class B2BodyDef
   {
      
      public var type:UInt = 0;
      
      public var position:B2Vec2 = new B2Vec2();
      
      public var angle:Float = Math.NaN;
      
      public var linearVelocity:B2Vec2 = new B2Vec2();
      
      public var angularVelocity:Float = Math.NaN;
      
      public var linearDamping:Float = Math.NaN;
      
      public var angularDamping:Float = Math.NaN;
      
      public var allowSleep:Bool = false;
      
      public var awake:Bool = false;
      
      public var fixedRotation:Bool = false;
      
      public var bullet:Bool = false;
      
      public var active:Bool = false;
      
      public var userData:ASAny;
      
      public var inertiaScale:Float = Math.NaN;
      
      public function new()
      {
         
         this.userData = null;
         this.position.Set(0,0);
         this.angle = 0;
         this.linearVelocity.Set(0,0);
         this.angularVelocity = 0;
         this.linearDamping = 0;
         this.angularDamping = 0;
         this.allowSleep = true;
         this.awake = true;
         this.fixedRotation = false;
         this.bullet = false;
         this.type = B2Body.b2_staticBody;
         this.active = true;
         this.inertiaScale = 1;
      }
   }


