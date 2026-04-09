package box2D.dynamics.contacts
;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.collision.shapes.B2EdgeShape;
   import box2D.collision.B2Manifold;
   import box2D.common.math.B2Transform;
   import box2D.dynamics.B2Fixture;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2EdgeAndCircleContact extends B2Contact
   {
      
      public function new()
      {
         super();
      }
      
      public static function Create(param1:ASAny) : B2Contact
      {
         return new B2EdgeAndCircleContact();
      }
      
      public static function Destroy(param1:B2Contact, param2:ASAny) 
      {
      }
      
      public override function Reset(param1:B2Fixture= null, param2:B2Fixture= null) 
      {
         super/*b2internal::*/.Reset(param1,param2);
      }
      
      override public function Evaluate() 
      {
         var _loc1_= /*b2internal::*/m_fixtureA.GetBody();
         var _loc2_= /*b2internal::*/m_fixtureB.GetBody();
         this.b2CollideEdgeAndCircle(/*b2internal::*/m_manifold,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureA.GetShape() , B2EdgeShape),_loc1_/*b2internal::*/.m_xf,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureB.GetShape() , B2CircleShape),_loc2_/*b2internal::*/.m_xf);
      }
      
      function b2CollideEdgeAndCircle(param1:B2Manifold, param2:B2EdgeShape, param3:B2Transform, param4:B2CircleShape, param5:B2Transform) 
      {
      }
   }


