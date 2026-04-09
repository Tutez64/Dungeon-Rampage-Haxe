package box2D.collision
;
   import box2D.common.*;
   import box2D.common.math.*;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2Manifold
   {
      
      public static inline final e_circles= 1;
      
      public static inline final e_faceA= 2;
      
      public static inline final e_faceB= 4;
      
      public var m_points:Vector<B2ManifoldPoint>;
      
      public var m_localPlaneNormal:B2Vec2;
      
      public var m_localPoint:B2Vec2;
      
      public var m_type:Int = 0;
      
      public var m_pointCount:Int = 0;
      
      public function new()
      {
         
         this.m_points = new Vector<B2ManifoldPoint>((B2Settings.b2_maxManifoldPoints : UInt));
         var _loc1_= 0;
         while(_loc1_ < B2Settings.b2_maxManifoldPoints)
         {
            this.m_points[_loc1_] = new B2ManifoldPoint();
            _loc1_++;
         }
         this.m_localPlaneNormal = new B2Vec2();
         this.m_localPoint = new B2Vec2();
      }
      
      public function Reset() 
      {
         var _loc1_= 0;
         while(_loc1_ < B2Settings.b2_maxManifoldPoints)
         {
            this.m_points[_loc1_] .Reset();
            _loc1_++;
         }
         this.m_localPlaneNormal.SetZero();
         this.m_localPoint.SetZero();
         this.m_type = 0;
         this.m_pointCount = 0;
      }
      
      public function Set(param1:B2Manifold) 
      {
         this.m_pointCount = param1.m_pointCount;
         var _loc2_= 0;
         while(_loc2_ < B2Settings.b2_maxManifoldPoints)
         {
            this.m_points[_loc2_] .Set(param1.m_points[_loc2_]);
            _loc2_++;
         }
         this.m_localPlaneNormal.SetV(param1.m_localPlaneNormal);
         this.m_localPoint.SetV(param1.m_localPoint);
         this.m_type = param1.m_type;
      }
      
      public function Copy() : B2Manifold
      {
         var _loc1_= new B2Manifold();
         _loc1_.Set(this);
         return _loc1_;
      }
   }


