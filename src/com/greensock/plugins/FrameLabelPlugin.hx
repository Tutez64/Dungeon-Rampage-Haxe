package com.greensock.plugins
;
   import com.greensock.*;
   import flash.display.*;
   
    class FrameLabelPlugin extends FramePlugin
   {
      
      public static inline final API:Float = 1;
      
      public function new()
      {
         super();
         this.propName = "frameLabel";
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         if(Std.isOfType(!ASCompat.toBool(param3.target) , MovieClip))
         {
            return false;
         }
         _target = ASCompat.dynamicAs(param1 , MovieClip);
         this.frame = _target.currentFrame;
         var _loc4_:Array<ASAny> = _target.currentLabels;
         var _loc5_:String = param2;
         var _loc6_= _target.currentFrame;
         var _loc7_= _loc4_.length;
         while(_loc7_-- != 0)
         {
            if(_loc4_[_loc7_].name == _loc5_)
            {
               _loc6_ = ASCompat.toInt(_loc4_[_loc7_].frame);
               break;
            }
         }
         if(this.frame != _loc6_)
         {
            addTween(this,"frame",this.frame,_loc6_,"frame");
         }
         return true;
      }
   }


