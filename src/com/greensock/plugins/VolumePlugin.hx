package com.greensock.plugins
;
   import com.greensock.*;
   import flash.media.SoundTransform;
   
    class VolumePlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      var _target:ASObject;
      
      var _st:SoundTransform;
      
      public function new()
      {
         super();
         this.propName = "volume";
         this.overwriteProps = ["volume"];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         if(Math.isNaN(ASCompat.toNumber(param2)) || param1.hasOwnProperty("volume") || !param1.hasOwnProperty("soundTransform"))
         {
            return false;
         }
         _target = param1;
         _st = ASCompat.dynamicAs(_target.soundTransform, flash.media.SoundTransform);
         addTween(_st,"volume",_st.volume,param2,"volume");
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         updateTweens(param1);
         ASCompat.setProperty(_target, "soundTransform", _st);
return param1;
      }
   }


