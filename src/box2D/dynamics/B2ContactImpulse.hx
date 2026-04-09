package box2D.dynamics
;
   import box2D.common.B2Settings;
   
    class B2ContactImpulse
   {
      
      public var normalImpulses:Vector<Float> = new Vector((B2Settings.b2_maxManifoldPoints : UInt));
      
      public var tangentImpulses:Vector<Float> = new Vector((B2Settings.b2_maxManifoldPoints : UInt));
      
      public function new()
      {
         
      }
   }


