package com.greensock.plugins
;
   import com.greensock.*;
   
    class VisiblePlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      var _target:ASObject;
      
      var _initVal:Bool = false;
      
      var _visible:Bool = false;
      
      var _tween:TweenLite;
      
      public function new()
      {
         super();
         this.propName = "visible";
         this.overwriteProps = ["visible"];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _target = param1;
         _tween = param3;
         _initVal = ASCompat.toBool(_target.visible);
         _visible = ASCompat.toBool(param2);
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         if(param1 == 1 && (_tween.cachedDuration == _tween.cachedTime || _tween.cachedTime == 0))
         {
            ASCompat.setProperty(_target, "visible", _visible);
         }
         else
         {
            ASCompat.setProperty(_target, "visible", _initVal);
         }
return param1;
      }
   }


