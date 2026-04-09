package box2D.dynamics.contacts
;
   import box2D.collision.shapes.B2EdgeShape;
   import box2D.collision.shapes.B2PolygonShape;
   import box2D.collision.shapes.B2Shape;
   import box2D.collision.B2Manifold;
   import box2D.common.math.B2Transform;
   import box2D.common.B2Settings;
   import box2D.dynamics.B2Fixture;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2PolyAndEdgeContact extends B2Contact
   {
      
      public function new()
      {
         super();
      }
      
      public static function Create(param1:ASAny) : B2Contact
      {
         return new B2PolyAndEdgeContact();
      }
      
      public static function Destroy(param1:B2Contact, param2:ASAny) 
      {
      }
      
      public override function Reset(param1:B2Fixture= null, param2:B2Fixture= null) 
      {
         super/*b2internal::*/.Reset(param1,param2);
         B2Settings.b2Assert(param1.GetType() == B2Shape/*b2internal::*/.e_polygonShape);
         B2Settings.b2Assert(param2.GetType() == B2Shape/*b2internal::*/.e_edgeShape);
      }
      
      override public function Evaluate() 
      {
         var _loc1_= /*b2internal::*/m_fixtureA.GetBody();
         var _loc2_= /*b2internal::*/m_fixtureB.GetBody();
         this.b2CollidePolyAndEdge(/*b2internal::*/m_manifold,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureA.GetShape() , B2PolygonShape),_loc1_/*b2internal::*/.m_xf,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureB.GetShape() , B2EdgeShape),_loc2_/*b2internal::*/.m_xf);
      }
      
      function b2CollidePolyAndEdge(param1:B2Manifold, param2:B2PolygonShape, param3:B2Transform, param4:B2EdgeShape, param5:B2Transform) 
      {
      }
   }


