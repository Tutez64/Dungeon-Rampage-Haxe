package com.greensock.plugins
;
   import com.greensock.TweenLite;
   
    class BezierThroughPlugin extends BezierPlugin
   {
      
      public static inline final API:Float = 1;
      
      public function new()
      {
         super();
         this.propName = "bezierThrough";
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         if(!Std.isOfType(param2 , Array))
         {
            return false;
         }
         init(param3,ASCompat.dynamicAs(param2 , Array),true);
         return true;
      }
   }


