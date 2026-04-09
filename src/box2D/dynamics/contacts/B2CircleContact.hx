package box2D.dynamics.contacts
;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.collision.B2Collision;
   import box2D.dynamics.B2Fixture;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2CircleContact extends B2Contact
   {
      
      public function new()
      {
         super();
      }
      
      public static function Create(param1:ASAny) : B2Contact
      {
         return new B2CircleContact();
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
         B2Collision.CollideCircles(/*b2internal::*/m_manifold,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureA.GetShape() , B2CircleShape),_loc1_/*b2internal::*/.m_xf,/*b2internal::*/ASCompat.reinterpretAs(m_fixtureB.GetShape() , B2CircleShape),_loc2_/*b2internal::*/.m_xf);
      }
   }


