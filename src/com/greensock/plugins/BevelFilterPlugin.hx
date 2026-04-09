package com.greensock.plugins
;
   import com.greensock.*;
   import flash.filters.BevelFilter;
   
    class BevelFilterPlugin extends FilterPlugin
   {
      
      public static inline final API:Float = 1;
      
      static var _propNames:Array<ASAny> = ["distance","angle","highlightColor","highlightAlpha","shadowColor","shadowAlpha","blurX","blurY","strength","quality"];
      
      public function new()
      {
         super();
         this.propName = "bevelFilter";
         this.overwriteProps = ["bevelFilter"];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _target = param1;
         _type = BevelFilter;
         initFilter(param2,new BevelFilter(0,0,(16777215 : UInt),0.5,(0 : UInt),0.5,2,2,0,ASCompat.thisOrDefault(ASCompat.toInt(param2.quality) , 2)),_propNames);
         return true;
      }
   }


