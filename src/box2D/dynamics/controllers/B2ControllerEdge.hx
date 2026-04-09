package box2D.dynamics.controllers
;
   import box2D.dynamics.B2Body;
   
    class B2ControllerEdge
   {
      
      public var controller:B2Controller;
      
      public var body:B2Body;
      
      public var prevBody:B2ControllerEdge;
      
      public var nextBody:B2ControllerEdge;
      
      public var prevController:B2ControllerEdge;
      
      public var nextController:B2ControllerEdge;
      
      public function new()
      {
         
      }
   }


