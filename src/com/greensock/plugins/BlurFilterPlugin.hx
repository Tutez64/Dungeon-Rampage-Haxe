package com.greensock.plugins
;
   import com.greensock.*;
   import flash.filters.BlurFilter;
   
    class BlurFilterPlugin extends FilterPlugin
   {
      
      public static inline final API:Float = 1;
      
      static var _propNames:Array<ASAny> = ["blurX","blurY","quality"];
      
      public function new()
      {
         super();
         this.propName = "blurFilter";
         this.overwriteProps = ["blurFilter"];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _target = param1;
         _type = BlurFilter;
         initFilter(param2,new BlurFilter(0,0,ASCompat.thisOrDefault(ASCompat.toInt(param2.quality) , 2)),_propNames);
         return true;
      }
   }


