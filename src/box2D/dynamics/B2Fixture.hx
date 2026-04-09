package box2D.dynamics
;
   import box2D.collision.IBroadPhase;
   import box2D.collision.shapes.B2MassData;
   import box2D.collision.shapes.B2Shape;
   import box2D.collision.B2AABB;
   import box2D.collision.B2RayCastInput;
   import box2D.collision.B2RayCastOutput;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Transform;
   import box2D.common.math.B2Vec2;
   import box2D.dynamics.contacts.B2Contact;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2Fixture
   {
      
      var m_massData:B2MassData;
      
      /*b2internal*/ public var m_aabb:B2AABB;
      
      /*b2internal*/ public var m_density:Float = Math.NaN;
      
      /*b2internal*/ public var m_next:B2Fixture;
      
      /*b2internal*/ public var m_body:B2Body;
      
      /*b2internal*/ public var m_shape:B2Shape;
      
      /*b2internal*/ public var m_friction:Float = Math.NaN;
      
      /*b2internal*/ public var m_restitution:Float = Math.NaN;
      
      /*b2internal*/ public var m_proxy:ASAny;
      
      /*b2internal*/ public var m_filter:B2FilterData = new B2FilterData();
      
      /*b2internal*/ public var m_isSensor:Bool = false;
      
      /*b2internal*/ public var m_userData:ASAny;
      
      public function new()
      {
         
         this/*b2internal::*/.m_aabb = new B2AABB();
         this/*b2internal::*/.m_userData = null;
         this/*b2internal::*/.m_body = null;
         this/*b2internal::*/.m_next = null;
         this/*b2internal::*/.m_shape = null;
         this/*b2internal::*/.m_density = 0;
         this/*b2internal::*/.m_friction = 0;
         this/*b2internal::*/.m_restitution = 0;
      }
      
      public function GetType() : Int
      {
         return this/*b2internal::*/.m_shape.GetType();
      }
      
      public function GetShape() : B2Shape
      {
         return this/*b2internal::*/.m_shape;
      }
      
      public function SetSensor(param1:Bool) 
      {
         var _loc3_:B2Contact = null;
         var _loc4_:B2Fixture = null;
         var _loc5_:B2Fixture = null;
         if(this/*b2internal::*/.m_isSensor == param1)
         {
            return;
         }
         this/*b2internal::*/.m_isSensor = param1;
         if(this/*b2internal::*/.m_body == null)
         {
            return;
         }
         var _loc2_= this/*b2internal::*/.m_body.GetContactList();
         while(_loc2_ != null)
         {
            _loc3_ = _loc2_.contact;
            _loc4_ = _loc3_.GetFixtureA();
            _loc5_ = _loc3_.GetFixtureB();
            if(_loc4_ == this || _loc5_ == this)
            {
               _loc3_.SetSensor(_loc4_.IsSensor() || _loc5_.IsSensor());
            }
            _loc2_ = _loc2_.next;
         }
      }
      
      public function IsSensor() : Bool
      {
         return this/*b2internal::*/.m_isSensor;
      }
      
      public function SetFilterData(param1:B2FilterData) 
      {
         var _loc3_:B2Contact = null;
         var _loc4_:B2Fixture = null;
         var _loc5_:B2Fixture = null;
         this/*b2internal::*/.m_filter = param1.Copy();
         if(this/*b2internal::*/.m_body != null)
         {
            return;
         }
         var _loc2_= this/*b2internal::*/.m_body.GetContactList();
         while(_loc2_ != null)
         {
            _loc3_ = _loc2_.contact;
            _loc4_ = _loc3_.GetFixtureA();
            _loc5_ = _loc3_.GetFixtureB();
            if(_loc4_ == this || _loc5_ == this)
            {
               _loc3_.FlagForFiltering();
            }
            _loc2_ = _loc2_.next;
         }
      }
      
      public function GetFilterData() : B2FilterData
      {
         return this/*b2internal::*/.m_filter.Copy();
      }
      
      public function GetBody() : B2Body
      {
         return this/*b2internal::*/.m_body;
      }
      
      public function GetNext() : B2Fixture
      {
         return this/*b2internal::*/.m_next;
      }
      
      public function GetUserData() : ASAny
      {
         return this/*b2internal::*/.m_userData;
      }
      
      public function SetUserData(param1:ASAny) 
      {
         this/*b2internal::*/.m_userData = param1;
      }
      
      public function TestPoint(param1:B2Vec2) : Bool
      {
         return this/*b2internal::*/.m_shape.TestPoint(this/*b2internal::*/.m_body.GetTransform(),param1);
      }
      
      public function RayCast(param1:B2RayCastOutput, param2:B2RayCastInput) : Bool
      {
         return this/*b2internal::*/.m_shape.RayCast(param1,param2,this/*b2internal::*/.m_body.GetTransform());
      }
      
      public function GetMassData(param1:B2MassData = null) : B2MassData
      {
         if(param1 == null)
         {
            param1 = new B2MassData();
         }
         this/*b2internal::*/.m_shape.ComputeMass(param1,this/*b2internal::*/.m_density);
         return param1;
      }
      
      public function SetDensity(param1:Float) 
      {
         this/*b2internal::*/.m_density = param1;
      }
      
      public function GetDensity() : Float
      {
         return this/*b2internal::*/.m_density;
      }
      
      public function GetFriction() : Float
      {
         return this/*b2internal::*/.m_friction;
      }
      
      public function SetFriction(param1:Float) 
      {
         this/*b2internal::*/.m_friction = param1;
      }
      
      public function GetRestitution() : Float
      {
         return this/*b2internal::*/.m_restitution;
      }
      
      public function SetRestitution(param1:Float) 
      {
         this/*b2internal::*/.m_restitution = param1;
      }
      
      public function GetAABB() : B2AABB
      {
         return this/*b2internal::*/.m_aabb;
      }
      
      /*b2internal*/ public function Create(param1:B2Body, param2:B2Transform, param3:B2FixtureDef) 
      {
         this/*b2internal::*/.m_userData = param3.userData;
         this/*b2internal::*/.m_friction = param3.friction;
         this/*b2internal::*/.m_restitution = param3.restitution;
         this/*b2internal::*/.m_body = param1;
         this/*b2internal::*/.m_next = null;
         this/*b2internal::*/.m_filter = param3.filter.Copy();
         this/*b2internal::*/.m_isSensor = param3.isSensor;
         this/*b2internal::*/.m_shape = param3.shape.Copy();
         this/*b2internal::*/.m_density = param3.density;
      }
      
      /*b2internal*/ public function Destroy() 
      {
         this/*b2internal::*/.m_shape = null;
      }
      
      /*b2internal*/ public function CreateProxy(param1:IBroadPhase, param2:B2Transform) 
      {
         this/*b2internal::*/.m_shape.ComputeAABB(this/*b2internal::*/.m_aabb,param2);
         this/*b2internal::*/.m_proxy = param1.CreateProxy(this/*b2internal::*/.m_aabb,this);
      }
      
      /*b2internal*/ public function DestroyProxy(param1:IBroadPhase) 
      {
         if(this/*b2internal::*/.m_proxy == null)
         {
            return;
         }
         param1.DestroyProxy(this/*b2internal::*/.m_proxy);
         this/*b2internal::*/.m_proxy = null;
      }
      
      /*b2internal*/ public function Synchronize(param1:IBroadPhase, param2:B2Transform, param3:B2Transform) 
      {
         if(!ASCompat.toBool(this/*b2internal::*/.m_proxy))
         {
            return;
         }
         var _loc4_= new B2AABB();
         var _loc5_= new B2AABB();
         this/*b2internal::*/.m_shape.ComputeAABB(_loc4_,param2);
         this/*b2internal::*/.m_shape.ComputeAABB(_loc5_,param3);
         this/*b2internal::*/.m_aabb._Combine(_loc4_,_loc5_);
         var _loc6_= B2Math.SubtractVV(param3.position,param2.position);
         param1.MoveProxy(this/*b2internal::*/.m_proxy,this/*b2internal::*/.m_aabb,_loc6_);
      }
   }


