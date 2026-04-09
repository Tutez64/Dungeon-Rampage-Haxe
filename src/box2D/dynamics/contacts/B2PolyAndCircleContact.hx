package box2D.dynamics.contacts
;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.collision.shapes.B2PolygonShape;
   import box2D.collision.shapes.B2Shape;
   import box2D.collision.B2Collision;
   import box2D.common.B2Settings;
   import box2D.dynamics.B2Fixture;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2PolyAndCircleContact extends B2Contact
   {
      
      public function new()
      {
         super();
      }
      
      public static function Create(param1:ASAny) : B2Contact
      {
         return new B2PolyAndCircleContact();
      }
      
      public static function Destroy(param1:B2Contact, param2:ASAny) 
      {
      }
      
      public override function Reset(param1:B2Fixture= null, param2:B2Fixture= null) 
      {
         super/*b2internal::*/.Reset(param1,param2);
         B2Settings.b2Assert(param1.GetType() == B2Shape/*b2internal::*/.e_polygonShape);
         B2Settings.b2Assert(param2.GetType() == B2Shape/*b2internal::*/.e_circleShape);
      }
      
      override public function Evaluate() 
      {
         var _loc1_= /*b2internal::*/m_fixtureA/*b2internal::*/.m_body;
         var _loc2_= /*b2internal::*/m_fixtureB/*b2internal::*/.m_body;
         B2Collision.CollidePolygonAndCircle(/*b2internal::*/m_manifold,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureA.GetShape() , B2PolygonShape),_loc1_/*b2internal::*/.m_xf,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureB.GetShape() , B2CircleShape),_loc2_/*b2internal::*/.m_xf);
      }
   }


