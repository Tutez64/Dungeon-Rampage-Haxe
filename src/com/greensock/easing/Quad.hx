package com.greensock.easing
;
    class Quad
   {
      
      public static inline final power= (1 : UInt);
      
      public function new()
      {
         
      }
      
      public static function easeOut(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return -param3 * (param1 = param1 / param4) * (param1 - 2) + param2;
      }
      
      public static function easeIn(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         return param3 * (param1 = param1 / param4) * param1 + param2;
      }
      
      public static function easeInOut(param1:Float, param2:Float, param3:Float, param4:Float) : Float
      {
         param1 = param1 / (param4 * 0.5);
         if(param1 < 1)
         {
            return param3 * 0.5 * param1 * param1 + param2;
         }
         return -param3 * 0.5 * (--param1 * (param1 - 2) - 1) + param2;
      }
   }


