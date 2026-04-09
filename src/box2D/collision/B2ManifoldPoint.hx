package box2D.collision
;
   import box2D.common.math.B2Vec2;
   
    class B2ManifoldPoint
   {
      
      public var m_localPoint:B2Vec2 = new B2Vec2();
      
      public var m_normalImpulse:Float = Math.NaN;
      
      public var m_tangentImpulse:Float = Math.NaN;
      
      public var m_id:B2ContactID = new B2ContactID();
      
      public function new()
      {
         
         this.Reset();
      }
      
      public function Reset() 
      {
         this.m_localPoint.SetZero();
         this.m_normalImpulse = 0;
         this.m_tangentImpulse = 0;
         this.m_id.key = (0 : UInt);
      }
      
      public function Set(param1:B2ManifoldPoint) 
      {
         this.m_localPoint.SetV(param1.m_localPoint);
         this.m_normalImpulse = param1.m_normalImpulse;
         this.m_tangentImpulse = param1.m_tangentImpulse;
         this.m_id.Set(param1.m_id);
      }
   }


