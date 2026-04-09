package box2D.dynamics.contacts
;
    class B2ContactRegister
   {
      
      public var createFcn:ASFunction;
      
      public var destroyFcn:ASFunction;
      
      public var primary:Bool = false;
      
      public var pool:B2Contact;
      
      public var poolCount:Int = 0;
      
      public function new()
      {
         
      }
   }


