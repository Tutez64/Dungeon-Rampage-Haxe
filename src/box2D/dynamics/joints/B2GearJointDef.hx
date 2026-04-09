package box2D.dynamics.joints
;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2GearJointDef extends B2JointDef
   {
      
      public var joint1:B2Joint;
      
      public var joint2:B2Joint;
      
      public var ratio:Float = Math.NaN;
      
      public function new()
      {
         super();
         type = B2Joint/*b2internal::*/.e_gearJoint;
         this.joint1 = null;
         this.joint2 = null;
         this.ratio = 1;
      }
   }


