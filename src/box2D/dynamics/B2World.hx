package box2D.dynamics
;
   import box2D.collision.*;
   import box2D.collision.shapes.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.contacts.*;
   import box2D.dynamics.controllers.B2Controller;
   import box2D.dynamics.controllers.B2ControllerEdge;
   import box2D.dynamics.joints.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2World
   {
      
      static var m_warmStarting:Bool = false;
      
      static var m_continuousPhysics:Bool = false;
      
      static var s_timestep2:B2TimeStep = new B2TimeStep();
      
      static var s_xf:B2Transform = new B2Transform();
      
      static var s_backupA:B2Sweep = new B2Sweep();
      
      static var s_backupB:B2Sweep = new B2Sweep();
      
      static var s_timestep:B2TimeStep = new B2TimeStep();
      
      static var s_queue:Vector<B2Body> = new Vector();
      
      static var s_jointColor:B2Color = new B2Color(0.5,0.8,0.8);
      
      public static inline final e_newFixture= 1;
      
      public static inline final e_locked= 2;
      
      var s_stack:Vector<B2Body> = new Vector();
      
      /*b2internal*/ public var m_flags:Int = 0;
      
      /*b2internal*/ public var m_contactManager:B2ContactManager = new B2ContactManager();
      
      var m_contactSolver:B2ContactSolver = new B2ContactSolver();
      
      var m_island:B2Island = new B2Island();
      
      /*b2internal*/ public var m_bodyList:B2Body;
      
      var m_jointList:B2Joint;
      
      /*b2internal*/ public var m_contactList:B2Contact;
      
      var m_bodyCount:Int = 0;
      
      /*b2internal*/ public var m_contactCount:Int = 0;
      
      var m_jointCount:Int = 0;
      
      var m_controllerList:B2Controller;
      
      var m_controllerCount:Int = 0;
      
      var m_gravity:B2Vec2;
      
      var m_allowSleep:Bool = false;
      
      /*b2internal*/ public var m_groundBody:B2Body;
      
      var m_destructionListener:B2DestructionListener;
      
      var m_debugDraw:B2DebugDraw;
      
      var m_inv_dt0:Float = Math.NaN;
      
      public function new(param1:B2Vec2, param2:Bool)
      {
         
         this.m_destructionListener = null;
         this.m_debugDraw = null;
         this/*b2internal::*/.m_bodyList = null;
         this/*b2internal::*/.m_contactList = null;
         this.m_jointList = null;
         this.m_controllerList = null;
         this.m_bodyCount = 0;
         this/*b2internal::*/.m_contactCount = 0;
         this.m_jointCount = 0;
         this.m_controllerCount = 0;
         m_warmStarting = true;
         m_continuousPhysics = true;
         this.m_allowSleep = param2;
         this.m_gravity = param1;
         this.m_inv_dt0 = 0;
         this/*b2internal::*/.m_contactManager/*b2internal::*/.m_world = this;
         var _loc3_= new B2BodyDef();
         this/*b2internal::*/.m_groundBody = this.CreateBody(_loc3_);
      }
      
      public function SetDestructionListener(param1:B2DestructionListener) 
      {
         this.m_destructionListener = param1;
      }
      
      public function SetContactFilter(param1:B2ContactFilter) 
      {
         this/*b2internal::*/.m_contactManager/*b2internal::*/.m_contactFilter = param1;
      }
      
      public function SetContactListener(param1:B2ContactListener) 
      {
         this/*b2internal::*/.m_contactManager/*b2internal::*/.m_contactListener = param1;
      }
      
      public function SetDebugDraw(param1:B2DebugDraw) 
      {
         this.m_debugDraw = param1;
      }
      
      public function SetBroadPhase(param1:IBroadPhase) 
      {
         var _loc4_:B2Fixture = null;
         var _loc2_= this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase;
         this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase = param1;
         var _loc3_= this/*b2internal::*/.m_bodyList;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_/*b2internal::*/.m_fixtureList;
            while(_loc4_ != null)
            {
               _loc4_/*b2internal::*/.m_proxy = param1.CreateProxy(_loc2_.GetFatAABB(_loc4_/*b2internal::*/.m_proxy),_loc4_);
               _loc4_ = _loc4_/*b2internal::*/.m_next;
            }
            _loc3_ = _loc3_/*b2internal::*/.m_next;
         }
      }
      
      public function Validate() 
      {
         this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase.Validate();
      }
      
      public function GetProxyCount() : Int
      {
         return this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase.GetProxyCount();
      }
      
      public function CreateBody(param1:B2BodyDef) : B2Body
      {
         if(this.IsLocked() == true)
         {
            return null;
         }
         var _loc2_= new B2Body(param1,this);
         _loc2_/*b2internal::*/.m_prev = null;
         _loc2_/*b2internal::*/.m_next = this/*b2internal::*/.m_bodyList;
         if(this/*b2internal::*/.m_bodyList != null)
         {
            this/*b2internal::*/.m_bodyList/*b2internal::*/.m_prev = _loc2_;
         }
         this/*b2internal::*/.m_bodyList = _loc2_;
         ++this.m_bodyCount;
         return _loc2_;
      }
      
      public function DestroyBody(param1:B2Body) 
      {
         var _loc6_:B2JointEdge = null;
         var _loc7_:B2ControllerEdge = null;
         var _loc8_:B2ContactEdge = null;
         var _loc9_:B2Fixture = null;
         if(this.IsLocked() == true)
         {
            return;
         }
         var _loc2_= param1/*b2internal::*/.m_jointList;
         while(_loc2_ != null)
         {
            _loc6_ = _loc2_;
            _loc2_ = _loc2_.next;
            if(this.m_destructionListener != null)
            {
               this.m_destructionListener.SayGoodbyeJoint(_loc6_.joint);
            }
            this.DestroyJoint(_loc6_.joint);
         }
         var _loc3_= param1/*b2internal::*/.m_controllerList;
         while(_loc3_ != null)
         {
            _loc7_ = _loc3_;
            _loc3_ = _loc3_.nextController;
            _loc7_.controller.RemoveBody(param1);
         }
         var _loc4_= param1/*b2internal::*/.m_contactList;
         while(_loc4_ != null)
         {
            _loc8_ = _loc4_;
            _loc4_ = _loc4_.next;
            this/*b2internal::*/.m_contactManager.Destroy(_loc8_.contact);
         }
         param1/*b2internal::*/.m_contactList = null;
         var _loc5_= param1/*b2internal::*/.m_fixtureList;
         while(_loc5_ != null)
         {
            _loc9_ = _loc5_;
            _loc5_ = _loc5_/*b2internal::*/.m_next;
            if(this.m_destructionListener != null)
            {
               this.m_destructionListener.SayGoodbyeFixture(_loc9_);
            }
            _loc9_/*b2internal::*/.DestroyProxy(this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase);
            _loc9_/*b2internal::*/.Destroy();
         }
         param1/*b2internal::*/.m_fixtureList = null;
         param1/*b2internal::*/.m_fixtureCount = 0;
         if(param1/*b2internal::*/.m_prev != null)
         {
            param1/*b2internal::*/.m_prev/*b2internal::*/.m_next = param1/*b2internal::*/.m_next;
         }
         if(param1/*b2internal::*/.m_next != null)
         {
            param1/*b2internal::*/.m_next/*b2internal::*/.m_prev = param1/*b2internal::*/.m_prev;
         }
         if(param1 == this/*b2internal::*/.m_bodyList)
         {
            this/*b2internal::*/.m_bodyList = param1/*b2internal::*/.m_next;
         }
         --this.m_bodyCount;
      }
      
      public function CreateJoint(param1:B2JointDef) : B2Joint
      {
         var _loc5_:B2ContactEdge = null;
         var _loc2_= B2Joint/*b2internal::*/.Create(param1,null);
         _loc2_/*b2internal::*/.m_prev = null;
         _loc2_/*b2internal::*/.m_next = this.m_jointList;
         if(this.m_jointList != null)
         {
            this.m_jointList/*b2internal::*/.m_prev = _loc2_;
         }
         this.m_jointList = _loc2_;
         ++this.m_jointCount;
         _loc2_/*b2internal::*/.m_edgeA.joint = _loc2_;
         _loc2_/*b2internal::*/.m_edgeA.other = _loc2_/*b2internal::*/.m_bodyB;
         _loc2_/*b2internal::*/.m_edgeA.prev = null;
         _loc2_/*b2internal::*/.m_edgeA.next = _loc2_/*b2internal::*/.m_bodyA/*b2internal::*/.m_jointList;
         if(_loc2_/*b2internal::*/.m_bodyA/*b2internal::*/.m_jointList != null)
         {
            _loc2_/*b2internal::*/.m_bodyA/*b2internal::*/.m_jointList.prev = _loc2_/*b2internal::*/.m_edgeA;
         }
         _loc2_/*b2internal::*/.m_bodyA/*b2internal::*/.m_jointList = _loc2_/*b2internal::*/.m_edgeA;
         _loc2_/*b2internal::*/.m_edgeB.joint = _loc2_;
         _loc2_/*b2internal::*/.m_edgeB.other = _loc2_/*b2internal::*/.m_bodyA;
         _loc2_/*b2internal::*/.m_edgeB.prev = null;
         _loc2_/*b2internal::*/.m_edgeB.next = _loc2_/*b2internal::*/.m_bodyB/*b2internal::*/.m_jointList;
         if(_loc2_/*b2internal::*/.m_bodyB/*b2internal::*/.m_jointList != null)
         {
            _loc2_/*b2internal::*/.m_bodyB/*b2internal::*/.m_jointList.prev = _loc2_/*b2internal::*/.m_edgeB;
         }
         _loc2_/*b2internal::*/.m_bodyB/*b2internal::*/.m_jointList = _loc2_/*b2internal::*/.m_edgeB;
         var _loc3_= param1.bodyA;
         var _loc4_= param1.bodyB;
         if(param1.collideConnected == false)
         {
            _loc5_ = _loc4_.GetContactList();
            while(_loc5_ != null)
            {
               if(_loc5_.other == _loc3_)
               {
                  _loc5_.contact.FlagForFiltering();
               }
               _loc5_ = _loc5_.next;
            }
         }
         return _loc2_;
      }
      
      public function DestroyJoint(param1:B2Joint) 
      {
         var _loc5_:B2ContactEdge = null;
         var _loc2_= param1/*b2internal::*/.m_collideConnected;
         if(param1/*b2internal::*/.m_prev != null)
         {
            param1/*b2internal::*/.m_prev/*b2internal::*/.m_next = param1/*b2internal::*/.m_next;
         }
         if(param1/*b2internal::*/.m_next != null)
         {
            param1/*b2internal::*/.m_next/*b2internal::*/.m_prev = param1/*b2internal::*/.m_prev;
         }
         if(param1 == this.m_jointList)
         {
            this.m_jointList = param1/*b2internal::*/.m_next;
         }
         var _loc3_= param1/*b2internal::*/.m_bodyA;
         var _loc4_= param1/*b2internal::*/.m_bodyB;
         _loc3_.SetAwake(true);
         _loc4_.SetAwake(true);
         if(param1/*b2internal::*/.m_edgeA.prev != null)
         {
            param1/*b2internal::*/.m_edgeA.prev.next = param1/*b2internal::*/.m_edgeA.next;
         }
         if(param1/*b2internal::*/.m_edgeA.next != null)
         {
            param1/*b2internal::*/.m_edgeA.next.prev = param1/*b2internal::*/.m_edgeA.prev;
         }
         if(param1/*b2internal::*/.m_edgeA == _loc3_/*b2internal::*/.m_jointList)
         {
            _loc3_/*b2internal::*/.m_jointList = param1/*b2internal::*/.m_edgeA.next;
         }
         param1/*b2internal::*/.m_edgeA.prev = null;
         param1/*b2internal::*/.m_edgeA.next = null;
         if(param1/*b2internal::*/.m_edgeB.prev != null)
         {
            param1/*b2internal::*/.m_edgeB.prev.next = param1/*b2internal::*/.m_edgeB.next;
         }
         if(param1/*b2internal::*/.m_edgeB.next != null)
         {
            param1/*b2internal::*/.m_edgeB.next.prev = param1/*b2internal::*/.m_edgeB.prev;
         }
         if(param1/*b2internal::*/.m_edgeB == _loc4_/*b2internal::*/.m_jointList)
         {
            _loc4_/*b2internal::*/.m_jointList = param1/*b2internal::*/.m_edgeB.next;
         }
         param1/*b2internal::*/.m_edgeB.prev = null;
         param1/*b2internal::*/.m_edgeB.next = null;
         B2Joint/*b2internal::*/.Destroy(param1,null);
         --this.m_jointCount;
         if(_loc2_ == false)
         {
            _loc5_ = _loc4_.GetContactList();
            while(_loc5_ != null)
            {
               if(_loc5_.other == _loc3_)
               {
                  _loc5_.contact.FlagForFiltering();
               }
               _loc5_ = _loc5_.next;
            }
         }
      }
      
      public function AddController(param1:B2Controller) : B2Controller
      {
         param1/*b2internal::*/.m_next = this.m_controllerList;
         param1/*b2internal::*/.m_prev = null;
         this.m_controllerList = param1;
         param1/*b2internal::*/.m_world = this;
         ++this.m_controllerCount;
         return param1;
      }
      
      public function RemoveController(param1:B2Controller) 
      {
         if(param1/*b2internal::*/.m_prev != null)
         {
            param1/*b2internal::*/.m_prev/*b2internal::*/.m_next = param1/*b2internal::*/.m_next;
         }
         if(param1/*b2internal::*/.m_next != null)
         {
            param1/*b2internal::*/.m_next/*b2internal::*/.m_prev = param1/*b2internal::*/.m_prev;
         }
         if(this.m_controllerList == param1)
         {
            this.m_controllerList = param1/*b2internal::*/.m_next;
         }
         --this.m_controllerCount;
      }
      
      public function CreateController(param1:B2Controller) : B2Controller
      {
         if(param1/*b2internal::*/.m_world != this)
         {
            throw new Error("Controller can only be a member of one world");
         }
         param1/*b2internal::*/.m_next = this.m_controllerList;
         param1/*b2internal::*/.m_prev = null;
         if(this.m_controllerList != null)
         {
            this.m_controllerList/*b2internal::*/.m_prev = param1;
         }
         this.m_controllerList = param1;
         ++this.m_controllerCount;
         param1/*b2internal::*/.m_world = this;
         return param1;
      }
      
      public function DestroyController(param1:B2Controller) 
      {
         param1.Clear();
         if(param1/*b2internal::*/.m_next != null)
         {
            param1/*b2internal::*/.m_next/*b2internal::*/.m_prev = param1/*b2internal::*/.m_prev;
         }
         if(param1/*b2internal::*/.m_prev != null)
         {
            param1/*b2internal::*/.m_prev/*b2internal::*/.m_next = param1/*b2internal::*/.m_next;
         }
         if(param1 == this.m_controllerList)
         {
            this.m_controllerList = param1/*b2internal::*/.m_next;
         }
         --this.m_controllerCount;
      }
      
      public function SetWarmStarting(param1:Bool) 
      {
         m_warmStarting = param1;
      }
      
      public function SetContinuousPhysics(param1:Bool) 
      {
         m_continuousPhysics = param1;
      }
      
      public function GetBodyCount() : Int
      {
         return this.m_bodyCount;
      }
      
      public function GetJointCount() : Int
      {
         return this.m_jointCount;
      }
      
      public function GetContactCount() : Int
      {
         return this/*b2internal::*/.m_contactCount;
      }
      
      public function SetGravity(param1:B2Vec2) 
      {
         this.m_gravity = param1;
      }
      
      public function GetGravity() : B2Vec2
      {
         return this.m_gravity;
      }
      
      public function GetGroundBody() : B2Body
      {
         return this/*b2internal::*/.m_groundBody;
      }
      
      public function Step(param1:Float, param2:Int, param3:Int) 
      {
         if((this/*b2internal::*/.m_flags & e_newFixture) != 0)
         {
            this/*b2internal::*/.m_contactManager.FindNewContacts();
            this/*b2internal::*/.m_flags = this/*b2internal::*/.m_flags & ~e_newFixture;
         }
         this/*b2internal::*/.m_flags = this/*b2internal::*/.m_flags | e_locked;
         var _loc4_= s_timestep2;
         _loc4_.dt = param1;
         _loc4_.velocityIterations = param2;
         _loc4_.positionIterations = param3;
         if(param1 > 0)
         {
            _loc4_.inv_dt = 1 / param1;
         }
         else
         {
            _loc4_.inv_dt = 0;
         }
         _loc4_.dtRatio = this.m_inv_dt0 * param1;
         _loc4_.warmStarting = m_warmStarting;
         this/*b2internal::*/.m_contactManager.Collide();
         if(_loc4_.dt > 0)
         {
            this/*b2internal::*/.Solve(_loc4_);
         }
         if(m_continuousPhysics && _loc4_.dt > 0)
         {
            this/*b2internal::*/.SolveTOI(_loc4_);
         }
         if(_loc4_.dt > 0)
         {
            this.m_inv_dt0 = _loc4_.inv_dt;
         }
         this/*b2internal::*/.m_flags = this/*b2internal::*/.m_flags & ~e_locked;
      }
      
      public function ClearForces() 
      {
         var _loc1_= this/*b2internal::*/.m_bodyList;
         while(_loc1_ != null)
         {
            _loc1_/*b2internal::*/.m_force.SetZero();
            _loc1_/*b2internal::*/.m_torque = 0;
            _loc1_ = _loc1_/*b2internal::*/.m_next;
         }
      }
      
      public function DrawDebugData() 
      {
         var _loc2_= 0;
         var _loc3_:B2Body = null;
         var _loc4_:B2Fixture = null;
         var _loc5_:B2Shape = null;
         var _loc6_:B2Joint = null;
         var _loc7_:IBroadPhase = null;
         var _loc11_:B2Transform = null;
         var _loc16_:B2Controller = null;
         var _loc17_:B2Contact = null;
         var _loc18_:B2Fixture = null;
         var _loc19_:B2Fixture = null;
         var _loc20_:B2Vec2 = null;
         var _loc21_:B2Vec2 = null;
         var _loc22_:B2AABB = null;
         if(this.m_debugDraw == null)
         {
            return;
         }
         this.m_debugDraw/*b2internal::*/.m_sprite.graphics.clear();
         var _loc1_= this.m_debugDraw.GetFlags();
         var _loc8_= new B2Vec2();
         var _loc9_= new B2Vec2();
         var _loc10_= new B2Vec2();
         var _loc12_= new B2AABB();
         var _loc13_= new B2AABB();
         var _loc14_:Array<ASAny> = [new B2Vec2(),new B2Vec2(),new B2Vec2(),new B2Vec2()];
         var _loc15_= new B2Color(0,0,0);
         if(((_loc1_ : Int) & (B2DebugDraw.e_shapeBit : Int)) != 0)
         {
            _loc3_ = this/*b2internal::*/.m_bodyList;
            while(_loc3_ != null)
            {
               _loc11_ = _loc3_/*b2internal::*/.m_xf;
               _loc4_ = _loc3_.GetFixtureList();
               while(_loc4_ != null)
               {
                  _loc5_ = _loc4_.GetShape();
                  if(_loc3_.IsActive() == false)
                  {
                     _loc15_.Set(0.5,0.5,0.3);
                     this/*b2internal::*/.DrawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else if(_loc3_.GetType() == B2Body.b2_staticBody)
                  {
                     _loc15_.Set(0.5,0.9,0.5);
                     this/*b2internal::*/.DrawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else if(_loc3_.GetType() == B2Body.b2_kinematicBody)
                  {
                     _loc15_.Set(0.5,0.5,0.9);
                     this/*b2internal::*/.DrawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else if(_loc3_.IsAwake() == false)
                  {
                     _loc15_.Set(0.6,0.6,0.6);
                     this/*b2internal::*/.DrawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else
                  {
                     _loc15_.Set(0.9,0.7,0.7);
                     this/*b2internal::*/.DrawShape(_loc5_,_loc11_,_loc15_);
                  }
                  _loc4_ = _loc4_/*b2internal::*/.m_next;
               }
               _loc3_ = _loc3_/*b2internal::*/.m_next;
            }
         }
         if(((_loc1_ : Int) & (B2DebugDraw.e_jointBit : Int)) != 0)
         {
            _loc6_ = this.m_jointList;
            while(_loc6_ != null)
            {
               this/*b2internal::*/.DrawJoint(_loc6_);
               _loc6_ = _loc6_/*b2internal::*/.m_next;
            }
         }
         if(((_loc1_ : Int) & (B2DebugDraw.e_controllerBit : Int)) != 0)
         {
            _loc16_ = this.m_controllerList;
            while(_loc16_ != null)
            {
               _loc16_.Draw(this.m_debugDraw);
               _loc16_ = _loc16_/*b2internal::*/.m_next;
            }
         }
         if(((_loc1_ : Int) & (B2DebugDraw.e_pairBit : Int)) != 0)
         {
            _loc15_.Set(0.3,0.9,0.9);
            _loc17_ = this/*b2internal::*/.m_contactManager/*b2internal::*/.m_contactList;
            while(_loc17_ != null)
            {
               _loc18_ = _loc17_.GetFixtureA();
               _loc19_ = _loc17_.GetFixtureB();
               _loc20_ = _loc18_.GetAABB().GetCenter();
               _loc21_ = _loc19_.GetAABB().GetCenter();
               this.m_debugDraw.DrawSegment(_loc20_,_loc21_,_loc15_);
               _loc17_ = _loc17_.GetNext();
            }
         }
         if(((_loc1_ : Int) & (B2DebugDraw.e_aabbBit : Int)) != 0)
         {
            _loc7_ = this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase;
            _loc14_ = [new B2Vec2(),new B2Vec2(),new B2Vec2(),new B2Vec2()];
            _loc3_ = this/*b2internal::*/.m_bodyList;
            while(_loc3_ != null)
            {
               if(_loc3_.IsActive() != false)
               {
                  _loc4_ = _loc3_.GetFixtureList();
                  while(_loc4_ != null)
                  {
                     _loc22_ = _loc7_.GetFatAABB(_loc4_/*b2internal::*/.m_proxy);
                     _loc14_[0].Set(_loc22_.lowerBound.x,_loc22_.lowerBound.y);
                     _loc14_[1].Set(_loc22_.upperBound.x,_loc22_.lowerBound.y);
                     _loc14_[2].Set(_loc22_.upperBound.x,_loc22_.upperBound.y);
                     _loc14_[3].Set(_loc22_.lowerBound.x,_loc22_.upperBound.y);
                     this.m_debugDraw.DrawPolygon(_loc14_,4,_loc15_);
                     _loc4_ = _loc4_.GetNext();
                  }
               }
               _loc3_ = _loc3_.GetNext();
            }
         }
         if(((_loc1_ : Int) & (B2DebugDraw.e_centerOfMassBit : Int)) != 0)
         {
            _loc3_ = this/*b2internal::*/.m_bodyList;
            while(_loc3_ != null)
            {
               _loc11_ = s_xf;
               _loc11_.R = _loc3_/*b2internal::*/.m_xf.R;
               _loc11_.position = _loc3_.GetWorldCenter();
               this.m_debugDraw.DrawTransform(_loc11_);
               _loc3_ = _loc3_/*b2internal::*/.m_next;
            }
         }
      }
      
      public function QueryAABB(param1:ASFunction, param2:B2AABB) 
      {
         var broadPhase:IBroadPhase = null;
         var WorldQueryWrapper:ASFunction = null;
         var callback= param1;
         var aabb= param2;
         WorldQueryWrapper = function(param1:ASAny):Bool
         {
            return ASCompat.toBool(callback(broadPhase.GetUserData(param1)));
         };
         broadPhase = this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase;
         broadPhase.Query(WorldQueryWrapper,aabb);
      }
      
      public function QueryShape(param1:ASFunction, param2:B2Shape, param3:B2Transform = null) 
      {
         var aabb:B2AABB;
         var broadPhase:IBroadPhase = null;
         var WorldQueryWrapper:ASFunction = null;
         var callback= param1;
         var shape= param2;
         var transform= param3;
         WorldQueryWrapper = function(param1:ASAny):Bool
         {
            var _loc2_= ASCompat.dynamicAs(broadPhase.GetUserData(param1) , B2Fixture);
            if(B2Shape.TestOverlap(shape,transform,_loc2_.GetShape(),_loc2_.GetBody().GetTransform()))
            {
               return ASCompat.toBool(callback(_loc2_));
            }
            return true;
         };
         if(transform == null)
         {
            transform = new B2Transform();
            transform.SetIdentity();
         }
         broadPhase = this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase;
         aabb = new B2AABB();
         shape.ComputeAABB(aabb,transform);
         broadPhase.Query(WorldQueryWrapper,aabb);
      }
      
      public function QueryPoint(param1:ASFunction, param2:B2Vec2) 
      {
         var broadPhase:IBroadPhase = null;
         var WorldQueryWrapper:ASFunction = null;
         var callback= param1;
         var p= param2;
         WorldQueryWrapper = function(param1:ASAny):Bool
         {
            var _loc2_= ASCompat.dynamicAs(broadPhase.GetUserData(param1) , B2Fixture);
            if(_loc2_.TestPoint(p))
            {
               return ASCompat.toBool(callback(_loc2_));
            }
            return true;
         };
         broadPhase = this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase;
         var aabb= new B2AABB();
         aabb.lowerBound.Set(p.x - B2Settings.b2_linearSlop,p.y - B2Settings.b2_linearSlop);
         aabb.upperBound.Set(p.x + B2Settings.b2_linearSlop,p.y + B2Settings.b2_linearSlop);
         broadPhase.Query(WorldQueryWrapper,aabb);
      }
      
      public function RayCast(param1:ASFunction, param2:B2Vec2, param3:B2Vec2) 
      {
         var broadPhase:IBroadPhase = null;
         var output:B2RayCastOutput = null;
         var RayCastWrapper:ASFunction = null;
         var callback= param1;
         var point1= param2;
         var point2= param3;
         RayCastWrapper = function(param1:B2RayCastInput, param2:ASAny):Float
         {
            var _loc6_= Math.NaN;
            var _loc7_:B2Vec2 = null;
            var _loc3_:ASAny = broadPhase.GetUserData(param2);
            var _loc4_= ASCompat.dynamicAs(_loc3_ , B2Fixture);
            var _loc5_= _loc4_.RayCast(output,param1);
            if(_loc5_)
            {
               _loc6_ = output.fraction;
               _loc7_ = new B2Vec2((1 - _loc6_) * point1.x + _loc6_ * point2.x,(1 - _loc6_) * point1.y + _loc6_ * point2.y);
               return ASCompat.toNumber(callback(_loc4_,_loc7_,output.normal,_loc6_));
            }
            return param1.maxFraction;
         };
         broadPhase = this/*b2internal::*/.m_contactManager/*b2internal::*/.m_broadPhase;
         output = new B2RayCastOutput();
         var input= new B2RayCastInput(point1,point2);
         broadPhase.RayCast(RayCastWrapper,input);
      }
      
      public function RayCastOne(param1:B2Vec2, param2:B2Vec2) : B2Fixture
      {
         var result:B2Fixture = null;
         var RayCastOneWrapper:ASFunction = null;
         var point1= param1;
         var point2= param2;
         RayCastOneWrapper = function(param1:B2Fixture, param2:B2Vec2, param3:B2Vec2, param4:Float):Float
         {
            result = param1;
            return param4;
         };
         this.RayCast(RayCastOneWrapper,point1,point2);
         return result;
      }
      
      public function RayCastAll(param1:B2Vec2, param2:B2Vec2) : Vector<B2Fixture>
      {
         var result:Vector<B2Fixture> = null;
         var RayCastAllWrapper:ASFunction = null;
         var point1= param1;
         var point2= param2;
         RayCastAllWrapper = function(param1:B2Fixture, param2:B2Vec2, param3:B2Vec2, param4:Float):Float
         {
            result[result.length] = param1;
            return 1;
         };
         result = new Vector<B2Fixture>();
         this.RayCast(RayCastAllWrapper,point1,point2);
         return result;
      }
      
      public function GetBodyList() : B2Body
      {
         return this/*b2internal::*/.m_bodyList;
      }
      
      public function GetJointList() : B2Joint
      {
         return this.m_jointList;
      }
      
      public function GetContactList() : B2Contact
      {
         return this/*b2internal::*/.m_contactList;
      }
      
      public function IsLocked() : Bool
      {
         return (this/*b2internal::*/.m_flags & e_locked) > 0;
      }
      
      /*b2internal*/ public function Solve(param1:B2TimeStep) 
      {
         var _loc15_:Int;
         var _loc16_:Int;
         var _loc2_:B2Body = null;
         var _loc10_= 0;
         var _loc11_= 0;
         var _loc12_:B2Body = null;
         var _loc13_:B2ContactEdge = null;
         var _loc14_:B2JointEdge = null;
         var _loc3_= this.m_controllerList;
         while(_loc3_ != null)
         {
            _loc3_.Step(param1);
            _loc3_ = _loc3_/*b2internal::*/.m_next;
         }
         var _loc4_= this.m_island;
         _loc4_.Initialize(this.m_bodyCount,this/*b2internal::*/.m_contactCount,this.m_jointCount,null,this/*b2internal::*/.m_contactManager/*b2internal::*/.m_contactListener,this.m_contactSolver);
         _loc2_ = this/*b2internal::*/.m_bodyList;
         while(_loc2_ != null)
         {
            _loc2_/*b2internal::*/.m_flags = ((_loc2_/*b2internal::*/.m_flags & (~(B2Body/*b2internal::*/.e_islandFlag : Int) : UInt) : UInt) : UInt);
            _loc2_ = _loc2_/*b2internal::*/.m_next;
         }
         var _loc5_= this/*b2internal::*/.m_contactList;
         while(_loc5_ != null)
         {
            _loc5_/*b2internal::*/.m_flags = ((_loc5_/*b2internal::*/.m_flags & (~(B2Contact/*b2internal::*/.e_islandFlag : Int) : UInt) : UInt) : UInt);
            _loc5_ = _loc5_/*b2internal::*/.m_next;
         }
         var _loc6_= this.m_jointList;
         while(_loc6_ != null)
         {
            _loc6_/*b2internal::*/.m_islandFlag = false;
            _loc6_ = _loc6_/*b2internal::*/.m_next;
         }
         var _loc7_= this.m_bodyCount;
         var _loc8_= this.s_stack;
         var _loc9_= this/*b2internal::*/.m_bodyList;
         while(_loc9_ != null)
         {
            if(((_loc9_/*b2internal::*/.m_flags : Int) & (B2Body/*b2internal::*/.e_islandFlag : Int)) == 0)
            {
               if(!(_loc9_.IsAwake() == false || _loc9_.IsActive() == false))
               {
                  if(_loc9_.GetType() != B2Body.b2_staticBody)
                  {
                     _loc4_.Clear();
                     _loc10_ = 0;
                     _loc8_[ASCompat.toInt(_loc15_ = _loc10_++)] = _loc9_;
                     _loc9_/*b2internal::*/.m_flags = ((_loc9_/*b2internal::*/.m_flags | B2Body/*b2internal::*/.e_islandFlag : UInt) : UInt);
                     while(_loc10_ > 0)
                     {
                        _loc2_ = _loc8_[--_loc10_];
                        _loc4_.AddBody(_loc2_);
                        if(_loc2_.IsAwake() == false)
                        {
                           _loc2_.SetAwake(true);
                        }
                        if(_loc2_.GetType() != B2Body.b2_staticBody)
                        {
                           _loc13_ = _loc2_/*b2internal::*/.m_contactList;
                           while(_loc13_ != null)
                           {
                              if(((_loc13_.contact/*b2internal::*/.m_flags : Int) & (B2Contact/*b2internal::*/.e_islandFlag : Int)) == 0)
                              {
                                 if(!(_loc13_.contact.IsSensor() == true || _loc13_.contact.IsEnabled() == false || _loc13_.contact.IsTouching() == false))
                                 {
                                    _loc4_.AddContact(_loc13_.contact);
                                    _loc13_.contact/*b2internal::*/.m_flags = ((_loc13_.contact/*b2internal::*/.m_flags | B2Contact/*b2internal::*/.e_islandFlag : UInt) : UInt);
                                    _loc12_ = _loc13_.other;
                                    if(((_loc12_/*b2internal::*/.m_flags : Int) & (B2Body/*b2internal::*/.e_islandFlag : Int)) == 0)
                                    {
                                       _loc8_[ASCompat.toInt(_loc16_ = _loc10_++)] = _loc12_;
                                       _loc12_/*b2internal::*/.m_flags = ((_loc12_/*b2internal::*/.m_flags | B2Body/*b2internal::*/.e_islandFlag : UInt) : UInt);
                                    }
                                 }
                              }
                              _loc13_ = _loc13_.next;
                           }
                           _loc14_ = _loc2_/*b2internal::*/.m_jointList;
                           while(_loc14_ != null)
                           {
                              if(_loc14_.joint/*b2internal::*/.m_islandFlag != true)
                              {
                                 _loc12_ = _loc14_.other;
                                 if(_loc12_.IsActive() != false)
                                 {
                                    _loc4_.AddJoint(_loc14_.joint);
                                    _loc14_.joint/*b2internal::*/.m_islandFlag = true;
                                    if(((_loc12_/*b2internal::*/.m_flags : Int) & (B2Body/*b2internal::*/.e_islandFlag : Int)) == 0)
                                    {
                                       _loc8_[ASCompat.toInt(_loc16_ = _loc10_++)] = _loc12_;
                                       _loc12_/*b2internal::*/.m_flags = ((_loc12_/*b2internal::*/.m_flags | B2Body/*b2internal::*/.e_islandFlag : UInt) : UInt);
                                    }
                                 }
                              }
                              _loc14_ = _loc14_.next;
                           }
                        }
                     }
                     _loc4_.Solve(param1,this.m_gravity,this.m_allowSleep);
                     _loc11_ = 0;
                     while(_loc11_ < _loc4_/*b2internal::*/.m_bodyCount)
                     {
                        _loc2_ = _loc4_/*b2internal::*/.m_bodies[_loc11_];
                        if(_loc2_.GetType() == B2Body.b2_staticBody)
                        {
                           _loc2_/*b2internal::*/.m_flags = ((_loc2_/*b2internal::*/.m_flags & (~(B2Body/*b2internal::*/.e_islandFlag : Int) : UInt) : UInt) : UInt);
                        }
                        _loc11_++;
                     }
                  }
               }
            }
            _loc9_ = _loc9_/*b2internal::*/.m_next;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc8_.length)
         {
            if(_loc8_[_loc11_] == null)
            {
               break;
            }
            _loc8_[_loc11_] = null;
            _loc11_++;
         }
         _loc2_ = this/*b2internal::*/.m_bodyList;
         while(_loc2_ != null)
         {
            if(!(_loc2_.IsAwake() == false || _loc2_.IsActive() == false))
            {
               if(_loc2_.GetType() != B2Body.b2_staticBody)
               {
                  _loc2_/*b2internal::*/.SynchronizeFixtures();
               }
            }
            _loc2_ = _loc2_/*b2internal::*/.m_next;
         }
         this/*b2internal::*/.m_contactManager.FindNewContacts();
      }
      
      /*b2internal*/ public function SolveTOI(param1:B2TimeStep) 
      {
         var _loc2_:B2Body = null;
         var _loc3_:B2Fixture = null;
         var _loc4_:B2Fixture = null;
         var _loc5_:B2Body = null;
         var _loc6_:B2Body = null;
         var _loc7_:B2ContactEdge = null;
         var _loc8_:B2Joint = null;
         var _loc11_:B2Contact = null;
         var _loc12_:B2Contact = null;
         var _loc13_= Math.NaN;
         var _loc14_:B2Body = null;
         var _loc15_= 0;
         var _loc16_= 0;
         var _loc17_:B2TimeStep = null;
         var _loc18_= 0;
         var _loc19_= Math.NaN;
         var _loc20_= Math.NaN;
         var _loc21_:B2JointEdge = null;
         var _loc22_:B2Body = null;
         var _loc9_= this.m_island;
         _loc9_.Initialize(this.m_bodyCount,B2Settings.b2_maxTOIContactsPerIsland,B2Settings.b2_maxTOIJointsPerIsland,null,this/*b2internal::*/.m_contactManager/*b2internal::*/.m_contactListener,this.m_contactSolver);
         var _loc10_= s_queue;
         _loc2_ = this/*b2internal::*/.m_bodyList;
         while(_loc2_ != null)
         {
            _loc2_/*b2internal::*/.m_flags = ((_loc2_/*b2internal::*/.m_flags & (~(B2Body/*b2internal::*/.e_islandFlag : Int) : UInt) : UInt) : UInt);
            _loc2_/*b2internal::*/.m_sweep.t0 = 0;
            _loc2_ = _loc2_/*b2internal::*/.m_next;
         }
         _loc11_ = this/*b2internal::*/.m_contactList;
         while(_loc11_ != null)
         {
            _loc11_/*b2internal::*/.m_flags = ((_loc11_/*b2internal::*/.m_flags & (~((B2Contact/*b2internal::*/.e_toiFlag : Int) | (B2Contact/*b2internal::*/.e_islandFlag : Int)) : UInt) : UInt) : UInt);
            _loc11_ = _loc11_/*b2internal::*/.m_next;
         }
         _loc8_ = this.m_jointList;
         while(_loc8_ != null)
         {
            _loc8_/*b2internal::*/.m_islandFlag = false;
            _loc8_ = _loc8_/*b2internal::*/.m_next;
         }
         while(true)
         {
            _loc12_ = null;
            _loc13_ = 1;
            _loc11_ = this/*b2internal::*/.m_contactList;
            while(_loc11_ != null)
            {
               if(!(_loc11_.IsSensor() == true || _loc11_.IsEnabled() == false || _loc11_.IsContinuous() == false))
               {
                  _loc19_ = 1;
                  if(((_loc11_/*b2internal::*/.m_flags : Int) & (B2Contact/*b2internal::*/.e_toiFlag : Int)) != 0)
                  {
                     _loc19_ = _loc11_/*b2internal::*/.m_toi;
                  }
                  else
                  {
                     _loc3_ = _loc11_/*b2internal::*/.m_fixtureA;
                     _loc4_ = _loc11_/*b2internal::*/.m_fixtureB;
                     _loc5_ = _loc3_/*b2internal::*/.m_body;
                     _loc6_ = _loc4_/*b2internal::*/.m_body;
                     if((_loc5_.GetType() != B2Body.b2_dynamicBody || _loc5_.IsAwake() == false) && (_loc6_.GetType() != B2Body.b2_dynamicBody || _loc6_.IsAwake() == false))
                     {
                        _loc11_ = _loc11_/*b2internal::*/.m_next;continue;
                     }
                     _loc20_ = _loc5_/*b2internal::*/.m_sweep.t0;
                     if(_loc5_/*b2internal::*/.m_sweep.t0 < _loc6_/*b2internal::*/.m_sweep.t0)
                     {
                        _loc20_ = _loc6_/*b2internal::*/.m_sweep.t0;
                        _loc5_/*b2internal::*/.m_sweep.Advance(_loc20_);
                     }
                     else if(_loc6_/*b2internal::*/.m_sweep.t0 < _loc5_/*b2internal::*/.m_sweep.t0)
                     {
                        _loc20_ = _loc5_/*b2internal::*/.m_sweep.t0;
                        _loc6_/*b2internal::*/.m_sweep.Advance(_loc20_);
                     }
                     _loc19_ = _loc11_/*b2internal::*/.ComputeTOI(_loc5_/*b2internal::*/.m_sweep,_loc6_/*b2internal::*/.m_sweep);
                     B2Settings.b2Assert(0 <= _loc19_ && _loc19_ <= 1);
                     if(_loc19_ > 0 && _loc19_ < 1)
                     {
                        _loc19_ = (1 - _loc19_) * _loc20_ + _loc19_;
                        if(_loc19_ > 1)
                        {
                           _loc19_ = 1;
                        }
                     }
                     _loc11_/*b2internal::*/.m_toi = _loc19_;
                     _loc11_/*b2internal::*/.m_flags = ((_loc11_/*b2internal::*/.m_flags | B2Contact/*b2internal::*/.e_toiFlag : UInt) : UInt);
                  }
                  if(ASCompat.MIN_FLOAT < _loc19_ && _loc19_ < _loc13_)
                  {
                     _loc12_ = _loc11_;
                     _loc13_ = _loc19_;
                  }
               }
_loc11_ = _loc11_/*b2internal::*/.m_next;
            }
            if(_loc12_ == null || 1 - 100 * ASCompat.MIN_FLOAT < _loc13_)
            {
               break;
            }
            _loc3_ = _loc12_/*b2internal::*/.m_fixtureA;
            _loc4_ = _loc12_/*b2internal::*/.m_fixtureB;
            _loc5_ = _loc3_/*b2internal::*/.m_body;
            _loc6_ = _loc4_/*b2internal::*/.m_body;
            s_backupA.Set(_loc5_/*b2internal::*/.m_sweep);
            s_backupB.Set(_loc6_/*b2internal::*/.m_sweep);
            _loc5_/*b2internal::*/.Advance(_loc13_);
            _loc6_/*b2internal::*/.Advance(_loc13_);
            _loc12_/*b2internal::*/.Update(this/*b2internal::*/.m_contactManager/*b2internal::*/.m_contactListener);
            _loc12_/*b2internal::*/.m_flags = ((_loc12_/*b2internal::*/.m_flags & (~(B2Contact/*b2internal::*/.e_toiFlag : Int) : UInt) : UInt) : UInt);
            if(_loc12_.IsSensor() == true || _loc12_.IsEnabled() == false)
            {
               _loc5_/*b2internal::*/.m_sweep.Set(s_backupA);
               _loc6_/*b2internal::*/.m_sweep.Set(s_backupB);
               _loc5_/*b2internal::*/.SynchronizeTransform();
               _loc6_/*b2internal::*/.SynchronizeTransform();
            }
            else if(_loc12_.IsTouching() != false)
            {
               _loc14_ = _loc5_;
               if(_loc14_.GetType() != B2Body.b2_dynamicBody)
               {
                  _loc14_ = _loc6_;
               }
               _loc9_.Clear();
               _loc15_ = 0;
               _loc16_ = 0;
               _loc10_[_loc15_ + _loc16_++] = _loc14_;
               _loc14_/*b2internal::*/.m_flags = ((_loc14_/*b2internal::*/.m_flags | B2Body/*b2internal::*/.e_islandFlag : UInt) : UInt);
               while(_loc16_ > 0)
               {
                  _loc2_ = _loc10_[_loc15_++];
                  _loc16_--;
                  _loc9_.AddBody(_loc2_);
                  if(_loc2_.IsAwake() == false)
                  {
                     _loc2_.SetAwake(true);
                  }
                  if(_loc2_.GetType() == B2Body.b2_dynamicBody)
                  {
                     _loc7_ = _loc2_/*b2internal::*/.m_contactList;
                     while(_loc7_ != null)
                     {
                        if(_loc9_/*b2internal::*/.m_contactCount == _loc9_/*b2internal::*/.m_contactCapacity)
                        {
                           break;
                        }
                        if(((_loc7_.contact/*b2internal::*/.m_flags : Int) & (B2Contact/*b2internal::*/.e_islandFlag : Int)) == 0)
                        {
                           if(!(_loc7_.contact.IsSensor() == true || _loc7_.contact.IsEnabled() == false || _loc7_.contact.IsTouching() == false))
                           {
                              _loc9_.AddContact(_loc7_.contact);
                              _loc7_.contact/*b2internal::*/.m_flags = ((_loc7_.contact/*b2internal::*/.m_flags | B2Contact/*b2internal::*/.e_islandFlag : UInt) : UInt);
                              _loc22_ = _loc7_.other;
                              if(((_loc22_/*b2internal::*/.m_flags : Int) & (B2Body/*b2internal::*/.e_islandFlag : Int)) == 0)
                              {
                                 if(_loc22_.GetType() != B2Body.b2_staticBody)
                                 {
                                    _loc22_/*b2internal::*/.Advance(_loc13_);
                                    _loc22_.SetAwake(true);
                                 }
                                 _loc10_[_loc15_ + _loc16_] = _loc22_;
                                 _loc16_++;
                                 _loc22_/*b2internal::*/.m_flags = ((_loc22_/*b2internal::*/.m_flags | B2Body/*b2internal::*/.e_islandFlag : UInt) : UInt);
                              }
                           }
                        }
                        _loc7_ = _loc7_.next;
                     }
                     _loc21_ = _loc2_/*b2internal::*/.m_jointList;
                     while(_loc21_ != null)
                     {
                        if(_loc9_/*b2internal::*/.m_jointCount != _loc9_/*b2internal::*/.m_jointCapacity)
                        {
                           if(_loc21_.joint/*b2internal::*/.m_islandFlag != true)
                           {
                              _loc22_ = _loc21_.other;
                              if(_loc22_.IsActive() != false)
                              {
                                 _loc9_.AddJoint(_loc21_.joint);
                                 _loc21_.joint/*b2internal::*/.m_islandFlag = true;
                                 if(((_loc22_/*b2internal::*/.m_flags : Int) & (B2Body/*b2internal::*/.e_islandFlag : Int)) == 0)
                                 {
                                    if(_loc22_.GetType() != B2Body.b2_staticBody)
                                    {
                                       _loc22_/*b2internal::*/.Advance(_loc13_);
                                       _loc22_.SetAwake(true);
                                    }
                                    _loc10_[_loc15_ + _loc16_] = _loc22_;
                                    _loc16_++;
                                    _loc22_/*b2internal::*/.m_flags = ((_loc22_/*b2internal::*/.m_flags | B2Body/*b2internal::*/.e_islandFlag : UInt) : UInt);
                                 }
                              }
                           }
                        }
                        _loc21_ = _loc21_.next;
                     }
                  }
               }
               _loc17_ = s_timestep;
               _loc17_.warmStarting = false;
               _loc17_.dt = (1 - _loc13_) * param1.dt;
               _loc17_.inv_dt = 1 / _loc17_.dt;
               _loc17_.dtRatio = 0;
               _loc17_.velocityIterations = param1.velocityIterations;
               _loc17_.positionIterations = param1.positionIterations;
               _loc9_.SolveTOI(_loc17_);
               _loc18_ = 0;
               while(_loc18_ < _loc9_/*b2internal::*/.m_bodyCount)
               {
                  _loc2_ = _loc9_/*b2internal::*/.m_bodies[_loc18_];
                  _loc2_/*b2internal::*/.m_flags = ((_loc2_/*b2internal::*/.m_flags & (~(B2Body/*b2internal::*/.e_islandFlag : Int) : UInt) : UInt) : UInt);
                  if(_loc2_.IsAwake() != false)
                  {
                     if(_loc2_.GetType() == B2Body.b2_dynamicBody)
                     {
                        _loc2_/*b2internal::*/.SynchronizeFixtures();
                        _loc7_ = _loc2_/*b2internal::*/.m_contactList;
                        while(_loc7_ != null)
                        {
                           _loc7_.contact/*b2internal::*/.m_flags = ((_loc7_.contact/*b2internal::*/.m_flags & (~(B2Contact/*b2internal::*/.e_toiFlag : Int) : UInt) : UInt) : UInt);
                           _loc7_ = _loc7_.next;
                        }
                     }
                  }
                  _loc18_++;
               }
               _loc18_ = 0;
               while(_loc18_ < _loc9_/*b2internal::*/.m_contactCount)
               {
                  _loc11_ = _loc9_/*b2internal::*/.m_contacts[_loc18_];
                  _loc11_/*b2internal::*/.m_flags = ((_loc11_/*b2internal::*/.m_flags & (~((B2Contact/*b2internal::*/.e_toiFlag : Int) | (B2Contact/*b2internal::*/.e_islandFlag : Int)) : UInt) : UInt) : UInt);
                  _loc18_++;
               }
               _loc18_ = 0;
               while(_loc18_ < _loc9_/*b2internal::*/.m_jointCount)
               {
                  _loc8_ = _loc9_/*b2internal::*/.m_joints[_loc18_];
                  _loc8_/*b2internal::*/.m_islandFlag = false;
                  _loc18_++;
               }
               this/*b2internal::*/.m_contactManager.FindNewContacts();
            }
         }
      }
      
      /*b2internal*/ public function DrawJoint(param1:B2Joint) 
      {
         var _loc11_:B2PulleyJoint = null;
         var _loc12_:B2Vec2 = null;
         var _loc13_:B2Vec2 = null;
         var _loc2_= param1.GetBodyA();
         var _loc3_= param1.GetBodyB();
         var _loc4_= _loc2_/*b2internal::*/.m_xf;
         var _loc5_= _loc3_/*b2internal::*/.m_xf;
         var _loc6_= _loc4_.position;
         var _loc7_= _loc5_.position;
         var _loc8_= param1.GetAnchorA();
         var _loc9_= param1.GetAnchorB();
         var _loc10_= s_jointColor;
         switch(param1/*b2internal::*/.m_type)
         {
            case B2Joint/*b2internal::*/.e_distanceJoint:
               this.m_debugDraw.DrawSegment(_loc8_,_loc9_,_loc10_);
               
            case B2Joint/*b2internal::*/.e_pulleyJoint:
               _loc11_ = ASCompat.reinterpretAs(param1 , B2PulleyJoint);
               _loc12_ = _loc11_.GetGroundAnchorA();
               _loc13_ = _loc11_.GetGroundAnchorB();
               this.m_debugDraw.DrawSegment(_loc12_,_loc8_,_loc10_);
               this.m_debugDraw.DrawSegment(_loc13_,_loc9_,_loc10_);
               this.m_debugDraw.DrawSegment(_loc12_,_loc13_,_loc10_);
               
            case B2Joint/*b2internal::*/.e_mouseJoint:
               this.m_debugDraw.DrawSegment(_loc8_,_loc9_,_loc10_);
               
            default:
               if(_loc2_ != this/*b2internal::*/.m_groundBody)
               {
                  this.m_debugDraw.DrawSegment(_loc6_,_loc8_,_loc10_);
               }
               this.m_debugDraw.DrawSegment(_loc8_,_loc9_,_loc10_);
               if(_loc3_ != this/*b2internal::*/.m_groundBody)
               {
                  this.m_debugDraw.DrawSegment(_loc7_,_loc9_,_loc10_);
               }
         }
      }
      
      /*b2internal*/ public function DrawShape(param1:B2Shape, param2:B2Transform, param3:B2Color) 
      {
         var _loc4_:B2CircleShape = null;
         var _loc5_:B2Vec2 = null;
         var _loc6_= Math.NaN;
         var _loc7_:B2Vec2 = null;
         var _loc8_= 0;
         var _loc9_:B2PolygonShape = null;
         var _loc10_= 0;
         var _loc11_:Vector<B2Vec2> = null;
         var _loc12_:Vector<B2Vec2> = null;
         var _loc13_:B2EdgeShape = null;
         switch(param1/*b2internal::*/.m_type)
         {
            case B2Shape/*b2internal::*/.e_circleShape:
               _loc4_ = ASCompat.reinterpretAs(param1 , B2CircleShape);
               _loc5_ = B2Math.MulX(param2,_loc4_/*b2internal::*/.m_p);
               _loc6_ = _loc4_/*b2internal::*/.m_radius;
               _loc7_ = param2.R.col1;
               this.m_debugDraw.DrawSolidCircle(_loc5_,_loc6_,_loc7_,param3);
               
            case B2Shape/*b2internal::*/.e_polygonShape:
               _loc9_ = ASCompat.reinterpretAs(param1 , B2PolygonShape);
               _loc10_ = _loc9_.GetVertexCount();
               _loc11_ = _loc9_.GetVertices();
               _loc12_ = new Vector<B2Vec2>((_loc10_ : UInt));
               _loc8_ = 0;
               while(_loc8_ < _loc10_)
               {
                  _loc12_[_loc8_] = B2Math.MulX(param2,_loc11_[_loc8_]);
                  _loc8_++;
               }
               this.m_debugDraw.DrawSolidPolygon(_loc12_,_loc10_,param3);
               
            case B2Shape/*b2internal::*/.e_edgeShape:
               _loc13_ = ASCompat.reinterpretAs(param1 , B2EdgeShape);
               this.m_debugDraw.DrawSegment(B2Math.MulX(param2,_loc13_.GetVertex1()),B2Math.MulX(param2,_loc13_.GetVertex2()),param3);
         }
      }
   }


