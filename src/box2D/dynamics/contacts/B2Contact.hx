package box2D.dynamics.contacts
;
   import box2D.collision.*;
   import box2D.collision.shapes.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2Contact
   {
      
      /*b2internal*/ public static var e_sensorFlag:UInt = (1 : UInt);
      
      /*b2internal*/ public static var e_continuousFlag:UInt = (2 : UInt);
      
      /*b2internal*/ public static var e_islandFlag:UInt = (4 : UInt);
      
      /*b2internal*/ public static var e_toiFlag:UInt = (8 : UInt);
      
      /*b2internal*/ public static var e_touchingFlag:UInt = (16 : UInt);
      
      /*b2internal*/ public static var e_enabledFlag:UInt = (32 : UInt);
      
      /*b2internal*/ public static var e_filterFlag:UInt = (64 : UInt);
      
      static var s_input:B2TOIInput = new B2TOIInput();
      
      /*b2internal*/ public var m_flags:UInt = 0;
      
      /*b2internal*/ public var m_prev:B2Contact;
      
      /*b2internal*/ public var m_next:B2Contact;
      
      /*b2internal*/ public var m_nodeA:B2ContactEdge = new B2ContactEdge();
      
      /*b2internal*/ public var m_nodeB:B2ContactEdge = new B2ContactEdge();
      
      /*b2internal*/ public var m_fixtureA:B2Fixture;
      
      /*b2internal*/ public var m_fixtureB:B2Fixture;
      
      /*b2internal*/ public var m_manifold:B2Manifold = new B2Manifold();
      
      /*b2internal*/ public var m_oldManifold:B2Manifold = new B2Manifold();
      
      /*b2internal*/ public var m_toi:Float = Math.NaN;
      
      public function new()
      {
         
      }
      
      public function GetManifold() : B2Manifold
      {
         return this/*b2internal::*/.m_manifold;
      }
      
      public function GetWorldManifold(param1:B2WorldManifold) 
      {
         var _loc2_= this/*b2internal::*/.m_fixtureA.GetBody();
         var _loc3_= this/*b2internal::*/.m_fixtureB.GetBody();
         var _loc4_= this/*b2internal::*/.m_fixtureA.GetShape();
         var _loc5_= this/*b2internal::*/.m_fixtureB.GetShape();
         param1.Initialize(this/*b2internal::*/.m_manifold,_loc2_.GetTransform(),_loc4_/*b2internal::*/.m_radius,_loc3_.GetTransform(),_loc5_/*b2internal::*/.m_radius);
      }
      
      public function IsTouching() : Bool
      {
         return (((this/*b2internal::*/.m_flags : Int) & /*b2internal::*/(e_touchingFlag : Int)) : UInt) == /*b2internal::*/e_touchingFlag;
      }
      
      public function IsContinuous() : Bool
      {
         return (((this/*b2internal::*/.m_flags : Int) & /*b2internal::*/(e_continuousFlag : Int)) : UInt) == /*b2internal::*/e_continuousFlag;
      }
      
      public function SetSensor(param1:Bool) 
      {
         if(param1)
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_sensorFlag : UInt) : UInt);
         }
         else
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags & (~ /*b2internal::*/(e_sensorFlag : Int) : UInt) : UInt) : UInt);
         }
      }
      
      public function IsSensor() : Bool
      {
         return (((this/*b2internal::*/.m_flags : Int) & /*b2internal::*/(e_sensorFlag : Int)) : UInt) == /*b2internal::*/e_sensorFlag;
      }
      
      public function SetEnabled(param1:Bool) 
      {
         if(param1)
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_enabledFlag : UInt) : UInt);
         }
         else
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags & (~ /*b2internal::*/(e_enabledFlag : Int) : UInt) : UInt) : UInt);
         }
      }
      
      public function IsEnabled() : Bool
      {
         return (((this/*b2internal::*/.m_flags : Int) & /*b2internal::*/(e_enabledFlag : Int)) : UInt) == /*b2internal::*/e_enabledFlag;
      }
      
      public function GetNext() : B2Contact
      {
         return this/*b2internal::*/.m_next;
      }
      
      public function GetFixtureA() : B2Fixture
      {
         return this/*b2internal::*/.m_fixtureA;
      }
      
      public function GetFixtureB() : B2Fixture
      {
         return this/*b2internal::*/.m_fixtureB;
      }
      
      public function FlagForFiltering() 
      {
         this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_filterFlag : UInt) : UInt);
      }
      
      /*b2internal*/ public function Reset(param1:B2Fixture = null, param2:B2Fixture = null) 
      {
         this/*b2internal::*/.m_flags = /*b2internal::*/e_enabledFlag;
         if(param1 == null || param2 == null)
         {
            this/*b2internal::*/.m_fixtureA = null;
            this/*b2internal::*/.m_fixtureB = null;
            return;
         }
         if(param1.IsSensor() || param2.IsSensor())
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_sensorFlag : UInt) : UInt);
         }
         var _loc3_= param1.GetBody();
         var _loc4_= param2.GetBody();
         if(_loc3_.GetType() != B2Body.b2_dynamicBody || _loc3_.IsBullet() || _loc4_.GetType() != B2Body.b2_dynamicBody || _loc4_.IsBullet())
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_continuousFlag : UInt) : UInt);
         }
         this/*b2internal::*/.m_fixtureA = param1;
         this/*b2internal::*/.m_fixtureB = param2;
         this/*b2internal::*/.m_manifold.m_pointCount = 0;
         this/*b2internal::*/.m_prev = null;
         this/*b2internal::*/.m_next = null;
         this/*b2internal::*/.m_nodeA.contact = null;
         this/*b2internal::*/.m_nodeA.prev = null;
         this/*b2internal::*/.m_nodeA.next = null;
         this/*b2internal::*/.m_nodeA.other = null;
         this/*b2internal::*/.m_nodeB.contact = null;
         this/*b2internal::*/.m_nodeB.prev = null;
         this/*b2internal::*/.m_nodeB.next = null;
         this/*b2internal::*/.m_nodeB.other = null;
      }
      
      /*b2internal*/ public function Update(param1:B2ContactListener) 
      {
         var _loc8_:B2Shape = null;
         var _loc9_:B2Shape = null;
         var _loc10_:B2Transform = null;
         var _loc11_:B2Transform = null;
         var _loc12_= 0;
         var _loc13_:B2ManifoldPoint = null;
         var _loc14_:B2ContactID = null;
         var _loc15_= 0;
         var _loc16_:B2ManifoldPoint = null;
         var _loc2_= this/*b2internal::*/.m_oldManifold;
         this/*b2internal::*/.m_oldManifold = this/*b2internal::*/.m_manifold;
         this/*b2internal::*/.m_manifold = _loc2_;
         this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_enabledFlag : UInt) : UInt);
         var _loc3_= false;
         var _loc4_= (((this/*b2internal::*/.m_flags : Int) & /*b2internal::*/(e_touchingFlag : Int)) : UInt) == /*b2internal::*/e_touchingFlag;
         var _loc5_= this/*b2internal::*/.m_fixtureA/*b2internal::*/.m_body;
         var _loc6_= this/*b2internal::*/.m_fixtureB/*b2internal::*/.m_body;
         var _loc7_= this/*b2internal::*/.m_fixtureA/*b2internal::*/.m_aabb.TestOverlap(this/*b2internal::*/.m_fixtureB/*b2internal::*/.m_aabb);
         if(((this/*b2internal::*/.m_flags : Int) & /*b2internal::*/(e_sensorFlag : Int)) != 0)
         {
            if(_loc7_)
            {
               _loc8_ = this/*b2internal::*/.m_fixtureA.GetShape();
               _loc9_ = this/*b2internal::*/.m_fixtureB.GetShape();
               _loc10_ = _loc5_.GetTransform();
               _loc11_ = _loc6_.GetTransform();
               _loc3_ = B2Shape.TestOverlap(_loc8_,_loc10_,_loc9_,_loc11_);
            }
            this/*b2internal::*/.m_manifold.m_pointCount = 0;
         }
         else
         {
            if(_loc5_.GetType() != B2Body.b2_dynamicBody || _loc5_.IsBullet() || _loc6_.GetType() != B2Body.b2_dynamicBody || _loc6_.IsBullet())
            {
               this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_continuousFlag : UInt) : UInt);
            }
            else
            {
               this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags & (~ /*b2internal::*/(e_continuousFlag : Int) : UInt) : UInt) : UInt);
            }
            if(_loc7_)
            {
               this/*b2internal::*/.Evaluate();
               _loc3_ = this/*b2internal::*/.m_manifold.m_pointCount > 0;
               _loc12_ = 0;
               while(_loc12_ < this/*b2internal::*/.m_manifold.m_pointCount)
               {
                  _loc13_ = this/*b2internal::*/.m_manifold.m_points[_loc12_];
                  _loc13_.m_normalImpulse = 0;
                  _loc13_.m_tangentImpulse = 0;
                  _loc14_ = _loc13_.m_id;
                  _loc15_ = 0;
                  while(_loc15_ < this/*b2internal::*/.m_oldManifold.m_pointCount)
                  {
                     _loc16_ = this/*b2internal::*/.m_oldManifold.m_points[_loc15_];
                     if(_loc16_.m_id.key == _loc14_.key)
                     {
                        _loc13_.m_normalImpulse = _loc16_.m_normalImpulse;
                        _loc13_.m_tangentImpulse = _loc16_.m_tangentImpulse;
                        break;
                     }
                     _loc15_++;
                  }
                  _loc12_++;
               }
            }
            else
            {
               this/*b2internal::*/.m_manifold.m_pointCount = 0;
            }
            if(_loc3_ != _loc4_)
            {
               _loc5_.SetAwake(true);
               _loc6_.SetAwake(true);
            }
         }
         if(_loc3_)
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags | /*b2internal::*/e_touchingFlag : UInt) : UInt);
         }
         else
         {
            this/*b2internal::*/.m_flags = ((this/*b2internal::*/.m_flags & (~ /*b2internal::*/(e_touchingFlag : Int) : UInt) : UInt) : UInt);
         }
         if(_loc4_ == false && _loc3_ == true)
         {
            param1.BeginContact(this);
         }
         if(_loc4_ == true && _loc3_ == false)
         {
            param1.EndContact(this);
         }
         if(((this/*b2internal::*/.m_flags : Int) & /*b2internal::*/(e_sensorFlag : Int)) == 0)
         {
            param1.PreSolve(this,this/*b2internal::*/.m_oldManifold);
         }
      }
      
      /*b2internal*/ public function Evaluate() 
      {
      }
      
      /*b2internal*/ public function ComputeTOI(param1:B2Sweep, param2:B2Sweep) : Float
      {
         s_input.proxyA.Set(this/*b2internal::*/.m_fixtureA.GetShape());
         s_input.proxyB.Set(this/*b2internal::*/.m_fixtureB.GetShape());
         s_input.sweepA = param1;
         s_input.sweepB = param2;
         s_input.tolerance = B2Settings.b2_linearSlop;
         return B2TimeOfImpact.TimeOfImpact(s_input);
      }
   }


