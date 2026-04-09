package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Body;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2PrismaticJointDef extends B2JointDef
   {
      
      public var localAnchorA:B2Vec2 = new B2Vec2();
      
      public var localAnchorB:B2Vec2 = new B2Vec2();
      
      public var localAxisA:B2Vec2 = new B2Vec2();
      
      public var referenceAngle:Float = Math.NaN;
      
      public var enableLimit:Bool = false;
      
      public var lowerTranslation:Float = Math.NaN;
      
      public var upperTranslation:Float = Math.NaN;
      
      public var enableMotor:Bool = false;
      
      public var maxMotorForce:Float = Math.NaN;
      
      public var motorSpeed:Float = Math.NaN;
      
      public function new()
      {
         super();
         type = B2Joint/*b2internal::*/.e_prismaticJoint;
         this.localAxisA.Set(1,0);
         this.referenceAngle = 0;
         this.enableLimit = false;
         this.lowerTranslation = 0;
         this.upperTranslation = 0;
         this.enableMotor = false;
         this.maxMotorForce = 0;
         this.motorSpeed = 0;
      }
      
      public function Initialize(param1:B2Body, param2:B2Body, param3:B2Vec2, param4:B2Vec2) 
      {
         bodyA = param1;
         bodyB = param2;
         this.localAnchorA = bodyA.GetLocalPoint(param3);
         this.localAnchorB = bodyB.GetLocalPoint(param3);
         this.localAxisA = bodyA.GetLocalVector(param4);
         this.referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
      }
   }


