package box2D.dynamics.contacts
;
   import box2D.collision.*;
   import box2D.collision.shapes.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2ContactFactory
   {
      
      var m_registers:Vector<Vector<B2ContactRegister>>;
      
      var m_allocator:ASAny;
      
      public function new(param1:ASAny)
      {
         
         this.m_allocator = param1;
         this/*b2internal::*/.InitializeRegisters();
      }
      
      /*b2internal*/ public function AddType(param1:ASFunction, param2:ASFunction, param3:Int, param4:Int) 
      {
         this.m_registers[param3][param4].createFcn = param1;
         this.m_registers[param3][param4].destroyFcn = param2;
         this.m_registers[param3][param4].primary = true;
         if(param3 != param4)
         {
            this.m_registers[param4][param3].createFcn = param1;
            this.m_registers[param4][param3].destroyFcn = param2;
            this.m_registers[param4][param3].primary = false;
         }
      }
      
      /*b2internal*/ public function InitializeRegisters() 
      {
         var _loc2_= 0;
         this.m_registers = new Vector<Vector<B2ContactRegister>>((B2Shape/*b2internal::*/.e_shapeTypeCount : UInt));
         var _loc1_= 0;
         while(_loc1_ < B2Shape/*b2internal::*/.e_shapeTypeCount)
         {
            this.m_registers[_loc1_] = new Vector<B2ContactRegister>((B2Shape/*b2internal::*/.e_shapeTypeCount : UInt));
            _loc2_ = 0;
            while(_loc2_ < B2Shape/*b2internal::*/.e_shapeTypeCount)
            {
               this.m_registers[_loc1_][_loc2_] = new B2ContactRegister();
               _loc2_++;
            }
            _loc1_++;
         }
         this/*b2internal::*/.AddType(B2CircleContact.Create,B2CircleContact.Destroy,B2Shape/*b2internal::*/.e_circleShape,B2Shape/*b2internal::*/.e_circleShape);
         this/*b2internal::*/.AddType(B2PolyAndCircleContact.Create,B2PolyAndCircleContact.Destroy,B2Shape/*b2internal::*/.e_polygonShape,B2Shape/*b2internal::*/.e_circleShape);
         this/*b2internal::*/.AddType(B2PolygonContact.Create,B2PolygonContact.Destroy,B2Shape/*b2internal::*/.e_polygonShape,B2Shape/*b2internal::*/.e_polygonShape);
         this/*b2internal::*/.AddType(B2EdgeAndCircleContact.Create,B2EdgeAndCircleContact.Destroy,B2Shape/*b2internal::*/.e_edgeShape,B2Shape/*b2internal::*/.e_circleShape);
         this/*b2internal::*/.AddType(B2PolyAndEdgeContact.Create,B2PolyAndEdgeContact.Destroy,B2Shape/*b2internal::*/.e_polygonShape,B2Shape/*b2internal::*/.e_edgeShape);
      }
      
      public function Create(param1:B2Fixture, param2:B2Fixture) : B2Contact
      {
         var _loc6_:B2Contact = null;
         var _loc3_= param1.GetType();
         var _loc4_= param2.GetType();
         var _loc5_= this.m_registers[_loc3_][_loc4_];
         if(_loc5_.pool != null)
         {
            _loc6_ = _loc5_.pool;
            _loc5_.pool = _loc6_/*b2internal::*/.m_next;
            --_loc5_.poolCount;
            _loc6_/*b2internal::*/.Reset(param1,param2);
            return _loc6_;
         }
         var _loc7_= _loc5_.createFcn;
         if(_loc7_ != null)
         {
            if(_loc5_.primary)
            {
               _loc6_ = ASCompat.dynamicAs(_loc7_(this.m_allocator), box2D.dynamics.contacts.B2Contact);
               _loc6_/*b2internal::*/.Reset(param1,param2);
               return _loc6_;
            }
            _loc6_ = ASCompat.dynamicAs(_loc7_(this.m_allocator), box2D.dynamics.contacts.B2Contact);
            _loc6_/*b2internal::*/.Reset(param2,param1);
            return _loc6_;
         }
         return null;
      }
      
      public function Destroy(param1:B2Contact) 
      {
         if(param1/*b2internal::*/.m_manifold.m_pointCount > 0)
         {
            param1/*b2internal::*/.m_fixtureA/*b2internal::*/.m_body.SetAwake(true);
            param1/*b2internal::*/.m_fixtureB/*b2internal::*/.m_body.SetAwake(true);
         }
         var _loc2_= param1/*b2internal::*/.m_fixtureA.GetType();
         var _loc3_= param1/*b2internal::*/.m_fixtureB.GetType();
         var _loc4_= this.m_registers[_loc2_][_loc3_];
         ++_loc4_.poolCount;
         param1/*b2internal::*/.m_next = _loc4_.pool;
         _loc4_.pool = param1;
         var _loc5_= _loc4_.destroyFcn;
         _loc5_(param1,this.m_allocator);
      }
   }


