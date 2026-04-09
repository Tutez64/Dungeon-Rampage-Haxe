package box2D.common
;
    class B2Settings
   {
      
      public static inline final VERSION= "2.1alpha";
      
      public static inline final USHRT_MAX_cpp/*cpp macro conflict*/= 65535;
      
      public static final b2_pi:Float = Math.PI;
      
      public static inline final b2_maxManifoldPoints= 2;
      
      public static inline final b2_aabbExtension:Float = 0.1;
      
      public static inline final b2_aabbMultiplier:Float = 2;
      
      public static final b2_polygonRadius:Float = 2 * b2_linearSlop;
      
      public static inline final b2_linearSlop:Float = 0.005;
      
      public static final b2_angularSlop:Float = 2 / 180 * b2_pi;
      
      public static final b2_toiSlop:Float = 8 * b2_linearSlop;
      
      public static inline final b2_maxTOIContactsPerIsland= 32;
      
      public static inline final b2_maxTOIJointsPerIsland= 32;
      
      public static inline final b2_velocityThreshold:Float = 1;
      
      public static inline final b2_maxLinearCorrection:Float = 0.2;
      
      public static final b2_maxAngularCorrection:Float = 8 / 180 * b2_pi;
      
      public static inline final b2_maxTranslation:Float = 2;
      
      public static final b2_maxTranslationSquared:Float = b2_maxTranslation * b2_maxTranslation;
      
      public static final b2_maxRotation:Float = 0.5 * b2_pi;
      
      public static final b2_maxRotationSquared:Float = b2_maxRotation * b2_maxRotation;
      
      public static inline final b2_contactBaumgarte:Float = 0.2;
      
      public static inline final b2_timeToSleep:Float = 0.5;
      
      public static inline final b2_linearSleepTolerance:Float = 0.01;
      
      public static final b2_angularSleepTolerance:Float = 2 / 180 * B2Settings.b2_pi;
      
      public function new()
      {
         
      }
      
      public static function b2MixFriction(param1:Float, param2:Float) : Float
      {
         return Math.sqrt(param1 * param2);
      }
      
      public static function b2MixRestitution(param1:Float, param2:Float) : Float
      {
         return param1 > param2 ? param1 : param2;
      }
      
      public static function b2Assert(param1:Bool) 
      {
         if(!param1)
         {
            throw "Assertion Failed";
         }
      }
   }


