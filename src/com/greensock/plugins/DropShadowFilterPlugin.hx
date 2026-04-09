package com.greensock.plugins
;
   import com.greensock.*;
   import flash.filters.DropShadowFilter;
   
    class DropShadowFilterPlugin extends FilterPlugin
   {
      
      public static inline final API:Float = 1;
      
      static var _propNames:Array<ASAny> = ["distance","angle","color","alpha","blurX","blurY","strength","quality","inner","knockout","hideObject"];
      
      public function new()
      {
         super();
         this.propName = "dropShadowFilter";
         this.overwriteProps = ["dropShadowFilter"];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _target = param1;
         _type = DropShadowFilter;
         initFilter(param2,new DropShadowFilter(0,45,(0 : UInt),0,0,0,1,ASCompat.thisOrDefault(ASCompat.toInt(param2.quality) , 2),ASCompat.toBool(param2.inner),ASCompat.toBool(param2.knockout),ASCompat.toBool(param2.hideObject)),_propNames);
         return true;
      }
   }


