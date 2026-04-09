package com.greensock.easing
;
    class Linear
   {
      
      public static inline final power= (0 : UInt);
      
      public function new()
      {
         
      }
      
      public static function easeOut(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return param3 * param1 / param4 + param2;
      }
      
      public static function easeIn(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return param3 * param1 / param4 + param2;
      }
      
      public static function easeNone(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return param3 * param1 / param4 + param2;
      }
      
      public static function easeInOut(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return param3 * param1 / param4 + param2;
      }
   }


