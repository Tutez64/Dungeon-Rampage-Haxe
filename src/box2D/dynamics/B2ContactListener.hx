package box2D.dynamics
;
   import box2D.collision.B2Manifold;
   import box2D.dynamics.contacts.B2Contact;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2ContactListener
   {
      
      /*b2internal*/ public static var b2_defaultListener:B2ContactListener = new B2ContactListener();
      
      public function new()
      {
         
      }
      
      public function BeginContact(param1:B2Contact) 
      {
      }
      
      public function EndContact(param1:B2Contact) 
      {
      }
      
      public function PreSolve(param1:B2Contact, param2:B2Manifold) 
      {
      }
      
      public function PostSolve(param1:B2Contact, param2:B2ContactImpulse) 
      {
      }
   }


