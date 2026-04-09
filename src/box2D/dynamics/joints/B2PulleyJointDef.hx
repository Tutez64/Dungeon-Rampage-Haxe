package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.B2Body;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2PulleyJointDef extends B2JointDef
   {
      
      public var groundAnchorA:B2Vec2 = new B2Vec2();
      
      public var groundAnchorB:B2Vec2 = new B2Vec2();
      
      public var localAnchorA:B2Vec2 = new B2Vec2();
      
      public var localAnchorB:B2Vec2 = new B2Vec2();
      
      public var lengthA:Float = Math.NaN;
      
      public var maxLengthA:Float = Math.NaN;
      
      public var lengthB:Float = Math.NaN;
      
      public var maxLengthB:Float = Math.NaN;
      
      public var ratio:Float = Math.NaN;
      
      public function new()
      {
         super();
         type = B2Joint/*b2internal::*/.e_pulleyJoint;
         this.groundAnchorA.Set(-1,1);
         this.groundAnchorB.Set(1,1);
         this.localAnchorA.Set(-1,0);
         this.localAnchorB.Set(1,0);
         this.lengthA = 0;
         this.maxLengthA = 0;
         this.lengthB = 0;
         this.maxLengthB = 0;
         this.ratio = 1;
         collideConnected = true;
      }
      
      public function Initialize(param1:B2Body, param2:B2Body, param3:B2Vec2, param4:B2Vec2, param5:B2Vec2, param6:B2Vec2, param7:Float) 
      {
         bodyA = param1;
         bodyB = param2;
         this.groundAnchorA.SetV(param3);
         this.groundAnchorB.SetV(param4);
         this.localAnchorA = bodyA.GetLocalPoint(param5);
         this.localAnchorB = bodyB.GetLocalPoint(param6);
         var _loc8_= param5.x - param3.x;
         var _loc9_= param5.y - param3.y;
         this.lengthA = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
         var _loc10_= param6.x - param4.x;
         var _loc11_= param6.y - param4.y;
         this.lengthB = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
         this.ratio = param7;
         var _loc12_= this.lengthA + this.ratio * this.lengthB;
         this.maxLengthA = _loc12_ - this.ratio * B2PulleyJoint/*b2internal::*/.b2_minPulleyLength;
         this.maxLengthB = (_loc12_ - B2PulleyJoint/*b2internal::*/.b2_minPulleyLength) / this.ratio;
      }
   }


