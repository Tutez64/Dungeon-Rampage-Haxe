package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Body;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2DistanceJointDef extends B2JointDef
   {
      
      public var localAnchorA:B2Vec2 = new B2Vec2();
      
      public var localAnchorB:B2Vec2 = new B2Vec2();
      
      public var length:Float = Math.NaN;
      
      public var frequencyHz:Float = Math.NaN;
      
      public var dampingRatio:Float = Math.NaN;
      
      public function new()
      {
         super();
         type = B2Joint/*b2internal::*/.e_distanceJoint;
         this.length = 1;
         this.frequencyHz = 0;
         this.dampingRatio = 0;
      }
      
      public function Initialize(param1:B2Body, param2:B2Body, param3:B2Vec2, param4:B2Vec2) 
      {
         bodyA = param1;
         bodyB = param2;
         this.localAnchorA.SetV(bodyA.GetLocalPoint(param3));
         this.localAnchorB.SetV(bodyB.GetLocalPoint(param4));
         var _loc5_= param4.x - param3.x;
         var _loc6_= param4.y - param3.y;
         this.length = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
         this.frequencyHz = 0;
         this.dampingRatio = 0;
      }
   }


