package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2MouseJointDef extends B2JointDef
   {
      
      public var target:B2Vec2 = new B2Vec2();
      
      public var maxForce:Float = Math.NaN;
      
      public var frequencyHz:Float = Math.NaN;
      
      public var dampingRatio:Float = Math.NaN;
      
      public function new()
      {
         super();
         type = B2Joint/*b2internal::*/.e_mouseJoint;
         this.maxForce = 0;
         this.frequencyHz = 5;
         this.dampingRatio = 0.7;
      }
   }


