package box2D.collision.shapes
;
   import box2D.collision.B2AABB;
   import box2D.collision.B2Distance;
   import box2D.collision.B2DistanceInput;
   import box2D.collision.B2DistanceOutput;
   import box2D.collision.B2DistanceProxy;
   import box2D.collision.B2RayCastInput;
   import box2D.collision.B2RayCastOutput;
   import box2D.collision.B2SimplexCache;
   import box2D.common.math.B2Transform;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Settings;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2Shape
   {
      
      /*b2internal*/ public static inline final e_unknownShape= -1;
      
      /*b2internal*/ public static inline final e_circleShape= 0;
      
      /*b2internal*/ public static inline final e_polygonShape= 1;
      
      /*b2internal*/ public static inline final e_edgeShape= 2;
      
      /*b2internal*/ public static inline final e_shapeTypeCount= 3;
      
      public static inline final e_hitCollide= 1;
      
      public static inline final e_missCollide= 0;
      
      public static inline final e_startsInsideCollide= -1;
      
      /*b2internal*/ public var m_type:Int = 0;
      
      /*b2internal*/ public var m_radius:Float = Math.NaN;
      
      public function new()
      {
         
         this/*b2internal::*/.m_type = /*b2internal::*/e_unknownShape;
         this/*b2internal::*/.m_radius = B2Settings.b2_linearSlop;
      }
      
      public static function TestOverlap(param1:B2Shape, param2:B2Transform, param3:B2Shape, param4:B2Transform) : Bool
      {
         var _loc5_= new B2DistanceInput();
         _loc5_.proxyA = new B2DistanceProxy();
         _loc5_.proxyA.Set(param1);
         _loc5_.proxyB = new B2DistanceProxy();
         _loc5_.proxyB.Set(param3);
         _loc5_.transformA = param2;
         _loc5_.transformB = param4;
         _loc5_.useRadii = true;
         var _loc6_= new B2SimplexCache();
         _loc6_.count = (0 : UInt);
         var _loc7_= new B2DistanceOutput();
         B2Distance.Distance(_loc7_,_loc6_,_loc5_);
         return _loc7_.distance < 10 * ASCompat.MIN_FLOAT;
      }
      
      public function Copy() : B2Shape
      {
         return null;
      }
      
      public function Set(param1:B2Shape) 
      {
         this/*b2internal::*/.m_radius = param1/*b2internal::*/.m_radius;
      }
      
      public function GetType() : Int
      {
         return this/*b2internal::*/.m_type;
      }
      
      public function TestPoint(param1:B2Transform, param2:B2Vec2) : Bool
      {
         return false;
      }
      
      public function RayCast(param1:B2RayCastOutput, param2:B2RayCastInput, param3:B2Transform) : Bool
      {
         return false;
      }
      
      public function ComputeAABB(param1:B2AABB, param2:B2Transform) 
      {
      }
      
      public function ComputeMass(param1:B2MassData, param2:Float) 
      {
      }
      
      public function ComputeSubmergedArea(param1:B2Vec2, param2:Float, param3:B2Transform, param4:B2Vec2) : Float
      {
         return 0;
      }
   }


