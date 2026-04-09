package box2D.dynamics.joints
;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Settings;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2TimeStep;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2Joint
   {
      
      /*b2internal*/ public static inline final e_unknownJoint= 0;
      
      /*b2internal*/ public static inline final e_revoluteJoint= 1;
      
      /*b2internal*/ public static inline final e_prismaticJoint= 2;
      
      /*b2internal*/ public static inline final e_distanceJoint= 3;
      
      /*b2internal*/ public static inline final e_pulleyJoint= 4;
      
      /*b2internal*/ public static inline final e_mouseJoint= 5;
      
      /*b2internal*/ public static inline final e_gearJoint= 6;
      
      /*b2internal*/ public static inline final e_lineJoint= 7;
      
      /*b2internal*/ public static inline final e_weldJoint= 8;
      
      /*b2internal*/ public static inline final e_frictionJoint= 9;
      
      /*b2internal*/ public static inline final e_inactiveLimit= 0;
      
      /*b2internal*/ public static inline final e_atLowerLimit= 1;
      
      /*b2internal*/ public static inline final e_atUpperLimit= 2;
      
      /*b2internal*/ public static inline final e_equalLimits= 3;
      
      /*b2internal*/ public var m_type:Int = 0;
      
      /*b2internal*/ public var m_prev:B2Joint;
      
      /*b2internal*/ public var m_next:B2Joint;
      
      /*b2internal*/ public var m_edgeA:B2JointEdge = new B2JointEdge();
      
      /*b2internal*/ public var m_edgeB:B2JointEdge = new B2JointEdge();
      
      /*b2internal*/ public var m_bodyA:B2Body;
      
      /*b2internal*/ public var m_bodyB:B2Body;
      
      /*b2internal*/ public var m_islandFlag:Bool = false;
      
      /*b2internal*/ public var m_collideConnected:Bool = false;
      
      var m_userData:ASAny;
      
      /*b2internal*/ public var m_localCenterA:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_localCenterB:B2Vec2 = new B2Vec2();
      
      /*b2internal*/ public var m_invMassA:Float = Math.NaN;
      
      /*b2internal*/ public var m_invMassB:Float = Math.NaN;
      
      /*b2internal*/ public var m_invIA:Float = Math.NaN;
      
      /*b2internal*/ public var m_invIB:Float = Math.NaN;
      
      public function new(param1:B2JointDef)
      {
         
         B2Settings.b2Assert(param1.bodyA != param1.bodyB);
         this/*b2internal::*/.m_type = param1.type;
         this/*b2internal::*/.m_prev = null;
         this/*b2internal::*/.m_next = null;
         this/*b2internal::*/.m_bodyA = param1.bodyA;
         this/*b2internal::*/.m_bodyB = param1.bodyB;
         this/*b2internal::*/.m_collideConnected = param1.collideConnected;
         this/*b2internal::*/.m_islandFlag = false;
         this.m_userData = param1.userData;
      }
      
      /*b2internal*/ public static function Create(param1:B2JointDef, param2:ASAny) : B2Joint
      {
         var _loc3_:B2Joint = null;
         switch(param1.type)
         {
/*b2internal::*/            case e_distanceJoint:
               _loc3_ = new B2DistanceJoint(ASCompat.reinterpretAs(param1 , B2DistanceJointDef));
               
/*b2internal::*/            case e_mouseJoint:
               _loc3_ = new B2MouseJoint(ASCompat.reinterpretAs(param1 , B2MouseJointDef));
               
/*b2internal::*/            case e_prismaticJoint:
               _loc3_ = new B2PrismaticJoint(ASCompat.reinterpretAs(param1 , B2PrismaticJointDef));
               
/*b2internal::*/            case e_revoluteJoint:
               _loc3_ = new B2RevoluteJoint(ASCompat.reinterpretAs(param1 , B2RevoluteJointDef));
               
/*b2internal::*/            case e_pulleyJoint:
               _loc3_ = new B2PulleyJoint(ASCompat.reinterpretAs(param1 , B2PulleyJointDef));
               
/*b2internal::*/            case e_gearJoint:
               _loc3_ = new B2GearJoint(ASCompat.reinterpretAs(param1 , B2GearJointDef));
               
/*b2internal::*/            case e_lineJoint:
               _loc3_ = new B2LineJoint(ASCompat.reinterpretAs(param1 , B2LineJointDef));
               
/*b2internal::*/            case e_weldJoint:
               _loc3_ = new B2WeldJoint(ASCompat.reinterpretAs(param1 , B2WeldJointDef));
               
/*b2internal::*/            case e_frictionJoint:
               _loc3_ = new B2FrictionJoint(ASCompat.reinterpretAs(param1 , B2FrictionJointDef));
         }
         return _loc3_;
      }
      
      /*b2internal*/ public static function Destroy(param1:B2Joint, param2:ASAny) 
      {
      }
      
      public function GetType() : Int
      {
         return this/*b2internal::*/.m_type;
      }
      
      public function GetAnchorA() : B2Vec2
      {
         return null;
      }
      
      public function GetAnchorB() : B2Vec2
      {
         return null;
      }
      
      public function GetReactionForce(param1:Float) : B2Vec2
      {
         return null;
      }
      
      public function GetReactionTorque(param1:Float) : Float
      {
         return 0;
      }
      
      public function GetBodyA() : B2Body
      {
         return this/*b2internal::*/.m_bodyA;
      }
      
      public function GetBodyB() : B2Body
      {
         return this/*b2internal::*/.m_bodyB;
      }
      
      public function GetNext() : B2Joint
      {
         return this/*b2internal::*/.m_next;
      }
      
      public function GetUserData() : ASAny
      {
         return this.m_userData;
      }
      
      public function SetUserData(param1:ASAny) 
      {
         this.m_userData = param1;
      }
      
      public function IsActive() : Bool
      {
         return this/*b2internal::*/.m_bodyA.IsActive() && this/*b2internal::*/.m_bodyB.IsActive();
      }
      
      /*b2internal*/ public function InitVelocityConstraints(param1:B2TimeStep) 
      {
      }
      
      /*b2internal*/ public function SolveVelocityConstraints(param1:B2TimeStep) 
      {
      }
      
      /*b2internal*/ public function FinalizeVelocityConstraints() 
      {
      }
      
      /*b2internal*/ public function SolvePositionConstraints(param1:Float) : Bool
      {
         return false;
      }
   }


