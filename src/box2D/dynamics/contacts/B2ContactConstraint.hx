package box2D.dynamics.contacts
;
   import box2D.collision.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2ContactConstraint
   {
      
      public var points:Vector<B2ContactConstraintPoint>;
      
      public var localPlaneNormal:B2Vec2 = new B2Vec2();
      
      public var localPoint:B2Vec2 = new B2Vec2();
      
      public var normal:B2Vec2 = new B2Vec2();
      
      public var normalMass:B2Mat22 = new B2Mat22();
      
      public var K:B2Mat22 = new B2Mat22();
      
      public var bodyA:B2Body;
      
      public var bodyB:B2Body;
      
      public var type:Int = 0;
      
      public var radius:Float = Math.NaN;
      
      public var friction:Float = Math.NaN;
      
      public var restitution:Float = Math.NaN;
      
      public var pointCount:Int = 0;
      
      public var manifold:B2Manifold;
      
      public function new()
      {
         
         this.points = new Vector<B2ContactConstraintPoint>((B2Settings.b2_maxManifoldPoints : UInt));
         var _loc1_= 0;
         while(_loc1_ < B2Settings.b2_maxManifoldPoints)
         {
            this.points[_loc1_] = new B2ContactConstraintPoint();
            _loc1_++;
         }
      }
   }


