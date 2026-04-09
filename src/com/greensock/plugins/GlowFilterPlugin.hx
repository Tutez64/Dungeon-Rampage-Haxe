package com.greensock.plugins
;
   import com.greensock.*;
   import flash.filters.GlowFilter;
   
    class GlowFilterPlugin extends FilterPlugin
   {
      
      public static inline final API:Float = 1;
      
      static var _propNames:Array<ASAny> = ["color","alpha","blurX","blurY","strength","quality","inner","knockout"];
      
      public function new()
      {
         super();
         this.propName = "glowFilter";
         this.overwriteProps = ["glowFilter"];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _target = param1;
         _type = GlowFilter;
         initFilter(param2,new GlowFilter((16777215 : UInt),0,0,0,ASCompat.toNumber(ASCompat.thisOrDefault(ASCompat.toNumber(param2.strength) , 1)),ASCompat.thisOrDefault(ASCompat.toInt(param2.quality) , 2),ASCompat.toBool(param2.inner),ASCompat.toBool(param2.knockout)),_propNames);
         return true;
      }
   }


