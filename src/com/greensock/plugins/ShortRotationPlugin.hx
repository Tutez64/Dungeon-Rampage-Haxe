package com.greensock.plugins
;
   import com.greensock.*;
   
    class ShortRotationPlugin extends TweenPlugin
   {
      
      public static inline final API:Float = 1;
      
      public function new()
      {
         super();
         this.propName = "shortRotation";
         this.overwriteProps = [];
      }
      
      override public function onInitTween(param1:ASObject, param2:ASAny, param3:TweenLite) : Bool
      {
         var _loc4_:String = null;
         if(ASCompat.typeof(param2) == "number")
         {
            return false;
         }
         if (checkNullIteratee(param2)) for(_tmp_ in param2.___keys())
         {
            _loc4_  = _tmp_;
            initRotation(param1,_loc4_,ASCompat.toNumber(param1[_loc4_]),ASCompat.toNumber(ASCompat.typeof(param2[_loc4_]) == "number" ? ASCompat.toNumber(param2[_loc4_]) : ASCompat.toNumber(param1[_loc4_] + ASCompat.toNumber(param2[_loc4_]))));
         }
         return true;
      }
      
      public function initRotation(param1:ASObject, param2:String, param3:Float, param4:Float) 
      {
         var _loc5_= (param4 - param3) % 360;
         if(_loc5_ != _loc5_ % 180)
         {
            _loc5_ = _loc5_ < 0 ? _loc5_ + 360 : _loc5_ - 360;
         }
         addTween(param1,param2,param3,param3 + _loc5_,param2);
         this.overwriteProps[this.overwriteProps.length] = param2;
      }
   }


