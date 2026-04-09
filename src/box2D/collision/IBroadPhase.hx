package box2D.collision
;
   import box2D.common.math.B2Vec2;
   
    interface IBroadPhase
   {
      
      function CreateProxy(param1:B2AABB, param2:ASAny) : ASAny;
      
      function DestroyProxy(param1:ASAny) : Void;
      
      function MoveProxy(param1:ASAny, param2:B2AABB, param3:B2Vec2) : Void;
      
      function TestOverlap(param1:ASAny, param2:ASAny) : Bool;
      
      function GetUserData(param1:ASAny) : ASAny;
      
      function GetFatAABB(param1:ASAny) : B2AABB;
      
      function GetProxyCount() : Int;
      
      function UpdatePairs(param1:ASFunction) : Void;
      
      function Query(param1:ASFunction, param2:B2AABB) : Void;
      
      function RayCast(param1:ASFunction, param2:B2RayCastInput) : Void;
      
      function Validate() : Void;
      
      function Rebalance(param1:Int) : Void;
   }


