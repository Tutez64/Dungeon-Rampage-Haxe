package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Body;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2WeldJointDef extends B2JointDef
   {
      
      public var localAnchorA:B2Vec2 = new B2Vec2();
      
      public var localAnchorB:B2Vec2 = new B2Vec2();
      
      public var referenceAngle:Float = Math.NaN;
      
      public function new()
      {
         super();
         type = B2Joint/*b2internal::*/.e_weldJoint;
         this.referenceAngle = 0;
      }
      
      public function Initialize(param1:B2Body, param2:B2Body, param3:B2Vec2) 
      {
         bodyA = param1;
         bodyB = param2;
         this.localAnchorA.SetV(bodyA.GetLocalPoint(param3));
         this.localAnchorB.SetV(bodyB.GetLocalPoint(param3));
         this.referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
      }
   }


