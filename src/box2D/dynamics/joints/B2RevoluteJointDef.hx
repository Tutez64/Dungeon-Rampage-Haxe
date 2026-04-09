package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Body;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2RevoluteJointDef extends B2JointDef
   {
      
      public var localAnchorA:B2Vec2 = new B2Vec2();
      
      public var localAnchorB:B2Vec2 = new B2Vec2();
      
      public var referenceAngle:Float = Math.NaN;
      
      public var enableLimit:Bool = false;
      
      public var lowerAngle:Float = Math.NaN;
      
      public var upperAngle:Float = Math.NaN;
      
      public var enableMotor:Bool = false;
      
      public var motorSpeed:Float = Math.NaN;
      
      public var maxMotorTorque:Float = Math.NaN;
      
      public function new()
      {
         super();
         type = B2Joint/*b2internal::*/.e_revoluteJoint;
         this.localAnchorA.Set(0,0);
         this.localAnchorB.Set(0,0);
         this.referenceAngle = 0;
         this.lowerAngle = 0;
         this.upperAngle = 0;
         this.maxMotorTorque = 0;
         this.motorSpeed = 0;
         this.enableLimit = false;
         this.enableMotor = false;
      }
      
      public function Initialize(param1:B2Body, param2:B2Body, param3:B2Vec2) 
      {
         bodyA = param1;
         bodyB = param2;
         this.localAnchorA = bodyA.GetLocalPoint(param3);
         this.localAnchorB = bodyB.GetLocalPoint(param3);
         this.referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
      }
   }


