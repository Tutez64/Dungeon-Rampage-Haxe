package com.greensock.plugins
;
   import com.greensock.*;
   
    class AutoAlphaPlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      var _target:ASObject;
      
      var _ignoreVisible:Bool = false;
      
      public function new()
      {
         super();
         this.propName = "autoAlpha";
         this.overwriteProps = ["alpha","visible"];
      }
      
      override public function killProps(param1:ASObject) 
      {
         super.killProps(param1);
         _ignoreVisible = param1.hasOwnProperty("visible" );
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         _target = param1;
         addTween(param1,"alpha",ASCompat.toNumberField(param1, "alpha"),param2,"alpha");
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         updateTweens(param1);
         if(!_ignoreVisible)
         {
            ASCompat.setProperty(_target, "visible", ASCompat.toNumberField(_target, "alpha") != 0);
         }
return param1;
      }
   }


