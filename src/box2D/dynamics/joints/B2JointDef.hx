package box2D.dynamics.joints
;
   import box2D.dynamics.B2Body;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2JointDef
   {
      
      public var type:Int = 0;
      
      public var userData:ASAny;
      
      public var bodyA:B2Body;
      
      public var bodyB:B2Body;
      
      public var collideConnected:Bool = false;
      
      public function new()
      {
         
         this.type = B2Joint/*b2internal::*/.e_unknownJoint;
         this.userData = null;
         this.bodyA = null;
         this.bodyB = null;
         this.collideConnected = false;
      }
   }


