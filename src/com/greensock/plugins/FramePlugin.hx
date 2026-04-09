package com.greensock.plugins
;
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   
    class FramePlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      var _target:MovieClip;
      
      public var frame:Int = 0;
      
      public function new()
      {
         super();
         this.propName = "frame";
         this.overwriteProps = ["frame","frameLabel"];
         this.round = true;
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         if(!Std.isOfType(param1 , MovieClip) || Math.isNaN(ASCompat.toNumber(param2)))
         {
            return false;
         }
         _target = ASCompat.dynamicAs(param1 , MovieClip);
         this.frame = _target.currentFrame;
         addTween(this,"frame",this.frame,param2,"frame");
         return true;
      }
      
      override public function  set_changeFactor(param1:Float) :Float      {
         updateTweens(param1);
         _target.gotoAndStop(this.frame);
return param1;
      }
   }


