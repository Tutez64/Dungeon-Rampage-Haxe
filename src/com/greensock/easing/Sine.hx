package com.greensock.easing
;
    class Sine
   {
      
      static final _HALF_PI:Float = Math.PI * 0.5;
      
      public function new()
      {
         
      }
      
      public static function easeOut(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return param3 * Math.sin(param1 / param4 * _HALF_PI) + param2;
      }
      
      public static function easeIn(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return -param3 * Math.cos(param1 / param4 * _HALF_PI) + param3 + param2;
      }
      
      public static function easeInOut(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return -param3 * 0.5 * (Math.cos(Math.PI * param1 / param4) - 1) + param2;
      }
   }


